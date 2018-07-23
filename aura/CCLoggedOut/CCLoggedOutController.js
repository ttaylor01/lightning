({
    doInit : function(component, event, helper) {
        var loginURL = $A.get("$Label.c.BaseURL") + $A.get("$Label.c.CommunityURL") + "/s/login";
        component.set("v.loginURL",loginURL);
    },
})