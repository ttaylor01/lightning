({
	doInit : function(component, event, helper) {
	},
    doAgree : function(component, event, helper) {
        var compEvent = component.getEvent("agreeToTermsAndAgreementDialog");
        compEvent.fire();
    },
    doCancel : function(component, event, helper) {
        var compEvent = component.getEvent("cancelTermsAndAgreementDialog");
        compEvent.fire();
    },
})