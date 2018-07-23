({
    doInit : function(component, event, helper) {
        // call the helper class to setup the case object for creation
        helper.getCase(component, event, helper);
        helper.getBriefDescriptionPicklistValues(component, 'Case_Reason__c', 'Case_Brief_Description__c');
        helper.getSubmissionMethodPicklistValues(component, 'Case_Reason__c', 'Case_Submission_Method__c');
        helper.getTransactionPicklistValues(component, event, helper);
	},
    doSave : function(component, event, helper) {
        var isValid = helper.validateInput(component,helper);
        if(isValid) {
            // create case
            helper.saveCase(component, event, helper);
        } else {
            helper.displayErrorDialog('IMPORTANT!','Please correct invalid input','error');
        }
    },
    doCancel : function(component, event, helper) {
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "List",
            "listView": component.get('v.viewSelect')
        });
        compEvent.fire();
    },
    setVisibility : function(component, event, helper) {
        helper.toggleVisibility(component);
    },
    onReasonChange: function(component, event, helper) {
        // Handle change in field visibility
        helper.toggleVisibility(component);

        // get the selected value
        var controllerValueKey = event.getSource().get("v.value");

        /*
         * Handle setting Brief Description
         */
        // get the map values
        var Map = component.get("v.briefDescriptionFieldMap");
        
        // check if selected value is not equal to None then call the helper function.
        // if controller field value is none then make dependent field value is none and disable field
        var resetDependentFields = false;
        if (controllerValueKey !== '--- None ---' && controllerValueKey !== '') {
            
            // get dependent values for controller field by using map[key].  
            // for i.e "USA" is controllerValueKey so in the map give key Name for get map values like 
            // map['USA'] = its return all dependent picklist values of states in USA.
            var listOfDependentFields = Map[controllerValueKey];
            // Handle when there are no dependent values
            if(listOfDependentFields === undefined || (listOfDependentFields.length === 0 )) {
                resetDependentFields = true;
            }
            helper.fetchBriefDescriptionValues(component, listOfDependentFields);
            
        } else {
            resetDependentFields = true;
        }
        if(resetDependentFields) {
            var defaultVal = [{
                class: "optionClass",
                label: '--- None ---',
                value: ''
            }];
            component.find('briefdescription').set("v.options", defaultVal);
            component.find('briefdescription').set("v.errors", null);
            component.set("v.isBriefDescriptionDisable", true);
        }
        
        /*
         * Handle setting Submission Method independently as it is not controlled by Brief Description
         */
        // get the map values
        var subMap = component.get("v.submissionMethodFieldMap");
        
        // check if selected value is not equal to None then call the helper function.
        // if controller field value is none then make dependent field value is none and disable field
        resetDependentFields = false;
        if (controllerValueKey !== '--- None ---' && controllerValueKey !== '') {
            
            // get dependent values for controller field by using map[key].  
            // for i.e "USA" is controllerValueKey so in the map give key Name for get map values like 
            // map['USA'] = its return all dependent picklist values of states in USA.
            var listOfDependentFields = subMap[controllerValueKey];
            // Handle when there are no dependent values
            if(listOfDependentFields === undefined || (listOfDependentFields.length === 0 )) {
                resetDependentFields = true;
            }
            console.log("Map for submissionMethod: "+JSON.stringify(listOfDependentFields));
            helper.fetchSubmissionMethodValues(component, listOfDependentFields);
            
        } else {
            resetDependentFields = true;
        }
        if(resetDependentFields) {
            var defaultVal = [{
                class: "optionClass",
                label: '--- None ---',
                value: ''
            }];
            component.find('submissionmethod').set("v.options", defaultVal);
            component.find('submissionmethod').set("v.errors", null);
            component.set("v.isSubmissionMethodDisable", true);
        }
    },
    
    // function call on change tha Dependent field    
    onBriefDescriptionChange: function(component, event, helper) {
        console.log("Brief Description: "+event.getSource().get("v.value"));
        // Handle change in field visibility
        helper.toggleVisibility(component);
    },
    // function call on change the Dependent field
    onSubmissionMethodChange: function(component, event, helper) {
        console.log("Submission Method: "+event.getSource().get("v.value"));
        // Handle change in field visibility
        helper.toggleVisibility(component);
    },

})