({
    navigate : function(component, event,helper) {
        // Dynamically create case detail component.
        var params = event.getParams();
        if( params.targetView !== undefined && params.targetView !== '') {
            component.set("v.currentView",params.targetView);
            if( params.listView !== undefined && params.listView !== '') {
                component.set("v.viewSelect",params.listView);
            }
	        var cmpName = params.targetView;
            if(cmpName === 'List') {
                helper.showComponent(component,"c:CCPayerReviewList","caseListCmp",
                                     {
                                         "aura:id": "caseListCmp",
                                         "viewSelect": params.listView
                                     });
            } else if(cmpName === 'Detail') {
                helper.showComponent(component,"c:CCPayerReviewDetail","caseDetailView",
                                     {
                                         "aura:id": "caseDetailView",
                                         "recordId": params.sObjectId,
                                         "viewSelect": params.listView
                                     });
            } else {
	            helper.displayErrorDialog('FYI!','We were unable to display the page.','info');
                helper.showComponent(component,"c:CCPayerReviewList","caseListCmp",
                                     {
                                         "aura:id": "caseListCmp",
                                         "viewSelect": params.listView
                                     });
            }
        } else {
            helper.displayErrorDialog('FYI!','We were unable to display the page.','info');
            helper.showComponent(component,"c:CCPayerReviewList","caseListCmp",
                                 {
                                     "aura:id": "caseListCmp",
                                     "viewSelect": params.listView
                                 });
        }
    },
    showComponent : function(component,name,cmpid,params) {
        $A.createComponent(
            name,
            params,
            function(newComp) {
                var content = component.find("mainContainer");
                content.set("v.body", newComp);
            }
        );
    },
})