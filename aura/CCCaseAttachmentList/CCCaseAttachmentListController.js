({
	doInit : function(component, event, helper) {
        if(helper.validateComponent(component)) {
            var csStatus = component.get("v.caseStatus");
            component.set("v.addBtnVisibility",(csStatus!=='Closed' && csStatus!=='Archived')?true:false);
            // call the helper class to get list of case comments
            helper.getCaseAttachments(component, event, helper);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "IMPORTANT!",
                "message": "Missing Case Record ID."
            });
            toastEvent.fire();
            return;
        }
	},
    doDelete : function(component, event, helper) {
        var rowEl = event.currentTarget;
        var attId = rowEl.getAttribute('data-pk');
        helper.deleteAttachment(component, event, helper, attId);
    },
    showAddAttachmentDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("addattachmentModal"),'hide-modal');
    },
    hideAddAttachmentDialog : function(component, event, helper) {
        helper.getCaseAttachments(component, event, helper);
        $A.util.addClass(component.find("addattachmentModal"),'hide-modal');
    },
})