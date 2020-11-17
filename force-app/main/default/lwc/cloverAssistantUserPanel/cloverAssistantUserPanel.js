import { LightningElement, api, wire } from 'lwc';
import getContactData from '@salesforce/apex/UserManagementController.getContactData';

export default class CloverAssistantUserPanel extends LightningElement {
    @api recordId;
    navPath = '';
    record;
    error;

    @wire(getContactData, {recordId: '$recordId'})
    wiredRecord({ data, error }) {
        if (data) {
            this.record = data;
            this.emailAddress = data.Email;
            this.userRoles = data.Roles__c;
        } else if (error) {
            this.error = error;
            console.log(error);
        }
    }
    
    handleNavToCreateUser() {
        this.navPath = 'create'
    }

    handleNavReturnHome() {
        this.navPath = '';
    }

    get navPathNewUserForm() {
        return this.navPath === 'create';
    }
}