({
    MAX_FILE_SIZE:  4500000, /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE:  450000, /* Use a multiple of 4 */
    
    addAttachment : function(component, event, helper) {
        // using the lighting:input type="file"
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
    
        var fr = new FileReader();
        var self = this;
        fr.onload = $A.getCallback(function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(component, file, fileContents, helper);
        });

        fr.readAsDataURL(file);
    },
    upload : function(component, file, fileContents, helper) {
        console.log('uploading file ...');

        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
        
        console.log('fromPos  '+fromPos);
        console.log('toPos  '+toPos);

        // SHOW SPINNER
        helper.doWait(component);
        // start with the initial chunk
        this.uploadChunk(component, file, fileContents, fromPos, toPos, helper, '');
    },
    uploadChunk : function(component, file, fileContents, fromPos, toPos, helper, attachId) {
        var action = component.get("c.saveTheChunk");
        var chunk = fileContents.substring(fromPos, toPos);
        console.log('chunk: '+chunk);
        
        action.setParams({
            recordId: component.get('v.recordId'),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
        
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                attachId = response.getReturnValue();
                console.log('return value:  '+attachId);
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);
                if(fromPos < toPos) {
                    self.uploadChunk(component, file, fileContents, fromPos, toPos, helper, attachId);
                } else {
                    // All chunks have been completed successfully
                    // HIDE SPINNER
                    helper.stopWait(component);

                    var compEvent = component.getEvent("refreshList");
                    compEvent.setParams({
                        "sObjectId": component.get('v.recordId')
                    });
                    compEvent.fire();
                }
            } else if (state === "ERROR") {
                // generic error handler
                var errorMsg = "Unknown Error";
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMsg = errors[0].message;
                    }
                }
                helper.displayErrorDialog('IMPORTANT!',errorMsg,'error');
            }
        });

        $A.enqueueAction(action);
    },
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.recordId") !== undefined && component.get("v.recordId") !== '');
        }
        return valid;
    },
    validateFileSelection : function(component,helper) {
        var valid = true;

        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];

        // First check file extension and file size
        // filename ends with .exe
        var ext = file.name.slice((file.name.lastIndexOf(".") - 1 >>> 0) + 2);
        if(ext === 'exe' || file.type === 'application/x-msdownload') {
            helper.displayErrorDialog('IMPORTANT!','Unsupported file format!\nSelected file format: '+file.type,'error');
            return false;
        }
        if (file.size > this.MAX_FILE_SIZE) {
            helper.displayErrorDialog('IMPORTANT!','File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes or 4.5 megabytes.\n' +
    	          'Selected file size: ' + file.size + ' bytes.','error');
            return false;
        }
        // To ensure no executable files are selected lets look at first four binary characters
        // Executable files begin with '4d5a' or the less common '5a4d'
        // See: https://stackoverflow.com/questions/18299806/how-to-check-file-mime-type-with-javascript-before-upload
        var fr = new FileReader();
        var badInput = false;
        fr.onloadend = function(e) {
            var arr = (new Uint8Array(e.target.result)).subarray(0, 4);
            var header = "";
            for(var i = 0; i < arr.length; i++) {
                header += arr[i].toString(16);
            }
            console.log("file header: "+header);
            if(header.startsWith("4d5a") || header.startsWith("5a4d")) {
                badInput = true;
            }
        };
        fr.readAsArrayBuffer(file);
        if(badInput) {
            helper.displayErrorDialog('IMPORTANT!','Unsupported binary executable file format!','error');
            return false;
        }

        return valid;
    },
    hideDialog : function(component) {
        document.getElementById("fileName").innerHTML = '';
        var compEvent = component.getEvent("hideAddAttachmentDialog");
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