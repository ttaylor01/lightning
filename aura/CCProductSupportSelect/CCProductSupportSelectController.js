({
    doInit : function(component, event, helper) {
        // call the helper class to setup the case object for creation
        helper.getProductPicklistValues(component, event, helper);
	},
    onProductChange: function(component, event, helper) {
        var product = event.getSource().get("v.value");
        console.log("Product: "+product);
        // Let's go ahead and remove the previous content
        // Instead of destroying component and preventing from creating new components just remove body content.
        component.find("caseCreateCmp").set("v.body",[]);
        // Also hide all static content.  We'll handle visibility below based on user selection
        $A.util.addClass(component.find("selectProductMessage"),'hidden');
        $A.util.addClass(component.find("stayTunedMessage"),'hidden');
        
        // Create Case Create Component
        if(product === '') {
            // Display default message
            $A.util.removeClass(component.find("selectProductMessage"),'hidden');
        } else if(product === 'Patient Access' || product === 'Provider Authorization') {
            helper.showComponent(component,"c:CCProductSupportCreate","caseEditView",
                                 {
                                     "aura:id": "caseEditView",
                                     "productSelect": product
                                 });
        } else {
            // Unsupported Product selection.  Display message
            $A.util.removeClass(component.find("stayTunedMessage"),'hidden');
        }
    },
	backToList : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "List",
            "listView": component.get('v.viewSelect')
        });   
        compEvent.fire();  
	},
})