import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUsersForPracticeGroup from '@salesforce/apex/AccountController.getUsersForPracticeGroup'
import getPracticeGroupInfo from '@salesforce/apex/AccountController.getPracticeGroupInfo';
import removeAccountContactRelations from '@salesforce/apex/AccountController.removeAccountContactRelations';
import updateSuccessAdvocatePermissions from '@salesforce/apex/UserManagementController.updateSuccessAdvocatePermissions';

const columns = [
    {label: 'Name', fieldName: 'name'},
    {label: 'Email', fieldName: 'email'},
    {label: 'Role', fieldName: 'role'},
    {label: 'Is Success Advocate', fieldName: 'isSuccessAdvocate', type: 'boolean'},
    {label: 'Status', fieldName: 'userStatus'},
]

export default class PracticeGroupUserList extends LightningElement {
    @api recordId;
    record;
    organizationId;
    wiredRelatedContacts;
    relatedContacts;
    loading = true;
    columns = columns;
    selectedAction;
    selectedActionRowId;
    selectedRows = [];

    constructor() {
        super();
        this.columns=[
            ...this.columns,
            { type: 'action', typeAttributes: {rowActions: this.getRowActions} }
        ]
    }

    @wire(getPracticeGroupInfo, {recordId: '$recordId'})
    wiredRecord({data, error}) {
        if (data) {
            this.record = data;
        }
        if (error) {
            console.log(error);
        }
    }

    @wire(getUsersForPracticeGroup, {accountId: '$recordId'})
    wiredGetRelatedContacts(value) {
        // Save result so we can refresh it later
        this.wiredRelatedContacts = value;
        // Deconstruct and process result
        const {data, error} = value;
        if (data) {
            this.relatedContacts = data.map((data) => ({
                isSuccessAdvocate: data.Success_Advocate__c,
                name: data.Contact.Name,
                email: data.Contact.Email,
                role: data.Contact.Roles__c,
                userStatus: data.Contact.User_Status__c ? data.Contact.User_Status__c : 'NEEDS INFORMATION',
                ...data
            }));
            this.loading = false;
        }
        if (error) {
            console.log(error);
            this.loading = false;
        }
    }

    getRowActions(row, doneCallback) {
        const actions = [];
        if (row['userStatus'] === 'NEEDS INFORMATION') {
            actions.push({
                'label': 'Configure Account',
                'iconName': 'utility:adduser',
                'name': 'activate'
            });
        } else if (row['userStatus'] !== 'NEEDS INFORMATION') {
            actions.push(...[
                {'label': 'Edit User', 'name': 'edit'}, 
                {'label': 'Reset Password', 'name': 'reset_password' },
                {'label': 'Deactivate Account', 'name': 'deactivate' },
            ]);
        }
        if (!row['isSuccessAdvocate']) {
            actions.push({ 'label': 'Promote to Success Advocate', 'name': 'promote' });
        } else if (row['isSuccessAdvocate']) {
            actions.push({ 'label': 'Remove as Success Advocate', 'name': 'demote' })
        }
        actions.push(...[{ 'label': 'Remove from Practice Group', 'name': 'remove' }]);
        setTimeout(() => {
            doneCallback(actions);
        }, 200);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'activate':
                this.selectedActionRowId = row.ContactId;
                this.selectedAction = 'activate';
                break;
            case 'remove':
                this.removeUsersFromGroup([row.Id]);
                break;
            case 'promote':
                this.updateUserSuccessAdvocatePermissions(row, true);
                break;
            case 'demote':
                this.updateUserSuccessAdvocatePermissions(row, false);
                break;
            case 'edit':
                this.selectedActionRowId = row.ContactId;
                this.selectedAction = 'edit';
                break;
        }
    }

    removeUsersFromGroup(recordIds) {
        this.loading = true;
        removeAccountContactRelations({relationIdsToRemove: JSON.stringify(recordIds)})
            .then(() => {
                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'The selected users have been removed from this practice group.',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                refreshApex(this.wiredRelatedContacts);
                // Refresh child components
                this.loading = false;
            })
            .catch((error) => {
                console.log(error);
                const toastEvent = new ShowToastEvent({
                    title: 'Something went wrong',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
                this.loading = false;
            })
    }

    updateUserSuccessAdvocatePermissions(row, isSuccessAdvocate) {
        this.loading = true;
        updateSuccessAdvocatePermissions({accountContactRelationId: row.Id, isSuccessAdvocate: isSuccessAdvocate})
            .then(() => {
                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'User permissions successfully updated',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                refreshApex(this.wiredRelatedContacts);
            })
            .catch((error) => {
                console.log(error);
                const toastEvent = new ShowToastEvent({
                    title: 'Something went wrong',
                    message: error.body.message[0].message,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            })
            .finally(() => {
                this.loading = false;
            })
    }

    handleAssignUsers() {
        this.selectedActionRowId = this.record.Id;
        this.selectedAction = 'assign';
    }

    handleRemoveUsers() {
        if (!this.selectedRows.length) {
            const toastEvent = new ShowToastEvent({
                message: 'Select at least one record and try again.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        } else {
            const userIdsToRemove = this.selectedRows.map((data) => data.Id);
            this.removeUsersFromGroup(userIdsToRemove);
        }
    }

    handleSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleModalClose() {
        this.selectedAction = null;
        this.selectedActionRowId = null;
    }

    handleSave() {
        this.handleModalClose();
        this.refreshData();
        this.dispatchEvent(new CustomEvent('save'));
    }

    @api
    async refreshData() {
        refreshApex(this.wiredRelatedContacts);
    }

    get noRelatedContactsFound() {
        return !this.relatedContacts.length && !this.loading;
    }
}