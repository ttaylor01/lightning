({
    getCase : function(component, event, helper) {
        // Display all cases for selected status
        helper.callServer(component,"c.getCase",function(response,error) {
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
        console.log("[CCCaseDetailHelper.saveCase] case: "+JSON.stringify(component.get('v.cs')));
        helper.callServer(component,"c.saveCase",function(response,error) {
            if(error) {
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
                // reset values from dirty input
                helper.getCase(component, event, helper);
            } else {
                component.set("v.cs", response);
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
/*
        $A.createComponent(
            "c:CCCaseAttachmentList",
            {
                "recordId": component.get('v.recordId'),
                "caseStatus": component.get('v.cs.Status'),
                "siteUrlPrefix": 'success'
            },
            function(newComp) {
                var content = component.find("caseAttachmentListCmp");
                content.set("v.body", newComp);
            }
        );
*/
        $A.createComponent(
            "c:CCFileAttachmentList",
            {
                "recordId": component.get('v.recordId'),
                "caseStatus": component.get('v.cs.Status'),
                "siteUrlPrefix": 'success'
            },
            function(newComp, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log("CCCaseDetail.showRelatedLists newComp: "+newComp);
                    var content = component.find("fileAttachmentListCmp");
                    content.set("v.body", newComp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("CCCaseDetail.showRelatedLists No response from server or client is offline.");
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
        $A.util.toggleClass(component.find("outputMyTicketNumber"), "hide-component");
        $A.util.toggleClass(component.find("inputMyTicketNumber"), "hide-component");
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
    },
    hideComponents : function(component) {
        if(component.get("v.cs.Call_Reason__c") === "Account Assistance") {
            component.set("v.payerNameIdVisibility",true);
            component.set("v.providerIdVisibility",true);
            component.set("v.providerNameVisibility",true);
        } else if(component.get("v.cs.Call_Reason__c") === "Auth/Referral") {
            component.set("v.payerNameIdVisibility",true);
            component.set("v.providerNameVisibility",true);
            component.set("v.providerIdVisibility",true);
            component.set("v.patientVisibility",true);
            component.set("v.webIdVisibility",true);
            component.set("v.memberVisibility",true);
            component.set("v.rejectVisibility",true);
            if(component.get("v.cs.Submission_Method__c") === "B2B") {
                component.set("v.b2bVisibility",true);
            }
        } else if(component.get("v.cs.Call_Reason__c") === "Claims") {
            component.set("v.payerNameIdVisibility",true);
            if(component.get("v.cs.Brief_Description__c") === "File Restore") {
                component.set("v.batchIdVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "File Status") {
                component.set("v.batchIdVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Medical Attachments") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Missing Response") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Not On File") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Rejection") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
            }
            if(component.get("v.cs.Submission_Method__c") === "B2B") {
                component.set("v.b2bVisibility",true);
            }
/*            
            if(component.get("v.cs.Brief_Description__c") === "Batch Reject") {
                component.set("v.batchIdVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Claim Reject") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.svcDateVisibility",true);
                component.set("v.chargeAmtVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                }
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "EOB Denial") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                component.set("v.chargeAmtVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Missing Response") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
            }
*/
        } else if(component.get("v.cs.Call_Reason__c") === "Claim Status") {
            component.set("v.payerNameIdVisibility",true);
            if(component.get("v.cs.Brief_Description__c") === "Error Message") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.webIdVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Claim Not Found") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.webIdVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Discrepancy") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.webIdVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Rejection") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.webIdVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            }
        } else if(component.get("v.cs.Call_Reason__c") === "Dental") {
            component.set("v.payerNameIdVisibility",true);
            if(component.get("v.cs.Brief_Description__c") === "Claim Reject") {
                component.set("v.batchIdVisibility",true);
                component.set("v.patientVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Claim Status") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.webIdVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "E&B") {
                component.set("v.patientVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "ERA Enrollment") {
                component.set("v.providerIdVisibility",true);
                component.set("v.providerNameVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Predetermination") {
                component.set("v.patientVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Remittance Viewer") {
                component.set("v.payerNameIdVisibility",true);
                if(component.get("v.cs.Brief_Description_Details__c") === "Additional Payers") {
                    component.set("v.providerIdVisibility",true);
                } else if(component.get("v.cs.Brief_Description_Details__c") === "Billing Service") {
                    component.set("v.providerIdVisibility",true);
                    component.set("v.providerNameVisibility",true);
                } else if(component.get("v.cs.Brief_Description_Details__c") === "Check Validation") {
                    component.set("v.providerIdVisibility",true);
                    component.set("v.providerNameVisibility",true);
                    component.set("v.checkVisibility",true);
                } else if(component.get("v.cs.Brief_Description_Details__c") === "Data Issues") {
                    component.set("v.providerIdVisibility",true);
                    component.set("v.providerNameVisibility",true);
                    component.set("v.checkVisibility",true);
                } else if(component.get("v.cs.Brief_Description_Details__c") === "Missing ERA") {
                    component.set("v.providerIdVisibility",true);
                    component.set("v.providerNameVisibility",true);
                    component.set("v.checkVisibility",true);
                } else if(component.get("v.cs.Brief_Description_Details__c") === "User Role Access") {
                    component.set("v.providerNameVisibility",true);
                    component.set("v.userVisibility",true);
                }
            }
            if(component.get("v.cs.Submission_Method__c") === "B2B") {
                component.set("v.b2bVisibility",true);
            }
        } else if(component.get("v.cs.Call_Reason__c") === "E&B") {
            component.set("v.payerNameIdVisibility",true);
            if(component.get("v.cs.Brief_Description__c") === "Error Message") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.webIdVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Discrepancy") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.webIdVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
            }
        } else if(component.get("v.cs.Call_Reason__c") === "ERA") {
            component.set("v.payerNameIdVisibility",true);
            component.set("v.providerIdVisibility",true);
            if(component.get("v.cs.Brief_Description__c") === "Data Issues") {
                component.set("v.checkVisibility",true);
                component.set("v.providerNameVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "EFT") {
                component.set("v.providerNameVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Enrollment") {
                component.set("v.providerNameVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "ERA Restore Request") {
                component.set("v.checkVisibility",true);
                component.set("v.providerNameVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Missing ERA") {
                component.set("v.checkVisibility",true);
                component.set("v.providerNameVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Payment Question") {
                component.set("v.checkVisibility",true);
                component.set("v.providerNameVisibility",true);
            }
/*
        } else if(component.get("v.cs.Call_Reason__c") === "Forms") {
            component.set("v.providerNameVisibility",true);
            if(component.get("v.cs.Brief_Description__c") === "835 Enrollment") {
                component.set("v.providerIdVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Billing Service Provider Access") {
                component.set("v.providerIdVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Org Identifier Change") {
                component.set("v.providerIdVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Org Type Change") {
                component.set("v.providerIdVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "PAA / PCA Change") {
            } else if(component.get("v.cs.Brief_Description__c") === "Service Termination Form") {
                component.set("v.providerIdVisibility",true);
            }
*/
        } else if(component.get("v.cs.Call_Reason__c") === "FTP/B2B") {
            component.set("v.userVisibility",true);
            component.set("v.payerNameIdVisibility",true);
        } else if(component.get("v.cs.Call_Reason__c") === "Login") {
            component.set("v.userVisibility",true);
        } else if(component.get("v.cs.Call_Reason__c") === "Remittance Viewer") {
            component.set("v.payerNameIdVisibility",true);
            if(component.get("v.cs.Brief_Description__c") === "Additional Payers") {
                component.set("v.providerIdVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Billing Service") {
                component.set("v.providerIdVisibility",true);
                component.set("v.providerNameVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Check Validation") {
                component.set("v.providerIdVisibility",true);
                component.set("v.providerNameVisibility",true);
                component.set("v.checkVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Data Issues") {
                component.set("v.providerIdVisibility",true);
                component.set("v.providerNameVisibility",true);
                component.set("v.checkVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "Missing ERA") {
                component.set("v.providerIdVisibility",true);
                component.set("v.providerNameVisibility",true);
                component.set("v.checkVisibility",true);
            } else if(component.get("v.cs.Brief_Description__c") === "User Role Access") {
                component.set("v.providerNameVisibility",true);
                component.set("v.userVisibility",true);
            }
        } else if(component.get("v.cs.Call_Reason__c") === "New Payer Request") {
            component.set("v.payerNameIdVisibility",true);
            component.set("v.payerRequestVisibility",true);
        } else if(component.get("v.cs.Call_Reason__c") === "Payer List") {
            component.set("v.payerNameIdVisibility",true);
        } else if(component.get("v.cs.Call_Reason__c") === "Payer Spaces") {
            component.set("v.payerSpacesVisibility",true);
        }
        
        if( component.get("v.providerNameVisibility") === true || component.get("v.providerIdVisibility") === true ) {
            component.set("v.providerVisibility",true);
        }
        if( component.get("v.payerNameIdVisibility") === true || component.get("v.payerRequestVisibility") === true || component.get("v.payerSpacesVisibility") === true ) {
            component.set("v.payerVisibility",true);
        }
        if( component.get("v.batchIdVisibility") === true || component.get("v.patientVisibility") === true || component.get("v.webIdVisibility") === true ||
           component.get("v.memberVisibility") === true || component.get("v.rejectVisibility") === true || component.get("v.svcDateVisibility") === true ||
           component.get("v.chargeAmtVisibility") === true ) {
            component.set("v.transactionVisibility",true);
        }
/*
        if(component.get("v.cs.Call_Reason__c") === "Auth/Referral") {
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
            $A.util.removeClass(component.find("providerpanel"),'hide-component');
            $A.util.removeClass(component.find("transactionpanel"),'hide-component');
            if(component.get("v.cs.Submission_Method__c") === "B2B") {
                $A.util.removeClass(component.find("b2bpanel"),'hide-component');
            }
        } else if(component.get("v.cs.Call_Reason__c") === "Claims") {
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
            if(component.get("v.cs.Brief_Description__c") === "Batch Reject") {
                $A.util.removeClass(component.find("transactionpanel"),'hide-component');
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Claim Reject") {
                $A.util.removeClass(component.find("transactionpanel"),'hide-component');
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    $A.util.removeClass(component.find("b2bpanel"),'hide-component');
                }
            } else if(component.get("v.cs.Brief_Description__c") === "EOB Denial") {
                $A.util.removeClass(component.find("transactionpanel"),'hide-component');
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    $A.util.removeClass(component.find("b2bpanel"),'hide-component');
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Missing Response") {
                $A.util.removeClass(component.find("transactionpanel"),'hide-component');
            }
        } else if(component.get("v.cs.Call_Reason__c") === "Claim Status") {
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
            if(component.get("v.cs.Brief_Description__c") === "Error Message") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
                $A.util.removeClass(component.find("transactionpanel"),'hide-component');
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    $A.util.removeClass(component.find("b2bpanel"),'hide-component');
                }
            }
        } else if(component.get("v.cs.Call_Reason__c") === "E&B") {
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
            if(component.get("v.cs.Brief_Description__c") === "Error Message") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
                $A.util.removeClass(component.find("transactionpanel"),'hide-component');
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    $A.util.removeClass(component.find("b2bpanel"),'hide-component');
                }
            }
        } else if(component.get("v.cs.Call_Reason__c") === "ERA") {
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
            $A.util.removeClass(component.find("providerpanel"),'hide-component');
            if(component.get("v.cs.Brief_Description__c") === "Data Issues") {
                $A.util.removeClass(component.find("checkpanel"),'hide-component');
            } else if(component.get("v.cs.Brief_Description__c") === "Enrollment") {
            } else if(component.get("v.cs.Brief_Description__c") === "ERA Restore Request") {
                $A.util.removeClass(component.find("checkpanel"),'hide-component');
            } else if(component.get("v.cs.Brief_Description__c") === "Missing ERA") {
                $A.util.removeClass(component.find("checkpanel"),'hide-component');
            }
        } else if(component.get("v.cs.Call_Reason__c") === "Forms") {
            $A.util.removeClass(component.find("providerpanel"),'hide-component');
            if(component.get("v.cs.Brief_Description__c") === "835 Enrollment") {
                // provideridVisibility setup
            } else if(component.get("v.cs.Brief_Description__c") === "Billing Service Provider Access") {
            } else if(component.get("v.cs.Brief_Description__c") === "Org Identifier Change") {
            } else if(component.get("v.cs.Brief_Description__c") === "Org Type Change") {
            } else if(component.get("v.cs.Brief_Description__c") === "PAA / PCA Change") {
            } else if(component.get("v.cs.Brief_Description__c") === "Service Termination Form") {
            }
        } else if(component.get("v.cs.Call_Reason__c") === "FTP") {
            $A.util.removeClass(component.find("userpanel"),'hide-component');
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
        } else if(component.get("v.cs.Call_Reason__c") === "Login") {
            $A.util.removeClass(component.find("userpanel"),'hide-component');
        } else if(component.get("v.cs.Call_Reason__c") === "Remittance Viewer") {
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
            if(component.get("v.cs.Brief_Description__c") === "Additional Payers") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
            } else if(component.get("v.cs.Brief_Description__c") === "Billing Service") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
            } else if(component.get("v.cs.Brief_Description__c") === "Check Validation") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
                $A.util.removeClass(component.find("checkpanel"),'hide-component');
            } else if(component.get("v.cs.Brief_Description__c") === "Data Issues") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
                $A.util.removeClass(component.find("checkpanel"),'hide-component');
            } else if(component.get("v.cs.Brief_Description__c") === "Missing ERA") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
                $A.util.removeClass(component.find("checkpanel"),'hide-component');
            } else if(component.get("v.cs.Brief_Description__c") === "User Role Access") {
                $A.util.removeClass(component.find("providerpanel"),'hide-component');
                $A.util.removeClass(component.find("userpanel"),'hide-component');
            }
        } else if(component.get("v.cs.Call_Reason__c") === "New Payer Request") {
            $A.util.removeClass(component.find("payerpanel"),'hide-component');
        }
*/
    }
})