({
    callServer : function(component,method,callback,params) {
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
    /**
    * Extract the parameter value from the URL string by parameter name
    */
    getParameterByName : function (component, name, url) {
        if (!url) {
            url = window.location.href;
        }
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    /**
    * Helper function to drop the parameter string including '?' character
    * www.example.com/file.php?f_id=55 will become www.example.com/file.php
    * Then reset the current URL without inserting new history or refreshing page.
    */
    refreshUrl : function() {
        //get full url
        var href = window.location.href;
        // strip URL of parameter string
        var newUrl = href.substring(0, href.indexOf('?'));
        // Do not insert a new history entry and just modify the current one
        window.history.replaceState({}, '', newUrl);
        return newUrl;
    },
    /**
    * Display a message
    */
    displayErrorDialog : function (title, message, type) {
        if (typeof type === 'undefined' || type.length === 0) {
            type = 'other';
        }
        var toast = $A.get("e.force:showToast");
        
        // For lightning1 show the toast
        if (toast)
        {
            //fire the toast event in Salesforce1
            toast.setParams({
                "type": type,
                "title": title,
                "message": message,
                "duration": 10000
            });
            
            toast.fire();
        }
        else // otherwise throw an alert
        {
            alert(title + ': ' + message);
        }
    },
    getFormattedDate : function getFormattedDate(date) {
        var options = {
            year: "numeric", month: "numeric",
            day: "numeric", hour: "2-digit", minute: "2-digit"
        };
        return date.toLocaleDateString("en-US",options);
    },
    showSpinner : function (component, event, helper) {
        var spinner = component.find("spinner");
        if($A.util.hasClass(spinner, 'slds-hide')) {
            $A.util.removeClass(spinner, "slds-hide");
        } else {
        }
    },
    hideSpinner : function (component, event, helper) {
        var spinner = component.find("spinner");
        if($A.util.hasClass(spinner, 'slds-hide')) {
        } else {
            $A.util.addClass(spinner, "slds-hide");
        }
    },
})