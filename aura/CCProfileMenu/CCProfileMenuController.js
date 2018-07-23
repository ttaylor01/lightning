({
    doInit : function(component, event, helper) {
        helper.getUserName(component, event, helper);
    },
    handleClick : function(component, event, helper) {
        var triggerCmp = component.find("menuTrigger");
        if (triggerCmp) {
            var source = event.getSource();
            var label = source.get("v.label");
            if(label === "logout") {
                helper.logout(component);
            }
        }
    },
})