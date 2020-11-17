public with sharing class AccountController {

    /**
     * Gets contacts and relevant user information from contacts associated with
     * the given account and recursively up to three levels deep
     * @param accountId - Id of the account to get contacts from all child accounts
     * @return list of contacts
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsWithUserInfo(Id accountId) {
        return [
            SELECT
            Id,
            Name,
            FirstName,
            LastName,
            IdP_Id__c,
            User_Status__c,
            NPI__c,
            Roles__c,
            Email
            FROM Contact
            WHERE (AccountId = :accountId 
            OR Account.ParentId = :accountId
            OR Account.Parent.ParentId = :accountId)
            AND RecordType.DeveloperName IN :Consts.CONTACT_USER_RECORD_TYPES
        ];
    }

    /** 
     * Overriding method to allow for safe filtering of contact records
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsWithUserInfo(Id accountId, String filterValue) {
        String queryString = 'SELECT ' +
                             'Id, ' +
                             'Name, ' +
                             'FirstName, ' +
                             'LastName, ' +
                             'IdP_Id__c, ' +
                             'User_Status__c, ' +
                             'NPI__c, ' +
                             'Roles__c, ' +
                             'Email ' +
                             'FROM Contact ' +
                             'WHERE (AccountId = \'' + accountId + '\'' +
                             'OR Account.ParentId = \'' + accountId + '\'' +
                             'OR Account.Parent.Parent.Id = \'' + accountId + '\') ' +
                             'AND RecordType.DeveloperName IN (' + '\'' + Consts.CONTACT_PRACTITIONER_RECORD_TYPE + '\',' + '\'' + Consts.CONTACT_STAFF_RECORD_TYPE + '\') ';
        String filter;
        if (filterValue != null) {
            String safeFilterValue = String.escapeSingleQuotes(filterValue);
            filter = 'AND ( Name LIKE \'%' + safeFilterValue + '%\' ' +
                     'OR Email LIKE \'%' + safeFilterValue + '%\' ' +
                     'OR NPI__c LIKE \'%' + safeFilterValue + '%\' )';
        }
        if (filter != null) queryString += filter;
        return Database.query(queryString);
    }

    /**
     * Gets all practice groups for the given account recursively
     * up to three levels deep
     * @param accountId - Id of the account to get practice groups from
     * @return list of related practice groups and contacts associated to it
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAllPracticeGroups(Id recordId) {
        Id accountId = getTopLevelAccountId(recordId);
        return [
            SELECT
            Id,
            Name,
            (SELECT Id FROM AccountContactRelations)
            FROM Account
            WHERE Type = :Consts.ACCOUNT_TYPE_PRACTICE_GROUP
            AND (Id = :accountId
            OR ParentId = :accountId
            OR Parent.ParentId = :accountId
            OR Parent.Parent.ParentId = :accountId)
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getChildPracticeGroups(Id recordId) {
        return [
            SELECT
            Id,
            Name,
            (SELECT Id FROM AccountContactRelations)
            FROM Account
            WHERE Type = :Consts.ACCOUNT_TYPE_PRACTICE_GROUP
            AND (Id = :recordId
            OR ParentId = :recordId
            OR Parent.ParentId = :recordId
            OR Parent.Parent.ParentId = :recordId)
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getUsersForPracticeGroup(Id accountId) {
        return [
            SELECT
            Id,
            AccountId,
            ContactId,
            Contact.Name,
            Contact.Email,
            Contact.NPI__c,
            Contact.Roles__c,
            Contact.User_Status__c,
            Success_Advocate__c
            FROM AccountContactRelation
            WHERE AccountId = :accountId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Account getPracticeGroupInfo(Id recordId) {
        return [
            SELECT
            Id,
            Name,
            Calculated_TaxId__c,
            Top_Level_Account_Id__c,
            ParentId,
            Parent.Type,
            Parent.ParentId,
            Parent.Parent.Type
            FROM Account
            WHERE Id = :recordId
        ];
    }

    @AuraEnabled
    public static void createAccountContactRelations(String relationsToInsert) {
        List<AccountContactRelation> relations = (List<AccountContactRelation>)JSON.deserialize(relationsToInsert, List<AccountContactRelation>.class);
        insert relations;
    }

    @AuraEnabled
    public static void removeAccountContactRelations(String relationIdsToRemove) {
        // Todo: add logic to prevent removal of the last practice group from contact
        List<Id> deserializedRelationIds = (List<Id>)JSON.deserialize(relationIdsToRemove, List<Id>.class);
        delete [SELECT Id FROM AccountContactRelation WHERE Id IN :deserializedRelationIds];
    }

    public static Id getTopLevelAccountId(Id accountOrContactId) {
        Id topLevelAcctId;
        if (accountOrContactId != null) {
            Schema.SObjectType objType = accountOrContactId.getSobjectType();
            if (objType == SObjectType.Account.getSObjectType()) {
                Account acct = [SELECT Top_Level_Account_Id__c FROM Account WHERE Id = :accountOrContactId];
                topLevelAcctId = acct.Top_Level_Account_Id__c;
    
            } else if (objType == SObjectType.Contact.getSObjectType()) {
                Contact cont = [SELECT Account.Top_Level_Account_Id__c FROM Contact WHERE Id = :accountOrContactId];
                topLevelAcctId = cont.Account.Top_Level_Account_Id__c;
            }
        }
        return topLevelAcctId;
    }

}
