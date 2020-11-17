public with sharing class AccountTriggerHandler {
    public static void beforeInsert(Account[] newAccounts) {
        //AccountTriggerHandlerHelper.anymethod();
        system.debug('Inside Before Insert');
    }

    public static void beforeUpdate(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        system.debug('Inside Before Update');
    }

    public static void afterInsert(Map<Id, Account> newAccounts) {
        system.debug('Inside After Insert');
    }

    public static void afterUpdate(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        system.debug('Inside After Update');
    }
}