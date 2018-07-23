({
    addComment : function(component, event, helper) {
        // Display all cases for selected status
        helper.doWait(component);
        helper.callServer(component,"c.addComment",function(response,error) {
            helper.stopWait(component);
            if(error) {
                helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
//                component.set("v.cs", response);
            }
        },
        {
            recordId: component.get('v.recordId'),
            body: component.get('v.body')
        });
    },
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.recordId") !== undefined && component.get("v.recordId") !== '');
        }
        return valid;
    },
    hideDialog : function(component, event) {
        component.set('v.body','');
        var compEvent = component.getEvent("hideAddCommentDialog");
        compEvent.setParams({
            'recordId': component.get('v.recordId')
        });
        compEvent.fire();  
    },
    doWait : function(component) {
        var evt = component.getEvent("showSpinner");
        evt.fire();
    },
    stopWait : function(component) {
        var evt = component.getEvent("hideSpinner");
        evt.fire();
    }
})