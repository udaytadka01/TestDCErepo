@isTest private with sharing class AccountTriggerHandlerTest {
    @isTest static void validateAccountTriggerConfig() {
        account acc=new account();
        acc.Name='ACME';
        insert acc;
        acc=[SELECT Name from Account where Id=: acc.Id];
        System.assertEquals('ACME', acc.Name);
        acc.Name='ACME ONE';
        update acc;
    }

    @isTest static void validateAccountTriggerConfig1() {
        account acc=new account();
        acc.Name='ACME';
        insert acc;
        acc=[SELECT Name from Account where Id=: acc.Id];
        System.assertEquals('ACME', acc.Name);
        delete acc;
        undelete acc;
        system.debug(acc);
    }
}