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
                helper.showComponent(component,"c:CCProductSupportList","caseListCmp",
                                     {
                                         "aura:id": "caseListCmp",
                                         "viewSelect": params.listView
                                     });
            } else if(cmpName === 'Detail') {
                helper.showComponent(component,"c:CCProductSupportDetail","caseDetailView",
                                     {
                                         "aura:id": "caseDetailView",
                                         "recordId": params.sObjectId,
                                         "viewSelect": params.listView
                                     });
            } else if(cmpName === 'Edit') {
                helper.showComponent(component,"c:CCProductSupportSelect","caseEditView",
                                     {
                                         "aura:id": "caseEditView",
                                         "viewSelect": params.listView
                                     });
            } else {
	            helper.displayErrorDialog('FYI!','We were unable to display the page.','info');
                helper.showComponent(component,"c:CCProductSupportList","caseListCmp",
                                     {
                                         "aura:id": "caseListCmp",
                                         "viewSelect": params.listView
                                     });
            }
        } else {
            helper.displayErrorDialog('FYI!','We were unable to display the page.','info');
            helper.showComponent(component,"c:CCProductSupportList","caseListCmp",
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
            function(newComp, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log("CCProductSupportContainer showComponent newComp: "+newComp);
                    var content = component.find("mainContainer");
                    content.set("v.body", newComp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("CCProductSupportContainer showComponent No response from server or client is offline.");
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("CCProductSupportContainer showComponent Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
})