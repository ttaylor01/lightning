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
                console.log("[CCCaseCreateHelper.getCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
            }
        },
        {
        });
    },
    saveCase : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        console.log("[CCCaseCreateHelper.saveCase] JSON.stringify'd case: "+JSON.stringify(component.get('v.cs')));
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
                console.log("[CCCaseCreateHelper.saveCase] Created case Id: "+response.Id);
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
        if(component.get("v.cs.Call_Reason__c") === "Account Assistance") {
            component.set("v.payerNameIdVisibility",true);
            component.set("v.providerIdVisibility",true);
            component.set("v.providerNameVisibility",true);
        } else if(component.get("v.cs.Call_Reason__c") === "Auth/Referral") {
            component.set("v.payerNameIdVisibility",true);
            component.set("v.providerNameVisibility",true);
            component.set("v.providerIdVisibility",true);
            component.set("v.patientVisibility",true);
            component.set("v.memberVisibility",true);
            component.set("v.rejectVisibility",true);
            if(component.get("v.cs.Submission_Method__c") === "B2B") {
                component.set("v.b2bVisibility",true);
            }
            if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                component.set("v.webIdVisibility",true);
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
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                    component.set("v.webIdVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Claim Not Found") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                    component.set("v.webIdVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Discrepancy") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                    component.set("v.webIdVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Rejection") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                component.set("v.svcDateVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                    component.set("v.webIdVisibility",true);
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
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                    component.set("v.webIdVisibility",true);
                }
            } else if(component.get("v.cs.Brief_Description__c") === "Discrepancy") {
                component.set("v.providerIdVisibility",true);
                component.set("v.patientVisibility",true);
                component.set("v.memberVisibility",true);
                component.set("v.rejectVisibility",true);
                if(component.get("v.cs.Submission_Method__c") === "B2B") {
                    component.set("v.b2bVisibility",true);
                }
                if(component.get("v.cs.Submission_Method__c") === "Manual Portal Entry") {
                    component.set("v.webIdVisibility",true);
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
        
    },
    resetVisibility : function(component) {
        // Reset all visibility sections
        component.set("v.userVisibility",false);
        component.set("v.payerVisibility",false);
        component.set("v.payerSpacesVisibility",false);
        component.set("v.payerNameIdVisibility",false);
        component.set("v.payerRequestVisibility",false);
        component.set("v.providerVisibility",false);
        component.set("v.providerIdVisibility",false);
        component.set("v.providerNameVisibility",false);
        component.set("v.transactionVisibility",false);
        component.set("v.batchIdVisibility",false);
        component.set("v.patientVisibility",false);
        component.set("v.webIdVisibility",false);
        component.set("v.memberVisibility",false);
        component.set("v.rejectVisibility",false);
        component.set("v.svcDateVisibility",false);
        component.set("v.chargeAmtVisibility",false);
        component.set("v.b2bVisibility",false);
        component.set("v.checkVisibility",false);
    },
    resetFields : function(component) {
        // Reset All fields on Case
        component.set("v.cs.User_ID__c",'');
        component.set("v.cs.Brief_Description__c",'');
        component.set("v.cs.Submission_Method__c",'');
        component.set("v.cs.Payer_Name__c",'');
        component.set("v.cs.Payer_ID__c",'');
        component.set("v.cs.Provider_Name__c",'');
        component.set("v.cs.NPI_Identifier__c",'');
        component.set("v.cs.Tax_ID__c",'');
        component.set("v.cs.PTAN_Identifier__c",'');
        component.set("v.cs.Government_Payer__c",false);
        component.set("v.cs.Atypical_Provider__c",false);
        component.set("v.cs.User_ID__c",'');
        component.set("v.cs.New_Payer_Request_Type__c",'');
        // Transaction Information
        component.set("v.cs.EDI_Batch_ID__c",'');
        component.set("v.cs.Patient_Name__c",'');
        component.set("v.cs.Web_Transaction_ID__c",'');
        component.set("v.cs.Member_ID__c",'');
        component.set("v.cs.EDI_Batch_Reject_Reason__c",'');
        component.set("v.cs.Date_of_Service__c",'');
        component.set("v.cs.Charge_Amount__c",'');
        // Check Information
        component.set("v.cs.Check_Date__c",'');
        component.set("v.cs.Check_Number__c",'');
        component.set("v.cs.Check_Amount__c",'');
        // B2B Transaction Information
        component.set("v.cs.B2B_Vendor_Transaction_ID__c",'');
        component.set("v.cs.B2B_transaction_Date__c",'');
        component.set("v.cs.B2B_Time_of_Transaction__c",'');
        component.set("v.cs.B2B_Vendor_Error_Code__c",'');
        // Details
        component.set("v.cs.Subject",'');
        component.set("v.cs.Description",'');
    },
    validateInput : function(component, helper) {
        var allValid = true;
        if(component.get("v.userVisibility")) {
            var inputCmp = component.find('userInput');
            inputCmp.showHelpMessageIfInvalid();
            allValid = allValid && inputCmp.get('v.validity').valid;
        }
        console.log("validateInput USER? "+allValid);
        if(component.get("v.payerVisibility")) {
            var payerValid = true;
            var ptanCmp = component.find('ptanid');
            if(component.find('governmentpayer').get('v.checked')) {
                ptanCmp.set("v.required",true);
                ptanCmp.showHelpMessageIfInvalid();
                console.log("ptan valid? "+ptanCmp.get('v.validity').valid);
            } else {
                ptanCmp.set("v.required",false);
                $A.util.removeClass(ptanCmp, "slds-has-error"); // remove red border
                $A.util.addClass(ptanCmp, "hide-error-message"); // hide error message
            }
            payerValid = payerValid && ptanCmp.get('v.validity').valid;
            if(component.get("v.payerNameIdVisibility")) {
                var payerCmp = component.find('payerName');
                payerCmp.showHelpMessageIfInvalid();
                payerValid = payerValid && payerCmp.get('v.validity').valid;
                payerCmp = component.find('payerId');
                payerCmp.showHelpMessageIfInvalid();
                payerValid = payerValid && payerCmp.get('v.validity').valid;
            }
            if(component.get("v.payerRequestVisibility")) {
                payerValid = this.validateSection(component,'payerRequestInput');

                var inputCmp = component.find("payerstates");
                var inputValue = inputCmp.get("v.value");
/* REMOVE REQUIREMENT
                if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
                    inputCmp.set("v.errors", [{message:"Please select at least one State"}]);
                    payerValid = payerValid && false;
                } else {
                    inputCmp.set("v.errors", null);
                    payerValid = payerValid && true;
                }
*/
                inputCmp = component.find("newpayertransaction");
                inputValue = inputCmp.get("v.value");
                if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
                    inputCmp.set("v.errors", [{message:"Please select at least one Transaction"}]);
                    payerValid = payerValid && false;
                } else {
                    inputCmp.set("v.errors", null);
                    payerValid = payerValid && true;
                }

            }
            allValid = allValid && payerValid;
        }
        console.log("validateInput PAYER? "+allValid);
        if(component.get("v.providerVisibility")) {
            var providerValid = true;
            if(component.get("v.providerNameVisibility")) {
                var inputCmp = component.find('providerNameInput');
                inputCmp.showHelpMessageIfInvalid();
                providerValid = providerValid && inputCmp.get('v.validity').valid;
                console.log("validateInput PROVIDER NAME? "+providerValid);
            }
            if(component.get("v.providerIdVisibility")) {
                var inputCmp = component.find('taxIdInput');
                inputCmp.showHelpMessageIfInvalid();
                providerValid = providerValid && inputCmp.get('v.validity').valid;
                console.log("validateInput PROVIDER TAXID? "+providerValid);
                inputCmp = component.find('npiIdInput');
                if(component.find('atypicalprovider').get('v.checked')) {
                    inputCmp.set("v.required",false);
                    $A.util.removeClass(inputCmp, "slds-has-error"); // remove red border
                    $A.util.addClass(inputCmp, "hide-error-message"); // hide error message
                } else {
                    inputCmp.set("v.required",true);
                    inputCmp.showHelpMessageIfInvalid();
                }
                providerValid = providerValid && inputCmp.get('v.validity').valid;
                console.log("validateInput PROVIDER NPI? "+providerValid);
            }
            allValid = allValid && providerValid;
        }
        console.log("validateInput PROVIDER? "+allValid);
        if(component.get("v.transactionVisibility")) {
            var transactionValid = true;
            var inputCmp;
            if(component.get("v.batchIdVisibility")) {
                inputCmp = component.find('batchid');
                inputCmp.showHelpMessageIfInvalid();
                transactionValid = transactionValid && inputCmp.get('v.validity').valid;
            }
            if(component.get("v.patientVisibility")) {
                inputCmp = component.find('patientname');
                inputCmp.showHelpMessageIfInvalid();
                transactionValid = transactionValid && inputCmp.get('v.validity').valid;
            }
            if(component.get("v.webIdVisibility")) {
                inputCmp = component.find('webtransactionid');
                inputCmp.showHelpMessageIfInvalid();
                transactionValid = transactionValid && inputCmp.get('v.validity').valid;
            }
            if(component.get("v.memberVisibility")) {
                inputCmp = component.find('memberid');
                inputCmp.showHelpMessageIfInvalid();
                transactionValid = transactionValid && inputCmp.get('v.validity').valid;
            }
            if(component.get("v.rejectVisibility")) {
                inputCmp = component.find('rejectionmessage');
                inputCmp.showHelpMessageIfInvalid();
                transactionValid = transactionValid && inputCmp.get('v.validity').valid;
            }
            if(component.get("v.svcDateVisibility")) {
                inputCmp = component.find('dateofservice');
                var inputValue = inputCmp.get("v.value");
                console.log("dateofservice: "+inputValue);
                if(helper.isValidDate(inputValue)) {
                    inputCmp.set("v.errors", null);
                    $A.util.removeClass(inputCmp, "slds-has-error"); // remove red border
                    transactionValid = transactionValid && true;
                } else {
                    $A.util.addClass(inputCmp, "slds-has-error"); // add red border
                    inputCmp.set("v.errors", [{message:"You must enter a valid Date of Service"}]);
                    transactionValid = transactionValid && false;
                }
            }
            if(component.get("v.chargeAmtVisibility")) {
                inputCmp = component.find('chargeamount');
                inputCmp.showHelpMessageIfInvalid();
                transactionValid = transactionValid && inputCmp.get('v.validity').valid;
            }
            allValid = allValid && transactionValid;
        }
        console.log("validateInput TRANSACTION? "+allValid);
        if(component.get("v.checkVisibility")) {
            var checkValid = this.validateSection(component,'checkInput');
            var inputCmp = component.find('checkDate');
            var inputValue = inputCmp.get("v.value");
            console.log("checkDate: "+inputValue);
            var validDate = true;
            if(helper.isValidDate(inputValue)) {
                // now check if more than 2 weeks in future
                var fortnightAway = new Date(+new Date + 12096e5);
                if(new Date(inputValue) > fortnightAway) {
                    validDate = false;
                }
            } else {
                validDate = false;
            }
            if(validDate) {
                inputCmp.set("v.errors", null);
                checkValid = checkValid && true;
            } else {
                inputCmp.set("v.errors", [{message:"You must enter a valid Check Date no more than 2 weeks in future."}]);
                checkValid = checkValid && false;
            }
            allValid = allValid && checkValid;
        }
        console.log("validateInput CHECK? "+allValid);
        if(component.get("v.b2bVisibility")) {
            var b2bValid = this.validateSection(component,'b2bInput');

            var inputCmp = component.find('b2bTransactionDate');
            var inputValue = inputCmp.get("v.value");
            console.log("b2bTransactionDate: "+inputValue);
            if(helper.isValidDate(inputValue)) {
                inputCmp.set("v.errors", null);
                b2bValid = b2bValid && true;
            } else {
                inputCmp.set("v.errors", [{message:"You must enter a valid Transaction Date"}]);
                b2bValid = b2bValid && false;
            }
            allValid = allValid && b2bValid;
        }
        console.log("validateInput B2B? "+allValid);

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

        inputCmp = component.find("briefdescriptiondetail");
        inputValue = inputCmp.get("v.value");
        inputDisabled = inputCmp.get("v.disabled");
        if(inputDisabled === true) {
            inputCmp.set("v.errors", null);
            allValid = allValid && true;
        } else {
	        if(inputValue === undefined || inputValue === "" || inputValue === "--- None ---") {
	            inputCmp.set("v.errors", [{message:"Please select a Brief Description Detail"}]);
	            allValid = allValid && false;
	        } else {
	            inputCmp.set("v.errors", null);
	            allValid = allValid && true;
	        }
        }
        console.log("validateInput BRIEF DESCRIPTION DETAIL? "+allValid);

        inputCmp = component.find("submissionmethod");
        inputValue = inputCmp.get("v.value");
        inputDisabled = inputCmp.get("v.disabled");
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

        var subjectCmp = component.find('subject');
        subjectCmp.showHelpMessageIfInvalid();
        allValid = allValid && subjectCmp.get('v.validity').valid;
        var descCmp = component.find('description');
        descCmp.showHelpMessageIfInvalid();
        allValid = allValid && descCmp.get('v.validity').valid;
        console.log("validateInput allValid? "+allValid);
        return allValid;
    },
    /*
     * Extract common logic per section of input page
     */
    validateSection : function(component, inputFields) {
        var isValid = component.find(inputFields).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            var isCmpValid = inputCmp.get('v.validity').valid;
            return validSoFar && isCmpValid;
        }, true);
        return isValid;
    },
    getPayerTransactionPicklistValues : function(component, event, helper) {
        helper.callServer(component,"c.getPayerTransactions",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                var picklistValues = []; // for store picklist values to set on ui field.
                for(var i=0; i<response.length; i++) {
                    picklistValues.push({
                        class: "optionClass",
                        label: response[i],
                        value: response[i]
                    });
                }
                component.find("newpayertransaction").set("v.options", picklistValues);
            }
        },
        {
        });
    },
    getPayerStatesPicklistValues : function(component, event, helper) {
        helper.callServer(component,"c.getPayerStates",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                var picklistValues = []; // for store picklist values to set on ui field.
                for(var i=0; i<response.length; i++) {
                    picklistValues.push({
                        class: "optionClass",
                        label: response[i],
                        value: response[i]
                    });
                }
                component.find("payerstates").set("v.options", picklistValues);
            }
        },
        {
        });
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

    getBriefDescriptionDetailPicklistValues: function(component, controllerField, dependentField) {
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
                component.set("v.briefDescriptionDetailFieldMap", StoreResponse);
                
            }
        });
        $A.enqueueAction(action);
    },
    fetchBriefDescriptionDetailValues: function(component, ListOfDependentFields) {
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
        component.find('briefdescriptiondetail').set("v.options", dependentFields);
        // make disable false for ui:inputselect field 
        component.set("v.isBriefDescriptionDetailDisable", false);
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