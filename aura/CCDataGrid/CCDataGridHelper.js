({
    onInit : function(component) {
        var obj = this.parseBody(component);
        component.set("v.cols", obj.cols);
        component.set("v.rows", obj.rows);
    },
    parseBody: function(component,colItems) {
        var body = component.get("v.body");
        colItems = colItems || [];
        var rowItems=[], rowData = [], rowDataItems = [];
        var thisTag, result;
        
        for (var i = 0; i < body.length; i++) {
            thisTag = body[i];
            if (thisTag.isInstanceOf('c:CCDataGridColumn')) {
                colItems.push({
                    label : thisTag.get('v.label'),
                    type :  thisTag.get('v.type'),
                    class: thisTag.get('v.class') + " " +  
                    (thisTag.get('v.hidden') ? "slds-is-sortable hiddenColumn" : "slds-is-sortable")
                });
                
            } else if (thisTag.isInstanceOf('c:CCDataGridRow')) {
                rowData = thisTag.get('v.data').split(
                    thisTag.get('v.delimiter')
                );
                rowDataItems = [];
                for (var j=0; j<rowData.length; j++) {
                    rowDataItems.push({
                        data: rowData[j],
                        label: colItems[j].label,
                        type: colItems[j].type,
                        class: colItems[j].class
                    }); 
                }
                rowItems.push({
                    data: rowDataItems,
                    pk: thisTag.get('v.pk')
                });
                
                
            } else if (thisTag.isInstanceOf('aura:iteration')) {
                result = this.parseBody(thisTag,colItems); 
                rowItems = rowItems.concat(result.rows);

            }
            
        }
        
        
        
        return {
            rows: rowItems,
            cols: colItems
        }
        
        
    }
    
})