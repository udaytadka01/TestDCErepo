import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getContactsWithUserInfo from '@salesforce/apex/AccountController.getContactsWithUserInfo';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email' },
    { label: 'Roles', fieldName: 'Roles__c' },
    { label: 'Status', fieldName: 'User_Status__c' }
];

export default class AccountCAUserList extends LightningElement {
    @api recordId;
    @track data;
    filterValue = null;
    columns = columns;
    selectedAction;
    selectedActionRowId;
    displayActionModal = false;
    loading = true;

    constructor() {
        super();
        this.columns=[
            ...this.columns,
            { type: 'action', typeAttributes: {rowActions: this.getRowActions} }
        ]
    }

    @wire(getContactsWithUserInfo, {accountId: '$recordId', filterValue: '$filterValue'})
    getWiredContacts(result) {
        this.wiredContacts = result;
        const { data, error } = result;
        this.loading = false;
        if (data) {
            this.data = data.map((data) => ({'User_Status__c': data.User_Status__c ? data.User_Status__c : 'NEEDS INFORMATION', ...data}));
        }
        if (error) {
            console.log(error);
        }
    }

    getRowActions(row, doneCallback) {
        const actions = [];
        if (row['User_Status__c'] === 'NEEDS INFORMATION') {
            actions.push({
                'label': 'Configure Account',
                'iconName': 'utility:adduser',
                'name': 'activate'
            });
        } else {
            actions.push(...[
                {'label': 'Edit User', 'name': 'edit'}, 
                {'label': 'Reset Password', 'name': 'reset_password' },
                {'label': 'Deactivate Account', 'name': 'deactivate' },
            ]);
        }
        setTimeout(() => {
            doneCallback(actions);
        }, 200);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'activate':
                this.selectedActionRowId = row.Id;
                this.selectedAction = actionName;
                break;
            case 'edit':
                this.selectedAction = actionName;
                this.selectedActionRowId = row.Id;
                break;
        }
    }

    handleModalClose() {
        this.selectedActionRowId = null;
        this.selectedAction = null;
    }

    handleCreateNewUser() {
        this.selectedActionRowId = this.recordId;
        this.selectedAction = 'activate';
    }

    handleSearch(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.filterValue = event.target.value;
        }
    }

    handleSave() {
        this.handleModalClose();
        this.refreshData();
    }

    refreshData() {
        this.loading = true;
        refreshApex(this.wiredContacts)
            .finally(() => {
                this.loading = false;
            });
    }
}