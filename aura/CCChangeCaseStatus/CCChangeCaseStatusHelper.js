({
    saveCase : function(component, event, helper) {
        // Display all cases for selected status
        console.log("[CCChangeCaseStatus.saveCase] case: "+JSON.stringify(component.get('v.cs')));
        var cs = component.get('v.cs');
        var sObj = {
            'sobjectType':'Case',
            'Id':cs.Id,
            'Status':cs.Status
        };
        component.set("v.cs",sObj);
        console.log("[CCChangeCaseStatus.saveCase] case: "+JSON.stringify(component.get('v.cs')));
        helper.callServer(component,"c.saveCaseStatus",function(response,error) {
            if(error) {
                helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                component.set("v.cs", response);
            }
        },
        {
            cs: component.get('v.cs'),
            status: component.get('v.status'),
            body: component.get('v.body')
        });
    },
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.cs") !== undefined && component.get("v.cs") !== '');
        }
        return valid;
    },
    hideDialog : function(component, event) {
        var compEvent = component.getEvent("hideChangeCaseStatusDialog");
        compEvent.setParams({
            'recordId': component.get('v.cs.Id')
        });
        compEvent.fire();  
    }
})