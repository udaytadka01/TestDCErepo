import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactData from '@salesforce/apex/UserManagementController.getContactData';
import createOrUpdateCAUser from '@salesforce/apex/UserManagementController.createOrUpdateCAUser';
import getAllPracticeGroups from '@salesforce/apex/AccountController.getAllPracticeGroups';

const ROLE_PICKLIST_VALUES = [
    {label: 'Staff', value: 'staff'},
    {label: 'Biller', value: 'biller'}
];
const ROLE_PRACTITIONER_PICKLIST_VALUE = [
    {label: 'Practitioner', value: 'practitioner'},
];
export default class ConvertContactToUserModal extends LightningElement {
    @api recordId; // contact Id or account Id
    practiceGroupOptions = [];
    selectedPracticeGroups = [];
    record;
    error;
    emailAddress;
    userRoles = 'staff'; // default user role
    firstName;
    lastName;
    rolePicklistValues = ROLE_PICKLIST_VALUES;
    loading = true;

    @wire(getContactData, {recordId: '$recordId'})
    getWiredRecord(result) {
        this.wiredRecord = result;
        const { data, error } = result;
        if (data) {
            this.record = data;
            this.emailAddress = data.Email;
            this.userRoles = data.Roles__c;
            this.firstName = data.FirstName;
            this.lastName = data.LastName;
            this.isPractitioner = data.NPI__c ? true : false;
            this.selectedPracticeGroups = data.AccountContactRelations.map((data) => data.AccountId);
            if (this.isPractitioner) {
                this.rolePicklistValues = ROLE_PRACTITIONER_PICKLIST_VALUE;
                this.userRoles = 'practitioner';
            }
        } else if (error) {
            this.error = error;
            console.log(error);
        }
        this.loading = false;
    }

    // Todo: this needs to grab all practice groups underneath the parent organization
    @wire(getAllPracticeGroups, {recordId: '$recordId'})
    getWiredPracticeGroups(result) {
        this.wiredPracticeGroups = result;
        const { data, error } = result;
        if (data) {
            this.practiceGroupOptions = data.map((data) => ({
                label: data.Name,
                value: data.Id
            }));
        }
        if (error) {

            this.error = error;
            console.log(error);
        }
    }

    connectedCallback() {
        this.refreshCache();
    }

    handleSave() {
        let inputCmps = this.template.querySelectorAll('.input');
        console.log(inputCmps);
        let allValid = [...inputCmps].reduce((validSoFar, cmp) => {
            cmp.reportValidity();
            return validSoFar && cmp.checkValidity();
        }, true);
        if (allValid) {
            const {accountId, contactId} = this.parseRecordIdType();
            this.loading = true;
            createOrUpdateCAUser({ 
                accountId: accountId, 
                contactId: contactId , 
                firstName: this.firstName, 
                lastName: this.lastName, 
                email: this.emailAddress, 
                role: this.userRoles, 
                accountsToRelate: this.practiceGroupsAdded,
                accountRelationsToRemove: this.practiceGroupsRemoved
            })
                .then(() => {
                    const toastEvent = new ShowToastEvent({
                        title: 'Success',
                        message: 'The user has been successfully created or updated.',
                        variant: 'success'
                    });
                    this.dispatchEvent(toastEvent);
                    this.dispatchEvent(new CustomEvent('save'));
                })
                .catch(error => {
                    console.log(error.body.message[0].message);
                    const toastEvent = new ShowToastEvent({
                        title: 'Something went wrong',
                        message: error.body.message[0].message,
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                })
                .finally(() => {
                    this.loading = false;
                });
        }
    }

    parseRecordIdType() {
        return ({
            accountId: this.recordId.substring(0,3) === '001' ? this.recordId : null,
            contactId: this.recordId.substring(0,3) === '003' ? this.recordId : null
        });
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.emailAddress = event.target.value;
    }

    handleRoleChange(event) {
        this.userRoles = event.target.value;
    }

    handlePracticeGroupChange(event) {
        this.selectedPracticeGroups = event.detail.value;
    }

    get practiceGroupsAdded() {
        let initialPgs = this.record ? this.record.AccountContactRelations.map(data => data.AccountId) : [];
        return this.selectedPracticeGroups.filter(val => !initialPgs.includes(val));
    }

    get practiceGroupsRemoved() {
        if (!this.record) return [];
        let initialRelations = this.record.AccountContactRelations;
        let pgOptions = this.practiceGroupOptions.map(data => data.value);
        let removedRelations = initialRelations.filter(({AccountId}) => !this.selectedPracticeGroups.includes(AccountId) && pgOptions.includes(AccountId));
        return removedRelations.map(val => val.Id);
    }

    get requiredFieldsPresent() {
        return this.emailAddress && this.firstName && this.lastName;
    }

    get dataInitialized() {
        return ((this.recordId && this.record) || !this.recordId) && this.practiceGroupOptions.length;
    }

    async refreshCache() {
        if (this.recordId.substring(0,3) === '003') {
            this.loading = true;
            if (this.dataInitialized) {
                await refreshApex(this.wiredRecord);
                await refreshApex(this.wiredPracticeGroups);
                this.loading = false;
            } else {
                setTimeout(() => {
                    this.refreshCache();
                }, 1000);
            }
        }
    }
}