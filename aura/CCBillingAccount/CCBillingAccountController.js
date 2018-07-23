({
	doInit : function(component, event, helper) {
        /*
         *  force:navigateToComponent not supported in Communities yet.
		 *  Had to use force:navigateToURL passing in parameter value
		 *  So we will get the parameter from the URL by calling a common function in CCDataComponent
         */
        if( component.get("v.recordId") === undefined || component.get("v.recordId") === '') {
            // no case id, See if it is set in the URL parameter
            var oId = helper.getParameterByName(component, 'recordId', window.location.href);
            if (oId != null) {
                component.set("v.recordId", oId);
                var newUrl = helper.refreshUrl();
                console.log("[CCBillingAccountController.doInit] replaced URL: "+window.location.href);
            }
        }
        helper.getAccount(component, event, helper);
        helper.getStatePicklistValues(component, event, helper);
	},
    doManagePaymentMethods : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "paymentMethods",
            "sObjectId": component.get("v.recordId")
        });   
        compEvent.fire();  
    },
    doManageBilling : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "manageBilling",
            "sObjectId": component.get("v.recordId")
        });   
        compEvent.fire();  
    },
    doSelectAccount : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "accountSelect"
        });   
        compEvent.fire();  
    },
    doSave : function(component, event, helper) {
        var isValid = helper.validateInput(component,helper);
        if(isValid) {
            helper.saveAccount(component, event, helper);
            helper.toggleEditMode(component);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Please correct invalid input','error');
        }
    },
    setEditMode : function(component, event, helper) {
        helper.toggleEditMode(component);
    },
    doCancel : function(component, event, helper) {
        // reset values from dirty input
        helper.getAccount(component, event, helper);
        helper.toggleEditMode(component);
    },
    onPaymentMethodChange : function(component, event, helper) {
        var selected = event.target.value;
        console.log("[CCBillingAccountController.onPaymentMethodChange] selected: "+selected);
        if(selected === "REMOVE") selected = "";
        component.set("v.ba.defaultPaymentMethodId",selected);
        console.log("[CCBillingAccountController.onPaymentMethodChange] defaultPaymentMethodId: "+component.get("v.ba.defaultPaymentMethodId"));
    },

    doWait : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
    },
    stopWait : function(component, event, helper) {
        helper.hideSpinner(component, event, helper);
    },
    /*
     * ALL Contact Logic Follows
     */
    doSaveBTContact : function(component, event, helper) {
        var fields = ["billToContactFirstName","billToContactLastName","billToContactEmail","billToContactPhone"];
        var isValid = helper.validateContactInput(component,helper,fields);
        if(isValid) {
            helper.saveBTContact(component, event, helper);
            helper.toggleEditModeBTContact(component);
        }
    },
    setEditBTContact : function(component, event, helper) {
        helper.toggleEditModeBTContact(component);
    },
    doCancelBTContact : function(component, event, helper) {
        // reset values from dirty input
        helper.getAccount(component, event, helper);
        helper.toggleEditModeBTContact(component);
    },
    doSaveSTContact : function(component, event, helper) {
        var fields = ["soldToContactFirstName","soldToContactLastName","soldToContactEmail","soldToContactPhone"];
        var isValid = helper.validateContactInput(component,helper,fields);
        if(isValid) {
            helper.saveSTContact(component, event, helper);
            helper.toggleEditModeSTContact(component);
        }
    },
    setEditSTContact : function(component, event, helper) {
        helper.toggleEditModeSTContact(component);
    },
    doCancelSTContact : function(component, event, helper) {
        // reset values from dirty input
        helper.getAccount(component, event, helper);
        helper.toggleEditModeSTContact(component);
    },
})