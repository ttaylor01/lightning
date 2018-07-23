({
	doInit : function(component, event, helper) {
        if(helper.validateComponent(component)) {
            // call the helper class to get list of cases
//            console.log("[CCBillingAccountEditController.doInit] Billing Account: "+JSON.stringify(component.get('v.ba')));
            helper.setPaymentMethods(component, helper);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Missing Ticket Record ID.','error');
        }
	},
    doSave : function(component, event, helper) {
        var isValid = helper.validateInput(component,helper);
        if(isValid) {
            helper.saveAccount(component, event, helper);
            helper.hideDialog(component, event);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Please correct invalid input','error');
        }
    },
    doManagePaymentMethods : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "paymentMethods",
            "sObjectId": component.get("v.recordId")
        });   
        compEvent.fire();
    },
    onPaymentMethodChange : function(component, event, helper) {
        var selected = event.target.id;
        console.log("[CCBillingAccountEditController.onPaymentMethodChange] selected: "+selected);
        if(selected === "REMOVE") selected = "";
        component.set("v.ba.defaultPaymentMethodId",selected);
        console.log("[CCBillingAccountEditController.onPaymentMethodChange] defaultPaymentMethodId: "+component.get("v.ba.defaultPaymentMethodId"));
    },
    doCancel : function(component, event, helper) {
        helper.hideDialog(component, event);
    },
})