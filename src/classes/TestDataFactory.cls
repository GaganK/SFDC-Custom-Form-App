@isTest
public class TestDataFactory {
    public static Custom_Form_Setting__c createGuestFormSettings(String sObjectName,String label,String pageLayout){
        Custom_Form_Setting__c cs = new  Custom_Form_Setting__c();
        cs.Sobject__c = sObjectName;
        cs.Sobject_Label_Name__c = label;
        cs.PageLayout_name__c = pageLayout;
        cs.Expire_Link_After__c = 1;
        cs.Active__c = true;
        insert cs;
        return cs;
    }
    public static Custom_Form_Setting__c createGuestFormSettingsWithRecordType(String recTypeId,String sObjectName,String label,String pageLayout){
        Custom_Form_Setting__c cs = new  Custom_Form_Setting__c();
        cs.Sobject__c = sObjectName;
        cs.Sobject_Label_Name__c = label;
        cs.PageLayout_name__c = pageLayout;
        cs.Expire_Link_After__c = 1;
        cs.Record_Type__c = recTypeId;
        cs.Active__c = true;
        insert cs;
        return cs;
    }
    public static GuestForms__c createGuestFormSettings(string csId){
        GuestForms__c gf = new  GuestForms__c();
        gf.Custom_Form_Settings__c = csId;
        insert gf;
        return gf;
    }
    public static Account createAccount()
    {
        Account acc = new Account();
        acc.Name = 'easyForms';
        insert acc;
        return acc;
    }
    public static Contact createContact()
    {
        Contact c = new Contact();
        c.LastName = 'easyForms';
        c.Email = 'test@test.com';
        insert c;
        return c;
    }
    
    public static Attachment createAttachment(String parentId)
    {
        Attachment attach=new Attachment();   	
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=parentId;
        insert attach;
        return attach;
    }
}