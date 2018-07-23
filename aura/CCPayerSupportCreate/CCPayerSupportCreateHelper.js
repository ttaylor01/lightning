({
    getCase : function(component, event, helper) {
        // Display all cases for selected status
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.getCase",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                // For some reason you have to set individual fields because setting the whole case
                // causes an 'Unable to read sObject' error when passing the case to apex controller upon save
                component.set("v.cs.RecordTypeId",response.RecordTypeId);
                component.set("v.cs.Contact",response.Contact);
                component.set("v.cs.CID_Identifier__c",response.CID_Identifier__c);
                console.log("[CCPayerSupportCreateHelper.getCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
            }
        },
        {
        });
    },
    saveCase : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        console.log("[CCPayerSupportCreateHelper.saveCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
        var caseObj = component.get('v.cs');
        // To help ensure we don't get the dreaded 'Unable to read sObject', set the sobjectType
        caseObj.sobjectType = 'Case';
        helper.callServer(component,"c.saveCase",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                // Woohoo.  Let's navigate to detail page
                var compEvent = component.getEvent("goToTarget");
                console.log("[CCPayerSupportCreateHelper.saveCase] Created case Id: "+response.Id);
                compEvent.setParams({
                    "sObjectId": response.Id,
                    "targetView": "Detail",
                    "listView": component.get('v.viewSelect')
                });
                compEvent.fire();
            }
        },
        {
            'cs': caseObj
        });
    },

    toggleVisibility : function(component) {
        this.resetVisibility(component);
        if(component.get("v.cs.Call_Reason__c") === "" || component.get("v.cs.Call_Reason__c") === "--- None ---") {
            this.resetFields(component);
        }
        if(component.get("v.cs.Call_Reason__c") === "Other") {
            component.set("v.otherVisibility",true);
        } else {
            this.resetFields(component);
        }
    },
    resetVisibility : function(component) {
        // Reset all visibility sections
        component.set("v.otherVisibility",false);
    },
    resetFields : function(component) {
        // Reset All fields on Case
        component.set("v.cs.Transaction__c",'');
    },
   
    validateInput : function(component, helper) {
        var allValid = true;
        var inputCmp = component.find("reason");
        var inputValue = inputCmp.get("v.value");
        if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
            inputCmp.set("v.errors", [{message:"Please select a Reason"}]);
            allValid = allValid && false;
        } else {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        }
        console.log("validateInput REASON? "+allValid);

        inputCmp = component.find("briefdescription");
        inputValue = inputCmp.get("v.value");
        var inputDisabled = inputCmp.get("v.disabled");
        if(inputDisabled === true) {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        } else {
	        if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
	            inputCmp.set("v.errors", [{message:"Please select a Brief Description"}]);
	            allValid = allValid && false;
	        } else {
	            inputCmp.set("v.errors", null);
	            allValid = allValid && true;
	        }
        }
        console.log("validateInput BRIEF DESCRIPTION? "+allValid);

        inputCmp = component.find("submissionmethod");
        inputValue = inputCmp.get("v.value");
        var inputDisabled = inputCmp.get("v.disabled");
        if(inputDisabled === true) {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        } else {
	        if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
	            inputCmp.set("v.errors", [{message:"Please select a Submission Method"}]);
	            allValid = allValid && false;
	        } else {
	            inputCmp.set("v.errors", null);
	            allValid = allValid && true;
	        }
        }
        console.log("validateInput SUBMISSION METHOD? "+allValid);

        var subjectCmp = component.find('subject');
        subjectCmp.showHelpMessageIfInvalid();
        allValid = allValid && subjectCmp.get('v.validity').valid;
        var descCmp = component.find('description');
        descCmp.showHelpMessageIfInvalid();
        allValid = allValid && descCmp.get('v.validity').valid;
        console.log("validateInput allValid? "+allValid);
        return allValid;
    },
    getTransactionPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "--- None ---",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "270/271",value: "270/271"});
        picklistValues.push({class: "optionClass",label: "276/277",value: "276/277"});
        picklistValues.push({class: "optionClass",label: "278",value: "278"});
        picklistValues.push({class: "optionClass",label: "835",value: "835"});
        picklistValues.push({class: "optionClass",label: "837",value: "837"});
        picklistValues.push({class: "optionClass",label: "ADT",value: "ADT"});
        picklistValues.push({class: "optionClass",label: "Payer Spaces",value: "Payer Spaces"});
        picklistValues.push({class: "optionClass",label: "Other",value: "Other"});
        component.find("transaction").set("v.options", picklistValues);
    },
    getBriefDescriptionPicklistValues: function(component, controllerField, dependentField) {
        // call the server side function
        var action = component.get("c.getDependentOptions");
        // pass parameters [object name , controller field name ,dependent field name] -
        // to server side function 
        
        action.setParams({
            'objApiName': component.get("v.objInfo"),
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField
        });
        //set callback
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to briefDescriptionFieldMap attribute 
                component.set("v.briefDescriptionFieldMap", StoreResponse);

                // SET ROOT CONTROLLING FIELD BASED ON INITIAL MAP
                // No need to set remaining controlling fields
                // create a empty array for store map keys(@@--->which is controller picklist values)
                
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on ui field.
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for ui:inputSelect  
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
                // set the ControllerField variable values (controller picklist field)
                component.find('reason').set("v.options", ControllerField);
            }
        });
        $A.enqueueAction(action);
    },
    fetchBriefDescriptionValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field)  
        var dependentFields = [];
        
        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            dependentFields.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            
        }
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push({
                class: "optionClass",
                label: ListOfDependentFields[i],
                value: ListOfDependentFields[i]
            });
        }
        // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
        component.find('briefdescription').set("v.options", dependentFields);
        // make disable false for ui:inputselect field 
        component.set("v.isBriefDescriptionDisable", false);
    },
    getSubmissionMethodPicklistValues: function(component, controllerField, dependentField) {
        // call the server side function
        var action = component.get("c.getDependentOptions");
        // pass parameters [object name , controller field name ,dependent field name] -
        // to server side function 
        
        action.setParams({
            'objApiName': component.get("v.objInfo"),
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField
        });
        //set callback
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to briefDescriptionFieldMap attribute 
                component.set("v.submissionMethodFieldMap", StoreResponse);
                
            }
        });
        $A.enqueueAction(action);
    },
    fetchSubmissionMethodValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field)  
        var dependentFields = [];
        
        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            dependentFields.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            
        }
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push({
                class: "optionClass",
                label: ListOfDependentFields[i],
                value: ListOfDependentFields[i]
            });
        }
        // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
        component.find('submissionmethod').set("v.options", dependentFields);
        // make disable false for ui:inputselect field 
        component.set("v.isSubmissionMethodDisable", false);
    },

    isValidDate : function(dateString) {
        // First check for existence of value
        if(dateString === undefined || dateString === "") {
            return false;
        }
        // First check for the pattern: yyyy-mm-dd
//        if(!/^\d{1,2}\/\d{1,2}\/\d{4}$/.test(dateString)) {
        if(!/^\d{4}\-\d{1,2}\-\d{1,2}$/.test(dateString)) {
            return false;
        }
        
        // Parse the date parts to integers (format: yyyy-mm-dd)
        var parts = dateString.split("-");
        var year = parseInt(parts[0], 10);
        var month = parseInt(parts[1], 10);
        var day = parseInt(parts[2], 10);
        console.log("dateString parts: "+parts);
        
        // Check the ranges of month and year
        if(year < 1000 || year > 3000 || month == 0 || month > 12)
            return false;
        
        var monthLength = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];
        
        // Adjust for leap years
        if(year % 400 == 0 || (year % 100 != 0 && year % 4 == 0))
            monthLength[1] = 29;
        
        // Check the range of the day
        return day > 0 && day <= monthLength[month - 1];
    },
})