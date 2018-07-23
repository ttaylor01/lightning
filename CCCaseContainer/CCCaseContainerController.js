({
    doInit : function(component, event, helper) {
        /*
         *  force:navigateToComponent not supported in Communities yet.
		 *  Had to use force:navigateToURL passing in parameter value
		 *  So we will get the parameter from the URL by calling a common function in CCDataComponent
         */
        var oId = helper.getParameterByName(component, 'recordId', window.location.href);
        if(oId === undefined || oId === '' || oId === null) {
            helper.showComponent(component,"c:CCCaseList","caseListCmp",
                                 {
                                     "aura:id": "caseListCmp",
                                     "viewSelect": "Open"
                                 });
        } else {
            if(oId === 'new') {
                helper.showComponent(component,"c:CCCaseCreate","caseEditView",
                                     {
                                         "aura:id": "caseEditView"
                                     });
            } else {
                helper.showComponent(component,"c:CCCaseDetail","caseDetailView",
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
        /*
         * cmp.find("aura:id value") not yet supported for dynamically created components
         * Must obtain the v.body to then obtain the component
         * So first obtain the div which contains the dynamically created component and get the v.body.
         * Then obtain the dynamically created component from the body
//        var sList = component.find("caseListCmp");
         */
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