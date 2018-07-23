({
    saveCase : function(component, event, helper) {
        // Display all cases for selected status
        console.log("[CCAlternateContact.saveCase] case: "+JSON.stringify(component.get('v.cs')));

        var apexBridge = component.find("AltApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCCaseEdit",
                method: "saveCase",
                records: [component.get('v.cs')]
            },
	        pleaseWait: { type: "None" },
            callBackMethod: function (response) {
                component.set("v.cs", response.output);
            },
            callBackError: function (serverResponse, errorMsg) {
                var msg = 'We are experiencing system errors.  Please try again or contact customer service for assistance';
                helper.displayErrorDialog('IMPORTANT!',msg,'error');
            }
        });
    },
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.cs") !== undefined && component.get("v.cs") !== '');
        }
        return valid;
    },
    hideDialog : function(component, event) {
        var compEvent = component.getEvent("hideChangeContactDialog");
        compEvent.setParams({
            recordId: component.get('v.cs.Id')
        });   
        compEvent.fire();  
    },
})