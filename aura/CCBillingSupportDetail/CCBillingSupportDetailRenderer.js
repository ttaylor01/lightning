({
    rerender : function(component, helper) {
        this.superRerender();
        helper.hideComponents(component);
        // Record Id is not available upon initial rendering until
        // the init is run to capture this value from URL.
        // Therefore, dynamically create the related list components
        // passing the the recordId once it's availabe.
        helper.showRelatedLists(component);
    },
    // Your renderer method overrides go here
    afterRender : function(component) {
        this.superAfterRender();
    }
})