({
    getCases : function(component, helper, page, recordToDisplay) {
        helper.callServer(component,"c.getCases",function(response,error) {
            if(error) {
                // do some error processing
//	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
//                console.log("response: "+JSON.stringify(response));
                component.set("v.page", response.page);
                component.set("v.total", response.total);
                component.set("v.pages", Math.ceil(response.total / recordToDisplay));
                component.set("v.next", (component.get("v.pages") / component.get("v.page") === 1) ? true : false );
                component.set("v.prev", (component.get("v.page") === 1) ? true : false );
                component.set("v.cases", response.cases);
                component.set("v.allCases", response.allCases);
            }
        },
        {
            listView: component.get('v.viewSelect'),
            searchStr: component.get('v.searchStr'),
            pageNumber: page,
            recordToDisplay: recordToDisplay,
            sortField: component.get("v.selectedTabsoft"),
            isAsc: component.get("v.isAsc")
        });
    },
    sortHelper: function(component, event, helper, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        var page = component.get("v.page") || 1;
        // get the select option (drop-down) values.   
        var recordToDisplay = component.get("v.pageSize");
        helper.getCases(component, helper, page, recordToDisplay);
    },
    convertArrayOfObjectsToCSV : function(component,objectRecords) {
        // declare variables
        var csvStringResult, counter, keys, fieldNames, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variable to separate CSV values and 
        // for start next line use '\n' [new line] in lineDivider variable
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys variable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Date Opened','Ticket Number','Subject','Last Modified Date','Status','My Tracking Number'];
        fieldNames = ['CreatedDate','CaseNumber','Subject','LastModifiedDate','Status','Customer_Reference_Number__c'];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i += 1) {
            // parse each record to get every key:value pair regardless of how many levels deep for each record
            var m = new Map();
            JSON.parse(JSON.stringify(objectRecords[i]), function(key,value) {
                m.set(key, value);
            });
            // build each row of the csv file based on the fieldNames as key to parsed map
            counter = 0;
            for(var sTempkey in fieldNames) {
                var skey = fieldNames[sTempkey];
                
                // add , [comma] after every String value,. [except first]
                if(counter > 0) {
                    csvStringResult += columnDivider; 
                }
                csvStringResult += '"';
                csvStringResult += (m.get(skey) !== undefined) ? m.get(skey) : ' ';
                csvStringResult += '"';
                
                counter += 1;
            } // inner for loop close 
            csvStringResult += lineDivider;
        } // outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    },
})