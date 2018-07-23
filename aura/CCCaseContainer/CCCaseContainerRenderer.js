({
    // Your renderer method overrides go here
    afterRender : function(component) {
        this.superAfterRender();
//        var targetEl = component.find("mainContainer").getElement();
//        targetEl.addEventListener("touchmove", function(e) {
//            e.stopPropagation();
//        }, false);
        
    }
    
})