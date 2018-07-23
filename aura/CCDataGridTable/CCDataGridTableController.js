({
    onRowClick: function(component,event,helper) { 
        var rowData = {};
        var rowEl = event.currentTarget;
        var rowId = rowEl.getAttribute('data-row');
        var compEvent = component.getEvent("rowclick");
        compEvent.setParams({
            pk : rowEl.getAttribute('data-pk'), 
            rowData: component.get('v.rows')[rowId].data,
            domEl: rowEl
        });
        compEvent.fire();
    }
    
})