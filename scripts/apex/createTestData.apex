// Get record type ids
RecordType orgRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'IndustriesBusiness'];
RecordType groupRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Group'];
RecordType practiceGroupRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Practice_Group'];
RecordType practitionerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Practitioner'];
RecordType staffRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];

// Insert Organization
Account org = new Account(
    Name = 'National Providers Association',
    Type = 'Organization',
    RecordTypeId = orgRecordType.Id,
    HealthCloudGA__TaxId__c = '1234567890'
);

insert org;

// Insert Groups
Account group1 = new Account(
    Name = 'Healthy Life Inc. LLC',
    Type = 'Group',
    RecordTypeId = groupRecordType.Id,
    ParentId = org.Id,
    HealthCloudGA__TaxId__c = '7894561230'
);

Account group2 = new Account(
    Name = 'Regional Medical',
    Type = 'Group',
    RecordTypeId = groupRecordType.Id,
    ParentId = org.Id,
    HealthCloudGA__TaxId__c = '5557894560'
);

insert new Account[]{group1, group2};

// Insert Practice Groups
Account pg1 = new Account(
    Name = 'Healthy Life Inc.',
    Type = 'Practice Group',
    RecordTypeId = practiceGroupRecordType.Id,
    ParentId = group1.Id
);

Account pg2 = new Account(
    Name = 'Great Care Now',
    Type = 'Practice Group',
    RecordTypeId = practiceGroupRecordType.Id,
    ParentId = group2.Id
);

Account pg3 = new Account(
    Name = 'Mom & Pop\'s Provider Office',
    Type = 'Practice Group',
    RecordTypeId = practiceGroupRecordType.Id,
    ParentId = group2.Id
);

insert new Account[]{pg1, pg2, pg3};

// Insert contacts
Contact practitioner1 = new Contact(
    FirstName = 'James',
    LastName = 'Montgomery',
    RecordTypeId = practitionerRecordType.Id,
    NPI__c = '5587762245',
    Roles__c = 'practitioner',
    AccountId = org.Id
);

Contact practitioner2 = new Contact(
    FirstName = 'Susan',
    LastName = 'Park',
    RecordTypeId = practitionerRecordType.Id,
    NPI__c = '5467841016',
    Roles__c = 'practitioner',
    User_Status__c = 'ACTIVE',
    Email = 'susan.park@example.com',
    IdP_Id__c = 'abc1234',
    AccountId = org.Id
);

Contact practitioner3 = new Contact(
    FirstName = 'Katherine',
    LastName = 'Cortez',
    RecordTypeId = practitionerRecordType.Id,
    NPI__c = '8794678520',
    Roles__c = 'practitioner',
    User_Status__c = 'ACTIVE',
    IdP_Id__c = 'xyz987',
    AccountId = org.Id,
    Email = 'katherine.cortez@example.com'
);

Contact practitioner4 = new Contact(
    FirstName = 'Yasmine',
    LastName = 'Page',
    RecordTypeId = practitionerRecordType.Id,
    NPI__c = '6457981320',
    Roles__c = 'practitioner',
    User_Status__c = 'ACTIVE',
    IdP_Id__c = 'jkl1234',
    AccountId = org.Id,
    Email = 'yasmine.page@example.com'
);

Contact staff1 = new Contact(
    FirstName = 'Dan',
    LastName = 'Smith',
    RecordTypeId = staffRecordType.Id,
    AccountId = org.Id,
    Roles__c = 'staff',
    User_Status__c = 'ACTIVE',
    IdP_Id__c = 'ghi1234',
    Email = 'dan.smith@example.com'
);

insert new Contact[]{practitioner1, practitioner2, practitioner3, practitioner4, staff1};

// Insert AccountContactRelations
AccountContactRelation[] relations = new AccountContactRelation[]{};

relations.add(new AccountContactRelation(
    AccountId = pg1.Id,
    ContactId = practitioner2.Id
));

relations.add(new AccountContactRelation(
    AccountId = pg2.Id,
    ContactId = practitioner3.Id
));

relations.add(new AccountContactRelation(
    AccountId = pg2.Id,
    ContactId = staff1.Id
));

relations.add(new AccountContactRelation(
    AccountId = pg3.Id,
    ContactId = practitioner4.Id
));

insert relations;