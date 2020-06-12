({
    doEdit : function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:NewCustomSettings",
            componentAttributes :{ "customFormSettings":component.get('v.customSetting')}
        });
        navigateEvent.fire();
    },goBack: function(component, event, helper) {
           var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:CreateCustomSettings"
            //You can pass attribute value from Component2 to Component1
            //componentAttributes :{ }
        });
        navigateEvent.fire();
    }
})