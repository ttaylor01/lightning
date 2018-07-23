({
	doInit : function(component, event, helper) {
        console.log("[CCFileAttachmentList.doInit] ");
        if(helper.validateComponent(component)) {
            var csStatus = component.get("v.caseStatus");
            console.log("[CCFileAttachmentList.doInit] csStatus: "+csStatus);
            component.set("v.addBtnVisibility",(csStatus!=='Closed' && csStatus!=='Archived')?true:false);
            console.log("[CCFileAttachmentList.doInit] addBtnVisibility: "+component.get("v.addBtnVisibility"));
            helper.getAttachments(component, event, helper);
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
    showAddAttachmentDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("addFileAttachmentModal"),'hide-modal');
    },
    hideAddAttachmentDialog : function(component, event, helper) {
        helper.getAttachments(component, event, helper);
        $A.util.addClass(component.find("addFileAttachmentModal"),'hide-modal');
    },
})