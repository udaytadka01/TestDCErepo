import { LightningElement, api } from 'lwc';

export default class BaseModal extends LightningElement {
    @api header;
    @api tagline;
    @api action;
    @api recordId;

    connectedCallback() {
        switch (this.action) {
            case 'activate':
                this.header = 'Configure New User';
                break;
            case 'assign':
                this.header = 'Assign Users to a Practice Group';
                break;
            case 'edit':
                this.header = 'Edit User';
                break;
        }
    }

    get displayUserForm() {
        return this.action === 'activate' || this.action === 'edit';
    }

    get displayAssignToPracticeGroupForm() {
        return this.action === 'assign';
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent('save'));
    }
}