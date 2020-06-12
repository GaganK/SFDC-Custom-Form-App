({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        if(recordId != null && recordId != '')
        {
            helper.getRecords(component,event,recordId);
        }
    },
    navigate: function(component, event, helper) {
        var recId = event.getSource().get("v.value");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    }
})