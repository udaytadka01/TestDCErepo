trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    if (Trigger.isInsert && Trigger.isBefore) {
        AccountTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        AccountTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if (Trigger.isInsert && Trigger.isAfter) {
        AccountTriggerHandler.afterInsert(Trigger.newMap);
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        AccountTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}