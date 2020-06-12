/***************************************************************** 
Purpose: Display all the guestform settings in a table and  
History                                                             
-------- -----------------------------------------------------------------------                                                       
VERSION        AUTHOR                 DATE            DETAIL       Description 
1.0            Varun Sirisilla        01/02/2020     Created      controller for createcustomsettings lightning component 
*********************************************************************************/
public with sharing class CreateCustomSettingsController {
    public static  TimeZone tz = UserInfo.getTimeZone();
    public static  DateTime dt = Datetime.now();
    
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : Displays all the custom settings in table with paginations 
@params : Decimal pageNumber ,Integer recordToDisply,string formSettingStatus
@return : customSettingsWrapper
*/ 
    @AuraEnabled
    public static customSettingsWrapper fetchCustomSettings(Decimal pageNumber ,Integer recordToDisply,string formSettingStatus) {
        try
        {
            constants constants = New constants();
            Integer pageSize = recordToDisply;
            Integer offSet = ((Integer)pageNumber - 1) * pageSize;
            // create a instance of wrapper class.
            customSettingsWrapper csw =  new customSettingsWrapper();
            // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
            csw.pageSize = pageSize;
            csw.page = (Integer) pageNumber;
            csw.total = [SELECT count() FROM Custom_Form_Setting__c];
            if(formSettingStatus == constants.ALL)
            {
                csw.cs = [SELECT Id,Sobject__c,Name,UUID__c,Record_Type__c,Record_Type_Name__c,PageLayout_name__c,Form_Background_Color__c,Form_body_color__c,Form_Header_Color__c,Expire_Link_After__c,Allowed_File_Types__c,Allow_read_after_submit__c,Allow_File_Upload__c,Allow_edit_after_submit__c,Number_of_GuestForms__c,Number_of_GuestForms_Submitted__c,Email_Template__c,Sobject_Label_Name__c,Active__c FROM Custom_Form_Setting__c  ORDER BY Name desc LIMIT :recordToDisply OFFSET :offSet];
            }else if(formSettingStatus == constants.ACTIVE){
                csw.cs = [SELECT Id,Sobject__c,Name,UUID__c,Record_Type__c,Record_Type_Name__c,PageLayout_name__c,Form_Background_Color__c,Form_body_color__c,Form_Header_Color__c,Expire_Link_After__c,Allowed_File_Types__c,Allow_read_after_submit__c,Allow_File_Upload__c,Email_Template__c,Allow_edit_after_submit__c,Number_of_GuestForms__c,Number_of_GuestForms_Submitted__c,Sobject_Label_Name__c,Active__c FROM Custom_Form_Setting__c where Active__c = true ORDER BY Name desc LIMIT :recordToDisply OFFSET :offSet];
            }else if(formSettingStatus == constants.INACTIVE){
                csw.cs = [SELECT Id,Sobject__c,Name,UUID__c,Record_Type__c,Record_Type_Name__c,PageLayout_name__c,Form_Background_Color__c,Form_body_color__c,Form_Header_Color__c,Expire_Link_After__c,Allowed_File_Types__c,Allow_read_after_submit__c,Allow_File_Upload__c,Email_Template__c,Allow_edit_after_submit__c,Number_of_GuestForms__c,Number_of_GuestForms_Submitted__c,Sobject_Label_Name__c,Active__c FROM Custom_Form_Setting__c where Active__c = false ORDER BY Name desc LIMIT :recordToDisply OFFSET :offSet];
            }
            // return the wrapper class instance .
            return csw;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            //Generate a Log record
            GuestForm_Log__c gl = new GuestForm_Log__c();
            gl.Exception_Type__c = e.getTypeName();
            gl.Error_Message__c = e.getMessage();
            insert gl;
            return null;
        }
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : Wrapper class to Displays all the custom settings in table with paginations 
*/   
    public class customSettingsWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Custom_Form_Setting__c> cs {get;set;}
    }  
    
    @AuraEnabled
    public static String deleteCustomSettings(Custom_Form_Setting__c cs) {
        String result;
        try{
            delete cs;
            //result = 'Record Deleted Successfully';
            result = System.Label.Record_Delete_Success_Message;
        }catch(Exception e){
            //Generate a Log record
            GuestForm_Log__c gl = new GuestForm_Log__c();
            gl.Exception_Type__c = e.getTypeName();
            gl.Error_Message__c = e.getMessage();
            insert gl;
            //result = 'Exception occured while deleting the record '+e.getMessage();
            result = System.Label.Exception_occured_while_deleting_the_record +e.getMessage();   
        }
        return result;
    } 
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will send an email to the recipient with the form link
@params : List<Custom_Form_Setting__c> csList,String toEmail,Id parentRId
@return : String
*/ 
    @AuraEnabled
    public static String sendEmail(List<Custom_Form_Setting__c> csList,String toEmail,Id parentRId) {
        String sobjectType;
        Set<Id> guestFormIds = new Set<Id>();
        String returnMessage;
        Constants constants = New Constants();
        List<GuestForms__c> leadEasyFormList = new List<GuestForms__c>();
        List<GuestForms__c> accountEasyFormList = new List<GuestForms__c>();
        List<GuestForms__c> contactEasyFormList = new List<GuestForms__c>();
        Map<Id,String> accountContentMap = new Map<Id,String>();
        Map<Id,String> contactContentMap = new Map<Id,String>();
        Map<Id,String> leadContentMap = new Map<Id,String>();
        Map<Id, String> newParseContent = new Map<Id, String>();
        List<GuestForms__c> gfList = new List<GuestForms__c>();
        Savepoint sp = Database.setSavepoint();
        try{
            for(Custom_Form_Setting__c cs : csList)          
            {
                GuestForms__c gf = new GuestForms__c();
                if(parentRId != null){
                    sobjectType = parentRId.getSObjectType().getDescribe().getName();
                    if(sobjectType != null && sobjectType == constants.CONTACT){
                        gf.Contact__c = parentRId;
                    } else if(sobjectType != null && sobjectType == constants.LEAD){
                        gf.Lead__c = parentRId;
                    }
                    else if(sobjectType != null && sobjectType == constants.ACCOUNT){
                        gf.Account__c = parentRId;
                    }
                }
                gf.First_sent_date__c = dt.addSeconds((tz.getOffset(dt)/1000));
                gf.Recipient_Email__c = toEmail;
                gf.Object_API_Name__c = cs.Sobject__c;
                gf.PageLayout_Name__c = cs.PageLayout_name__c;
                gf.Custom_Form_Settings__c = cs.id;
                gf.Expire_Link_After__c = cs.Expire_Link_After__c;
                gf.Email_Template__c = cs.Email_Template__c;
                gf.Object_Name__c = cs.Sobject_Label_Name__c;
                gf.Status__c = constants.SENT;
                gf.UUID__c = CustomFormsUtility.getUUID();
                gfList.add(gf);                
            }
            if(gfList.size()>0){
                insert gfList;
                for(GuestForms__c gf: gfList){
                    guestFormIds.add(gf.Id);
                }
                Map<string,EmailTemplate> mapToEmailTemp = new Map<string,EmailTemplate>();
                for(EmailTemplate emilTempObj :[SELECT Id,Name,DeveloperName,TemplateType, Subject, Body,HtmlValue FROM EmailTemplate]){
                    mapToEmailTemp.put(emilTempObj.DeveloperName,emilTempObj);
                }
                List<GuestForms__c> guestFormList = [select Id,UUID__c,Object_Name__c,Email_Template__c,Expire_Link_After__c,Custom_Form_Settings__c,PageLayout_Name__c
                                                     ,Account__c,Contact__c,Lead__c,GuestForm_Setting_Id__c,Object_API_Name__c,Recipient_Email__c,First_sent_date__c from GuestForms__c where Id IN:guestFormIds];
                for(GuestForms__c g : guestFormList){
                    if(g.Account__c != null && g.Email_Template__c != null){
                        if(mapToEmailTemp != null && mapToEmailTemp.get(g.Email_Template__c) != null){
                            if(mapToEmailTemp.get(g.Email_Template__c).TemplateType== constants.TEXT)
                                accountContentMap.put(mapToEmailTemp.get(g.Email_Template__c).Id, mapToEmailTemp.get(g.Email_Template__c).Body);
                            else{
                                accountContentMap.put(mapToEmailTemp.get(g.Email_Template__c).Id, mapToEmailTemp.get(g.Email_Template__c).HtmlValue);
                            }
                        }
                        accountEasyFormList.add(g);
                    }else if(g.Contact__c != null){
                        if(mapToEmailTemp != null && mapToEmailTemp.get(g.Email_Template__c) != null){
                            if(mapToEmailTemp.get(g.Email_Template__c).TemplateType== constants.TEXT)
                                contactContentMap.put(mapToEmailTemp.get(g.Email_Template__c).Id, mapToEmailTemp.get(g.Email_Template__c).Body);
                            else{
                                contactContentMap.put(mapToEmailTemp.get(g.Email_Template__c).Id, mapToEmailTemp.get(g.Email_Template__c).HtmlValue);
                            }
                        }
                        contactEasyFormList.add(g);
                    }else if(g.Lead__c != null){
                        if(mapToEmailTemp != null && mapToEmailTemp.get(g.Email_Template__c) != null){
                            if(mapToEmailTemp.get(g.Email_Template__c).TemplateType== constants.TEXT)
                                leadContentMap.put(mapToEmailTemp.get(g.Email_Template__c).Id, mapToEmailTemp.get(g.Email_Template__c).Body);
                            else{
                                leadContentMap.put(mapToEmailTemp.get(g.Email_Template__c).Id, mapToEmailTemp.get(g.Email_Template__c).HtmlValue);
                            }
                        }
                        leadEasyFormList.add(g);
                    }
                }
                if(sobjectType == 'Account'){
                    if(accountEasyFormList.size() > 0 && accountContentMap != null) {
                        newParseContent = parse(parentRId,accountContentMap);
                        System.debug(newParseContent);
                    }
                }else if(sobjectType == 'Contact'){
                    newParseContent = parse(parentRId,contactContentMap);
                    System.debug(newParseContent);
                }else if(sobjectType == 'Lead'){
                    newParseContent = parse(parentRId,leadContentMap);
                    System.debug(newParseContent);
                }
                String message;
                //Split the email addrress
                List<String> toAddress = toEmail.split(';');
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
                
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
                for(GuestForms__c g : guestFormList){
                    EmailTemplate et = new EmailTemplate();
                    if(g.Email_Template__c != null &&  mapToEmailTemp.get(g.Email_Template__c) != null){
                        et = mapToEmailTemp.get(g.Email_Template__c);
                    }else{
                        et =  mapToEmailTemp.get(System.Label.GuestForm_Default_Email);
                    }   
                    if(et != null)
                    {
                        string subject = et.subject;
                        System.debug(subject);
                        string csId = g.GuestForm_Setting_Id__c;
                        string gfId =g.UUID__c ;
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(et.Id);
                        mail.setToAddresses(toAddress);
                        //mail.setTargetObjectId(objectId);
                        //mail.setWhatId(g.id);
                        String htmlBody;
                        if(et.TemplateType == constants.TEXT)
                        {
                            htmlBody= et.Body;
                        }else{
                            htmlBody= et.HtmlValue;
                        }
                        if(newParseContent != null && mapToEmailTemp.get(g.Email_Template__c) != null && newParseContent.get(mapToEmailTemp.get(g.Email_Template__c).Id) != null){
                            htmlBody = newParseContent.get(mapToEmailTemp.get(g.Email_Template__c).Id);
                        }
                        if(System.Label.GuestForm_Site_Link != null)
                        {
                            String siteLink = System.Label.GuestForm_Site_Link;
                            siteLink = siteLink+'/?customsettingId='+csId+'&guestformid='+gfId;  
                            htmlBody = htmlBody.replace('{!guestformlink}', siteLink );
                        }
                        mail.setSubject(subject);
                        mail.setSenderDisplayName('Guest Form');
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(false);
                        mail.setUseSignature(false);
                        message = System.Label.Email_Sent_Successfully;
                        messages.add(mail);
                        
                    }else{
                        returnMessage = System.Label.Please_Provide_a_valid_email_template_Message;
                    }
                }
                if(messages != null && messages.size()>0)
                {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    returnMessage = System.Label.Email_Sent_Successfully;
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage() +e.getLineNumber());
            Database.rollback(sp);
            returnMessage = +e.getMessage()+'.';
            //Generate a Log record
            GuestForm_Log__c gl = new GuestForm_Log__c();
            gl.Exception_Type__c = e.getTypeName();
            gl.Error_Message__c = e.getMessage() + e.getLineNumber();
            insert gl;
        }
        return returnMessage;
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will return all the email fields and emails when the form in sending from Account or contact or lead
@params : Id recId
@return : List<EmailFieldsWrapper>
*/ 
    @AuraEnabled
    Public static  List<EmailFieldsWrapper> getEmailFields(Id recId){
        try
        {
            Integer emailIdFieldCnt = 0;
            List<EmailFieldsWrapper> ewList = new List<EmailFieldsWrapper>();
            List<String> emailFields = new List<String>();
            String sobjectName = recId.getSObjectType().getDescribe().getName();
            System.debug(sobjectName);
            // Convert to schema.sObjectType
            Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sobjectName);
            // Create an instance of that type
            Sobject genericObject = convertType.newSObject();
            String strEmailFiels = '';
            Map<String, Schema.SObjectField> fieldMap = convertType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : genericObject.getSobjectType().getDescribe().fields.getMap().values())
            {
                if(Schema.DisplayType.EMAIL == field.getDescribe().getType())
                {
                    emailIdFieldCnt = emailIdFieldCnt++;
                    strEmailFiels += ', ' + field.getDescribe().getName();
                    emailFields.add(field.getDescribe().getName());
                }
            }
            strEmailFiels = strEmailFiels.removeStart(',');
            string query;
            SObject sObj;
            if(strEmailFiels != null && strEmailFiels != ''){
                query  = 'select '+ strEmailFiels+ ' from '+sobjectName+' where id = \''+recId+'\'';
                sObj = Database.query(query);
            }
            
            for(string e : emailFields){
                EmailFieldsWrapper ew = new EmailFieldsWrapper();
                if(String.valueOf(sObj.get(e)) != null && String.valueOf(sObj.get(e)) != '')
                {
                    ew.fieldName = e;
                    ew.fieldLabel = fieldMap.get(e).getDescribe().getLabel();
                    ew.emailId = String.valueOf(sObj.get(e));
                    ew.emailIdFieldCnt = emailIdFieldCnt;
                    ewList.add(ew);
                }
            }
            return ewList;
        }  
        catch (Exception e){
            //Generate a Log record
            GuestForm_Log__c gl = new GuestForm_Log__c();
            gl.Exception_Type__c = e.getTypeName();
            gl.Error_Message__c = e.getMessage()+e.getLinenumber();
            insert gl;
            return null;
        }
    }
    
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : Wrapper class to get all Email fields
*/
    public class EmailFieldsWrapper{
        @AuraEnabled
        public string   fieldName{get;set;}
        @AuraEnabled
        public string fieldLabel{get;set;}
        @AuraEnabled
        public string  emailId{get;set;}
        @AuraEnabled
        public Integer  emailIdFieldCnt{get;set;}
    }
    public static Map<Id, String> parse(Id parentId, Map<Id,String> contentMap)
    {
        Set<String> allApis = new Set<String>();
        String objectAPI = '';
        for(Id emailTemplateId : contentMap.keySet())
        {
            objectAPI = getObjectAPI(parentId);
            allApis.addAll(getFields(contentMap.get(emailTemplateId), objectAPI));
            break;
        }
        String objectFields = '';
        for(String field : allApis)
        {
            objectFields += field + ', ';
        }
        if(objectFields != '')
        {
            Map<Id, String> templateIdToNewContent = new Map<Id, String>();
            objectFields = objectFields.substring(0, objectFields.length() - 2);
            String queryStr = 'select ' + objectFields + ' from ' + objectAPI + ' where Id =:parentId';
            Map<String, String> tempMap = new Map<String, String>();
            for(sObject obj : Database.query(queryStr))
            {
                for(String field : allApis)
                {
                    tempMap.put(field, String.valueOf(getFieldValue(obj, field)));
                }
                for(Id emailTemplateId : contentMap.keySet())
                {
                    templateIdToNewContent.put(emailTemplateId, match(contentMap.get(emailTemplateId), tempMap, objectAPI));
                }
            }
            return templateIdToNewContent;
        }
        
        Map<Id, String> templatetIdToContent = new Map<Id, String>();
        for(Id emailTemplateId : contentMap.keySet())
        {
            templatetIdToContent.put(emailTemplateId, contentMap.get(emailTemplateId));
        }
        return templatetIdToContent;
    }
    
    public static Object getFieldValue(SObject entity, String fieldName)
    {
        if(entity == null)
        {
            return null;
        }
        
        if(fieldName.contains('.'))
        {
            return getFieldValue(entity.getSObject(fieldName.substringBefore('.')), fieldName.substringAfter('.'));
        }
        else
        {
            return entity.get(fieldName);
        }
    }
    
    private static Set<String> getFields(String content, String objectAPI)
    {
        Set<String> fieldApis = new Set<String>();
        Matcher m = Pattern.compile('(\\{!\\s*' + objectAPI + '\\.([A-Za-z\\._0-9]+)\\s*\\})').matcher(content);
        Set<String> matchFields = new Set<String>();
        while(m.find())
        {
            String merge_field = m.group(2);
            fieldApis.add(merge_field);
        }
        
        return fieldApis;
    }
    
    private static String match(String content, Map<String, String> obj, String objectAPI)
    {
        Matcher m = Pattern.compile('(\\{!\\s*' + objectAPI + '\\.([A-Za-z\\._0-9]+)\\s*\\})').matcher(content);
        Set<String> matchFields = new Set<String>();
        while(m.find())
        {
            String merge_field = (String)m.group(0);
            String field = (String)m.group(2);
            
            String value;
            try
            {
                value = (String)obj.get(field);
            }
            catch(Exception e)
            {
                value = '';
            }
            if(value != null)
            {
                content = content.replace(merge_field, value);
            }
            else
            {
                content = content.replace(merge_field, '');
            }
        }
        
        return content;
    }
    
    private static String getObjectAPI(String recordId)
    {
        String keyCode  = recordId.subString(0,3);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values())
        {
            if(objectInstance.getDescribe().getKeyPrefix() == keyCode)
            {
                return objectInstance.getDescribe().getName();
            }
        }
        return null;
    }
    
}