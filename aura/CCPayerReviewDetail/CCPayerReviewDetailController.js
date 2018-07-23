({
	doInit : function(component, event, helper) {
        /*
         *  force:navigateToComponent not supported in Communities yet.
		 *  Had to use force:navigateToURL passing in parameter value
		 *  So we will get the parameter from the URL by calling a common function in CCDataComponent
         */
        if( component.get("v.recordId") === undefined || component.get("v.recordId") === '') {
            // no case id, See if it is set in the URL parameter
            var oId = helper.getParameterByName(component, 'recordId', window.location.href);
            if (oId != null) {
                component.set("v.recordId", oId);
                helper.refreshUrl();
            }
        }

        if(helper.validateComponent(component)) {
            // call the helper class to get list of cases
            console.log("Payer Review Detail valid: "+component.get("v.recordId"));
            helper.getCase(component, event, helper);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Missing Case Record ID.','error');
            return;
        }
	},
    doSave : function(component, event, helper) {
        var fields = ["myticketnumber","secondaryticketnumber"];
        var allValid = fields.reduce(function (validSoFar, inputField) {
            var inputCmp = component.find(inputField);
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (!allValid) {
            helper.displayErrorDialog('IMPORTANT!','Please enter valid values and try again','error');
            return;
        }
        helper.saveCase(component, event, helper);
        helper.toggleEditMode(component);
    },
    setEditMode : function(component, event, helper) {
        helper.toggleEditMode(component);
    },
    doCancel : function(component, event, helper) {
        // reset values from dirty input
        helper.getCase(component, event, helper);
        helper.toggleEditMode(component);
    },
    doArchiveCase : function(component, event, helper) {
        component.set("v.cs.Status",'Archived');
        helper.saveCase(component, event, helper);
    },
    showCloseCaseDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("closecasecmp"),'hide-modal');
    },
	hideChangeCaseStatusDialog : function(component, event, helper) {
        // reset values from dirty input
        helper.getCase(component, event, helper);
        $A.util.addClass(component.find("closecasecmp"),'hide-modal');
        $A.util.addClass(component.find("reopencasecmp"),'hide-modal');
	},
    showReopenCaseDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("reopencasecmp"),'hide-modal');
    },
    showChangeContactDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("changecontactcmp"),'hide-modal');
    },
	hideChangeContactDialog : function(component, event, helper) {
        // reset values from dirty input
        helper.getCase(component, event, helper);
        $A.util.addClass(component.find("changecontactcmp"),'hide-modal');
	},
	backToList : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "List",
            "listView": component.get('v.viewSelect')
        });   
        compEvent.fire();  
	},
    doWait : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
    },
    stopWait : function(component, event, helper) {
        helper.hideSpinner(component, event, helper);
    }
})