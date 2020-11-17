import { LightningElement, api, wire } from 'lwc';
import getChildPracticeGroups from '@salesforce/apex/AccountController.getChildPracticeGroups';

export default class AccountPracticeGroupAdminList extends LightningElement {
    @api recordId;
    loading = true;
    records;
    showNewUserModal = false;
    
    @wire(getChildPracticeGroups, {recordId: '$recordId'})
    getWiredRecords(result) {
        this.wiredRecords = result;
        const {data, error} = result;
        if (data) {
            this.records = data;
            this.loading = false;
        }
        if (error) {
            console.log(error);
            this.loading = false;
        }
    }

    handleSave() {
        this.showNewUserModal = false;
        const childComponents = this.template.querySelectorAll('c-practice-group-user-list');
        for (let child of childComponents) {
            child.refreshData();
        }
    }

    handleCreateNewUser() {
        this.showNewUserModal = true;
    }

    handleCloseModal() {
        this.showNewUserModal = false;
    }

}