@Istest
public with sharing class ObjectRecordTypeHelperTest {
    @istest
    static void testDCEObjectRecordTypeHelper(){
        
        RecordType orgRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'IndustriesBusiness'];
        
        Account org = new Account(
            Name = 'National Providers Association_Dup',
            Type = 'Organization',
            RecordTypeId = orgRecordType.Id,
            HealthCloudGA__TaxId__c = '1234567890'        );
        insert org;
        
        List<Account> listAccounts=new List<Account>();
        listAccounts.add(org);
        Map<Id,Account> mapAccs=new Map<Id,Account>();
        mapAccs.putAll(listAccounts);
        
        List<Account> lstAccounts1=ObjectRecordTypeHelper.getListsObjectsWithRecordType(listAccounts,'Business');
        system.assertEquals(1, lstAccounts1.size(), 'Size of list of accounts records not expected.');
        
        List<Account> lstAccounts2=ObjectRecordTypeHelper.getListsObjectsWithOutRecordType(listAccounts,'Business1');
        system.assertEquals(1, lstAccounts2.size(), 'Size of list of accounts records not expected.');
        
        List<Account> lstAccounts3=ObjectRecordTypeHelper.getListsObjectsWithRecordType(mapAccs,'Business');
        system.assertEquals(1, lstAccounts3.size(), 'Size of list of accounts records not expected.');
        
        List<Account> lstAccounts4=ObjectRecordTypeHelper.getListsObjectsWithOutRecordType(mapAccs,'Business1');
        system.assertEquals(1, lstAccounts4.size(), 'Size of list of accounts records not expected.');
        
    } 
}