({
    getAccount : function(component, event, helper) {
        // Display all cases for selected status
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.getBillingAccount",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
	            component.set("v.ba", response);
                component.set("v.recordId", response.id);
	            component.set("v.billToContact", response.billToContact);
	            component.set("v.soldToContact", response.soldToContact);
                helper.setPaymentMethods(component, helper);
            }
        },
        {
            recordId: component.get('v.recordId')
        });
    },
    saveAccount : function(component, event, helper) {
        // Display all cases for selected status
//        console.log("[CCBillingAccountHelper.saveAccount] account: "+JSON.stringify(component.get('v.ba')));
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.saveBillingAccount",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
                // reset values from dirty input
                helper.getAccount(component, event, helper);
            } else {
                component.set("v.ba", response);
                helper.setPaymentMethods(component, helper);
            }
        },
        {
            id: component.get('v.ba.id'),
            autoPay: component.get('v.ba.autoPay'),
            defaultPaymentMethodId: component.get('v.ba.defaultPaymentMethodId')
        });
    },
    toggleEditMode : function(component) {
        $A.util.toggleClass(component.find("btnSave"), "hide-button");
        $A.util.toggleClass(component.find("btnCancel"), "hide-button");
        $A.util.toggleClass(component.find("btnPaymentMethods"), "hide-button");
        $A.util.toggleClass(component.find("btnBilling"), "hide-button");
        $A.util.toggleClass(component.find("btnEdit"), "hide-button");
        $A.util.toggleClass(component.find("outputAutoPay"), "hide-component");
        $A.util.toggleClass(component.find("inputAutoPay"), "hide-component");
        $A.util.toggleClass(component.find("outputPaymentMethod"), "hide-component");
        $A.util.toggleClass(component.find("inputPaymentMethod"), "hide-component");
    },
    setPaymentMethods : function(component, helper) {
        var typeMap = component.get('v.ba.paymentMethodOptions');
        var methodTypes = [];
        console.log("defaultPayment: "+component.get('v.ba.defaultPayment'));
        if(Object.keys(typeMap).length > 0 && component.get('v.ba.defaultPayment')) {
            methodTypes.push({
                key: "REMOVE",
                value: "Remove Default Method"
            });
        }
        for(var singleKey in typeMap) {
            methodTypes.push({
                key: singleKey,
                value: typeMap[singleKey]
            });
        }
        component.set("v.methodTypes",methodTypes);
    },
    validateInput : function(component, helper) {
        var allValid = true;
//        var inputCmp = component.find('paymentmethods');
        var inputValue = component.get('v.ba.defaultPaymentMethodId');
        if(component.find('autopay').get('v.checked')) {
            if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
                component.set("v.paymentmethodError",true);
//                inputCmp.set("v.errors", [{message:"Because this customer account is designated as Auto-Pay, you must specify an Electronic Payment Method as the default."}]);
                allValid = allValid && false;
            } else {
                component.set("v.paymentmethodError",false);
//                inputCmp.set("v.errors", null);
                allValid = allValid && true;
            }
        } else {
            component.set("v.paymentmethodError",false);
//            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        }
        if(component.get('v.ba.applyAutoPayEdit') === true) {
            if(!component.find('autopay').get('v.checked') || inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
                component.set("v.autopayError",true);
//                inputCmp.set("v.errors", [{message:"Because the latest Invoice Amount is less than $1000, you cannot disable Auto-Pay or remove default payment method."}]);
                allValid = allValid && false;
            } else {
                component.set("v.autopayError",false);
//                inputCmp.set("v.errors", null);
                allValid = allValid && true;
            }
        }
        return allValid;
    },
    /*
     *  ALL Contact Logic follows. 
     */
    toggleEditModeBTContact : function(component) {
        $A.util.toggleClass(component.find("btnSaveBTContact"), "hide-button");
        $A.util.toggleClass(component.find("btnCancelBTContact"), "hide-button");
        $A.util.toggleClass(component.find("btnEditBTContact"), "hide-button");
        if(component.get("v.billToEditVisibility")) {
            component.set("v.billToEditVisibility",false);
        } else {
            component.set("v.billToEditVisibility",true);
        }
    },
    toggleEditModeSTContact : function(component) {
        $A.util.toggleClass(component.find("btnSaveSTContact"), "hide-button");
        $A.util.toggleClass(component.find("btnCancelSTContact"), "hide-button");
        $A.util.toggleClass(component.find("btnEditSTContact"), "hide-button");
        if(component.get("v.soldToEditVisibility")) {
            component.set("v.soldToEditVisibility",false);
        } else {
            component.set("v.soldToEditVisibility",true);
        }
    },
    saveBTContact : function(component, event, helper) {
        var bc = component.get('v.billToContact');
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
        console.log("[CCBillingAccountHelper.saveBTContact] btc: "+JSON.stringify(btc));

        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.saveBillingContact",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
                // reset values from dirty input
                helper.getAccount(component, event, helper);
            } else {
                console.log("[CCBillingAccountHelper.saveBTContact] response: "+JSON.stringify(response));
                component.set("v.billToContact", response);
            }
        },
        {
            zContact: btc
        });
    },
    saveSTContact : function(component, event, helper) {
        var bc = component.get('v.soldToContact');
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
        console.log("[CCBillingAccountHelper.saveSTContact] btc: "+JSON.stringify(btc));

        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.saveBillingContact",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
                // reset values from dirty input
                helper.getAccount(component, event, helper);
            } else {
                console.log("[CCBillingAccountHelper.saveSTContact] response: "+JSON.stringify(response));
                component.set("v.soldToContact", response);
            }
        },
        {
            zContact: btc
        });
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
                component.find("billToContactState").set("v.options", picklistValues);
                component.find("soldToContactState").set("v.options", picklistValues);
            }
        },
        {
        });
    },

    hideComponents : function(component) {
    }
})