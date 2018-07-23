({
    doInit : function(component, event, helper) {
        if( component.get("v.recordId") === undefined || component.get("v.recordId") === '') {
            // no case id, See if it is set in the URL parameter
            var oId = helper.getParameterByName(component, 'recordId', window.location.href);
            if (oId != null) {
                component.set("v.recordId", oId);
                var newUrl = helper.refreshUrl();
            }
        }
        // call the helper function
        helper.getPaymentMethods(component, event, helper);
        helper.getStatePicklistValues(component, event, helper);
    },
	backToAccount : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "accountDetail",
            "sObjectId": component.get("v.recordId")
        });   
        compEvent.fire();  
	},
    doDelete : function(component, event, helper) {
        var rowEl = event.currentTarget;
        var paymentMethodId = rowEl.getAttribute('data-pk');
        console.log("[CCBillingPaymentMethodController.doDelete] paymentMethodId: "+paymentMethodId);
        var doIt = confirm('Are you sure you want to delete this payment method? Note: this cannot be undone.');
        if(doIt) {
            helper.deletePaymentMethod(component, event, helper, paymentMethodId);
        }
    },
    doSave : function(component, event, helper) {
        // Get button name to determine payment type:  CreditCard or ACH
        var paymentMethodType= event.getSource().get("v.name");
        console.log("[CCBillingPaymentMethodController.doSave] paymentMethodType: "+paymentMethodType);
        var isValid = helper.validateInput(component, helper, paymentMethodType);
        if(isValid) {
            // Set type of payment method to save
            component.set("v.paymentMethodType",paymentMethodType);
            // Unhide the modal dialog
            $A.util.removeClass(component.find("taaModal"),'hide-modal');
        } else {
            helper.displayErrorDialog('IMPORTANT!','Please correct invalid input','error');
        }
    },
	cancelTermsAndAgreementDialog : function(component, event, helper) {
        console.log("[CCBillingPaymentMethodController.cancelTermsAndAgreementDialog] CANCEL TAA");
        $A.util.addClass(component.find("taaModal"),'hide-modal');
	},
	agreeToTermsAndAgreementDialog : function(component, event, helper) {
        console.log("[CCBillingPaymentMethodController.agreeToTermsAndAgreementDialog] AGREE TAA");
        $A.util.addClass(component.find("taaModal"),'hide-modal');
        var paymentMethodType= component.get("v.paymentMethodType");
        helper.savePaymentMethod(component, event, helper, paymentMethodType);
	},
    doCancel : function(component, event, helper) {
        // Clean up some input
        var paymentMethodType= event.getSource().get("v.name");
        console.log("[CCBillingPaymentMethodController.doCancel] paymentMethodType: "+paymentMethodType);
        helper.resetFields(component);
        if(paymentMethodType === 'CreditCard') {
            helper.toggleAddCreditCardMode(component);
        } else {
            helper.toggleAddACHMode(component);
        }
    },
    doCancelCC : function(component, event, helper) {
        // Clean up some input
        helper.resetFields(component);
        helper.toggleAddCreditCardMode(component);
    },
    doCancelACH : function(component, event, helper) {
        // Clean up some input
        helper.resetFields(component);
        helper.toggleAddACHMode(component);
    },
    doWait : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
    },
    stopWait : function(component, event, helper) {
        helper.hideSpinner(component, event, helper);
    },

    /*
     * Credit Card Logic
     */
    setAddCreditCardMode : function(component, event, helper) {
        helper.toggleAddCreditCardMode(component);
    },
    onCreditCardTypeChange : function(component, event, helper) {
        var selected = event.target.id;
        component.set("v.cc.creditCardType",selected);
        console.log("[CCBillingPaymentMethodController.onCreditCardTypeChange] selected: "+selected);
    },

    /*
     * ACH Logic
     */
    setAddACHMode : function(component, event, helper) {
        helper.toggleAddACHMode(component);
    },
    doContactSupport : function(component, event, helper) {
        var urlStr = "/billingsupport?recordId=new&billingAccountId="+component.get("v.recordId")+"&retUrl=%2Fbilling%3FrecordId%3D"+component.get("v.recordId");
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": urlStr
		});
		urlEvent.fire();
    },
    
})