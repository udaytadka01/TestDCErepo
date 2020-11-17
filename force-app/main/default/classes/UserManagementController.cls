public with sharing class UserManagementController {

    @AuraEnabled(cacheable=true)
    public static Contact getContactData(Id recordId) {
        return [
            SELECT
            FirstName,
            LastName,
            IdP_Id__c, 
            Email,
            Roles__c,
            User_Status__c,
            NPI__c,
            (SELECT Id, AccountId FROM AccountContactRelations)
            FROM Contact 
            WHERE Id = :recordId
        ];
    }

    @AuraEnabled
    public static void createOrUpdateCAUser(Id accountId, Id contactId, String firstName, 
                                            String lastName, String email, String role, List<String> accountsToRelate,
                                            List<String> accountRelationsToRemove) {
        if (accountId == null && contactId == null) {
            throw new AuraException('Oops! Something went wrong. Please give your system administrator the following information: \n' +  
                                    'Either Account Id or Contact Id is required to create a Clover Assistant user');
        }
        // First, call CA user endpoint (TODO)
        /* CA Endpoint logic here */

        // Create contact record
        Contact theContact = upsertCAUserContact(accountId, contactId, firstName, lastName, email, role, 'Fake Idp Id' + lastName, 'ACTIVE');

        // Create or remove contact relationships
        if (accountsToRelate.size() > 0 || accountRelationsToRemove.size() > 0) {
            managePracticeGroupRelations(theContact, accountsToRelate, accountRelationsToRemove);
        }
        
        // Create community user
        /* Community user create logic here */

        // Then, call CA user API
        /* Update node/user data logic here */
    }

    @AuraEnabled
    public static void updateSuccessAdvocatePermissions(Id accountContactRelationId, Boolean isSuccessAdvocate) {
        AccountContactRelation relationToUpdate = new AccountContactRelation(
            Id = accountContactRelationId,
            Success_Advocate__c = isSuccessAdvocate
        );
        try {
            update relationToUpdate;
        } catch(Exception e) {
            throwGenericAuraException(e);
        }
    }

    private static Contact upsertCAUserContact(Id accountId, Id contactId, String firstName, String lastName, String email, String role, String idpId, String userStatus) {
        RecordType contactStaffRecordType = [SELECT Id FROM RecordType WHERE sObjectType='Contact' AND DeveloperName = :Consts.CONTACT_STAFF_RECORD_TYPE];
        Contact contactToUpsert = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Roles__c = role,
            IdP_Id__c = idpId,
            User_Status__c = userStatus
        );
        if (contactId != null) contactToUpsert.Id = contactId;
        if (accountId != null) contactToUpsert.AccountId = AccountController.getTopLevelAccountId(accountId);
        if (role == 'staff' || role == 'biller') contactToUpsert.RecordTypeId = contactStaffRecordType.Id;
        try{
            upsert contactToUpsert;
        } catch(Exception e) {
            throwGenericAuraException(e);
        }
        return contactToUpsert;
    }

    private static void managePracticeGroupRelations(Contact theContact, List<Id> accountIdsToInsert, List<Id> relationIdsToDelete) {
        List<AccountContactRelation> relationsToInsert = new List<AccountContactRelation>();
        List<AccountContactRelation> relationsToDelete = new List<AccountContactRelation>();
        for (Id relationId : relationIdsToDelete) {
            relationsToDelete.add(new AccountContactRelation(
                Id = relationId
            ));
        }
        for (Id acctId : accountIdsToInsert) {
            relationsToInsert.add(new AccountContactRelation(
                AccountId = acctId,
                ContactId = theContact.Id
            ));
        }

        try {
            if (relationsToInsert.size() > 0) {
                insert relationsToInsert;
            }
            if (relationsToDelete.size() > 0) {
                delete relationsToDelete;
            }
        } catch (Exception e) {
            throwGenericAuraException(e);
        }
    }

    private static void throwGenericAuraException(Exception e) {
        throw new AuraException('Oops! Something went wrong. Please give your system administrator the following information: \n' + 
                                    e.getMessage());
    }
}