({
    getObjectsNames : function(component,event) {
        component.set('v.spinner',true);
        var action = component.get("c.getSobjects");
        //action.setParams({ objectType : objType });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {     
                var sObj = [];
                var allValues = response.getReturnValue();
                // component.set('v.objectClass','slds-show')
                for(var key in allValues){
                    sObj.push({value:allValues[key], key:key}); //Here we are creating the list to show on UI.
                }
                component.set("v.objectList",sObj); 
                component.set('v.spinner',false);
            }                    
            else if (state === "ERROR") {
                component.set('v.spinner',false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else {
                    component.set('v.spinner',false);
                    console.log("Unknown Error");
                }
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecordTypes : function(component,event,selectedSobj){
        component.set('v.spinner',true);
        var action = component.get("c.getRecordTypesAndPageLayouts");
        action.setParams({ objectName : selectedSobj });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set('v.recordTypePageLayout',response.getReturnValue());
                var rp = component.get('v.recordTypePageLayout');
                var sObj = [];
                var allValues = rp.recordTypeMap;
                component.set('v.pageLayoutList',rp.pageLayouts);
                if(rp.isCustom == false){
                    component.set('v.allowEditClass','slds-hide');
                }else{
                    component.set('v.allowEditClass','slds-show');
                }
                //alert(rp.pageLayouts);
                if(allValues != null)
                {
                    for(var key in allValues){
                        sObj.push({value:allValues[key], key:key}); //Here we are creating the list to show on UI.
                    }
                    component.set("v.recordTypeList",sObj);
                }else{
                    component.set("v.recordTypeList",null);
                }
                component.set('v.spinner',false);
            }                    
            else if (state === "ERROR") {
                component.set('v.spinner',false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else {
                    component.set('v.spinner',false);
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },getEmailTemplates: function(component,event){
        var action = component.get("c.getEmailTemplates");
        //action.setParams({ objectName : selectedSobj });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {            
                var et = [];
                var allValues = response.getReturnValue();
                //(JSON.stringify(allValues));
                if(allValues != null)
                {
                    for(var key in allValues){
                        et.push({value:allValues[key], key:key});                            
                    }
                }
                component.set('v.EmailTemplateValueList',et);
                component.set('v.spinner',false);
            }                    
            else if (state === "ERROR") {
                component.set('v.spinner',false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else {
                    component.set('v.spinner',false);
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    showInfo : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info',
            message: 'This is an information message.',
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSuccess : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showError : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showWarning : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'This is a warning message.',
            duration:' 5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    },
})