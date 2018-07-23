({
    scriptsLoaded : function(component, event, helper) {
        console.log('CCSelect2:scriptsLoaded - load successfully');
        helper.refresh(component,event,helper);
    },
    
    doInit: function(component, event, helper) {
        helper.fetchPickListVal(component);
    },
    
    getSelectedValues : function(component,event) {
        var selectedOptions = $('[id$='+component.get('v.selectId')+']').select2("val");
        console.log("CCSelect2.getSelectedValues selectedOptions: "+selectedOptions);
        component.set("v.selectedValues",selectedOptions);
        return selectedOptions;
    },
    validateInput : function(component, event, helper) {
        var valid = true;
        if(component.get('v.inputRequired') === false) {
            return true;
        }
        var $select2 = $('[id$='+component.get('v.selectId')+']').select2();
        // reset to hide error messsage and remove class that outlines component in red
        helper.refresh(component,event,helper);
        component.set("v.errorVisibility",false);
        $select2.data('select2').$container.removeClass("hasError");

        var selectedOptions = $('[id$='+component.get('v.selectId')+']').select2("val");
        console.log("CCSelect2:validateInput selectedOptions: "+selectedOptions);
        if(selectedOptions === undefined || selectedOptions === ""
           || selectedOptions === "-- None --" || selectedOptions === null) {
            // Show error messsage and add class to outline component in red
	        component.set("v.errorVisibility",true);
            $select2.data('select2').$container.addClass("hasError");
            valid = false;
        }
        return valid;
    },
})