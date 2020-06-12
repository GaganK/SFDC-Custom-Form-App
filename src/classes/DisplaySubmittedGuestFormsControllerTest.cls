@isTest
public class DisplaySubmittedGuestFormsControllerTest {
    @isTest
    static void DisplaySubmittedGuestFormsControllerTest(){
        Account acc = TestDataFactory.createAccount();
        Contact con = TestDataFactory.createContact();
        
        Custom_Form_Setting__c cs = TestDataFactory.createGuestFormSettings('GuestForms__c','GuestForms__c','EasyForm Layout');
        GuestForms__c gf1 = TestDataFactory.createGuestFormSettings(cs.id);
        GuestForms__c gf2 = TestDataFactory.createGuestFormSettings(cs.id);
        
        GuestForms__c guestForm1  = [select  Custom_Form_Settings__r.Record_Type__c,UUID__C,First_open_date__c,Custom_Form_Settings__r.Form_Header_Color__c,Custom_Form_Settings__r.Form_body_color__c,Custom_Form_Settings__r.Form_Background_Color__c,Status__c,PageLayout__c,Number_of_opens__c,Object_API_Name__c,PageLayout_name__c,Last_open_date__c,Id,First_submitted_date__c,Number_of_submissions__c,Last_submitted_date__c,Parent__c,Custom_Form_Settings__r.Sobject_Label_Name__c,Custom_Form_Settings__r.Allowed_File_Types__c,Custom_Form_Settings__r.Allow_edit_after_submit__c,Custom_Form_Settings__r.Allow_File_Upload__c,Custom_Form_Settings__r.Allow_read_after_submit__c from guestforms__c
                                     where Id=: gf1.Id];
        GuestForms__c guestForm2  = [select  Custom_Form_Settings__r.Record_Type__c,UUID__C,First_open_date__c,Custom_Form_Settings__r.Form_Header_Color__c,Custom_Form_Settings__r.Form_body_color__c,Custom_Form_Settings__r.Form_Background_Color__c,Status__c,PageLayout__c,Number_of_opens__c,Object_API_Name__c,PageLayout_name__c,Last_open_date__c,Id,First_submitted_date__c,Number_of_submissions__c,Last_submitted_date__c,Parent__c,Custom_Form_Settings__r.Sobject_Label_Name__c,Custom_Form_Settings__r.Allowed_File_Types__c,Custom_Form_Settings__r.Allow_edit_after_submit__c,Custom_Form_Settings__r.Allow_File_Upload__c,Custom_Form_Settings__r.Allow_read_after_submit__c from guestforms__c
                                     where Id=: gf2.Id];
        guestForm1.Object_API_Name__c = 'Account';
        guestForm1.Parent__c = con.Id;
        guestForm1.Account__c = acc.Id;
        update guestForm1;  
        guestForm2.Object_API_Name__c = 'Account';
        guestForm2.Parent__c = con.Id;
        guestForm2.Account__c = acc.Id;
        update guestForm2;
        DisplaySubmittedGuestFormsController.getRecords(acc.Id);  
        guestForm1.Object_API_Name__c = 'Contact';
        guestForm1.Parent__c = acc.Id;
        guestForm1.Contact__c = con.Id;
        update guestForm1;  
        guestForm2.Object_API_Name__c = 'Contact';
        guestForm2.Parent__c = acc.Id;
        guestForm2.Contact__c = con.Id;
        update guestForm2;
        DisplaySubmittedGuestFormsController.getRecords(con.Id);  
        
    }
}