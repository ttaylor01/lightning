({
    doInit : function(component, event, helper) {
        // call the helper class to setup the case object for creation
        helper.getCase(component, event, helper);
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
        // Determine if return URL was passed.  If so return to calling page
        // else navigate back to list
        var retUrl = component.get('v.retUrl');
        if(retUrl === undefined || retUrl === '' || retUrl === null) {
            // If NO return URL was passed, return to default list
            var compEvent = component.getEvent("goToTarget");
            compEvent.setParams({
                "targetView": "List",
                "listView": component.get('v.viewSelect')
            });
            compEvent.fire();
        } else {
            // Else return to calling page url
            var urlStr = retUrl;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": urlStr
            });
            urlEvent.fire();
        }
    },
    setVisibility : function(component, event, helper) {
        helper.toggleVisibility(component);
    },
    onReasonChange: function(component, event, helper) {
        // Handle change in field visibility
        helper.toggleVisibility(component);
    },
    // Handler for receiving the updateLookupIdEvent event
    handleLookupIdUpdate : function(component, event, helper) {
        // Get the Id from the Event
        var fieldName = 'v.cs.' + event.getParam("fieldAPIName");
        var objId = event.getParam("sObjectId");
        // Set the Id bound to the View
        component.set(fieldName, objId);
    },
    // Handler for receiving the clearLookupIdEvent event
    handleLookupIdClear : function(component, event, helper) {
        // Clear the Id bound to the View
        var fieldName = 'v.cs.' + event.getParam("fieldAPIName");
        component.set(fieldName, null);
    },
})