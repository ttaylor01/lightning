({
	doInit : function(component, event, helper) {
        if( component.get("v.recordId") === undefined || component.get("v.recordId") === '') {
            // no case id, See if it is set in the URL parameter
            var oId = helper.getParameterByName(component, 'recordId', window.location.href);
            if (oId != null) {
                component.set("v.recordId", oId);
                var newUrl = helper.refreshUrl();
                console.log("[CCBillingController.doInit] replaced URL: "+window.location.href);
            }
        }
        helper.getAccount(component, event, helper);
	},
    doManagePaymentMethods : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "paymentMethods",
            "sObjectId": component.get("v.recordId")
        });   
        compEvent.fire();
    },
    doSelectAccount : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "accountSelect"
        });   
        compEvent.fire();
    },
    showEditAccountDialog : function(component, event, helper) {
        $A.util.removeClass(component.find("editaccountModal"),'hide-modal');
    },
	hideEditAccountDialog : function(component, event, helper) {
        helper.getAccount(component, event, helper);
        $A.util.addClass(component.find("editaccountModal"),'hide-modal');
	},

    doWait : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
    },
    stopWait : function(component, event, helper) {
        helper.hideSpinner(component, event, helper);
    },
    /*
     * ALL Contact Logic Follows
     */
    showEditContactDialog : function(component, event, helper) {
        var billingContactType = event.getSource().get("v.name");
        var editContactCmp = component.find("editContactCmp");
        if(billingContactType === 'BillTo') {
            editContactCmp.setBillingContact(component.get("v.billToContact"));
        } else {
            editContactCmp.setBillingContact(component.get("v.soldToContact"));
        }
        $A.util.removeClass(component.find("editcontactModal"),'hide-modal');
    },
	hideEditContactDialog : function(component, event, helper) {
        helper.getAccount(component, event, helper);
        $A.util.addClass(component.find("editcontactModal"),'hide-modal');
	},
    doContactSupport : function(component, event, helper) {
        var urlStr = "/billingsupport?recordId=new&billingAccountId="+component.get("v.recordId")+"&retUrl=%2Fbilling%3FrecordId%3D"+component.get("v.recordId");
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": urlStr
		});
		urlEvent.fire();
    },
})