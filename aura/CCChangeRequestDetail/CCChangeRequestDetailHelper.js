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
	            component.set("v.cs", response);
                helper.setButtonVisibility(component);
            }
        },
        {
            recordId: component.get('v.recordId')
        });
    },
    saveCase : function(component, event, helper) {
        // Display all cases for selected status
        helper.showSpinner(component, event, helper);
        helper.callServer(component,"c.saveCase",function(response,error) {
	        helper.hideSpinner(component, event, helper);
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
                // reset values from dirty input
                helper.getCase(component, event, helper);
            } else {
                component.set("v.cs", response);
                helper.setButtonVisibility(component);
            }
        },
        {
            cs: component.get('v.cs')
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
                    var content = component.find("fileAttachmentListCmp");
                    content.set("v.body", newComp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("CCChangeRequestDetail.showRelatedLists No response from server or client is offline.");
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("CCChangeRequestDetail.showRelatedLists Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
    toggleEditMode : function(component) {
        $A.util.toggleClass(component.find("btnSave"), "hide-button");
        $A.util.toggleClass(component.find("btnCancel"), "hide-button");
        $A.util.toggleClass(component.find("btnEdit"), "hide-button");
        $A.util.toggleClass(component.find("btnChangeContact"), "hide-button");
        $A.util.toggleClass(component.find("outputAlternateEmail"), "hide-component");
        $A.util.toggleClass(component.find("inputAlternateEmail"), "hide-component");
        $A.util.toggleClass(component.find("outputAlternateEmail2"), "hide-component");
        $A.util.toggleClass(component.find("inputAlternateEmail2"), "hide-component");
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
        var csIsSpecialReportingNeeded = component.get("v.cs.Is_Special_Reporting_Needed__c");
        component.set("v.reportingneedsVisibility",(csIsSpecialReportingNeeded===true)?true:false);
        component.set("v.otherTransactionVisibility",(component.get("v.cs.Transaction__c")==='Other')?true:false);
    },
    hideComponents : function(component) {
/*
        if(component.get("v.cs.Call_Reason__c") === "Other") {
            component.set("v.otherVisibility",true);
        }
*/
    }
})