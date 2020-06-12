({
        doInit: function(component, event, helper) {
            if(component.get('v.recordId') != null){
                var recordId = component.get('v.recordId');
                    component.set('v.contactSendForm',true);
                component.set('v.changeEmailClass','slds-show');
                helper.getEmailFields(component,event,recordId);
                component.set('v.isEmailModalOpen',true);
            }
            component.set('v.spinner',true);
            // this function call on the component load first time     
            // get the page Number if it's not define, take 1 as default
            var page = component.get("v.page") || 1;
            // get the select option (drop-down) values.   
            var recordToDisply = component.find("recordSize").get("v.value");
            var formsettingStatus = component.find("formSettingsFilter").get("v.value");
            //alert(formsettingStatus);
            // call the helper function   
            helper.getCustomSettings(component, page, recordToDisply,formsettingStatus);
        },
        
        navigate: function(component, event, helper) {
            // this function call on click on the previous page button  
            var page = component.get("v.page") || 1;
            // get the previous button label  
            var direction = event.getSource().get("v.label");
            // get the select option (drop-down) values.  
            var recordToDisply = component.find("recordSize").get("v.value");
            var formsettingStatus = component.find("formSettingsFilter").get("v.value");
            // set the current page,(using ternary operator.)  
            page = direction === "Previous Page" ? (page - 1) : (page + 1);
            // call the helper function
            helper.getCustomSettings(component, page, recordToDisply,formsettingStatus);
        },
        
        onSelectChange: function(component, event, helper) {
            // this function call on the select opetion change,	 
            var page = 1
            var recordToDisply = component.find("recordSize").get("v.value");
            var formsettingStatus = component.find("formSettingsFilter").get("v.value");
            helper.getCustomSettings(component, page, recordToDisply,formsettingStatus);
        },
        
        editrecord : function(component,event,helper) {
            component.set('v.spinner',true);
            var currentRecordId = event.getSource().get("v.value");
            component.set("v.currentRecordId",currentRecordId);
            var navigateEvent = $A.get("e.force:navigateToComponent");
            navigateEvent.setParams({
                componentDef: "c:NewCustomSettings",
                //You can pass attribute value from Component1 to Component2
                componentAttributes :{ "customFormSettings":currentRecordId}
            });
            navigateEvent.fire();
            component.set('v.spinner',false);
        },
        cancel: function(component, event, helper) {
            location.reload();
        },
        createCustomSettings: function(component, event, helper) {
            var navigateEvent = $A.get("e.force:navigateToComponent");
            navigateEvent.setParams({
                componentDef: "c:NewCustomSettings"
                //You can pass attribute value from Component1 to Component2
                //componentAttributes :{ }
            });
            navigateEvent.fire();
            // component.set('v.isOpen',true);
        },
        //Select all contacts
        handleSelectAllContact: function(component, event, helper) {
            var getID = component.get("v.customForm");
            var checkvalue = component.find("selectAll").get("v.value");        
            var checkContact = component.find("checkContact"); 
            if(checkvalue == true){
                for(var i=0; i<checkContact.length; i++){
                    checkContact[i].set("v.value",true);
                }
            }
            else{ 
                for(var i=0; i<checkContact.length; i++){
                    checkContact[i].set("v.value",false);
                }
            }
        },
        
        //Process the selected contacts
        handleSelectedSettings: function(component, event, helper) {
            component.set('v.spinner',true);
            var selectedsettings = [];
            var checkvalue = component.find("checkContact");
            if(!Array.isArray(checkvalue)){
                if (checkvalue.get("v.value") == true) {
                    selectedsettings.push(checkvalue.get("v.text"));
                }
            }else{
                for (var i = 0; i < checkvalue.length; i++) {
                    if (checkvalue[i].get("v.value") == true) {
                        selectedsettings.push(checkvalue[i].get("v.text"));
                    }
                }
            }
            if(selectedsettings.length > 0 && (component.get('v.toEmail') != null)){
                var email;
                var parentRId;
                email = component.get('v.toEmail');
                /*if(component.get('v.toEmail') != null){
                    email = component.get('v.toEmail');
                }else if(component.get('v.parentRecord.Email') != null){
                    email = component.get('v.parentRecord.Email');
                    parentRId = component.get('v.parentRecord.Id');
                }*/
                var action = component.get("c.sendEmail");
                // set the parameters to method 
                action.setParams({
                    "csList": selectedsettings,
                    "toEmail": email,
                    "parentRId":component.get('v.recordId')
                });
                // set a call back   
                action.setCallback(this, function(a) {
                    // store the response return value (wrapper class insatance)  
                    var result = a.getReturnValue();
                    console.log('result ---->' + JSON.stringify(result));
                    if(result == 'Email Sent Successfully!!'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Email Sent Successfully',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: result,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                });
                // enqueue the action 
                $A.enqueueAction(action);
                component.set('v.spinner',false);
            }
            else if(component.get('v.toEmail') == null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Please Enter your Email',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                component.set('v.spinner',false);
            }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Please select atleast one form',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set('v.spinner',false);
                }
            //alert('selectedsettings-' + selectedsettings);
        },
        openRelatedList: function(component, event, helper) {
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
            relatedListEvent.setParams({
                "relatedListId": "GuestForms1__r",
                "parentRecordId": event.getSource().get("v.value")
            });
            relatedListEvent.fire();
        },
       
        handleSelect:function(component,event,helper){
            var currentRecord = event.detail.menuItem.get("v.value");
            var menuValue = event.detail.menuItem.get("v.accesskey");
            switch(menuValue) {
                case "1": helper.doEdit(component, event,currentRecord ); 
                    break;
                case "2": helper.doview(component, event, currentRecord); 
                    break;
                case "3": helper.doDelete(component, event, currentRecord); 
                    break;
            }   
            
        },closeModel: function(component, event, helper) {
            component.set("v.contactTableModal", false);
            // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
            component.set("v.isOpen", false);
            component.set("v.isEmailModalOpen", false);
        },
        
        submitDetails: function(component, event, helper) {
            if(!component.get("v.manualEmailEntry")){
                var selectedEmails = [];
                var emailId = component.find("emailId");
                
                if(!Array.isArray(emailId)){
                    if (emailId.get("v.value") == true) {
                        selectedEmails.push(emailId.get("v.text"));
                    }
                }else{
                    for (var i = 0; i < emailId.length; i++) {
                        if (emailId[i].get("v.value") == true) {
                            selectedEmails.push(emailId[i].get("v.text"));
                        }
                    }
                }
                var toEmails;
                for(var i =0;i<selectedEmails.length;i++){
                    if(toEmails == null){
                        toEmails = selectedEmails[i];
                    }else{
                        toEmails = toEmails+';'+selectedEmails[i];
                    }
                }
                component.set('v.toEmail',toEmails);
                if(toEmails != null)
                {
                    component.set('v.toEmailDisabled',true);
                }
            }
            else{
                component.set('v.toEmailDisabled',false);
            }
            component.set("v.isEmailModalOpen", false);
        },
        onSelectManualEntry:function(component,event,helper){
            var checkCmp = component.find("manualEmailEntry").get("v.value");
            if(checkCmp == true){
                component.set('v.disableCheckBox',true);
                var deSelect = component.find("emailId");
                for (var i = 0; i < deSelect.length; i++){
                    deSelect[i].set("v.value",false);
                }
            }else{
                component.set('v.disableCheckBox',false);
            }
        },
        enableManualEmailEntry:function(component,event,helper){
            component.set("v.isEmailModalOpen", true);
            component.set("v.toEmailDisabled",false);
            var checkCmp = component.find("manualEmailEntry").get("v.value");
            if(checkCmp == true){
                component.set('v.disableCheckBox',true);
                var deSelect = component.find("emailId");
                for (var i = 0; i < deSelect.length; i++){
                    deSelect[i].set("v.value",false);
                }
            }else{
                component.set('v.disableCheckBox',false);
            }
        },
      
    })