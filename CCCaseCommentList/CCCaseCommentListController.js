({
	doInit : function(component, event, helper) {
        if(helper.validateComponent(component)) {
            var csStatus = component.get("v.caseStatus");
            component.set("v.addBtnVisibility",(csStatus!=='Closed' && csStatus!=='Archived')?true:false);
            // call the helper class to get list of case comments
            helper.getCaseComments(component, event, helper);
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
    showAddCommentDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("addcommentModal"),'hide-modal');
    },
	hideAddCommentDialog : function(component, event, helper) {
        helper.getCaseComments(component, event, helper);
        $A.util.addClass(component.find("addcommentModal"),'hide-modal');
	},
})