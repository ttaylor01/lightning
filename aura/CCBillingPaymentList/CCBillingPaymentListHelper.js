({
    getPaymentList : function(component, event, helper) {
        // Display all case comments
        helper.callServer(component,"c.getPayments",function(response,error) {
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
    loadList : function(component, event, helper) {
        var numberOfPages = component.get("v.numberOfPages");
        var numberPerPage = component.get("v.numberPerPage");
        var currentPage = component.get("v.currentPage");
        console.log("[CCBillingPaymentListHelper.loadList] numberPerPage: "+numberPerPage);
        console.log("[CCBillingPaymentListHelper.loadList] currentPage: "+currentPage);
        var begin = (currentPage - 1) * numberPerPage;
        var end = (begin*1) + (numberPerPage*1);
        console.log("[CCBillingPaymentListHelper.loadList] begin: "+begin);
        console.log("[CCBillingPaymentListHelper.loadList] end: "+end);
        var payments = component.get("v.payments");
        var paymentPageList = payments.slice(begin, end);
        component.set("v.paymentPageList",paymentPageList);
        component.set("v.next", (numberOfPages / currentPage === 1) ? true : false );
        component.set("v.prev", (currentPage === 1) ? true : false );
    },
    initializeComponents : function(component, event, helper, response) {
        console.log("[CCBillingPaymentListHelper.initializeComponents] response: "+JSON.stringify(response));
        component.set("v.payments", response);
        component.set("v.total",response.length);
        component.set("v.numberOfPages",Math.ceil(component.get("v.total") / component.get("v.numberPerPage")));
        helper.loadList(component,event,helper);
    },
})