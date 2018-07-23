({
	doInit : function(component, event, helper) {
        if(helper.validateComponent(component)) {
            // call the helper class to get list of cases
            component.set("v.billingContact.state","Florida");
//            console.log("[CCBillingContactEditController.doInit] billingContact: "+JSON.stringify(component.get('v.billingContact')));
            helper.getStatePicklistValues(component, event, helper);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Missing Ticket Record ID.','error');
        }
	},
    setBillingContact : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('[CCBillingContactEditController.setBillingContact] : billingContact'+ JSON.stringify(params.billingContact));
        component.set("v.billingContact",params.billingContact);
    },
    doSave : function(component, event, helper) {
        var fields = ["billingContactFirstName","billingContactLastName","billingContactEmail","billingContactPhone"];
        var isValid = helper.validateContactInput(component,helper,fields);
        if(isValid) {
            helper.saveContact(component, event, helper);
            helper.hideDialog(component, event);
        }
    },
    doCancel : function(component, event, helper) {
        helper.hideDialog(component, event);
    },
})