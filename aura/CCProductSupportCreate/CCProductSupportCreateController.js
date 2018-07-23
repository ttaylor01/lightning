({
    doInit : function(component, event, helper) {
        // call the helper class to setup the case object for creation
        helper.getCase(component, event, helper);
        helper.getReasonPicklistValues(component, event, helper);
        helper.getPriorityPicklistValues(component, event, helper);
	},
    doSave : function(component, event, helper) {
        var isValid = helper.validateInput(component,helper);
        if(isValid) {
            // create case
            helper.saveCase(component, event, helper);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Please correct invalid input','error');
        }
    },
    doCancel : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "List",
            "listView": component.get('v.viewSelect')
        });
        compEvent.fire();
    },
    setVisibility : function(component, event, helper) {
        helper.toggleVisibility(component);
    },
    onReasonChange: function(component, event, helper) {
        // Handle change in field visibility
        helper.toggleVisibility(component);
    },
    // Handler for receiving the updateLookupIdEvent event
    handleContactIdUpdate : function(component, event, helper) {
        // Get the Id from the Event
        var fieldName = 'v.cs.' + event.getParam("fieldAPIName");
        var contactId = event.getParam("sObjectId");
        // Set the Id bound to the View
        component.set(fieldName, contactId);
    },
    // Handler for receiving the clearLookupIdEvent event
    handleContactIdClear : function(component, event, helper) {
        // Clear the Id bound to the View
        var fieldName = 'v.cs.' + event.getParam("fieldAPIName");
        component.set(fieldName, null);
    },
})