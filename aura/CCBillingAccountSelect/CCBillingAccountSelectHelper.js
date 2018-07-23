({
    getAccounts : function(component, event, helper) {
        // Display all cases for selected status
        helper.callServer(component,"c.getBillingAccounts",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
	            component.set("v.accounts", response);
            }
        },
        {
            recordId: component.get('v.recordId')
        });
    },
})