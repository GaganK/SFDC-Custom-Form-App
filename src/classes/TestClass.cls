public without sharing class TestClass {
    public static void testing(){
        List<FieldPermissions> fpList = [SELECT SobjectType, Field, PermissionsRead, PermissionsEdit, Parent.ProfileId FROM FieldPermissions WHERE SobjectType = 'Machine__c'  AND Parent.ProfileId=:Userinfo.getProfileId()];
        if(!fpList.isEmpty()){
            for(FieldPermissions fp : fpList){
                System.debug(fp.Field);
            }
            Boolean hasReadPermission = fpList[0].PermissionsRead;
            Boolean hasEditPermission = fpList[0].PermissionsEdit;
            system.debug('Read Permission - ' + hasReadPermission);
            system.debug('Edit Permission - ' + hasEditPermission);
        }
    }
}