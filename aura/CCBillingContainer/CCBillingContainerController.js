({
    doInit : function(component, event, helper) {
        /*
         *  force:navigateToComponent not supported in Communities yet.
		 *  Had to use force:navigateToURL passing in parameter value
		 *  So we will get the parameter from the URL by calling a common function in CCDataComponent
         */
        var oId = helper.getParameterByName(component, 'recordId', window.location.href);
        if(oId === undefined || oId === '' || oId === null) {
            // determine if we need to redirect to Select Account or directly to Account Detail
            helper.getAccounts(component, event, helper);
        } else {
            helper.showComponent(component,"c:CCBilling","billingAccountCmp",
                                 {
                                     "aura:id": "billingAccountCmp",
                                     "recordId": oId
                                 });
            // clean URL of unwanted Parameters
            var newUrl = helper.refreshUrl();
        }

    },
    goToTargetView : function(component, event, helper) {
        helper.navigate(component,event,helper);
    },
})