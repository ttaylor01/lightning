({
    getInvoiceList : function(component, event, helper) {
        // Display all case comments
        helper.callServer(component,"c.getBillingManagementWrapper",function(response,error) {
            if(error) {
                // do some error processing
//	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                helper.initializeComponents(component, event, helper, response);
            }
        },
        {
            recordId: component.get('v.recordId'),
            listView: component.get('v.viewSelect')
        });
    },
    loadList : function(component, event, helper) {
        var numberOfPages = component.get("v.numberOfPages");
        var numberPerPage = component.get("v.numberPerPage");
        var currentPage = component.get("v.currentPage");
//        console.log("[CCBillingManagementHelper.loadList] numberPerPage: "+numberPerPage);
//        console.log("[CCBillingManagementHelper.loadList] currentPage: "+currentPage);
        var begin = (currentPage - 1) * numberPerPage;
        var end = (begin*1) + (numberPerPage*1);
//        console.log("[CCBillingManagementHelper.loadList] begin: "+begin);
//        console.log("[CCBillingManagementHelper.loadList] end: "+end);
        var invoices = component.get("v.invoices");
        var invoicePageList = invoices.slice(begin, end);
        component.set("v.invoicePageList",invoicePageList);
        component.set("v.next", (numberOfPages / currentPage === 1) ? true : false );
        component.set("v.prev", (currentPage === 1) ? true : false );
    },
    toggleMakePaymentMode : function(component) {
        if(component.get("v.makePaymentVisibility")) {
            component.set("v.makePaymentVisibility",false);
        } else {
            component.set("v.makePaymentVisibility",true);
        }
    },
    validateInput : function(component, helper) {
        var errorMsg = '';
        var allValid = true;
        var invoices = component.get("v.invoicePayments");
        var totalAmount = 0;
        for(var i=0; i<invoices.length; i++) {
            var amount = invoices[i].inputPaymentAmount;
            totalAmount = totalAmount + amount;
            if(amount != undefined && amount != 0 && amount != "") {
                if(amount > invoices[i].invoice.Zuora__Balance2__c) {
                    allValid = allValid && false;
                    errorMsg = errorMsg + 'Amount of payment for Invoice, '+invoices[i].invoice.Name+', cannot exceed remaining invoice balance.<br/>';
                }
            } else {
                allValid = allValid && false;
                errorMsg = errorMsg + 'Enter an amount for Invoice, '+invoices[i].invoice.Name+'.<br/>';
            }
        }
        console.log("[CCBillingManagementHelper.validateInput] total Amount: "+totalAmount);
        if(allValid && totalAmount === 0) {
            allValid = allValid && false;
            errorMsg = errorMsg + 'You must enter an Amount.<br/>';
        }
        var pmId = component.get("v.billingWrapper.paymentMethodId");
        console.log("[CCBillingManagementHelper.validateInput] paymentMethodId: "+pmId);
        if(pmId === undefined || pmId === "") {
            allValid = allValid && false;
            errorMsg = errorMsg + 'You must select a Payment Option to apply a payment.<br/>';
        }
        console.log("[CCBillingManagementHelper.validateInput] errorMsg: "+errorMsg);
        console.log("[CCBillingManagementHelper.validateInput] allValid? "+allValid);
        return errorMsg;
    },
    resetFields : function(component) {
        var invoices = component.get("v.invoices");
        for(var i=0; i<invoices.length; i++) {
            invoices[i].selected = false;
            invoices[i].inputPaymentAmount = invoices[i].invoice.Zuora__Balance2__c;
        }
        component.set("v.invoices",invoices);

        invoices = component.get("v.invoicePageList");
        for(var i=0; i<invoices.length; i++) {
            invoices[i].selected = false;
            invoices[i].inputPaymentAmount = invoices[i].invoice.Zuora__Balance2__c;
        }
        component.set("v.invoicePageList",invoices);

        var invPayments = [];
        component.set("v.invoicePayments",invPayments);
        component.set("v.errorMsg","");
        component.set("v.paymentError",false);
    },
    makePayment : function(component, event, helper) {
        var invoices = component.get("v.invoicePayments");
        var payments = [];
        for(var i=0; i<invoices.length; i++) {
            payments.push(invoices[i]);
        }
        // SHOW SPINNER
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.savePayments",function(response,error) {
            // refresh list
            // HIDE SPINNER
	        helper.hideSpinner(component, event, helper);
            if(error) {
                helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                helper.initializeComponents(component, event, helper, response);
                helper.resetFields(component);
                helper.toggleMakePaymentMode(component);
            }
        },
        {
            recordId: component.get('v.recordId'),
            jsonObject: JSON.stringify(payments),
            paymentMethodId: component.get("v.billingWrapper.paymentMethodId")
        });
    },
    initializeComponents : function(component, event, helper, response) {
        console.log("[CCBillingManagementHelper.initializeComponents] response: "+JSON.stringify(response));
        component.set("v.billingWrapper", response);
        component.set("v.invoices", response.invoices);
        component.set("v.total",response.invoices.length);
        component.set("v.numberOfPages",Math.ceil(component.get("v.total") / component.get("v.numberPerPage")));
        helper.loadList(component,event,helper);
        
        // Create payment method types for radio button composition
        var typeMap = response.paymentMethodOptions;
        var methodTypes = [];
        for(var singleKey in typeMap) {
            methodTypes.push({
                key: singleKey,
                value: typeMap[singleKey]
            });
        }
        component.set("v.pmTypes",methodTypes);

        // enable/disable buttons
        component.set("v.disableMakePaymentListBtn",true);
        component.set("v.disableMakePayment",true);
        if(response.total.Zuora__Balance2__c > 0) {
            component.set("v.disableMakePaymentListBtn",false);
        }
        if(methodTypes.length > 0) {
            component.set("v.disableMakePayment",false);
        }
    },
})