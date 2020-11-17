@isTest private with sharing class ContactTriggerHandlerTest {
    @isTest static void validateContactTriggerConfig() {
        contact con=new contact();
        con.LastName='JOHN';
        insert con;
        con=[SELECT LastName from Contact where Id=: con.Id];
        System.assertEquals('JOHN', con.LastName);
        con.LastName='CHERRY';
        update con;
    }

    @isTest static void validateContactTriggerConfig1() {
        contact con=new contact();
        con.LastName='WILLIAM';
        insert con;
        con=[SELECT LastName from Contact where Id=: con.Id];
        System.assertEquals('WILLIAM', con.LastName);
        delete con;
        undelete con;
        system.debug(con);
    }
}