({
    doInit : function(component, event, helper) {
        if( component.get("v.recordId") === undefined || component.get("v.recordId") === '') {
            // no case id, See if it is set in the URL parameter
            var oId = helper.getParameterByName(component, 'recordId', window.location.href);
            if (oId != null) {
                component.set("v.recordId", oId);
                var newUrl = helper.refreshUrl();
            }
        }
        // call the helper function
        helper.getInvoiceList(component, event, helper);
    },
    doSearch : function(component, event, helper) {
        // Only search if ENTER key pressed or if search button selected
        var doSearch = false;
        // Check if key entered
        if(event.getParams().keyCode) {
            // Do search if ENTER key pressed
            if(event.getParams().keyCode === 13) {
                doSearch = true;
            }
        } else {
            // Search button must have been selected
            doSearch = true;
        }

        if(doSearch) {
            event.preventDefault();
            // Reset the page Number to 1 for new search terms
            // get the select option (drop-down) values.   
            helper.getInvoiceList(component, event, helper);
        }
    },
    doManagePaymentMethods : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "paymentMethods",
            "sObjectId": component.get("v.recordId")
        });   
        compEvent.fire();
    },
	backToAccount : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "accountDetail",
            "sObjectId": component.get("v.recordId")
        });
        compEvent.fire();
	},
	doViewPayments : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "paymentList",
            "sObjectId": component.get("v.recordId")
        });
        compEvent.fire();
	},
    setMakePaymentMode : function(component, event, helper) {
        var invoices = component.get("v.invoices");
        var hasSelected = false;
        var invPayments = [];
        for(var i=0; i<invoices.length; i++) {
            var inv = invoices[i];
            if(inv.selected) {
                hasSelected = true;
                inv.inputPaymentAmount = inv.invoice.Zuora__Balance2__c;
                invPayments.push(inv);
            }
        }
        if(hasSelected) {
            helper.toggleMakePaymentMode(component);
            component.set("v.invoicePayments",invPayments);
        } else {
            helper.displayErrorDialog('Please Select an Invoice','Select one or more Invoices to apply a payment.','error');
        }
    },
    doCancelMakePayment : function(component, event, helper) {
        helper.resetFields(component);
        helper.toggleMakePaymentMode(component);
    },
    onMakePaymentMethodChange : function(component, event, helper) {
        var selected = event.target.id;
        console.log("[CCBillingManagement.onMakePaymentMethodChange] selected: "+selected);
        var selectedValue = selected.replace(component.get("v.uniquePageId"),""); 
        console.log("[CCBillingManagement.onMakePaymentMethodChange] selectedValue: "+selectedValue);
        component.set("v.billingWrapper.paymentMethodId",selectedValue);
        console.log("[CCBillingManagement.onMakePaymentMethodChange] paymentMethodId: "+component.get("v.billingWrapper.paymentMethodId"));
    },
    doMakePayment : function(component, event, helper) {
        var errorMsg = helper.validateInput(component,helper);
        if(errorMsg === undefined || errorMsg === "") {
            component.set("v.errorMsg","");
            component.set("v.paymentError",false);
            helper.makePayment(component, event, helper);
        } else {
            component.set("v.errorMsg",errorMsg);
            component.set("v.paymentError",true);
            helper.displayErrorDialog('IMPORTANT!','Please correct invalid input','error');
        }
    },
    doWait : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
    },
    stopWait : function(component, event, helper) {
        helper.hideSpinner(component, event, helper);
    },
    // PAGINATION LOGIC
    previousPage: function(component, event, helper) {
        // this function call on click on the previous page button
        var page = component.get("v.currentPage") || 1;
        // set the current page,(using ternary operator.)  "(page + 1)"
        page = (page - 1);
        component.set("v.currentPage",page);
        // call the helper function
        helper.loadList(component, event, helper);
    },
    nextPage: function(component, event, helper) {
        // this function call on click on the next page button   
        var page = component.get("v.currentPage") || 1;
        // set the current page,(using ternary operator.)  "(page + 1)"
        page = (page + 1);
        component.set("v.currentPage",page);
        // call the helper function
        helper.loadList(component, event, helper);
    },
    onSelectChange: function(component, event, helper) {
        // this function call on the select opetion change,	 
        component.set("v.currentPage",1);
        component.set("v.numberOfPages",Math.ceil(component.get("v.total") / component.get("v.numberPerPage")));
        helper.loadList(component, event, helper);
    },
    onPDFClick : function(component, event, helper) {
        var rowEl = event.currentTarget;
        var invoiceId = rowEl.getAttribute('data-pk');
        console.log("[CCBillingManagement.onPDFClick] invoiceId: "+invoiceId);
//        window.open("/success/apex/CCViewInvoice?invId="+invoiceId, '_blank');

        helper.callServer(component,"c.getInvoicePDF",function(response,error) {
            if(error) {
                // do some error processing
                console.log("[CCBillingManagement.onPDFClick] error: "+JSON.stringify(error));
            } else {
                var viewPDFUrl = "/success/sfc/servlet.shepherd/version/download/"+response;
                console.log("[CCBillingManagement.onPDFClick] viewFileUrl: "+viewPDFUrl);
                window.open(viewPDFUrl, "_blank");
/*
                var fileName = invoiceId+".pdf";
                if (window.navigator && window.navigator.msSaveOrOpenBlob) { // IE workaround
                    var byteCharacters = atob(data);
                    var byteNumbers = new Array(byteCharacters.length);
                    for (var i = 0; i < byteCharacters.length; i++) {
                        byteNumbers[i] = byteCharacters.charCodeAt(i);
                    }
                    var byteArray = new Uint8Array(byteNumbers);
                    var blob = new Blob([byteArray], {type: 'application/pdf'});
                    window.navigator.msSaveOrOpenBlob(blob, fileName);
                }
                else { // much easier if not IE
                    window.open("data:application/pdf;base64, " + data, '', "height=600,width=800");
                }
*/
            }
        },
        {
            recordId: invoiceId
        });

    },
})