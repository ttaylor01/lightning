({
	doInit : function(component, event, helper) {
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
            helper.getCase(component, event, helper);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Missing Case Record ID.','error');
            return;
        }
	},
    doSave : function(component, event, helper) {
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
    showChangeAlternateContactDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("changealternatecontactcmp"),'hide-modal');
    },
    showChangeBillingAccountDialog : function(component, event, helper) {
//        $A.util.removeClass(component.find("changebillingaccountcmp"),'hide-modal');
    },
	hideChangeContactDialog : function(component, event, helper) {
        // reset values from dirty input
        helper.getCase(component, event, helper);
        $A.util.addClass(component.find("changecontactcmp"),'hide-modal');
        $A.util.addClass(component.find("changealternatecontactcmp"),'hide-modal');
//        $A.util.addClass(component.find("changebillingaccountcmp"),'hide-modal');
	},
	backToList : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "List",
            "listView": component.get('v.viewSelect')
        });   
        compEvent.fire();  
	},
})