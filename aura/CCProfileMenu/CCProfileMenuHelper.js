({
    getUserName : function(component, event, helper) {
        helper.callServer(component,"c.getUserName",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
                // For some reason you have to set individual fields because setting the whole case
                // causes an 'Unable to read sObject' error when passing the case to apex controller upon save
                component.set("v.name",response);
            }
        },
        {
        });
    },
    /*
     * The retURL doesn't actually redirect to the specified URL
     * You must set the Logout URL in
     * 1.  Community Workspaces --> Administration --> Login & Registration AND
     * 2.  SSO settings
     */
    logout : function(component) {
        var logoutURL = $A.get("$Label.c.BaseURL") + "/" + component.get("v.pathPrefix") + "/secur/logout.jsp";
        console.log("[CCProfileMenuHelper.logout] logoutURL: "+logoutURL);
//        var landingURL = $A.get("$Label.c.BaseURL") + "%2Fselfservice%2FCCLoggedOut"
        var landingURL = $A.get("$Label.c.BaseURL") + "/success/s/login"
        console.log("[CCProfileMenuHelper.logout] landingURL: "+landingURL);
        var url = logoutURL + "?retURL=" + landingURL;
        console.log("[CCProfileMenuHelper.logout] url: "+url);
        window.location.replace(url);
//        window.location.replace("https://qa-availity-support.cs18.force.com/success/secur/logout.jsp?retUrl=https%3A%2F%2Fqa-availity-support.cs18.force.com%2Fsuccess%2FCommunitiesLanding")
//        window.location.replace("https://qa-availity-support.cs18.force.com/success/secur/logout.jsp?retUrl=https%3A%2F%2Fqa-availity-support.cs18.force.com%2Fselfservice%2FCCLoggedOut")
    }
})