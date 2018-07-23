({
    getCase : function(component, event, helper) {
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCBillingSupportDetail",
                method: "getCase",
                input: { 
                    recordId: component.get('v.recordId')
                }
            },
	        pleaseWait: { type: "Spinner", message: "Finding ticket, please wait" },
            callBackMethod: function (response) {
                component.set("v.cs", response.output);
                helper.setButtonVisibility(component);
                component.set("v.whereClause",'Id IN (Select ContactId FROM User WHERE Billing_Authorization__c = true)');
            },
            callBackError: function (serverResponse, errorMsg) {
                var msg = 'We are experiencing system errors.  Please try again or contact customer service for assistance';
                helper.displayErrorDialog('IMPORTANT!',msg,'error');
            }
        });
    },
    saveCase : function(component, event, helper) {
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCBillingSupportDetail",
                method: "saveCase",
                input: { 
                    recordId: component.get('v.recordId')
                },
                records: [component.get('v.cs')]
            },
	        pleaseWait: { type: "Spinner", message: "Finding ticket, please wait" },
            callBackMethod: function (response) {
                component.set("v.cs", response.output);
            },
            callBackError: function (serverResponse, errorMsg) {
                var msg = 'We are experiencing system errors.  Please try again or contact customer service for assistance';
                helper.displayErrorDialog('IMPORTANT!',msg,'error');
                // reset values from dirty input
                helper.getCase(component, event, helper);
            }
        });
    },
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.recordId") !== undefined && component.get("v.recordId") !== '');
        }
        return valid;
    },
    showRelatedLists : function(component) {
        // Dynamically create case comments component.
        // This is called once the init has run and captured the recordId
        $A.createComponent(
            "c:CCCaseCommentList",
            {
                "recordId": component.get('v.recordId'),
                "caseStatus": component.get('v.cs.Status')
            },
            function(newComp) {
                var content = component.find("caseCommentListCmp");
                content.set("v.body", newComp);
            }
        );

        $A.createComponent(
            "c:CCFileAttachmentList",
            {
                "recordId": component.get('v.recordId'),
                "caseStatus": component.get('v.cs.Status'),
                "siteUrlPrefix": 'success'
            },
            function(newComp, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log("CCBillingSupportDetail.showRelatedLists newComp: "+newComp);
                    var content = component.find("fileAttachmentListCmp");
                    content.set("v.body", newComp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("CCBillingSupportDetail.showRelatedLists No response from server or client is offline.");
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("CCCaseDetail.showRelatedLists Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
    toggleEditMode : function(component) {
        $A.util.toggleClass(component.find("btnSave"), "hide-button");
        $A.util.toggleClass(component.find("btnCancel"), "hide-button");
        $A.util.toggleClass(component.find("btnEdit"), "hide-button");
        $A.util.toggleClass(component.find("btnCloseCase"), "hide-button");
        $A.util.toggleClass(component.find("btnChangeContact"), "hide-button");
//        $A.util.toggleClass(component.find("outputAlternateEmail"), "hide-component");
        $A.util.toggleClass(component.find("inputAlternateEmail"), "hide-component");
        $A.util.toggleClass(component.find("inputBillingAccount"), "hide-component");
    },
    setButtonVisibility : function(component) {
        var csStatus = component.get("v.cs.Status");
        component.set("v.archiveVisibility",(csStatus==='Closed')?true:false);
        component.set("v.openVisibility",(csStatus!=='Closed' && csStatus!=='Archived')?true:false);
        var days = 0;
        if(csStatus==='Closed' || csStatus==='Archived') {
            console.log("ClosedDate: "+component.get("v.cs.ClosedDate"));
            var closedDate = new Date(component.get("v.cs.ClosedDate"));
            var currentDate = new Date();
//            currentDate.setDate(currentDate.getDate()+15);
            console.log("closedDate: "+closedDate);
            console.log("currentDate: "+currentDate);
            var milliseconds = currentDate.getTime() - closedDate.getTime();
            var seconds = milliseconds / 1000;
            var minutes = seconds / 60;
            var hours = minutes / 60;
            days = hours / 24;
            console.log("days: "+days);
        }
        component.set("v.reopenVisibility",((csStatus==='Closed' || csStatus==='Archived')&&days<14)?true:false);
//        component.set("v.reopenVisibility",(csStatus==='Closed' || csStatus==='Archived')?true:false);
    },
    hideComponents : function(component) {
    }
})