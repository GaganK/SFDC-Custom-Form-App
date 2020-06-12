/***************************************************************** 
Purpose: Get all pagelayout sections and fields  
History                                                             
-------- -----------------------------------------------------------------------                                                       
VERSION        AUTHOR                 DATE            DETAIL       Description 
1.0            Varun Sirisilla        01/02/2020     Created      controller for formbuilder lightning component 
*********************************************************************************/
public without sharing class FormBuilderController {
    public static  TimeZone tz = UserInfo.getTimeZone();
    public static  DateTime dt = Datetime.now();
    /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will get all pagelayoutfields
@params : String customSettingsId,String guestFormId
@return : List<LayoutSection>
*/ 
    @AuraEnabled 
    public static List<LayoutSection> getPageLayoutFields(String customSettingsId,String guestFormId) {
        system.debug(customSettingsId);
        system.debug(guestFormId);
        constants constants = New constants();
        Savepoint sp = Database.setSavepoint();
        List<sObject> gfList = customFormsUtility.getGuestForm(guestFormId);
        List<GuestForms__c> gf = (List<GuestForms__c>)gfList;
        System.debug(gf);
        if(gf[0].First_open_date__c == null){
            gf[0].First_open_date__c = dt.addSeconds((tz.getOffset(dt)/1000));
        }
        if(gf[0].Status__c != constants.SUBMITTED){
            gf[0].Status__c = constants.OPENED;  
        }
        gf[0].Last_open_date__c = dt.addSeconds((tz.getOffset(dt)/1000));
        if(gf[0].Number_of_opens__c == null){
            gf[0].Number_of_opens__c = 1;
        }else{
            gf[0].Number_of_opens__c = gf[0].Number_of_opens__c + 1;
        }
        System.debug('ObjectName*************'+gf[0].Object_API_Name__c);
        List<LayoutSection> lstSections = new List<LayoutSection>();   
        try { 
            List<String> componentNameList = new List<String>();
            componentNameList.add(gf[0].PageLayout__c);
            // Retrieve page layout details 
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
            // We are going to find the fields names and will keep them according to columns so 
            // we can show them as per page layout 
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                if(ls.label != constants.CUSTOMLINKS){
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                    section.guestFormList = gf[0];
                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                        LayoutColumn column = new LayoutColumn();
                        // check if there are fields available in that column
                        if( lc.layoutItems != null ) { 
                            // Get the max number of fields in a column to preserve the alignment 
                            if( maxFieldsInColumn < lc.layoutItems.size() ) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for( Metadata.LayoutItem li : lc.layoutItems ) {
                                // Pass the LayoutItem object in the LayoutField consturctor        
                                column.lstFields.add( new LayoutField( li,gf[0].Object_API_Name__c) );
                            }
                        }
                        // No need to add a column in the section if there is no field available 
                        if( column.lstFields.size() > 0 ) {
                            lstColumns.add( column );
                            System.debug(lstColumns);
                        }
                    }
                    // Now, we need to arrange the fields in section so we can use them in the iteration 
                    // on the component so we will have to arrange them in the order 
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < lstColumns.size(); j++ ){
                                if( lstColumns[j].lstFields.size() > i ) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );    
                                }    
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }    
                        }    
                    }
                    
                    lstSections.add( section );
                }
            }
            update gf;
        }
        catch( Exception e ){
            system.debug(e.getLineNumber() + e.getMessage());
            Database.rollback(sp);
            //System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        return lstSections;
    }
    @AuraEnabled
    public static List<LayoutSection> pageLayoutSectionsandFields(string pageLayout,string sObj){
        constants constants = New constants();
        string pageLayoutName = sObj+'-'+pageLayout;
        List<LayoutSection> lstSections = new List<LayoutSection>();   
        try { 
            List<String> componentNameList = new List<String>();
            componentNameList.add(pageLayoutName);
            // Retrieve page layout details 
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
            // We are going to find the fields names and will keep them according to columns so 
            // we can show them as per page layout 
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                system.debug(ls.label);
                if(ls.label != constants.CUSTOMLINKS)
                {
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                        LayoutColumn column = new LayoutColumn();
                        // check if there are fields available in that column
                        if( lc.layoutItems != null ) { 
                            // Get the max number of fields in a column to preserve the alignment 
                            if( maxFieldsInColumn < lc.layoutItems.size() ) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for( Metadata.LayoutItem li : lc.layoutItems ) {
                                // Pass the LayoutItem object in the LayoutField consturctor        
                                column.lstFields.add( new LayoutField( li,sObj) );
                            }
                        }
                        // No need to add a column in the section if there is no field available 
                        if( column.lstFields.size() > 0 ) {
                            lstColumns.add( column );
                            System.debug(lstColumns);
                        }
                    }
                    // Now, we need to arrange the fields in section so we can use them in the iteration 
                    // on the component so we will have to arrange them in the order 
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < lstColumns.size(); j++ ){
                                if( lstColumns[j].lstFields.size() > i ) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );    
                                }    
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }    
                        }    
                    }
                    
                    lstSections.add( section );
                }
            }
        }
        catch( Exception e ){
            
        }
        return lstSections;
        
    }
    public class LayoutSection {   
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        @AuraEnabled public GuestForms__c guestFormList;
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
            this.guestFormList = new GuestForms__c();
        }
    }
    private class LayoutColumn {
        private List<LayoutField> lstFields;    
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    public class LayoutField {
        Constants constants = New Constants();
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        public LayoutField() {}
        public LayoutField( Metadata.LayoutItem li,String ObjectName) {
            System.debug(li);
            //if(li.field == constants.NAME && (ObjectName == constants.CONTACT || ObjectName == constants.LEAD)){
               // this.fieldName = constants.LASTNAME;
           //}else{
                this.fieldName = li.field;
            //}
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }    
        }
    }
      /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will update guestform
@params : GuestForms__c guestForm,String parentId,string attachId
@return : void
*/ 
    @AuraEnabled
    Public static void updateGuestForm(GuestForms__c guestForm,String parentId,string attachId){
        Constants constants = New Constants();
        if(attachId !=null && parentId != null)
        {
            List<Attachment> updateAttachList = new List<Attachment>();
            List<Attachment> at = [select id,name,body,parentId from Attachment where id=:attachId];
            for(Attachment a : at){
                Attachment atch=new Attachment();
                atch.body = a.body;
                atch.name =a.name;
                atch.parentid =parentId ;
                updateAttachList.add(atch);
            }
            if(updateAttachList.size()>0){
                insert updateAttachList;
            }
        }
        if(guestForm.First_submitted_date__c ==  null){
            guestForm.First_submitted_date__c =  dt.addSeconds((tz.getOffset(dt)/1000));
        }
        guestForm.Last_submitted_date__c = dt.addSeconds((tz.getOffset(dt)/1000));
        if(guestForm.Number_of_submissions__c == null){
            guestForm.Number_of_submissions__c = 1;
        }else{
            guestForm.Number_of_submissions__c = guestForm.Number_of_submissions__c + 1;
        }
        guestForm.Parent__c = parentId;
        guestForm.Status__c = constants.SUBMITTED;
        try{
            update guestForm;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
          /*
@Author : Varun Sirisilla
@BuiltDate : 01/02/2020
@Description : This method will save the attachment
@params : Id parentId, String fileName, String base64Data, String contentType, String fileId
@return : Id
*/ 
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        Constants constants = New Constants();
        base64Data = EncodingUtil.urlDecode(base64Data, constants.UTF);
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        insert oAttachment;
        return oAttachment.Id;
    }
    private static void appendToFile(Id fileId, String base64Data) {
        Constants constants = New Constants();
        base64Data = EncodingUtil.urlDecode(base64Data, constants.UTF);
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
    }
    
}