import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getUsersForPracticeGroup from '@salesforce/apex/AccountController.getUsersForPracticeGroup';
import getPracticeGroupInfo from '@salesforce/apex/AccountController.getPracticeGroupInfo';
import getContactsWithUserInfo from '@salesforce/apex/AccountController.getContactsWithUserInfo';
import createAccountContactRelations from '@salesforce/apex/AccountController.createAccountContactRelations';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email' },
    { label: 'Roles', fieldName: 'Roles__c' },
];

export default class AssignUsersToPracticeGroup extends LightningElement {
    @api recordId; // Practice Group Id
    filterValue = null;
    record;
    relatedContacts;
    allContacts;
    organizationId;
    selectedRows = [];
    columns = columns;
    loading = true;

    @wire(getPracticeGroupInfo, {recordId: '$recordId'})
    wiredRecord({data, error}) {
        if (data) {
            this.record = data;
            this.organizationId = data.Top_Level_Account_Id__c;
        }
        if (error) {
            console.log(error);
        }
    }

    @wire(getUsersForPracticeGroup, {accountId: '$recordId'})
    wiredGetRelatedContacts(result) {
        this.wiredRelatedContacts = result;
        const {data, error} = result;
        if (data) {
            this.relatedContacts = data;
        }
        if (error) {
            console.log(error);
        }
    }

    // TODO - only surface providers who are on the roster
    @wire(getContactsWithUserInfo, {accountId: '$organizationId', filterValue: '$filterValue'})
    wiredGetAllContacts(result) {
        this.wiredAllContacts = result;
        const {data, error} = result;
        if (data) {
            this.allContacts = data;
        }
        if (error) {
            console.log(error);
        }
    }

    connectedCallback() {
        // Force cache to refresh on component mount
        this.refreshCache();
    }

    handleSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleSave() {
        let acctContactRelations = this.selectedRows.map((data) => ({
            ContactId: data.Id,
            AccountId: this.recordId
        }));
        this.loading = true;
        createAccountContactRelations({relationsToInsert: JSON.stringify(acctContactRelations)})
            .then(result => {
                this.loading = false;
                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'The selected users have been successfully added to this practice group',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                this.dispatchEvent(new CustomEvent('save'));
            })
            .catch(error => {
                this.loading = false;
                console.log(error);
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            });
    }

    handleSearch(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.filterValue = event.target.value;
        }
    }

    get unassignedContacts() {
        let currentAssignedUserIds = this.relatedContacts.map(({ContactId}) => ContactId);
        return this.allContacts.filter(({Id}) => !currentAssignedUserIds.includes(Id));
    }

    get dataInitialized() {
        return this.record && this.relatedContacts && this.allContacts;
    }

    get noRowsSelected() {
        return this.selectedRows.length === 0;
    }

    @api
    async refreshCache() {
        this.loading = true;
        if (this.dataInitialized) {
            await refreshApex(this.wiredAllContacts);
            await refreshApex(this.wiredRelatedContacts)
                .then(() => {
                    this.loading = false;
                });
        } else {
            setTimeout(() => {
                this.refreshCache();
            }, 1000);
        }
    }
}