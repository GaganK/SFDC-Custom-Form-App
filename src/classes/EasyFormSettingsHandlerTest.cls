@isTest
public class EasyFormSettingsHandlerTest {
    public Static Final Id RECORDTYPEID = Schema.SObjectType.GuestForms__c.getRecordTypeInfosByName().get('Master').getRecordTypeId();
    
    @isTest
    static void createGuestForm(){
        Custom_Form_Setting__c cs = TestDataFactory.createGuestFormSettingsWithRecordType(RECORDTYPEID,'GuestForms__c','GuestForms__c','EasyForm Layout');
        cs.Record_Type__c = null;
        update cs;
        GuestForms__c g = TestDataFactory.createGuestFormSettings(cs.id);
    }
}