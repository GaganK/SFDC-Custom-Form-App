trigger EasyFormSettingsTrigger on Custom_Form_Setting__c (before insert,before update) {
    if(trigger.isinsert && trigger.isbefore){
        EasyFormSettingsHandler.beforeInsert(trigger.new);
    }
    if(trigger.isupdate && trigger.isbefore){
        EasyFormSettingsHandler.beforeUpdate(trigger.new,trigger.oldmap);
    }
}