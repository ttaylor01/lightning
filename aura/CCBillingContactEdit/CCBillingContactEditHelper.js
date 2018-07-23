({
    saveContact : function(component, event, helper) {
        var bc = component.get('v.billingContact');
        var btc = {sobjectType:'Contact',
                   TrackerKey__c : bc.id,
                   FirstName : bc.firstName,
                   LastName : bc.lastName,
                   MailingStreet : bc.address1,
                   MailingCity : bc.city,
                   MailingState : bc.state,
                   MailingPostalCode : bc.postalCode,
                   Email : bc.email,
                   Phone : bc.phone
                  };
        console.log("[CCBillingContactEditHelper.saveContact] btc: "+JSON.stringify(btc));

        helper.doWait(component);
        helper.callServer(component,"c.saveBillingContact",function(response,error) {
            helper.stopWait(component);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
//                console.log("[CCBillingContactEditHelper.saveContact] response: "+JSON.stringify(response));
            }
        },
        {
            zContact: btc
        });
    },
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.recordId") !== undefined && component.get("v.recordId") !== '');
        }
        return valid;
    },
    validateContactInput : function(component, helper, fields) {
        var allValid = true;
        var allValid = fields.reduce(function (validSoFar, inputField) {
            var inputCmp = component.find(inputField);
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (!allValid) {
            helper.displayErrorDialog('IMPORTANT!','Please enter valid values and try again','error');
            return;
        }
        
        return allValid;
    },
    getStatePicklistValues : function(component, event, helper) {
        helper.callServer(component,"c.getStates",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                var picklistValues = []; // for store picklist values to set on ui field.
                for(var i=0; i<response.length; i++) {
                    picklistValues.push({
                        class: "optionClass",
                        label: response[i],
                        value: response[i]
                    });
                }
                component.find("billingContactState").set("v.options", picklistValues);
            }
        },
        {
        });
    },
    hideDialog : function(component, event) {
        component.set('v.body','');
        var compEvent = component.getEvent("hideEditContactDialog");
        compEvent.setParams({
            'recordId': component.get('v.recordId')
        });
        compEvent.fire();  
    },
    doWait : function(component) {
        var evt = component.getEvent("showSpinner");
        evt.fire();
    },
    stopWait : function(component) {
        var evt = component.getEvent("hideSpinner");
        evt.fire();
    }
})