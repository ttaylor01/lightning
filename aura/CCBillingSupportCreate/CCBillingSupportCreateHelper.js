({
    getCase : function(component, event, helper) {
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCBillingSupportDetail",
                method: "getCase",
                input: { 
                    billingAccountId: component.get('v.billingAccountId')
                }
            },
	        pleaseWait: { type: "Spinner", message: "Finding ticket, please wait" },
            callBackMethod: function (response) {
                // If billingAccountId passed in and present, assume user does not need to populate
                // and hide/unhide input control as appropriate
                var billingAccountId = component.get('v.billingAccountId');
                if(billingAccountId === undefined || billingAccountId === '' || billingAccountId === null) {
                    component.set("v.billingAccountInputVisibility",true);
                }
                component.set("v.cs", response.output);
                component.set("v.whereClause","Zuora__Account__c = '"+response.output.AccountId+"'");
                // help IE out a little by setting empty field to non null blank value. 
                component.set("v.cs.Description", '');
                console.log("[CCBillingSupportCreateHelper.getCase] whereClause: "+component.get("v.whereClause"));
                console.log("[CCBillingSupportCreateHelper.getCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
            },
            callBackError: function (serverResponse, errorMsg) {
                var msg = 'We are experiencing system errors.  Please try again or contact customer service for assistance';
                helper.displayErrorDialog('IMPORTANT!',msg,'error');
            }
        });
    },
    saveCase : function(component, event, helper) {
        console.log("[CCBillingSupportCreateHelper.saveCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCBillingSupportDetail",
                method: "saveCase",
                records: [component.get('v.cs')]
            },
	        pleaseWait: { type: "Spinner", message: "Finding ticket, please wait" },
            callBackMethod: function (response) {
                // Woohoo.  Let's navigate to detail page
                var compEvent = component.getEvent("goToTarget");
                console.log("[CCBillingSupportCreateHelper.saveCase] Created case Id: "+response.output.Id);
                compEvent.setParams({
                    "sObjectId": response.output.Id,
                    "targetView": "Detail",
                    "listView": component.get('v.viewSelect')
                });
                compEvent.fire();
            },
            callBackError: function (serverResponse, errorMsg) {
                var msg = 'We are experiencing system errors.  Please try again or contact customer service for assistance';
                helper.displayErrorDialog('IMPORTANT!',msg,'error');
            }
        });
    },

    toggleVisibility : function(component) {
        this.resetVisibility(component);
    },
    resetVisibility : function(component) {
        // Reset all visibility sections
        component.set("v.otherVisibility",false);
    },
    resetFields : function(component) {
        // Reset All fields on Case
        component.set("v.cs.Subject",'');
        component.set("v.cs.Description",'');
    },
   
    validateInput : function(component, helper) {
        var allValid = true;

        if(component.get("v.billingAccountInputVisibility")) {
            var inputValue = component.get("v.cs.Billing_Account__c");
            var lookupCmp = component.find("lookupBillingAccountCmp");
            if(inputValue === undefined || inputValue === "" || inputValue === null) {
                // Display error message
                lookupCmp.setError('You must select a Billing Account');
                allValid = allValid && false;
            } else {
                lookupCmp.clearError();
                allValid = allValid && true;
            }
            console.log("validateInput BILLING ACCOUNT? "+allValid);
        }

        var subjectCmp = component.find('subject');
        subjectCmp.showHelpMessageIfInvalid();
        allValid = allValid && subjectCmp.get('v.validity').valid;
        var descCmp = component.find('description');
        descCmp.showHelpMessageIfInvalid();
        allValid = allValid && descCmp.get('v.validity').valid;
        console.log("validateInput allValid? "+allValid);
        return allValid;
    },
    isValidDate : function(dateString) {
        // First check for existence of value
        if(dateString === undefined || dateString === "") {
            return false;
        }
        // First check for the pattern: yyyy-mm-dd
//        if(!/^\d{1,2}\/\d{1,2}\/\d{4}$/.test(dateString)) {
        if(!/^\d{4}\-\d{1,2}\-\d{1,2}$/.test(dateString)) {
            return false;
        }
        
        // Parse the date parts to integers (format: yyyy-mm-dd)
        var parts = dateString.split("-");
        var year = parseInt(parts[0], 10);
        var month = parseInt(parts[1], 10);
        var day = parseInt(parts[2], 10);
        console.log("dateString parts: "+parts);
        
        // Check the ranges of month and year
        if(year < 1000 || year > 3000 || month == 0 || month > 12)
            return false;
        
        var monthLength = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];
        
        // Adjust for leap years
        if(year % 400 == 0 || (year % 100 != 0 && year % 4 == 0))
            monthLength[1] = 29;
        
        // Check the range of the day
        return day > 0 && day <= monthLength[month - 1];
    },
})