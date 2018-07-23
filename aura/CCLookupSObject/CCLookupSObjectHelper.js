({
    /**
    * Search SObject
    */
    doSearch : function(cmp) {
        console.log('--Inside doSearch method---');
        // Get the search string, input element and the selection container
        var searchString = cmp.get("v.searchString");
        var inputElement = cmp.find('lookup');
        var lookupList = cmp.find("lookuplist");
        var lookupListItems = cmp.find("lookuplist-items");
        var whereClause = cmp.get("v.customFilter");
        
        // Clear any errors 
        inputElement.set('v.errors', null);
        
        // min 2 characters is required for an effective search
        if (typeof searchString === 'undefined' || searchString.length < 2)
        {
            // Hide the lookuplist
            $A.util.addClass(lookupList, 'slds-hide');
            return;
        }
        // Show the lookuplist
        $A.util.removeClass(lookupList, 'slds-hide');
        
        // Get the API Name
        var sObjectAPIName = cmp.get('v.sObjectAPIName');
        
        // Create an Apex action
        var action;
        
        // Set the parameters
        if(whereClause === undefined || whereClause === "" || whereClause === null) {
            action = cmp.get("c.lookup");
            // Mark the action as abortable, this is to prevent multiple events from the keyup executing
            action.setAbortable();
	        action.setParams({ "searchString" : searchString, "sObjectAPIName" : sObjectAPIName});
        } else {
            action = cmp.get("c.lookupWithClause");
            // Mark the action as abortable, this is to prevent multiple events from the keyup executing
            action.setAbortable();
            action.setParams({ "searchString" : searchString, "sObjectAPIName" : sObjectAPIName, "whereClause" : whereClause});
        }
        
        // Define the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            // Callback succeeded
            if (cmp.isValid() && state === "SUCCESS")
            {
                // Get the search matches
                var matchingResult = response.getReturnValue();
                
                // If we have no matches, return
                if (matchingResult.length == 0)
                {
                    cmp.set('v.matchingResult', null);
                    return;
                }
                
                // Set the results in matchingResult attribute of component
                console.log('--Result found--'+matchingResult);
                cmp.set('v.matchingResult', matchingResult);
                console.log('--Result found2--'+cmp.get('v.matchingResult'));
            }
            else if (state === "ERROR") // Handle any error 
            {
                var errors = response.getError();
                
                if (errors) 
                {
                    if (errors[0] && errors[0].message) 
                    {
                        this.displayErrorDialog('Error', errors[0].message);
                    }
                }
                else
                {
                    this.displayErrorDialog('Error', 'Unknown error.');
                }
            }
        });
        
        // Enqueue the action 
        $A.enqueueAction(action); 
    },
    
    /**
    * Handle the Selection of an searched Item
    */
    doSelection : function(cmp, event) {
        // Resolve the Object Id from the events Element Id (this will be the <> tag)
        var recId = this.getSelectedRecordId(event.currentTarget.id);
        // The Object label is the 2nd child (index 1)
        var recLabel = event.currentTarget.innerText;
        // Log the Object Id and Label to the console
        console.log('recId=' + recId);
        console.log('recLabel=' + recLabel);

        // Create the UpdateLookupId event
        var updateEvent = cmp.getEvent("updateLookupIdEvent");
        // Populate the event with the selected Object Id
        updateEvent.setParams({
            "sObjectId" : recId,
            "fieldAPIName" : cmp.get("v.fieldAPIName")
        });
        // Fire the event
        updateEvent.fire();

        //set the selected record Id
        cmp.set('v.recordId',recId);
        
        // Update the Searchstring with the Label
        cmp.set("v.searchString", recLabel);

        // Hide the Lookup List
        var lookupList = cmp.find("lookuplist");
        $A.util.addClass(lookupList, 'slds-hide');
        
        // Hide the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.addClass(inputElement, 'slds-hide');
        
        // Show the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.removeClass(lookupPill, 'slds-hide');
        
        // Lookup Div has selection
        var inputElement = cmp.find('lookup-div');
        $A.util.addClass(inputElement, 'slds-has-selection');
        
    },
    
    /**
    * Clear the Selection
    */
    clearSelection : function(cmp) {
        // Create the ClearLookupId event
        var clearEvent = cmp.getEvent("clearLookupIdEvent");
        clearEvent.setParams({
            "fieldAPIName" : cmp.get("v.fieldAPIName")
        });
        // Fire the event
        clearEvent.fire();
        
        // Clear the Searchstring
        cmp.set("v.searchString", '');
        cmp.set('v.recordId', null);
        // Hide the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.addClass(lookupPill, 'slds-hide');
        
        // Show the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.removeClass(inputElement, 'slds-hide');
        
        // Lookup Div has no selection
        var inputElement = cmp.find('lookup-div');
        $A.util.removeClass(inputElement, 'slds-has-selection');
    },
    
    /**
    * Resolve the Object Id from the Element Id by splitting the id at the _
    */
    getSelectedRecordId : function(recId) {
        var i = recId.lastIndexOf('_');
        return recId.substr(i+1);
    },
    
    /**
    * Display a message
    */
    displayErrorDialog : function (title, message) {
        var toast = $A.get("e.force:showToast");
        
        // For lightning1 show the toast
        if (toast)
        {
            //fire the toast event in Salesforce1
            toast.setParams({
                "title": title,
                "message": message
            });
            
            toast.fire();
        }
        else // otherwise throw an alert
        {
            alert(title + ': ' + message);
        }
    }
})