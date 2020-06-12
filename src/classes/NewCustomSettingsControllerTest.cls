@isTest
public class NewCustomSettingsControllerTest {
    @testsetup
    static void createTestData(){
        Custom_Form_Setting__c cs = TestDataFactory.createGuestFormSettings('GuestForms__c','GuestForms__c','EasyForm Layout');
        GuestForms__c g = TestDataFactory.createGuestFormSettings(cs.id);
    }
    @isTest
    static void testNewCustomSettingsController(){
        List<Custom_Form_Setting__c> csListNew = new List<Custom_Form_Setting__c>();
        List<Custom_Form_Setting__c> csList = new List<Custom_Form_Setting__c>();
        Custom_Form_Setting__c cs = [select id,Email_Template__c,Sobject_Label_Name__c,Sobject__c,PageLayout_name__c,Expire_Link_After__c,Active__c from Custom_Form_Setting__c where Sobject__c = 'GuestForms__c'];
        csList.add(cs);
        NewCustomSettingsController.getSobjects();
        Boolean result = NewCustomSettingsController.checkObjectType('Account');
        System.assertEquals(false, result);
        NewCustomSettingsController.checkObjectType('GuestForms__c');
        NewCustomSettingsController.checkObjectType('test__c');
        NewCustomSettingsController.getLookupFields(cs);
        NewCustomSettingsController.getEmailTemplates();
        NewCustomSettingsController.saveGSSettings(cs);
        cs.Sobject__c = null;
        //negative Scenario
        NewCustomSettingsController.saveGSSettings(cs);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EasyFormsMockHttpResponse());
        NewCustomSettingsController.getRecordTypesAndPageLayouts('GuestForms__c');
        NewCustomSettingsController.getRecordTypesAndPageLayouts('Account');
        //negative Scenario
        NewCustomSettingsController.getRecordTypesAndPageLayouts('test');
        Test.stopTest();
        
    }
}