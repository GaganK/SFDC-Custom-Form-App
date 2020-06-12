({
    doInit : function(component, event, helper) {
        component.set('v.fileUpLoad',component.get('v.customFormSettings.Allow_File_Upload__c'));
        var action = component.get("c.pageLayoutSectionsandFields");
        action.setParams({
            pageLayout: component.get('v.customFormSettings.PageLayout_name__c'),
            sObj :component.get('v.customFormSettings.Sobject__c')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
           // console.log(''+JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                component.set("v.layoutSections", response.getReturnValue() );
             
                    component.set('v.spinner',false);
                
            }
            else if (state === "INCOMPLETE") {
                component.set('v.spinner',false);
                
            }
                else if (state === "ERROR") {
                    component.set('v.spinner',false);
                    
                    var errors = response.getError();
                    console.log(errors);
                }
        });
        
        $A.enqueueAction(action);
        
    },
    handleLoad: function(component, event, helper) {
    },
    loadPage: function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:NewCustomSettings",
            //You can pass attribute value from Component1 to Component2
            componentAttributes :{ "customFormSettings":component.get('v.customFormSettings'),
                                  "fromPreview":true}
        });
        navigateEvent.fire();
    },
    saveRecord: function(component, event, helper) {
        
        var action = component.get("c.saveGSSettings");
        action.setParams({
            cs: component.get('v.customFormSettings'),
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            console.log(''+JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Record Saved'){
                    var message = 'Record Saved';
                    helper.showSuccess(component,event,message);
                    var navigateEvent = $A.get("e.force:navigateToComponent");
                    navigateEvent.setParams({
                        componentDef: "c:CreateCustomSettings"
                        //You can pass attribute value from Component2 to Component1
                        //componentAttributes :{ }
                    });
                    navigateEvent.fire();
                }else{
                    var message = response.getReturnValue();
                    helper.showError(component,event,message);
                }
            }
            else if (state === "INCOMPLETE") {
                var message = 'Unable to save the record';
                helper.showError(component,event,message);
            }
            
                else if (state === "ERROR") {
                    var message = 'Unable to save the record';
                    helper.showError(component,event,message);
                    var errors = response.getError();
                    console.log(errors);
                }
        });
        
        $A.enqueueAction(action);
    }
})