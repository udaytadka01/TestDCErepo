public with sharing class ContactTriggerHandler {
    public static void beforeInsert(Contact[] newContacts) {
        //ContactTriggerHandlerHelper.anymethod();
        system.debug('Inside Before Insert');
    }

    public static void beforeUpdate(Map<Id, Contact> oldContacts, Map<Id, Contact> newContacts) {
        system.debug('Inside Before Update');
    }

    public static void afterInsert(Map<Id, Contact> newContacts) {
        system.debug('Inside After Insert');
    }

    public static void afterUpdate(Map<Id, Contact> oldContacts, Map<Id, Contact> newContacts) {
        system.debug('Inside After Update');
    }
}