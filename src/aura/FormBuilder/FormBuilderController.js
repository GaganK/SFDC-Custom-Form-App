({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner',false);
        var action = component.get("c.getPageLayoutFields");
        action.setParams({
            customSettingsId: component.get('v.customsettingId'),
            guestFormId :component.get('v.guestFormId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(response.getReturnValue() == null){
                component.set('v.saveclass','slds-hide');
            }
            if (state === "SUCCESS") {
                var filetypes = [];
                component.set("v.layoutSections", response.getReturnValue() );
                var guestForm = component.get('v.layoutSections');
                component.set('v.guestForm',guestForm[0].guestFormList);
                if(guestForm[0].guestFormList.Status__c == 'Submitted' && guestForm[0].guestFormList.Parent__c != null){
                    component.set('v.attId',guestForm[0].guestFormList.Parent__c)
                }else{
                    component.set('v.attId',guestForm[0].guestFormList.Id);   
                }
                
                
                component.set('v.sObjectName',guestForm[0].guestFormList.Object_API_Name__c	);
                component.set('v.fileUpLoad',guestForm[0].guestFormList.Custom_Form_Settings__r.Allow_File_Upload__c);
                component.set('v.allowEdit',guestForm[0].guestFormList.Custom_Form_Settings__r.Allow_edit_after_submit__c);
                // alert(guestForm[0].guestFormList.ContentDocumentLink[0].ContentDocumentId);
                // component.set('v.formLogo',guestForm[0].guestFormList.ContentDocumentLink[0].ContentDocumentId);
                if(guestForm[0].guestFormList.Custom_Form_Settings__r.Allowed_File_Types__c != null){
                    filetypes = guestForm[0].guestFormList.Custom_Form_Settings__r.Allowed_File_Types__c.split(';'); 
                }
                //alert(filetypes[0]);
                component.set('v.fileExtension',filetypes);
                
                if(guestForm[0].guestFormList.Parent__c != null){
                    component.set('v.currentRecordId',guestForm[0].guestFormList.Parent__c);
                }
                if(guestForm[0].guestFormList.Status__c == 'Submitted' && guestForm[0].guestFormList.Custom_Form_Settings__r.Allow_read_after_submit__c == false){
                    alert('You dont have permission to read record');
                    location.reload();
                    window.close();
                }
                // alert(guestForm[0].guestFormList.Custom_Form_Settings__r.Allow_edit_after_submit__c);
                console.log('mine'+JSON.stringify(response.getReturnValue()[0].lstFields));
                console.log('mine'+JSON.stringify(response.getReturnValue()));
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log(errors);
                }
        });
        $A.enqueueAction(action);
    },
    handleLoad : function(component, event, helper) {
    },
    handleSubmit : function(component, event, helper) {
        var guestForm = component.get('v.guestForm');
        if(guestForm.Custom_Form_Settings__r.Record_Type__c != null)
        {
            event.preventDefault(); // stop form submission
            var eventFields = event.getParam("fields");
            eventFields['RecordTypeId'] = guestForm.Custom_Form_Settings__r.Record_Type__c;
            component.find('myform').submit(eventFields);
        }
        if(component.get('v.allowEdit') == false && guestForm.Status__c == 'Submitted'){
            alert('Cannot Edit')
            event.preventDefault();
        }
    },
    handleSuccess : function(component, event, helper) {
        
        var payload = event.getParams().response;
        if(payload.id != null) {
            component.set('v.parentId',payload.id);
            var action = component.get("c.updateGuestForm");
            action.setParams({
                guestForm: component.get('v.guestForm'),
                parentId :payload.id,
                attachId : component.get('v.attachId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                //  alert(''+response.getReturnValue())
                if (state === "SUCCESS") {
                    component.set("v.isOpen", true);
                }
                else if (state === "INCOMPLETE") {
                    var errors = response.getError();
                    alert(errors);
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        alert(errors);
                    }
            });
            
            $A.enqueueAction(action);
        }
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var filetype;
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            filetype = fileName.split('.').pop();
            component.set('v.filetype',filetype);
        }
        component.set("v.fileName", fileName);
    },
    doSave: function(component, event, helper) {
        var fileextension = component.get('v.fileExtension');
        
        if(component.find("fileId").get("v.files") != null && component.get('v.fileName') != null && component.get('v.fileName') != ''){
            var fileType = component.get('v.filetype');
            if(fileextension.length == 0 || fileextension.includes(fileType.toString().toUpperCase())){
                helper.uploadHelper(component, event);
            }
            else{
                alert('only ' +component.get('v.fileExtension') +' are allowed' );
            }
        }
        else{
            alert('Please Select a valid file');
            component.set("v.fileName",null);
        }
    },
    loadPage: function(component, event, helper) {
        location.reload();
        window.close();
    },
    cancelFile : function(component, event, helper) {
        component.set("v.fileName",null);
    },  
   
    
})