({
    getCase : function(component, event, helper) {
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCCaseEdit",
                method: "getCase"
            },
	        pleaseWait: { type: "Spinner", message: "Finding ticket, please wait" },
            callBackMethod: function (response) {
                component.set("v.cs", response.output);
                component.set("v.cs.Call_Reason__c",component.get("v.productSelect"));
                console.log("[CCProviderSupportCreateHelper.getCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
            },
            callBackError: function (serverResponse, errorMsg) {
                var msg = 'We are experiencing system errors.  Please try again or contact customer service for assistance';
                helper.displayErrorDialog('IMPORTANT!',msg,'error');
            }
        });
    },
    saveCase : function(component, event, helper) {
        console.log("[CCProviderSupportCreateHelper.saveCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCCaseEdit",
                method: "saveCase",
                records: [component.get('v.cs')]
            },
	        pleaseWait: { type: "Spinner", message: "Finding ticket, please wait" },
            callBackMethod: function (response) {
                // Woohoo.  Let's navigate to detail page
                var compEvent = component.getEvent("goToTarget");
                console.log("[CCProviderSupportCreateHelper.saveCase] Created case Id: "+response.output.Id);
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
        if(component.get("v.cs.Call_Reason__c") === "" || component.get("v.cs.Call_Reason__c") === "--- None ---") {
            this.resetFields(component);
        }
        if(component.get("v.cs.Call_Reason__c") === "Other") {
            component.set("v.otherVisibility",true);
        } else {
            this.resetFields(component);
        }
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
        var inputCmp = component.find("reason");
        var inputValue = inputCmp.get("v.value");
        if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
            inputCmp.set("v.errors", [{message:"Please select a Product"}]);
            allValid = allValid && false;
        } else {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        }
        console.log("validateInput REASON? "+allValid);
/*
        inputCmp = component.find("priority");
        inputValue = inputCmp.get("v.value");
        if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
            inputCmp.set("v.errors", [{message:"Please select a Priority"}]);
            allValid = allValid && false;
        } else {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        }
        console.log("validateInput PRIORITY? "+allValid);
*/
        var subjectCmp = component.find('subject');
        subjectCmp.showHelpMessageIfInvalid();
        allValid = allValid && subjectCmp.get('v.validity').valid;
        var descCmp = component.find('description');
        descCmp.showHelpMessageIfInvalid();
        allValid = allValid && descCmp.get('v.validity').valid;
        console.log("validateInput allValid? "+allValid);
        return allValid;
    },
    getReasonPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "--- None ---",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "Patient Access",value: "Patient Access"});
        picklistValues.push({class: "optionClass",label: "Provider Authorization",value: "Provider Authorization"});
        component.find("reason").set("v.options", picklistValues);
    },
    getPriorityPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "--- None ---",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "High",value: "High"});
        picklistValues.push({class: "optionClass",label: "Medium",value: "Medium"});
        picklistValues.push({class: "optionClass",label: "Low",value: "Low"});
        component.find("priority").set("v.options", picklistValues);
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