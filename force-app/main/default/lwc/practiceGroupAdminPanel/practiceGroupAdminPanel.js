import { LightningElement, api } from 'lwc';

export default class PracticeGroupAdminPanel extends LightningElement {
    @api recordId;
    showNewUserModal;

    handleCreateNewUser() {
        this.showNewUserModal = true;
    }

    handleCloseModal() {
        this.showNewUserModal = false;
    }

    handleSave() {
        this.showNewUserModal = false;
        const childComponents = this.template.querySelectorAll('c-practice-group-user-list');
        for (let child of childComponents) {
            child.refreshData();
        }
    }
}