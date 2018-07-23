({
    fetchPickListVal: function(component) {
      /* call the apex getselectOptions method which is returns picklist values
         set the picklist values on "picklistOptsList" attribute [String list].
         which attribute used for iterate the select options in component.
       */  
        var action = component.get("c.getSelectOptions");
        action.setParams({
             "objObject": {sobjectType : component.get('v.obj')},
             "fld": component.get('v.fld')
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                component.set("v.picklistOptsList", opts);
            }
        });
        $A.enqueueAction(action);
    },
    refresh : function(component, event, helper) {
        var ph = 'Select one or more ' + component.get('v.label');
        //       $(".select2Class").select2({
        var tmpStr = '[id$='+component.get('v.selectId')+']';
        console.log("CCSelect2.refresh tmpStr: "+tmpStr);
        $(tmpStr).select2({
            placeholder: ph,
            allowClear: true
        });
    },
})