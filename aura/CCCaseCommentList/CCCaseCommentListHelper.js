({
    getCaseComments : function(component, event, helper) {
        // Display all case comments
        helper.callServer(component,"c.getCaseComments",function(response) {
            component.set("v.casecomments", response);
        },
        {
            recordId: component.get('v.recordId')
        });
    },
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.recordId") !== undefined && component.get("v.recordId") !== '');
        }
        return valid;
    },
})