/***************************************************************** 
Purpose: Creating New Custom Setting  
History                                                             
-------- -----------------------------------------------------------------------                                                       
VERSION        AUTHOR                 DATE            DETAIL       Description 
1.0            Varun Sirisilla        01/02/2020     Created      controller for NewCustomSettings lightning component 
*********************************************************************************/
public class NewCustomSettingsController {
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : return all the sobjects
@return : Map<String,String>
*/ 
    @AuraEnabled
    Public static Map<String,String> getSobjects(){

            List<Easy_Forms_Supported_Standard_Object__mdt> supportedObj = [Select MasterLabel,DeveloperName,Active__c from Easy_Forms_Supported_Standard_Object__mdt where Active__c = true];
            Map<String,String> objectNames  = new Map<String,String>();
            List<String> objectAPINames = new List<String>();
            if(supportedObj.Size()>0){
                for(Easy_Forms_Supported_Standard_Object__mdt efsso : supportedObj){
                    objectAPINames.add(efsso.DeveloperName);
                    objectNames.put(efsso.DeveloperName,efsso.MasterLabel);
                }
            }
            for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() )
            {
                Schema.DescribeSObjectResult objResult = o.getDescribe();
                if(objResult.getName().right(5) != '__mdt' && objResult.isCustom() == true  && objResult.isCustomSetting() == false)
                {
                    System.debug('custom ' +objResult.getName());
                    objectAPINames.add(objResult.getName());
                    objectNames.put(objResult.getName(),objResult.getLabel());
                }
            }  
            return objectNames;
       
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : Check the object type
@params : String objectName
@return : Boolean
*/ 
    @Auraenabled
    public static Boolean checkObjectType(String objectName) {
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
            if(objToken  != null && objToken.getDescribe().isCustom())
                return true;
            return false;
       
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : returns the record types and pagelayout of the given sobject using tooling API
@params : String objectName
@return : RecordTypePageLayoutWrapper
*/ 
    @AuraEnabled
    Public static RecordTypePageLayoutWrapper getRecordTypesAndPageLayouts(String objectName){
        try
        {
            Constants constants = New Constants();
            RecordTypePageLayoutWrapper rp = new RecordTypePageLayoutWrapper();
            Map<String,String> recordTypeMap = new Map<String,String>();
            if(objectName != null)
            {
                SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
                if(objToken  != null && objToken.getDescribe().isCustom()){
                    rp.isCustom = true;
                }else{
                    rp.isCustom = false;
                }
                SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
                Schema.DescribeSObjectResult objRes = objtype.getDescribe();
                Schema.DescribeSObjectResult R = objRes.SObjectType.getDescribe();
                List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
                for(Schema.RecordTypeInfo rTypeInfo : RT){
                    if(rTypeInfo.active == true)
                    {
                        if(rTypeInfo.getName() != constants.MASTER)
                        {
                            recordTypeMap.put(rTypeInfo.getRecordTypeId(),rTypeInfo.getName());
                        }
                    }
                }
                if(recordTypeMap != null)
                {
                    rp.recordTypeMap = recordTypeMap;
                }
                if(NewCustomSettingsController.getPageLayouts(objectName) != null)
                {
                    rp.pageLayouts = NewCustomSettingsController.getPageLayouts(objectName);
                }
            }
            return rp;
        }catch (Exception e){
            System.debug(e.getMessage() + e.getLineNumber());
            //Generate a Log record
            GuestForm_Log__c gl = new GuestForm_Log__c();
            gl.Exception_Type__c = e.getTypeName();
            gl.Error_Message__c = e.getMessage() + e.getLineNumber();
            insert gl;
            return null;
        }
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will returns all the HTML,text,custom email templates
@params : no Params
@return : Map<string,string>
*/ 
    @AuraEnabled
    Public static Map<string,string> getEmailTemplates(){
        
            Map<String,String> emailMap = new Map<String,String>();
            for(EmailTemplate et : [SELECT Id,Name,DeveloperName, Subject, Body,HtmlValue,TemplateType FROM EmailTemplate where TemplateType in('HTML','text','custom')]){
                emailMap.put(et.DeveloperName, et.name);
            }
            return emailMap;
        
    }
    
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will returns all the pagelayouts under the sobject
@params : String objName,String pageLayoutName
@return : List<String>
*/ 
    Public Static List<string> getPageLayouts(string objectName){
        List<string> pageLayouts = new List<string>();
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        if(objToken  != null && objToken.getDescribe().isCustom()){
            string objId = CustomFormsUtility.getCustomObjectId(objectName);
            if(objId != null){
                pageLayouts = CustomFormsUtility.getPageLayoutsToolingAPI(objId);
            }
        }else{
            pageLayouts = CustomFormsUtility.getPageLayoutsToolingAPI(objectName);
        }
        System.debug(pageLayouts);    
        return pageLayouts;
    }
    Public class RecordTypePageLayoutWrapper{
        @AuraEnabled
        Public Map<String,String> recordTypeMap{get;set;}
        @AuraEnabled
        Public List<String> pageLayouts{get;set;}
        @AuraEnabled
        Public Boolean isCustom{get;set;}
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will save the guestform settings record
@params : Custom_Form_Setting__c cs
@return : String
*/ 
    @AuraEnabled
    Public static String saveGSSettings(Custom_Form_Setting__c cs){
        System.debug(cs);
        string result;
        try{
            upsert cs;
            if(cs.Id != null)
                result = System.Label.Record_Saved;
            
        }
        catch(Exception e){
            system.debug(e.getMessage());
            result = e.getMessage();
            //Generate a Log record
            GuestForm_Log__c gl = new GuestForm_Log__c();
            gl.Exception_Type__c = e.getTypeName();
            gl.Error_Message__c = e.getMessage();
            insert gl;
        }
        return result;
    }
    @AuraEnabled
    Public static LookupWrapper getLookupFields(Custom_Form_Setting__c cs){
        Map<String,String> conLookupsMap = new Map<String,String>();
        Map<String,String> leadLookupsMap = new Map<String,String>();
        Map<String,String> accountLookupsMap = new Map<String,String>();
        Integer lookupFieldCnt = 0;
        
        String objType=cs.Sobject__c;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            lookupFieldCnt = lookupFieldCnt++;
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            //get data types for each fields
            Schema.DisplayType fielddataType = 
                fieldMap.get(fieldName).getDescribe().getType();
            if(fielddataType == Schema.DisplayType.Reference) {
                Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
                    .get(objType)
                    .getDescribe()
                    .fields
                    .getMap()
                    .get(fieldName)
                    .getDescribe();
                for(Schema.SObjectType reference : f.getReferenceTo()) {
                    if(reference.getDescribe().getName() == 'Contact'){
                        conLookupsMap.put(fieldName,fieldLabel);
                        
                    }else if(reference.getDescribe().getName() == 'Account'){
                        accountLookupsMap.put(fieldName,fieldLabel);
                    }else if(reference.getDescribe().getName() == 'Lead'){
                        leadLookupsMap.put(fieldName,fieldLabel);
                    }
                    System.debug('Lookup reference object name: ' + reference.getDescribe().getName());
                    System.debug('Lookup reference object label: ' + reference.getDescribe().getLabel());
                }
            } 
        } 
        LookupWrapper lw = new LookupWrapper();
        lw.conLookupsMap = conLookupsMap;
        lw.accountLookupsMap = accountLookupsMap;
        lw.leadLookupsMap =  leadLookupsMap;
        lw.lookupFieldCnt = lookupFieldCnt;
        return lw;
        
    }
    Public class LookupWrapper{
        @AuraEnabled
        Public Map<String,String> conLookupsMap {get;set;}
        @AuraEnabled
        Public Map<String,String> leadLookupsMap {get;set;}
        @AuraEnabled
        Public Map<String,String> accountLookupsMap {get;set;}
        @AuraEnabled
        Public Integer lookupFieldCnt {get;set;}
    }
}