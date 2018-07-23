({
    getPaymentMethods : function(component, event, helper) {
        // Display all case comments
        helper.callServer(component,"c.getPaymentMethodWrapper",function(response,error) {
            if(error) {
                // do some error processing
//	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                helper.initializeComponents(component, event, helper, response);
            }
        },
        {
            recordId: component.get('v.recordId')
        });
    },
    deletePaymentMethod : function(component, event, helper, paymentMethodId) {
        console.log("[CCBillingPaymentMethodController.deletePaymentMethod] Id: "+paymentMethodId);
        // SHOW SPINNER
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.removePaymentMethod",function(response,error) {
            // HIDE SPINNER
	        helper.hideSpinner(component, event, helper);
            if(error) {
                helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                helper.initializeComponents(component, event, helper, response);
            }
        },
        {
            recordId: component.get('v.recordId'),
            pmId: paymentMethodId
        });
    },
    savePaymentMethod : function(component, event, helper, paymentMethodType) {
        console.log("[CCBillingPaymentMethodController.savePaymentMethod] paymentMethodType: "+paymentMethodType);
        var inputObj;
        if(paymentMethodType === 'CreditCard') {
            inputObj = component.get("v.cc");
        } else {
            inputObj = component.get("v.ach");
        }
        console.log("[CCBillingPaymentMethodHelper.savePaymentMethod] inputObj: "+JSON.stringify(inputObj));
        // SHOW SPINNER
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.savePaymentMethod",function(response,error) {
            // refresh list
            // HIDE SPINNER
	        helper.hideSpinner(component, event, helper);
            if(error) {
                helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                helper.initializeComponents(component, event, helper, response);
                helper.resetFields(component);
                if(paymentMethodType === 'CreditCard') {
                    helper.toggleAddCreditCardMode(component);
                } else {
                    helper.toggleAddACHMode(component);
                }
            }
        },
        {
            recordId: component.get('v.recordId'),
            jsonObject: JSON.stringify(inputObj)
        });
    },
    validateInput : function(component, helper, paymentType) {
        var allValid = true;
        if(paymentType === 'CreditCard') {
            var ccType = component.get("v.cc.creditCardType");
            console.log("[CCBillingPaymentMethodHelper.validateInput] ccType: "+ccType);
            if(ccType === undefined || ccType === "" || ccType === "--- None ---") {
                component.set("v.cardtypeError",true);
                allValid = allValid && false;
            } else {
                component.set("v.cardtypeError",false);
                allValid = allValid && true;
            }

            var inputCmp = component.find('cardnumber');
            var inputValue = inputCmp.get("v.value");
            if(inputValue === undefined || inputValue === "") {
                inputCmp.set("v.errors", [{message:"You must enter a Credit Card Number"}]);
                $A.util.addClass(inputCmp, "hasError"); // add red border
                allValid = allValid && false;
            } else {
                // Replace all non numeric characters from credit card number
                console.log("[CCBillingPaymentMethodHelper.validateInput] DIRTY CC Number: "+inputValue);
                inputValue = inputValue.replace(/\D/g,'');
                inputCmp.set("v.value",inputValue);
                console.log("[CCBillingPaymentMethodHelper.validateInput] CLEAN CC Number: "+inputValue);
                inputCmp.set("v.errors", null);
                $A.util.removeClass(inputCmp, "hasError"); // remove red border
                allValid = allValid && true;
            }
            // allValid at this point means we have a card type selected and entered card number value
            if(allValid) {
                if(!helper.isValidCreditCard(ccType,inputValue)) {
                    inputCmp.set("v.errors", [{message:"Invalid Card Number for the Type selected"}]);
                    $A.util.addClass(inputCmp, "hasError"); // add red border
                    allValid = allValid && false;
                } else {
                    inputCmp.set("v.errors", null);
                    $A.util.removeClass(inputCmp, "hasError"); // remove red border
                    allValid = allValid && true;
                }
            }

            inputCmp = component.find("expirationmonth");
            inputValue = inputCmp.get("v.value");
            if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
                inputCmp.set("v.errors", [{message:"Please select an Expiration Month"}]);
                allValid = allValid && false;
            } else {
                inputCmp.set("v.errors", null);
                allValid = allValid && true;
            }
            inputCmp = component.find("expirationyear");
            inputValue = inputCmp.get("v.value");
            if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
                inputCmp.set("v.errors", [{message:"Please select an Expiration Year"}]);
                allValid = allValid && false;
            } else {
                inputCmp.set("v.errors", null);
                allValid = allValid && true;
            }

            inputCmp = component.find('cvv');
            inputValue = inputCmp.get("v.value");
            console.log("[CCBillingPaymentMethodHelper.validateInput] ccv Value: "+inputValue);
            if(inputValue === undefined || inputValue === "" || inputValue === null) {
                inputCmp.set("v.errors", [{message:"Please enter a valid security code."}]);
                $A.util.addClass(inputCmp, "hasError"); // add red border
                allValid = allValid && false;
            } else {
                if(!helper.isValidCVV(ccType,inputValue)) {
                    inputCmp.set("v.errors", [{message:"Invalid CVV for the Type selected"}]);
                    $A.util.addClass(inputCmp, "hasError"); // add red border
                    allValid = allValid && false;
                } else {
                    inputCmp.set("v.errors", null);
                    $A.util.removeClass(inputCmp, "hasError"); // remove red border
                    allValid = allValid && true;
                }
            }

            inputCmp = component.find('cardholdername');
            inputCmp.showHelpMessageIfInvalid();
            allValid = allValid && inputCmp.get('v.validity').valid;
        } else {
            var inputCmp = component.find('achaccountname');
            inputCmp.showHelpMessageIfInvalid();
            allValid = allValid && inputCmp.get('v.validity').valid;
            var inputCmp = component.find('achAbaCode');
            inputCmp.showHelpMessageIfInvalid();
            allValid = allValid && inputCmp.get('v.validity').valid;
            var inputCmp = component.find('achAccountNumber');
            inputCmp.showHelpMessageIfInvalid();
            allValid = allValid && inputCmp.get('v.validity').valid;

            inputCmp = component.find("achAccountType");
            var inputValue = inputCmp.get("v.value");
            if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
                inputCmp.set("v.errors", [{message:"Please select an Account Type"}]);
                allValid = allValid && false;
            } else {
                inputCmp.set("v.errors", null);
                allValid = allValid && true;
            }
            
            var inputCmp = component.find('achBankName');
            inputCmp.showHelpMessageIfInvalid();
            allValid = allValid && inputCmp.get('v.validity').valid;
        }

        console.log("validateInput allValid? "+allValid);
        return allValid;
    },
    /*
     * American Express :- Starting with 34 or 37, length 15 digits.
     * Visa :- Starting with 4, length 13 or 16 digits.
     * MasterCard :- Starting with 51 through 55, length 16 digits.
     * Discover :- Starting with 6011, length 16 digits or starting with 5, length 15 digits.
     * Diners Club :- Starting with 300 through 305, 36, or 38, length 14 digits.
     * JCB :- Starting with 2131 or 1800, length 15 digits or starting with 35, length 16 digits.
     */
    isValidCreditCard : function(ccType, ccNumber) {
        console.log("[CCBillingPaymentMethodHelper.isValidCreditCard] ccType: "+ccType);
        console.log("[CCBillingPaymentMethodHelper.isValidCreditCard] ccNumber: "+ccNumber);
        var regExp;
        if (ccType === 'Visa') {
            regExp = /^(?:4[0-9]{12}(?:[0-9]{3})?)$/;
        } else if (ccType === 'MasterCard') {
            regExp = /^(?:5[1-5][0-9]{14})$/;
        } else if (ccType === 'Discover') {
            regExp = /^(?:6(?:011|5[0-9][0-9])[0-9]{12})$/;
        } else if (ccType === 'AmericanExpress') {
            regExp = /^(?:3[47][0-9]{13})$/;
        } else if (ccType === 'DinersClub') {
            regExp = /^(?:3(?:0[0-5]|[68][0-9])[0-9]{11})$/;
        } else if (ccType === 'JCB') {
            regExp = /^(?:(?:2131|1800|35\d{3})\d{11})$/;
        } else {
            return false;
        }
        if(ccNumber.match(regExp)) {
            return true;
        } else {
            return false;
        }
    },
    isValidCVV : function(ccType, ccvNumber) {
        console.log("[CCBillingPaymentMethodHelper.isValidCVV] ccType: "+ccType);
        console.log("[CCBillingPaymentMethodHelper.isValidCVV] ccvNumber: "+ccvNumber);
        var regExp;
        if (ccType === 'Visa') {
            regExp = /^[0-9]{3}$/;
        } else if (ccType === 'MasterCard') {
            regExp = /^[0-9]{3}$/;
        } else if (ccType === 'Discover') {
            regExp = /^[0-9]{3}$/;
        } else if (ccType === 'AmericanExpress') {
            regExp = /^[0-9]{4}$/;
        } else if (ccType === 'DinersClub') {
            regExp = /^[0-9]{3}$/;
        } else if (ccType === 'JCB') {
            regExp = /^[0-9]{3}$/;
        } else {
            return false;
        }
        if(ccvNumber.match(regExp)) {
            return true;
        } else {
            return false;
        }
    },
    resetFields : function(component) {
        // Reset All fields on Credit Card
        component.set("v.cc.creditCardType",'');
        component.set("v.cc.creditCardNumber",'');
        component.set("v.cc.creditCardHolderName",'');
        component.set("v.cc.creditCardExpirationMonth",'');
        component.set("v.cc.creditCardExpirationYear",'');
        component.set("v.cc.creditCardAddress1",'');
        component.set("v.cc.creditCardAddress2",'');
        component.set("v.cc.creditCardCity",'');
        component.set("v.cc.creditCardState",'');
        component.set("v.cc.creditCardPostalCode",'');
        component.set("v.cc.creditCardSecurityCode",'');
        // Reset All fields on ACH
        component.set("v.ach.achAccountName",'');
        component.set("v.ach.achAbaCode",'');
        component.set("v.ach.achAccountNumber",'');
        component.set("v.ach.achAccountType",'');
        component.set("v.ach.achBankName",'');
    },

    /*
     * Credit Card Logic
     */
    toggleAddCreditCardMode : function(component) {
//        $A.util.addClass(component.find("btnSaveCC_top"), "hide-button"); // hide Save button
//        $A.util.addClass(component.find("btnSaveCC_bottom"), "hide-button"); // hide Save button
        if(component.get("v.creditcardVisibility")) {
            component.set("v.creditcardVisibility",false);
            component.set("v.creditcardListVisibility",true);
            component.set("v.achListVisibility",true);
            component.set("v.achVisibility",false);
        } else {
            component.set("v.creditcardVisibility",true);
            component.set("v.creditcardListVisibility",false);
            component.set("v.achListVisibility",false);
            component.set("v.achVisibility",false);
        }
    },

    /*
     * ACH LOGIC
     */
    toggleAddACHMode : function(component) {
//        $A.util.addClass(component.find("btnSaveACH_top"), "hide-button"); // hide Save button
//        $A.util.addClass(component.find("btnSaveACH_bottom"), "hide-button"); // hide Save button
        if(component.get("v.achVisibility")) {
            component.set("v.achVisibility",false);
            component.set("v.achListVisibility",true);
            component.set("v.creditcardListVisibility",true);
            component.set("v.creditcardVisibility",false);
        } else {
            component.set("v.achVisibility",true);
            component.set("v.achListVisibility",false);
            component.set("v.creditcardVisibility",false);
            component.set("v.creditcardListVisibility",false);
        }
    },

    /*
     * COMMON Logic
     */
    initializeComponents : function(component, event, helper, response) {
//        console.log("[CCBillingPaymentMethodController.initializeComponents] response: "+JSON.stringify(response));
        component.set("v.pmw", response);
        component.set("v.creditCards", response.creditCards);
        component.set("v.bankAccounts", response.bankAccounts);
        component.set("v.cc", response.inputCreditCard);
        component.set("v.cc.paymentMethodType",'CreditCard');
        component.set("v.ach", response.inputBankAccount);
        component.set("v.ach.paymentMethodType",'ACH');
        // Create collection of card types for radio button composition
        var typeMap = response.ccTypeOptions;
        var cardTypes = [];
        for(var singleKey in typeMap) {
            cardTypes.push({
                key: singleKey,
                value: typeMap[singleKey]
            });
        }
        component.set("v.cardTypes",cardTypes);
        helper.getExpirationMonthPicklistValues(component,event,helper);
        helper.getExpirationYearPicklistValues(component,event,helper);
        helper.getACHAccountTypePicklistValues(component,event,helper);
    },
    getStatePicklistValues : function(component, event, helper) {
        helper.callServer(component,"c.getStates",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
//                console.log("[CCBillingPaymentMethodHelper.getStatePicklistValues] states "+JSON.stringify(response));
                var picklistValues = []; // for store picklist values to set on ui field.
                picklistValues.push({
                    class: "optionClass",
                    label: "--- None ---",
                    value: ""
                });
                for(var i=0; i<response.length; i++) {
                    picklistValues.push({
                        class: "optionClass",
                        label: response[i],
                        value: response[i]
                    });
                }
                component.find("cardState").set("v.options", picklistValues);
            }
        },
        {
        });
    },
    getExpirationMonthPicklistValues : function(component, event, helper) {
        // Create collection of card types for radio button composition
        var monthMap = component.get("v.pmw.monthOptions");
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "--- None ---",
            value: ""
        });
        for(var singleKey in monthMap) {
            picklistValues.push({
                class: "optionClass",
                label: monthMap[singleKey],
                value: singleKey
            });
        }
        component.find("expirationmonth").set("v.options", picklistValues);
    },
    getExpirationYearPicklistValues : function(component, event, helper) {
        // Create collection of card types for radio button composition
        var yearMap = component.get("v.pmw.yearOptions");
//        console.log("[CCBillingPaymentMethodHelper.getExpirationYearPicklistValues] expiration years "+JSON.stringify(yearMap));
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "--- None ---",
            value: ""
        });
        for(var singleKey in yearMap) {
            picklistValues.push({
                class: "optionClass",
                label: yearMap[singleKey],
                value: singleKey
            });
        }
//        console.log("[CCBillingPaymentMethodHelper.getExpirationYearPicklistValues] picklistValues "+JSON.stringify(picklistValues));
        component.find("expirationyear").set("v.options", picklistValues);
    },
    getACHAccountTypePicklistValues : function(component, event, helper) {
        // Create collection of card types for radio button composition
        var achTypes = component.get("v.pmw.achTypeOptions");
//        console.log("[CCBillingPaymentMethodHelper.getACHAccountTypePicklistValues] ach Types "+JSON.stringify(achTypes));
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "--- None ---",
            value: ""
        });
        for(var singleKey in achTypes) {
            picklistValues.push({
                class: "optionClass",
                label: achTypes[singleKey],
                value: singleKey
            });
        }
//        console.log("[CCBillingPaymentMethodHelper.getACHAccountTypePicklistValues] picklistValues "+JSON.stringify(picklistValues));
        component.find("achAccountType").set("v.options", picklistValues);
    },
})