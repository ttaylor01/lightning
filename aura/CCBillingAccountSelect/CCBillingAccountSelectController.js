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
                var newUrl = helper.refreshUrl();
                console.log("[CCBillingAccountSelectController.doInit] replaced URL: "+window.location.href);
            }
        }
        helper.getAccounts(component, event, helper);
	},
    onListItemClick : function(component, event, helper) {
        var rowEl = event.currentTarget;
        component.set("v.recordId",rowEl.getAttribute('data-pk'));
        var selectedRowEl = component.get("v.selectedRowEl");
        if (selectedRowEl) {
            $A.util.removeClass(selectedRowEl,"slds-is-selected");
        }
        component.set("v.selectedRowEl", rowEl);
        $A.util.addClass(rowEl,"slds-is-selected");

        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "accountDetail",
            "sObjectId": component.get("v.recordId")
        });   
        compEvent.fire();  
    },
})