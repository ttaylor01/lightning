({
    saveAccount : function(component, event, helper) {
        // Display all cases for selected status
//        console.log("[CCBillingAccountHelper.saveAccount] account: "+JSON.stringify(component.get('v.ba')));
        helper.doWait(component);
        helper.callServer(component,"c.saveBillingAccount",function(response,error) {
            helper.stopWait(component);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
            }
        },
        {
            id: component.get('v.ba.id'),
            autoPay: component.get('v.ba.autoPay'),
            defaultPaymentMethodId: component.get('v.ba.defaultPaymentMethodId')
        });
    },
    validateInput : function(component, helper) {
        var allValid = true;
//        var inputCmp = component.find('paymentmethods');
        var inputValue = component.get('v.ba.defaultPaymentMethodId');
        console.log("[CCBillingAccountEditHelper.validateInput] defaultPaymentMethodId: "+inputValue);
        console.log("[CCBillingAccountEditHelper.validateInput] autoPay: "+component.find('autopay').get('v.checked'));
        if(component.find('autopay').get('v.checked')) {
            if(inputValue === undefined || inputValue === "" || inputValue === "REMOVE") {
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
            if(!component.find('autopay').get('v.checked') || inputValue === undefined || inputValue === "" || inputValue === "REMOVE") {
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
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.recordId") !== undefined && component.get("v.recordId") !== '');
        }
        return valid;
    },
    hideDialog : function(component, event) {
        component.set('v.body','');
        var compEvent = component.getEvent("hideEditAccountDialog");
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