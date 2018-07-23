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
        helper.getPaymentList(component, event, helper);
    },
	backToManageBilling : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "accountDetail",
            "sObjectId": component.get("v.recordId")
        });
        compEvent.fire();
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
})