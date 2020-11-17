public with sharing class Consts {

    public static final String ACCOUNT_TYPE_ORGANIZATION = 'Organization';
    public static final String ACCOUNT_TYPE_GROUP = 'Group';
    public static final String ACCOUNT_TYPE_PRACTICE_GROUP = 'Practice Group';

    public static final String CONTACT_PRACTITIONER_RECORD_TYPE = 'Practitioner';
    public static final String CONTACT_STAFF_RECORD_TYPE = 'Staff';

    public static final List<String> CONTACT_USER_RECORD_TYPES = new String[]{
        CONTACT_PRACTITIONER_RECORD_TYPE,
        CONTACT_STAFF_RECORD_TYPE
    };
}
