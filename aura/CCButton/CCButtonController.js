({
	navigate : function(component, event, helper) {
		//Find the text value of the component with aura:id set to "address"
		var address = component.get("v.endpoint");
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": address
		});
		urlEvent.fire();
	}
})