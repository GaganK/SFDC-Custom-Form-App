public class DisplaySubmittedGuestFormsController {
    @AuraEnabled
    Public static List<SubmittedGuestFormWrapper> getRecords(Id recordId){
        List<SubmittedGuestFormWrapper> swList = new List<SubmittedGuestFormWrapper>();
        Map<String,List<GuestForms__c>> guestFormMap = new Map<String,List<GuestForms__c>>();
        List<GuestForms__c> guestForms = new List<GuestForms__c>();
        String sobjectName = recordId.getSObjectType().getDescribe().getName();
        if(sobjectName != null && sobjectName != '')
        {
            if(sobjectName == 'Contact')
                guestForms = [select id,Parent__c,Object_Name__c,Object_API_Name__c,Form_Name__c,Name from GuestForms__c where Contact__c =: recordId and Parent__c != null];
            else if(sobjectName == 'Account')
                guestForms = [select id,Parent__c,Object_Name__c,Object_API_Name__c,Form_Name__c,Name from GuestForms__c where Account__c =: recordId and Parent__c != null];
            else if(sobjectName == 'Lead')
                guestForms = [select id,Parent__c,Object_Name__c,Object_API_Name__c,Form_Name__c,Name from GuestForms__c where Lead__c =: recordId and Parent__c != null];
        }
        if(guestForms.size() >0){
            for(GuestForms__c gf : guestForms){
                if(guestFormMap.get(gf.Object_API_Name__c) != null && guestFormMap.get(gf.Object_API_Name__c).size()>0)
                {
                    List<GuestForms__c> tmpGuestForms = new List<GuestForms__c>();
                    tmpGuestForms.add(gf);
                    for(GuestForms__c tmpgf : guestFormMap.get(gf.Object_API_Name__c)){
                        tmpGuestForms.add(tmpgf);
                    }
                    guestFormMap.remove(gf.Object_API_Name__c);
                    guestFormMap.put(gf.Object_API_Name__c,tmpGuestForms);
                }else{
                    List<GuestForms__c> tmpGuestForms = new List<GuestForms__c>();
                    tmpGuestForms.add(gf);
                    guestFormMap.put(gf.Object_API_Name__c,tmpGuestForms);
                }
            }
            for(String sObj : guestFormMap.keyset()){
                SubmittedGuestFormWrapper sw = new SubmittedGuestFormWrapper();
                sw.objLabel = CustomFormsUtility.getSobjLabel(sObj);
                sw.objAPI = sObj;
                sw.guestFormList = guestFormMap.get(sObj);
                sw.noOfRecords = guestFormMap.get(sObj).size();
                swList.add(sw);
            }
        }
        return swList;
        
    }
    Public class SubmittedGuestFormWrapper{
        @AuraEnabled
        Public String objLabel{get;set;}
        @AuraEnabled
        Public String objAPI{get;set;}
        @AuraEnabled
        Public List<GuestForms__c> guestFormList{get;set;}
         @AuraEnabled
        Public Integer noOfRecords{get;set;}
    }
}