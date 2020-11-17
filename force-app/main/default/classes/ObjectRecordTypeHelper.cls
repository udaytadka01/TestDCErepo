public with sharing class ObjectRecordTypeHelper {
/*
    Note: This class does not have Map return type methods. You can please do type caste the caller class.
    
    Caller class sample code.

    Account acc=new Account(Name='test');
    List<Account> listAccounts=new List<Account>();
    listAccounts.add(acc);
    List<Account> lstAccounts=ObjectRecordTypeHelper.getListsObjectsWithRecordType(listAccounts,'Business');
    Map<id,Account>  mapAccunt=New Map<id,Account>(lstAccounts);

    */
    public static List<sObject> getListsObjectsWithRecordType(List<sObject> insObjects, String developerRecordTypeName){
        return (List<sObject>)getListSObjectWithRecordType(developerRecordTypeName,true,insObjects);
    }
    public static List<sObject> getListsObjectsWithOutRecordType(List<sObject> insObjects, String developerRecordTypeName){
        return (List<sObject>)getListSObjectWithRecordType(developerRecordTypeName,false,insObjects);
    } 
    public static List<sObject> getListsObjectsWithRecordType(Map<Id,sObject> inMapsObjects, String developerRecordTypeName){
        List<sObject> insObjects=new List<sObject>();
        insObjects = inMapsObjects.values();
        return getListsObjectsWithRecordType(insObjects,developerRecordTypeName);
    }
    public static List<sObject> getListsObjectsWithOutRecordType(Map<Id,sObject> inMapsObjects, String developerRecordTypeName){
        List<sObject> insObjects=new List<sObject>();
        insObjects = inMapsObjects.values();
        return getListsObjectsWithOutRecordType(insObjects,developerRecordTypeName);
    }


    /****************************************** private section ******************************************/

    private static List<sObject> getListSObjectWithRecordType(String developerRecordTypeName, boolean include, List<sObject> inObjects){
        string objectName = inObjects[0].getSObjectType().getDescribe().getName();        
        Id currentRecordTypeId = getRT2IdMap(objectName).get(developerRecordTypeName);
        List<sObject> selectedObjects = new List<sObject>();
        for(sObject theObject: inObjects){
            if(include){
                if((Id)theObject.get('recordTypeId') == currentRecordTypeId){
                    selectedObjects.add(theObject);
                }
            }
            else{
                if((Id)theObject.get('recordTypeId') <> currentRecordTypeId){
                    selectedObjects.add(theObject);
                }
            }
        }
        return selectedObjects;
    }

    private static Map<String,Id> getRT2IdMap(String sObjectName){
        Map<String,Id> devObjRTnameToIdMap = new Map<String,Id>();
        for(Schema.RecordTypeInfo currObjectType: Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName().values()){
            devObjRTnameToIdMap.put(currObjectType.getName(),currObjectType.getRecordTypeId());
        }
        return devObjRTnameToIdMap;
    }
}
