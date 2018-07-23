({
    getCaseAttachments : function(component, event, helper) {
        // Display all case comments
        helper.callServer(component,"c.getCaseAttachments",function(response) {
            component.set("v.attachments", response);
            var viewFileUrl = '';
            if(component.get("v.siteUrlPrefix") !== undefined && component.get("v.siteUrlPrefix") !== '') {
                viewFileUrl = '/' + component.get("v.siteUrlPrefix") + '/servlet/servlet.FileDownload?file=';
            } else {
                viewFileUrl = '/servlet/servlet.FileDownload?file=';
            }
            component.set("v.viewFileURL",viewFileUrl);
        },
        {
            recordId: component.get('v.recordId')
        });
    },
    deleteAttachment : function(component, event, helper, attId) {
        console.log("deleteAttachment Id: "+attId);
        // SHOW SPINNER
        helper.doWait(component);
        // Display all case comments
        helper.callServer(component,"c.deleteAttachment",function(response,error) {
            // refresh list
            // HIDE SPINNER
            helper.stopWait(component);
            if(error) {
                helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                component.set("v.attachments", response);
            }
        },
        {
            recordId: component.get('v.recordId'),
            attachmentId: attId
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
    }
})