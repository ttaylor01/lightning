({
	doInit : function(component, event, helper) {
        if(helper.validateComponent(component)) {
            // call the helper class to get list of cases
        } else {
            helper.displayErrorDialog('IMPORTANT!','Missing Ticket Record ID.','error');
            return;
        }

	},
    doSave : function(component, event, helper) {
        var contactId = component.get("v.recordId");
        if (typeof contactId === 'undefined' || contactId === null || contactId.length < 1) {
            helper.displayErrorDialog('IMPORTANT!','You must select a Contact.','error');
            return;
        }
        component.set("v.cs.ContactId",contactId);
        helper.saveCase(component, event, helper);
        helper.hideDialog(component, event);
    },
    doCancel : function(component, event, helper) {
        helper.hideDialog(component, event);
    },
    // Handler for receiving the updateLookupIdEvent event
    handleContactIdUpdate : function(component, event, helper) {
        // Get the Id from the Event
        var contactId = event.getParam("sObjectId");
        // Set the Id bound to the View
        component.set('v.recordId', contactId);
    },
    // Handler for receiving the clearLookupIdEvent event
    handleContactIdClear : function(component, event, helper) {
        // Clear the Id bound to the View
        component.set('v.recordId', null);
    },
})