@isTest
public class CreateCustomSettingsControllerTest {
    @testsetup
    static void createTestData(){
        Custom_Form_Setting__c accountCs = TestDataFactory.createGuestFormSettings('Account','Account','Account Layout');
        Custom_Form_Setting__c contactCs = TestDataFactory.createGuestFormSettings('Contact','Contact','Contact Layout');
        GuestForms__c g = TestDataFactory.createGuestFormSettings(accountCs.id);
        Account a = TestDataFactory.createAccount();
        Contact c = TestDataFactory.createContact();
    }
    @isTest
    static void testCreateCustomSettings(){
        Account acc = [select id from Account where name = 'easyForms'];
        Contact c = [select id from Contact where name = 'easyForms'];
        List<Custom_Form_Setting__c> csListNew = new List<Custom_Form_Setting__c>();
        List<Custom_Form_Setting__c> csList = new List<Custom_Form_Setting__c>();
        Custom_Form_Setting__c accCS = [select id,Email_Template__c,Sobject_Label_Name__c,Sobject__c,PageLayout_name__c,Expire_Link_After__c,Active__c from Custom_Form_Setting__c where Sobject__c = 'Account'];
        Custom_Form_Setting__c conCS = [select id,Email_Template__c,Sobject_Label_Name__c,Sobject__c,PageLayout_name__c,Expire_Link_After__c,Active__c from Custom_Form_Setting__c where Sobject__c = 'Contact'];
        csListNew.add(conCS);
        csList.add(accCS);
        
        //getEmailFields
        createCustomSettingsController.getEmailFields(c.Id);
        
        CsListNew[0].Email_Template__c = System.Label.GuestForm_Default_Email;
        update CsListNew;
        //sendEmail Method
        createCustomSettingsController.sendEmail(CsListNew, 'toEmail@test.com',c.Id);
        createCustomSettingsController.sendEmail(CsListNew, 'toEmail@test.com',acc.Id);
        //Negative Scenario
        createCustomSettingsController.sendEmail(CsListNew, 'toEmailtest.com',acc.Id);
        
        //fetchCustomSettings Method
        createCustomSettingsController.fetchCustomSettings(1,5,'ALL');
        createCustomSettingsController.fetchCustomSettings(1,5,'Active');
        createCustomSettingsController.fetchCustomSettings(1,5,'InActive');
        //Negative Scenario
        createCustomSettingsController.fetchCustomSettings(0,5,'InActive');
        
        //deleteMassCustomSettings method
        String returnMessage = createCustomSettingsController.deleteCustomSettings(accCs);
        System.assertEquals(System.Label.Record_Delete_Success_Message, returnMessage);
        //Negative Scenario
        createCustomSettingsController.deleteCustomSettings(accCs);
        
        
    }
}