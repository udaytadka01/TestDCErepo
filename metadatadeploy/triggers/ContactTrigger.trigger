trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    if (Trigger.isInsert && Trigger.isBefore) {
        ContactTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        ContactTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if (Trigger.isInsert && Trigger.isAfter) {
        ContactTriggerHandler.afterInsert(Trigger.newMap);
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        ContactTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
    } 
}