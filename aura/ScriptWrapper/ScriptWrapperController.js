({
	init : function(component, event, helper) {
        // <ltng:require scripts="{!v.urls}"/>
        $A.createComponent("ltng:require", {
            scripts: [component.get("v.paramURL")]
        }, function(ltngRequire, status, errorMessage) {
            if (status === "SUCCESS") {
                component.set("v.body", [ltngRequire]);
            } else if (status === "ERROR") {
                console.log("ScriptWrapper init Error: " + errorMessage);
                // Show error message
            }
        });
	}
})