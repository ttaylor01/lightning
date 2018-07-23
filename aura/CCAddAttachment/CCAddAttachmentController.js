({
    doInit : function(component, event, helper) {
        if(helper.validateComponent(component)) {
            // call the helper class to get list of cases
        } else {
            helper.displayErrorDialog('IMPORTANT!','Missing Ticket Record ID.','error');
        }
	},
    handleFilesChange : function(component, event, helper) {
        // using the lighting:input type="file"
//        var fileInput = event.getSource().get("v.files");
//        var file = fileInput[0];

        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
        console.log("fileName: " + file.name);
        console.log("contentType: " + file.type);
        console.log("file size: " + file.size);
        if(helper.validateFileSelection(component,helper)) {
            document.getElementById("fileName").innerHTML = file.name;
        } else {
            document.getElementById("fileName").innerHTML = '';
//            fileInput = null;
        }
    },
    doSave : function(component, event, helper) {
        helper.addAttachment(component, event, helper);
        helper.hideDialog(component);
    },
    doCancel : function(component, event, helper) {
        helper.hideDialog(component);
    },
    showSystemError: function(cmp, event) {
        // Handle system error
        console.log("showSystemError: component: "+JSON.stringify(cmp));
        console.log("showSystemError: event message: "+event.getParam("message"));
        console.log("showSystemError: event error: "+event.getParam("error"));
    }
})