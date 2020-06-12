trigger EasyFormTrigger on GuestForms__c (before insert) {
    if(trigger.isbefore && trigger.isinsert){
        for(GuestForms__c g : trigger.new){
              g.UUID__c = CustomFormsUtility.getUUID();
        }
    }
}