({
    getCase : function(component, event, helper) {
        // Display all cases for selected status
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.getCase",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                // For some reason you have to set individual fields because setting the whole case
                // causes an 'Unable to read sObject' error when passing the case to apex controller upon save
                component.set("v.cs.RecordTypeId",response.RecordTypeId);
                component.set("v.cs.Contact",response.Contact);
                component.set("v.cs.CID_Identifier__c",response.CID_Identifier__c);
                component.set("v.cs.Type",'Payer Request');
                component.set("v.cs.Requestor_Priority__c",'Major');
                component.set("v.cs.Health_Plan__c",response.Health_Plan__c);
                component.set("v.cs.Status",'New');
                component.set("v.cs.SOW_Required__c",'Yes');
                console.log("[CCChangeRequestCreateHelper.getCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
            }
        },
        {
        });
    },
    saveCase : function(component, event, helper) {
        helper.showSpinner(component, event, helper);

        // Obtain multi select picklist values from custom component
        var selectCmp = component.find('regionCmp');
        var selectedOpt = selectCmp.getSelectedValues();
        console.log("[CCChangeRequestCreateHelper.saveCase] regions: "+selectedOpt);
        component.set('v.cs.Region__c',selectedOpt);
        selectCmp = component.find('systemsimpactedCmp');
        selectedOpt = selectCmp.getSelectedValues();
        console.log("[CCChangeRequestCreateHelper.saveCase] systems impacted: "+selectedOpt);
        component.set('v.cs.System_Impacted__c',selectedOpt);

        console.log("[CCChangeRequestCreateHelper.saveCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
        var caseObj = component.get('v.cs');
        // To help ensure we don't get the dreaded 'Unable to read sObject', set the sobjectType
        caseObj.sobjectType = 'Case';
        helper.callServer(component,"c.saveCase",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                // Woohoo.  Let's navigate to detail page
                var compEvent = component.getEvent("goToTarget");
                console.log("[CCChangeRequestCreateHelper.saveCase] Created case Id: "+response.Id);
                compEvent.setParams({
                    "sObjectId": response.Id,
                    "targetView": "Detail",
                    "listView": component.get('v.viewSelect')
                });
                compEvent.fire();
            }
        },
        {
            'cs': caseObj
        });
    },

    toggleVisibility : function(component) {
        this.resetVisibility(component);
/*
        if(component.get("v.cs.Call_Reason__c") === "" || component.get("v.cs.Call_Reason__c") === "--- None ---") {
            this.resetFields(component);
        }
        if(component.get("v.cs.Call_Reason__c") === "Other") {
            component.set("v.otherVisibility",true);
        } else {
            this.resetFields(component);
        }
*/
    },
    resetVisibility : function(component) {
        // Reset all visibility sections
//        component.set("v.otherVisibility",false);
    },
    resetFields : function(component) {
        // Reset All fields on Case
        component.set("v.cs.Transaction__c",'');
        component.set("v.cs.Other_Transaction__c",'');
    },
   
    validateInput : function(component, helper) {
        var allValid = true;
        var inputCmp = component.find("requestorpriority");
        var inputValue = inputCmp.get("v.value");
        if(inputValue === undefined || inputValue === "" || inputValue === "-- None --") {
            inputCmp.set("v.errors", [{message:"Please select a Requested Priority"}]);
            allValid = allValid && false;
        } else {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        }

        inputCmp = component.find('requestedproductiondate');
        var inputValue = inputCmp.get("v.value");
        console.log("requestedproductiondate: "+inputValue);
        var validDate = true;
        if(helper.isValidDate(inputValue)) {
            // now check if more than 90 days in future
            var NinetyDaysAway = new Date(+new Date + (89 * 24 * 60 * 60 * 1000));
            if(new Date(inputValue) <= NinetyDaysAway) {
                validDate = false;
            }
        } else {
            validDate = false;
        }
        if(validDate) {
            inputCmp.set("v.errors", null);
            $A.util.removeClass(inputCmp, "slds-has-error"); // remove red border
            allValid = allValid && true;
        } else {
            $A.util.addClass(inputCmp, "slds-has-error"); // add red border
            inputCmp.set("v.errors", [{message:"You must enter a valid Requested Production Date at least 90 days from today"}]);
            allValid = allValid && false;
        }

        inputCmp = component.find('regionCmp');
        if(inputCmp.validateInput()) {
            allValid = allValid && true;
            console.log("REGION IS valid");
        } else {
            allValid = allValid && false;
            console.log("REGION NOT valid");
        }

        if(component.get("v.reportingneedsVisibility")) {
            var reportingneedsCmp = component.find('reportingneeds');
            if(component.find('specialreporting').get('v.checked')) {
                reportingneedsCmp.showHelpMessageIfInvalid();
                console.log("reportingneeds valid? "+reportingneedsCmp.get('v.validity').valid);
            } else {
                $A.util.removeClass(reportingneedsCmp, "slds-has-error"); // remove red border
                $A.util.addClass(reportingneedsCmp, "hide-error-message"); // hide error message
            }
            allValid = allValid && reportingneedsCmp.get('v.validity').valid;
        }

        inputCmp = component.find('systemsimpactedCmp');
        if(inputCmp.validateInput()) {
            allValid = allValid && true;
            console.log("Systems Impacted IS valid");
        } else {
            allValid = allValid && false;
            console.log("Systems Impacted NOT valid");
        }

        inputCmp = component.find("transaction");
        inputValue = inputCmp.get("v.value");
        if(inputValue === undefined || inputValue === "" || inputValue === "-- None --") {
            inputCmp.set("v.errors", [{message:"Please select a Transaction"}]);
            allValid = allValid && false;
        } else {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
            if(inputValue === "Other") {
                var otherTranCmp = component.find('othertransaction');
                otherTranCmp.showHelpMessageIfInvalid();
                allValid = allValid && otherTranCmp.get('v.validity').valid;
            }
        }

        inputCmp = component.find('justification');
        inputCmp.showHelpMessageIfInvalid();
        allValid = allValid && inputCmp.get('v.validity').valid;

        var subjectCmp = component.find('subject');
        subjectCmp.showHelpMessageIfInvalid();
        allValid = allValid && subjectCmp.get('v.validity').valid;
        var descCmp = component.find('description');
        descCmp.showHelpMessageIfInvalid();
        allValid = allValid && descCmp.get('v.validity').valid;
        console.log("validateInput allValid? "+allValid);
        return allValid;
    },
/*
    getTypePicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "-- None --",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "ACS Submitted Registrations",value: "ACS Submitted Registrations"});
        picklistValues.push({class: "optionClass",label: "Advanced Clearinghouse",value: "Advanced Clearinghouse"});
        picklistValues.push({class: "optionClass",label: "Bug",value: "Bug"});
        picklistValues.push({class: "optionClass",label: "Heads Up",value: "Heads Up"});
        picklistValues.push({class: "optionClass",label: "Implementations",value: "Implementations"});
        picklistValues.push({class: "optionClass",label: "Payer Request",value: "Payer Request"});
        picklistValues.push({class: "optionClass",label: "Provider Request",value: "Provider Request"});
        picklistValues.push({class: "optionClass",label: "Technology Request",value: "Technology Request"});
        picklistValues.push({class: "optionClass",label: "Vendor Request",value: "Vendor Request"});
        picklistValues.push({class: "optionClass",label: "Voice of the Customer",value: "Voice of the Customer"});
        component.find("type").set("v.options", picklistValues);
    },
*/
    getTransactionPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "-- None --",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "270/271",value: "270/271"});
        picklistValues.push({class: "optionClass",label: "276/277",value: "276/277"});
        picklistValues.push({class: "optionClass",label: "278",value: "278"});
        picklistValues.push({class: "optionClass",label: "835",value: "835"});
        picklistValues.push({class: "optionClass",label: "837",value: "837"});
        picklistValues.push({class: "optionClass",label: "ACE",value: "ACE"});
        picklistValues.push({class: "optionClass",label: "ADT",value: "ADT"});
        picklistValues.push({class: "optionClass",label: "API",value: "API"});
        picklistValues.push({class: "optionClass",label: "Auto Auth",value: "Auto Auth"});
        picklistValues.push({class: "optionClass",label: "HL7",value: "HL7"});
        picklistValues.push({class: "optionClass",label: "Other",value: "Other"});
        picklistValues.push({class: "optionClass",label: "Payer Spaces",value: "Payer Spaces"});
        picklistValues.push({class: "optionClass",label: "PDM",value: "PDM"});
        picklistValues.push({class: "optionClass",label: "RPM",value: "RPM"});
        picklistValues.push({class: "optionClass",label: "SAS",value: "SAS"});
        component.find("transaction").set("v.options", picklistValues);
    },
    getRequestorPriorityPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "-- None --",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "Critical",value: "Critical"});
        picklistValues.push({class: "optionClass",label: "Major",value: "Major"});
        picklistValues.push({class: "optionClass",label: "Minor",value: "Minor"});
        component.find("requestorpriority").set("v.options", picklistValues);
    },
    getControlledDeploymentRequestPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "-- None --",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "Yes",value: "Yes"});
        picklistValues.push({class: "optionClass",label: "No",value: "No"});
        component.find("controlleddeploymentrequest").set("v.options", picklistValues);
    },
    getReleaseCommunicationRequiredPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "-- None --",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "Yes",value: "Yes"});
        picklistValues.push({class: "optionClass",label: "No",value: "No"});
        component.find("releasecommunicationrequired").set("v.options", picklistValues);
    },
/*
    getRegionPicklistValues : function(component, event, helper) {
        helper.callServer(component,"c.getRegions",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                var picklistValues = []; // for store picklist values to set on ui field.
                for(var i=0; i<response.length; i++) {
                    picklistValues.push({
                        class: "optionClass",
                        label: response[i],
                        value: response[i]
                    });
                }
                component.find("region").set("v.options", picklistValues);
            }
        },
        {
        });
    },
    getSystemsImpactedPicklistValues : function(component, event, helper) {
        helper.callServer(component,"c.getSystemsImpacted",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                var picklistValues = []; // for store picklist values to set on ui field.
                for(var i=0; i<response.length; i++) {
                    picklistValues.push({
                        class: "optionClass",
                        label: response[i],
                        value: response[i]
                    });
                }
                component.find("systemsimpacted").set("v.options", picklistValues);
            }
        },
        {
        });
    },
*/

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