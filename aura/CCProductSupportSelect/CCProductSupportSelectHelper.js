({
    getProductPicklistValues : function(component, event, helper) {
        var picklistValues = []; // for store picklist values to set on ui field.
        picklistValues.push({
            class: "optionClass",
            label: "--- None ---",
            value: ""
        });
        picklistValues.push({class: "optionClass",label: "Patient Access",value: "Patient Access"});
        picklistValues.push({class: "optionClass",label: "Provider Authorization",value: "Provider Authorization"});
        picklistValues.push({class: "optionClass",label: "Revenue Cycle Management",value: "Revenue Cycle Management"});
        picklistValues.push({class: "optionClass",label: "Advanced Clearinghouse",value: "Advanced Clearinghouse"});
        picklistValues.push({class: "optionClass",label: "Basic Clearinghouse",value: "Basic Clearinghouse"});
        component.find("product").set("v.options", picklistValues);
    },
    showComponent : function(component,name,cmpid,params) {
        $A.createComponent(
            name,
            params,
            function(newComp, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log("CCProductSupportSelect showComponent newComp: "+newComp);
                    var content = component.find("caseCreateCmp");
                    content.set("v.body", newComp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("CCProductSupportSelect showComponent No response from server or client is offline.");
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("CCProductSupportSelect showComponent Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
})