({
    doInit : function(component, event, helper) {
        component.set('v.spinner',true);
        if(component.get('v.fromPreview') == false)
        {
            component.set('v.recId',component.get('v.customFormSettings.Id'));
        }else{
            if(component.get('v.customFormSettings.Allow_File_Upload__c') == true){
                component.set('v.showFileTypes','slds-show');
            }else{
                component.set('v.showFileTypes','slds-hide');
            }
            var fileTypes = component.get('v.customFormSettings.Allowed_File_Types__c');
            component.find("fileTypes").set("v.value",fileTypes );
        }
        if( component.get('v.customFormSettings.Id') != null)
        {
            var fileTypes = component.get('v.customFormSettings.Allowed_File_Types__c');
            component.find("fileTypes").set("v.value",fileTypes );
            if(component.get('v.customFormSettings.Allow_File_Upload__c') == true){
                component.set('v.showFileTypes','slds-show');
            }else{
                component.set('v.showFileTypes','slds-hide');
            }
        }else{
            component.set('v.customFormSettings.Active__c',true);
            component.set('v.customFormSettings.Allow_read_after_submit__c',true);
        }
        helper.getObjectsNames(component, event);
        helper.getEmailTemplates(component,event);
        if(component.get('v.customFormSettings.Sobject__c') != null && component.get('v.customFormSettings.Sobject__c') != ''){
            component.set('v.pageLayoutList',null);
            component.set('v.spinner',true);
            var selectedSobj = component.get('v.customFormSettings.Sobject__c');
            helper.getRecordTypes(component,event,selectedSobj);
        }
    },
    navigateBack : function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:CreateCustomSettings"
            //You can pass attribute value from Component2 to Component1
            //componentAttributes :{ }
        });
        navigateEvent.fire();
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    getRecordType:function(component,event,helper){
        if(component.get('v.customFormSettings.Sobject__c') != null && component.get('v.customFormSettings.Sobject__c') != ''){
            component.set('v.pageLayoutList',null);
            component.set('v.spinner',true);
            var selectedSobj = component.get('v.customFormSettings.Sobject__c');
            helper.getRecordTypes(component,event,selectedSobj);
        }else{
             component.set('v.pageLayoutList',null);
             component.set("v.recordTypeList",null);
        }
    },
    getFileTypes : function(component,event,helper){
        if(event.getSource().get("v.value") == true){
            component.set('v.showFileTypes','slds-show');
        }else{
            component.set('v.showFileTypes','slds-hide');
        }
    },
    previewForm : function(component,event,helper){
        
        var fileTypes = component.find("fileTypes").get("v.value");
        component.set('v.customFormSettings.Allowed_File_Types__c',fileTypes);
        var allValid = component.find('csForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            component.set("v.preview",true);
            /*
            var navigateEvent = $A.get("e.force:navigateToComponent");
            navigateEvent.setParams({
                componentDef: "c:PreviewForm",
                //You can pass attribute value from Component1 to Component2
                componentAttributes :{ "customFormSettings":component.get('v.customFormSettings')}
            });
            navigateEvent.fire();*/
        } else {
            var message = 'Please Provide FormName, Sobject, PageLayout to preview the form ';
            helper.showError(component,event,message);
        }
    },
    closeModel : function(component,event,helper){
        component.set("v.preview",false);
    },
    editMode: function(component,event,helper){
        component.set('v.showEdit','slds-hide');
        component.set('v.spinner',true);
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:NewCustomSettings",
            componentAttributes :{ "customFormSettings":component.get('v.customFormSettings')}
        });
        navigateEvent.fire();
        component.set('v.spinner',false);
    },saveRecord: function(component, event, helper) {
        var customFormSettings = component.get('v.customFormSettings');
        var allValid = component.find('csForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) 
        {
            var fileTypes = component.find("fileTypes").get("v.value");
            component.set('v.customFormSettings.Allowed_File_Types__c',fileTypes);
            if(component.get('v.allowEditClass') == 'slds-hide'){
                component.set('v.customFormSettings.Allow_read_after_submit__c',false);
                component.set('v.customFormSettings.Allow_edit_after_submit__c',false);
            }
            /*if(customFormSettings.Id == null || customFormSettings.Id == ''){
                component.set('v.lookupModal',true);
                helper.getLookupfields(component,event,customFormSettings);
            }*/
            var action = component.get("c.saveGSSettings");
            action.setParams({
                cs: component.get('v.customFormSettings'),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
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
        }else{
            var message = 'Please Enter required fields';
            helper.showError(component,event,message);
        }
    },
    
    
})