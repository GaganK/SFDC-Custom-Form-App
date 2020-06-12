@isTest
public class FormBuilderControllerTest {
    @isTest
    static void testformbuilder(){
        Custom_Form_Setting__c cs = TestDataFactory.createGuestFormSettings('GuestForms__c','GuestForms__c','EasyForm Layout');
        GuestForms__c gf = TestDataFactory.createGuestFormSettings(cs.id);
        GuestForms__c guestForm  = [select  Custom_Form_Settings__r.Record_Type__c,UUID__C,First_open_date__c,Custom_Form_Settings__r.Form_Header_Color__c,Custom_Form_Settings__r.Form_body_color__c,Custom_Form_Settings__r.Form_Background_Color__c,Status__c,PageLayout__c,Number_of_opens__c,Object_API_Name__c,PageLayout_name__c,Last_open_date__c,Id,First_submitted_date__c,Number_of_submissions__c,Last_submitted_date__c,Parent__c,Custom_Form_Settings__r.Sobject_Label_Name__c,Custom_Form_Settings__r.Allowed_File_Types__c,Custom_Form_Settings__r.Allow_edit_after_submit__c,Custom_Form_Settings__r.Allow_File_Upload__c,Custom_Form_Settings__r.Allow_read_after_submit__c from guestforms__c
                                    where Id=: gf.Id];
        Attachment att  = TestDataFactory.createAttachment(cs.Id);
        guestForm.Object_API_Name__c = 'GuestForms__c';
        guestForm.PageLayout_Name__c = 'EasyForm Layout';
        update guestForm;
        formBuilderController.getPageLayoutFields(cs.Id,guestForm.UUID__c);
        formBuilderController.updateGuestForm(guestForm,cs.Id,att.Id);
        Id fileId= formBuilderController.saveTheFile(guestForm.id,'Test','372848327teug','Application/JSON');
        formBuilderController.saveChunk(guestForm.id,'Test','372848327teug','Application/JSON',fileId);
        formBuilderController.pageLayoutSectionsandFields(guestForm.PageLayout_Name__c,guestForm.Object_API_Name__c);
    }
    
}