({
    doInit : function(component, event, helper) {
        var action = component.get("c.getHIMSSAnalyticsID");
        console.log("HIMSSAnalyticsProfile recordId: "+component.get("v.recordId"));

        action.setParams({"accountId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                // do open window
                component.set("v.UniqueId", response.getReturnValue());
                helper.gotoHIMSS(component, helper);
            } else {
                // error
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "Unable to obtain HIMSS Unique Id."
                });
                toastEvent.fire();
            }
            $A.get("e.force:closeQuickAction").fire();
        });
      $A.enqueueAction(action);
    },
})