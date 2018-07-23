({
	doInit : function(component, event, helper) {
        if(helper.validateComponent(component)) {
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
        var fld = "v.cs." + component.get('v.sObjectFieldAPIName');
        component.set(fld,contactId);
        helper.saveCase(component, event, helper);
        helper.hideDialog(component, event);
    },
    doDelete : function(component, event, helper) {
        component.set('v.recordId', null);
        var contactId = component.get("v.recordId");
        var fld = "v.cs." + component.get('v.sObjectFieldAPIName');
        component.set(fld,contactId);
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