({
    getAccounts : function(component, event, helper) {
        // Display all cases for selected status
        helper.callServer(component,"c.getBillingAccounts",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
	            component.set("v.accounts", response);
                var accounts = component.get("v.accounts");
                console.log("[CCBillingContainerHelper.getAccounts] accounts: "+JSON.stringify(accounts));
                // If only one account, redirect to main billing account page
                if(accounts != undefined && accounts.length === 1) {
                    var oid = accounts[0].Zuora__Zuora_Id__c;
                    helper.showComponent(component,"c:CCBilling","billingAccountCmp",
                                         {
                                             "aura:id": "billingAccountCmp",
                                             "recordId": oid
                                         });
                } else {
                    helper.showComponent(component,"c:CCBillingAccountSelect","billingAccountSelectCmp",
                                         {
                                             "aura:id": "billingAccountSelectCmp"
                                         });
                }
            }
        },
        {
            recordId: ''
        });
    },
    navigate : function(component, event,helper) {
        // Dynamically create case detail component.
        var params = event.getParams();
        console.log("CCBillingContainer navigate params: "+JSON.stringify(params));
        if( params.targetView !== undefined && params.targetView !== '') {
            component.set("v.currentView",params.targetView);
	        var cmpName = params.targetView;
            if(cmpName === 'accountSelect') {
                helper.showComponent(component,"c:CCBillingAccountSelect","billingAccountSelectCmp",
                                     {
                                         "aura:id": "billingAccountSelectCmp"
                                     });
            } else if(cmpName === 'accountDetail') {
                helper.showComponent(component,"c:CCBilling","billingAccountCmp",
                                     {
                                         "aura:id": "billingAccountCmp",
                                         "recordId": params.sObjectId
                                     });
            } else if(cmpName === 'paymentMethods') {
                helper.showComponent(component,"c:CCBillingPaymentMethod","billingPaymentMethodCmp",
                                     {
                                         "aura:id": "billingPaymentMethodCmp",
                                         "recordId": params.sObjectId
                                     });
            } else if(cmpName === 'manageBilling') {
                helper.showComponent(component,"c:CCBillingManagement","billingManagementCmp",
                                     {
                                         "aura:id": "billingManagementCmp",
                                         "recordId": params.sObjectId
                                     });
            } else if(cmpName === 'paymentList') {
                helper.showComponent(component,"c:CCBillingPaymentList","paymentListCmp",
                                     {
                                         "aura:id": "paymentListCmp",
                                         "recordId": params.sObjectId
                                     });
            } else {
	            helper.displayErrorDialog('FYI!','We were unable to display the page.','info');
                helper.showComponent(component,"c:CCBillingAccountSelect","billingAccountSelectCmp",
                                     {
                                         "aura:id": "billingAccountSelectCmp"
                                     });
            }
        } else {
            helper.displayErrorDialog('FYI!','We were unable to display the page.','info');
            helper.showComponent(component,"c:CCBillingAccountSelect","billingAccountSelectCmp",
                                 {
                                     "aura:id": "billingAccountSelectCmp"
                                 });
        }
    },
    showComponent : function(component,name,cmpid,params) {
        $A.createComponent(
            name,
            params,
            function(newComp, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log("CCBillingContainer showComponent newComp: "+newComp);
                    var content = component.find("mainContainer");
                    content.set("v.body", newComp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("CCBillingContainer showComponent No response from server or client is offline.");
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("CCBillingContainer showComponent Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
})