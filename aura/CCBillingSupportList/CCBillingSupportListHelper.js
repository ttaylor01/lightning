({
    getCases : function(component, helper, page, recordToDisplay) {
        var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component,
            request: {
                controller: "CCBillingSupportList",
                method: "getCases",
                input: { 
                    listView: component.get('v.viewSelect'),
                    searchStr: component.get('v.searchStr'),
                    pageNumber: page,
                    recordToDisplay: recordToDisplay,
                    sortField: component.get("v.selectedTabsoft"),
                    isAsc: component.get("v.isAsc")
                }
            },
	        pleaseWait: { type: "Spinner", message: "Finding tickets, please wait" },
            callBackMethod: function (response) {
                component.set("v.page", response.output.page);
                component.set("v.total", response.output.total);
                component.set("v.pages", Math.ceil(response.output.total / recordToDisplay));
                component.set("v.next", (component.get("v.pages") / component.get("v.page") === 1) ? true : false );
                component.set("v.prev", (component.get("v.page") === 1) ? true : false );
                component.set("v.cases", response.output.cases);
                component.set("v.allCases", response.output.allCases);
            },
            callBackError: function (serverResponse, errorMsg) {
                var msg = 'We are experiencing system errors.  Please try again or contact customer service for assistance';
                helper.displayErrorDialog('IMPORTANT!',msg,'error');
            }
        });
    },
    sortHelper: function(component, event, helper, sortFieldName) {
        console.log("sortHelper: "+sortFieldName);
        var currentDir = component.get("v.arrowDirection");
        
        if (currentDir === 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        console.log("sortHelper arrow direction: "+component.get("v.arrowDirection"));
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
        if (objectRecords === null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variable to separate CSV values and 
        // for start next line use '\n' [new line] in lineDivider variable
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys variable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Subject','Ticket Number','Date/Time Opened','Last Modified Date','Status','Invoice Number'];
        fieldNames = ['Subject','CaseNumber','CreatedDate','LastModifiedDate','Status','Invoice_Number__c'];
        
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