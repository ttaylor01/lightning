({
	// Your renderer method overrides go here
	afterRender : function(component, helper) {
		var ret = this.superAfterRender();

		var isValid = helper.validateComponent(component);

        if ( isValid){
//        	var onlineBtn = document.getElementById('ccButton');
            var onlineBtn = component.find("ccButton");

            if( (component.get("v.btnVariation") != null) && onlineBtn ) {

				var btnColor = component.get("v.btnVariation");
                if( btnColor == "Neutral" ) {
//		                $A.util.addClass(onlineBtn, "slds-button_neutral");
		                $A.util.addClass(onlineBtn, "ccBtnNeutral");
		        }
                if( btnColor == "Brand" ) {
//		                $A.util.addClass(onlineBtn, "slds-button_brand");
		                $A.util.addClass(onlineBtn, "ccBtnBlue");
		        }
                if( btnColor == "Destructive" ) {
//		                $A.util.addClass(onlineBtn, "slds-button_destructive");
		                $A.util.addClass(onlineBtn, "ccBtnRed");
		        }
                if( btnColor == "Inverse" ) {
//		                $A.util.addClass(onlineBtn, "slds-button_inverse");
		                $A.util.addClass(onlineBtn, "ccBtnInverse");
		        }
                if( btnColor == "Success" ) {
//		                $A.util.addClass(onlineBtn, "ccBtnGreen");
		                $A.util.addClass(onlineBtn, "ccBtnGreen");
		        }
/*
                if( btnColor == "Blue" ) {
		                $A.util.addClass(onlineBtn, "ccBtnBlue");
		        }
		        if( btnColor == "Green" ) {
		                $A.util.addClass(onlineBtn, "ccBtnGreen");
		        }
		        if( btnColor == "Grey" ) {
		                $A.util.addClass(onlineBtn, "ccBtnGrey");
		        }
		        if( btnColor == "Yellow" ) {
		                $A.util.addClass(onlineBtn, "ccBtnYellow");
		        }
		        if( btnColor == "Red" ) {
		                $A.util.addClass(onlineBtn, "ccBtnRed");
		        }
		        if( btnColor == "Orange" ) {
		                $A.util.addClass(onlineBtn, "ccBtnOrange");
		        }
*/
            }
        }

	    return ret;
	}
})