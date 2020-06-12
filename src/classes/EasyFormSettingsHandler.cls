public class EasyFormSettingsHandler {
    public static void beforeInsert(List<sobject> csList){
        for(Sobject  guestFormSettings : csList){
            Custom_Form_Setting__c cs = (Custom_Form_Setting__c)guestFormSettings;
            cs.UUID__c = CustomFormsUtility.getUUID();
            cs.Sobject_Label_Name__c = CustomFormsUtility.getSobjLabel(cs.Sobject__c);
            if(cs.Record_Type__c != null && cs.Record_Type__c != ''){
                cs.Record_Type_Name__c = CustomFormsUtility.getRecordTypeName(cs.Record_Type__c,cs.Sobject__c);}
        }
    }
    public static void beforeUpdate(List<sobject> csList,map<id,sobject> csMap){
        for(Sobject  guestFormSettings : csList){
            Custom_Form_Setting__c cs = (Custom_Form_Setting__c)guestFormSettings;
            Sobject oldCs = csMap.get(cs.Id);
            Custom_Form_Setting__c oldRec = (Custom_Form_Setting__c)oldCs;
            if(cs.Sobject__c != oldRec.Record_Type__c && cs.Sobject__c != null){
              cs.Sobject_Label_Name__c = CustomFormsUtility.getSobjLabel(cs.Sobject__c);
            }
            if(cs.Record_Type__c == null || cs.Record_Type__c == '')
            {
                cs.Record_Type_Name__c = null;
            }
            if(cs.Record_Type__c != oldRec.Record_Type__c && cs.Record_Type__c != null){
                cs.Record_Type_Name__c = CustomFormsUtility.getRecordTypeName(cs.Record_Type__c,cs.Sobject__c);
            }
         }
    }
    
}