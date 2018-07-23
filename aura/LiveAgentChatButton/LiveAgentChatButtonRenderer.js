({
	// Your renderer method overrides go here
	afterRender : function(cmp, helper) {
		var ret = this.superAfterRender();
		var isValid = helper.validateComponent(cmp);

        if ( isValid){
			var onlineBtn = document.getElementById('btONline');//cmp.find("btONline");
			var offlineBtn = document.getElementById('btOFFline');//cmp.find("btOFFline");

            if( (  cmp.get("v.previousIsLiveAgentOnline")  != null ) &&
                    (cmp.get("v.previousIsLiveAgentOnline")== true)  
					&& onlineBtn && offlineBtn ){
                	$A.util.removeClass(onlineBtn, "toggle");
	                $A.util.addClass(offlineBtn, "toggle");
            }
        }

	    return ret;
	}
})