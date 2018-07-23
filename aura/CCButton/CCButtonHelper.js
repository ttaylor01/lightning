({
    validateComponent : function(component) {
        var valid = true;

         if (component.isValid()) {
            valid =  ( component.get("v.btnText") != undefined && component.get("v.btnText") != '')
                        || ( component.get("v.endpoint") != undefined && component.get("v.endpoint") != '');
        }
         return valid;
    },
})