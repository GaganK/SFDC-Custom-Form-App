({
    getCustomSettings: function(component, page, recordToDisply,formsettingStatus) {
        component.set('v.spinner',true);
        // create a server side action. 
        var action = component.get("c.fetchCustomSettings");
        // set the parameters to method 
        action.setParams({
            "pageNumber": page,
            "recordToDisply": recordToDisply,
            "formSettingStatus" : formsettingStatus
        });
        // set a call back   
        action.setCallback(this, function(a) {
            // store the response return value (wrapper class insatance)  
            var result = a.getReturnValue();
            //console.log('result ---->' + JSON.stringify(result));
            // set the component attributes value with wrapper class properties.   
            if(result != null)
            {
                
                if(result.cs.length == 0){
                    component.set('v.buttonClass','slds-hide'); 
                                        component.set('v.pageNoShow','slds-hide'); 

                    
                }
                component.set('v.spinner',false);
                component.set("v.customForm", result.cs);
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisply));
            }else{
                component.set('v.spinner',false);
                var message = 'Error in fetching custom settings. For more details please see latest guesform logs.'
                this.showErrorToast(component,event,message);
            }
        });
        // enqueue the action 
        $A.enqueueAction(action);
    },
    doEdit: function(component, event,currentRecord) {
        component.set('v.spinner',true);
        component.set("v.currentRecordId",currentRecord);
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:NewCustomSettings",
            componentAttributes :{ "customFormSettings":currentRecord}
        });
        navigateEvent.fire();
        component.set('v.spinner',false);
    },
    doview: function(component, event,currentRecord) {
        component.set('v.spinner',true);
        component.set("v.currentRecordId",currentRecord);
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:NewCustomSettings",
            componentAttributes :{ "customFormSettings":currentRecord,"viewMode":true,
                                  "showSave":'slds-hide',
                                  "showEdit":'slds-show'}
        });
        navigateEvent.fire();
        component.set('v.spinner',false);
    },
    doDelete:function(component,event,currentRecord){
        var msg ='Are you sure you want to delete the selected item?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            component.set('v.spinner',true);
            component.set("v.currentRecordId",currentRecord);
            var action = component.get("c.deleteCustomSettings");
            // set the parameters to method 
            action.setParams({
                "cs":   currentRecord
            });
            // set a call back   
            action.setCallback(this, function(response) {
                var state = response.getState();
                var resp = response.getReturnValue();
                if (state === "SUCCESS") {     
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Message',
                        message:resp,
                        duration:' 2000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }                    
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown Error");
                    }
                }
                location.reload();
            });
            $A.enqueueAction(action);
        }
    },
    getEmailFields: function(component, event,currentRecord) {
        var action = component.get("c.getEmailFields");
        action.setParams({ recId : currentRecord });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // alert("From server: " + JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue() != null && response.getReturnValue() != '')
                {
                    component.set('v.emailWrapper',response.getReturnValue());
                    
                }else{
                    component.set('v.isEmailModalOpen',false);
                    component.set('v.changeEmailClass','slds-hide');
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
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
    },
    showInfoToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info Message',
            message: 'Mode is dismissible ,duration is 5sec and this is normal Message',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Mode is pester ,duration is 5sec and this is normal Message',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showErrorToast : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:message,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
  
})