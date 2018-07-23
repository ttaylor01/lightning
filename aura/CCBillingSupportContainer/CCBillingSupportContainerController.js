({
    doInit : function(component, event, helper) {
        /*
         *  force:navigateToComponent not supported in Communities yet.
		 *  Had to use force:navigateToURL passing in parameter value
		 *  So we will get the parameter from the URL by calling a common function in CCDataComponent
         */
        var oId = helper.getParameterByName(component, 'recordId', window.location.href);
        // Capture return URL and billingAccountId if flowing from Billing pages
        var retUrl = helper.getParameterByName(component, 'retUrl', window.location.href);
        var billingAccountId = helper.getParameterByName(component, 'billingAccountId', window.location.href);
        if(oId === undefined || oId === '' || oId === null) {
            helper.showComponent(component,"c:CCBillingSupportList","caseListCmp",
                                 {
                                     "aura:id": "caseListCmp",
                                     "viewSelect": "Open"
                                 });
        } else {
            if(oId === 'new') {
                helper.showComponent(component,"c:CCBillingSupportCreate","caseEditView",
                                     {
                                         "aura:id": "caseEditView",
                                         "billingAccountId": billingAccountId,
                                         "retUrl": retUrl
                                     });
            } else {
                helper.showComponent(component,"c:CCBillingSupportDetail","caseDetailView",
                                     {
                                         "aura:id": "caseDetailView",
                                         "recordId": oId
                                     });
            }
            // clean URL of unwanted Parameters
            helper.refreshUrl();
        }

    },
	onCaseListFormSubmit : function(component, event) {
        var formData = event.getParam('formData');
        // Set viewSelect to assist in navigation from list and detail pages
        component.set("v.viewSelect",formData.listView);
        var mainContainer = component.find("mainContainer").get("v.body");
        var sList = mainContainer[0].find("caseListCmp");
        sList.set('v.viewSelect', formData.listView);
        sList.set('v.searchStr', formData.searchStr);
        sList.refresh();
    },
    goToTargetView : function(component, event, helper) {
        helper.navigate(component,event,helper);
    },
})