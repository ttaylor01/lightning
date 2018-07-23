({
    /**
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        console.log('--Inside Search method of Controller---' + event.getSource());
        helper.doSearch(cmp); 
    },
    
    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
        console.log('--Inside selection method of Controller---' + event.currentTarget.id);
        helper.doSelection(cmp, event);
    },
    
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp);    
    },

    /**
     * Exposed methods to set and clear error messages on the input component
     */
    setError : function(component, event, helper) {
		var params = event.getParam('arguments');
        if (params && params.msg) {
            component.set("v.errorMsg",params.msg);
            component.set("v.lookupError",true);
            var inputCmp = component.find('lookup');
            $A.util.addClass(inputCmp, "hasError"); // add red border
        } else {
            throw new Error("No arguments passed!");
        }
    },
    clearError : function(component, event, helper) {
        component.set("v.lookupError",false);
        var inputCmp = component.find('lookup');
        $A.util.removeClass(inputCmp, "hasError"); // add red border
    }

})