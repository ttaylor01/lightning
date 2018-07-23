({
    doInit : function(component, event, helper) {
        // call the helper class to setup the case object for creation
        helper.getCase(component, event, helper);
//        helper.getTypePicklistValues(component, event, helper);
        helper.getRequestorPriorityPicklistValues(component, event, helper);
        helper.getTransactionPicklistValues(component, event, helper);
        helper.getControlledDeploymentRequestPicklistValues(component, event, helper);
        helper.getReleaseCommunicationRequiredPicklistValues(component, event, helper);
//        helper.getRegionPicklistValues(component, event, helper);
//        helper.getSystemsImpactedPicklistValues(component, event, helper);
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
    // function call on change tha Dependent field
    onTransactionChange : function(component, event,helper) {
        var tranCmp = component.find('transaction');
        var tranValue = tranCmp.get("v.value");
        var otherTranCmp = component.find('othertransaction');
        if(tranValue === "Other") {
            component.set("v.otherTransactionVisibility",true);
            otherTranCmp.set("v.required",true);
        } else {
            component.set("v.otherTransactionVisibility",false);
            otherTranCmp.set("v.required",false);
            component.set("v.cs.Other_Transaction__c",'');
            $A.util.removeClass(otherTranCmp, "slds-has-error"); // remove red border
            $A.util.addClass(otherTranCmp, "hide-error-message"); // hide error message
        }
    },
    onSpecialReportingChange : function(component, event,helper) {
        var reportingneeds = component.find('reportingneeds');
        if(component.find('specialreporting').get('v.checked')) {
            component.set("v.reportingneedsVisibility",true);
        } else {
            component.set('v.reportingneedsVisibility',false);
            component.set("v.cs.Special_Reporting_Needs__c",'');
        }
    },
    onCRFormAttachedChange : function(component,event,helper) {
        if(component.find('crformattached').get('v.checked')) {
            component.set("v.crformattachedVisibility",true);
        } else {
            component.set('v.crformattachedVisibility',false);
            component.set("v.cs.Attachment__c",'');
        }
    },
    validateRequestedProdDate : function(component, event, helper) {
        var inputCmp = component.find('requestedproductiondate');
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
        } else {
            $A.util.addClass(inputCmp, "slds-has-error"); // add red border
            inputCmp.set("v.errors", [{message:"You must enter a valid Requested Production Date at least 90 days from today"}]);
        }
    },

})