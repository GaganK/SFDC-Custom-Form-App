/***************************************************************** 
Purpose: Utility class
History                                                             
-------- -----------------------------------------------------------------------                                                       
VERSION        AUTHOR                 DATE            DETAIL       Description 
1.0            Varun Sirisilla        01/02/2020     Created       Utility class 
*********************************************************************************/
public class CustomFormsUtility {
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : generate UUID
@params : no params
@return : String
*/ 
    Public static String getUUID()
    {
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        System.debug(guid);
        return guid;
        
        
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : checkExpiration of form
@params : no params
@return : pageReference
*/ 
    public pageReference checkExpiration() {
        string guestformid =  ApexPages.currentPage().getParameters().get('guestformid');
        if(guestformid!=null){
            GuestForms__c guestObj = new GuestForms__c();
            guestObj = [Select id,  Link_Expired__c from GuestForms__c where UUID__c=:guestformid];
            if(guestObj.Link_Expired__c) {
                return new PageReference('/apex/LinkExpired');
            }else{
                return null;
            }
        }else{
            return null; 
        }
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : return list of records for a sobject
@params : Id rId
@return : List<Sobject>
*/ 
    public static List<Sobject> getRecord(Id rId) {
        
        String sObjName = Rid.getSObjectType().getDescribe().getName();
        String query='';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        query = 'select ' + commaSepratedFields + ' from ' + sObjName;
        query += ' WHERE Id = \''+rId+'\'';
        System.debug('******soqlQuery*********'+query );
        list<Sobject> olist =  new list<Sobject>();
        olist = database.query(query);
        System.debug(olist);
        return olist;
        
        
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : return object label 
@params : String sObjAPIName
@return : String
*/ 
    Public static String getSobjLabel(String sObjAPIName){
        Map<String,String> objectNames  = new Map<String,String>();
        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() )
        {
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            objectNames.put(objResult.getName(),objResult.getLabel());
        }
        return objectNames.get(sObjAPIName);
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : return guestforms__c record
@params : String rId
@return : List<guestforms__c>
*/
    Public static List<guestforms__c> getGuestForm(String rId){
       
            if(rId != null)
            return [select  Custom_Form_Settings__r.Record_Type__c,UUID__C,First_open_date__c,Custom_Form_Settings__r.Form_Header_Color__c,Custom_Form_Settings__r.Form_body_color__c,Custom_Form_Settings__r.Form_Background_Color__c,Status__c,PageLayout__c,Number_of_opens__c,Object_API_Name__c,PageLayout_name__c,Last_open_date__c,Id,First_submitted_date__c,Number_of_submissions__c,Last_submitted_date__c,Parent__c,Custom_Form_Settings__r.Sobject_Label_Name__c,Custom_Form_Settings__r.Allowed_File_Types__c,Custom_Form_Settings__r.Allow_edit_after_submit__c,Custom_Form_Settings__r.Allow_File_Upload__c,Custom_Form_Settings__r.Allow_read_after_submit__c from guestforms__c
                    where UUID__c=: rId Limit 1];
            else
                return null;
        
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will return record type name
@params : String recordTypeId,String sObjName
@return : String
*/
    Public static String getRecordTypeName(String recordTypeId,String sObjName){
        return Schema.getGlobalDescribe().get(sObjName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }   
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : Fetches user session Id from GetSessionIdVF page
@params : 
@return : String
*/
    public static String fetchUserSessionId(){
        String sessionId = '';
        String vfContent;
        if(!Test.isRunningTest()) { 
            // Refer to the Page
            PageReference reportPage = Page.GetSessionIdVF;
            // Get the content of the VF page
            
            vfContent = reportPage.getContent().toString();
            
            System.debug('vfContent '+vfContent);
            // Find the position of Start_Of_Session_Id and End_Of_Session_Id
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
            // Get the Session Id
            sessionId = vfContent.substring(startP, endP);
            System.debug('sessionId '+sessionId);
        }else{
            sessionId=UserInfo.getSessionId();
        }
        // Return Session Id
        return sessionId;
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : util class to fetch pagelayouts under the sobject using tooling api
@params : string objName
@return : List<string>
*/ 
    public static List<string> getPageLayoutsToolingAPI(string objName){
        System.debug(objName);
        String sessionId = fetchUserSessionId();
        List<string> pageLayouts = new List<string>();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId); 
        req.setHeader('Content-Type', 'application/json');
        String SFdomainUrl=URL.getSalesforceBaseUrl().toExternalForm();
        String query='Select+id,Name+from+Layout+where+TableEnumOrId=\''+objName+'\'';
        req.setEndpoint(SFdomainUrl+'/services/data/v42.0/tooling/query/?q='+query);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse response = h.send(req);
        System.debug(response.getBody());
        
        if(response.getStatusCode() < 300)
        {
            LayoutWrapper lw = LayoutWrapper.parse(response.getBody());
            for(LayoutWrapper.Records r : lw.Records){
                if(r.name != null)
                    pageLayouts.add(r.name);
            }
            System.debug(pageLayouts);
            return pageLayouts;
        }else{
            return null;
        }
    }
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : util class to fetch customobjectId of sobject using tooling api
@params : string objName
@return : string
*/ 
    public static string getCustomObjectId(string objName){
        String sessionId = fetchUserSessionId();
        string objId;
        string objectName = objName.removeEnd('__c');
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId); 
        req.setHeader('Content-Type', 'application/json');
        String SFdomainUrl=URL.getSalesforceBaseUrl().toExternalForm();
        String query='Select+Id,DeveloperName,NamespacePrefix+From+CustomObject+Where+DeveloperName=\''+objectName+'\'';
        req.setEndpoint(SFdomainUrl+'/services/data/v42.0/tooling/query/?q='+query);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse response = h.send(req);
        if(response.getStatusCode() < 300)
        {
            CustomObjectIdWrapper r = CustomObjectIdWrapper.parse(response.getBody());
            if(r != null && r.Records.Size()>0)
            {
                objId = r.Records[0].id; 
            }
            return objId;
        }else{
            return null;
        }
    }
    
    
}