({
    getAccount : function(component, event, helper) {
        // Display all cases for selected status
//        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.getBillingAccount",function(response,error) {
//	        helper.hideSpinner(component, event, helper);
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
	            component.set("v.ba", response);
                component.set("v.recordId", response.id);
	            component.set("v.billToContact", response.billToContact);
	            component.set("v.soldToContact", response.soldToContact);
	            component.set("v.hasMulitipleBillingAccounts", response.hasMulitipleBillingAccounts);
            }
        },
        {
            recordId: component.get('v.recordId')
        });
    },
    createModalComponents : function(component) {
        // Dynamically create case comments component.
        // This is called once the init has run and captured the recordId
        $A.createComponent(
            "c:CCBillingAccountEdit",
            {
                "recordId": component.get('v.recordId'),
                "ba": component.get('v.ba')
            },
            function(newComp) {
                var content = component.find("editaccountModal");
                content.set("v.body", newComp);
            }
        );
/*
        $A.createComponent(
            "c:CCBillingContactEdit",
            {
                "aura:id": "editContactCmp",
                "recordId": component.get('v.recordId'),
                "billingContact": component.get('v.billToContact')
            },
            function(newComp) {
                var content = component.find("editcontactModal");
                content.set("v.body", newComp);
            }
        );
*/
    },

})