({
    navigateDetail : function(component, event, helper) {
     
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.guestFormRecord.Parent__c'),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})