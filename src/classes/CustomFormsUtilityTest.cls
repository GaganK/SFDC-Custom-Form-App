@isTest
public class CustomFormsUtilityTest {
    public Static Final Id RECORDTYPEID = Schema.SObjectType.GuestForms__c.getRecordTypeInfosByName().get('Master').getRecordTypeId();
    @testsetup
    static void createTestData(){
          Custom_Form_Setting__c cs = TestDataFactory.createGuestFormSettings('GuestForms__c','GuestForms__c','EasyForm Layout');
        GuestForms__c g = TestDataFactory.createGuestFormSettings(cs.id);
      
    }
    @isTest
    static void testCustomFormsUtility(){
        GuestForms__c gf = [select id,Link_Expired__c,UUID__c from GuestForms__c];
        List<Custom_Form_Setting__c> csListNew = new List<Custom_Form_Setting__c>();
        List<Custom_Form_Setting__c> csList = new List<Custom_Form_Setting__c>();
        Custom_Form_Setting__c cs = [select id,Email_Template__c,Sobject_Label_Name__c,Sobject__c,PageLayout_name__c,Expire_Link_After__c,Active__c from Custom_Form_Setting__c where Sobject__c = 'GuestForms__c'];
        csList.add(cs);
        Test.setCurrentPage(Page.FormBuilderPage);
        ApexPages.currentPage().getParameters().put('guestformid',gf.UUID__c);
        CustomFormsUtility cf = new CustomFormsUtility();
        cf.checkExpiration();
        CustomFormsUtility.getUUID();
        CustomFormsUtility.getRecord(cs.Id);
        CustomFormsUtility.getGuestForm(null);
        CustomFormsUtility.getGuestForm(gf.UUID__C);
        if(RECORDTYPEID != null){
            CustomFormsUtility.getRecordTypeName(RECORDTYPEID,'GuestForms__c');
        }
        PageReference reportPage = Page.GetSessionIdVF;
        Test.setCurrentPage(reportPage); 
        CustomFormsUtility.fetchUserSessionId();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EasyFormsMockHttpResponse());
        CustomFormsUtility.getPageLayoutsToolingAPI('Account');
        CustomFormsUtility.getCustomObjectId('Account');
        Test.stopTest();
    }
}