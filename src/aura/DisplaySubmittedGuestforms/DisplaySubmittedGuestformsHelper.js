({
    getRecords : function(component,event,recordId) {
        var action = component.get("c.getRecords");
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == null || response.getReturnValue() == ''){
                    component.set("v.submitRecords",  null);
                }else{
                    component.set("v.submitRecords",  response.getReturnValue());
                }
                component.set('v.spinner',false);
                //  alert(JSON.stringify(component.get('v.submitRecords')));
            }
            else if (state === "INCOMPLETE") {
                component.set('v.spinner',false);
                
                // do something
            }
                else if (state === "ERROR") {
                    component.set('v.spinner',false);
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})