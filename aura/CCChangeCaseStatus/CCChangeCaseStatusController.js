({
	doInit : function(component, event, helper) {
        console.log("[CCChangeCaseStatus.doInit] case: "+component.get("v.cs"));
        if(helper.validateComponent(component)) {
            // Make sure I have reference to actual sobject
        } else {
            helper.displayErrorDialog('IMPORTANT!','Missing Ticket Record ID.','error');
        }
	},
    doSave : function(component, event, helper) {
        var fields = ["comment"];
        var allValid = fields.reduce(function (validSoFar, inputField) {
            var inputCmp = component.find(inputField);
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (!allValid) {
            helper.displayErrorDialog('IMPORTANT!','Please enter valid values and try again.','error');
            return;
        }
        helper.saveCase(component, event, helper);
        helper.hideDialog(component, event);
    },
    doCancel : function(component, event, helper) {
        helper.hideDialog(component, event);
    },
})