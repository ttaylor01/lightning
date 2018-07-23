({
    getAttachments : function(component, event, helper) {
        console.log("[CCFileAttachmentList.getAttachments] recordId: "+component.get('v.recordId'));
        // Display all case comments
        helper.callServerController(component,"c.getFileAttachments",function(response,error) {
            if(error) {
                console.log("[CCFileAttachmentList.getAttachments] error: "+JSON.stringify(error));
            } else {
                console.log("[CCFileAttachmentList.getAttachments] files: "+JSON.stringify(response));
                component.set("v.attachments", response);

            var viewFileUrl = '';
            if(component.get("v.siteUrlPrefix") !== undefined && component.get("v.siteUrlPrefix") !== '') {
                viewFileUrl = '/' + component.get("v.siteUrlPrefix") + '/sfc/servlet.shepherd/version/download/';
            } else {
                viewFileUrl = '/sfc/servlet.shepherd/version/download/';
            }
            component.set("v.viewFileURL",viewFileUrl);
            }
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
    doWait : function(component) {
        var evt = component.getEvent("showSpinner");
        evt.fire();
    },
    stopWait : function(component) {
        var evt = component.getEvent("hideSpinner");
        evt.fire();
    },
    callServerController : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue(),null);
            } else if (state === "ERROR") {
                // generic error handler
                var errorMsg = "Unknown Error";
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMsg = errors[0].message;
//                        throw new Error("Error" + errors[0].message);
                    }
                }
                // pass error value to callback function
                callback.call(this,null,errorMsg);
            }
        });
        
        $A.enqueueAction(action);
    },
})