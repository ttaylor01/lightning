({
    doInit : function(component, event, helper) {
        // this function call on the component load first time     
        // get the page Number if it's not define, take 1 as default
        var page = component.get("v.page") || 1;
        // get the select option (drop-down) values.
        var recordToDisplay = component.get("v.pageSize");
        // call the helper function
        helper.getCases(component, helper, page, recordToDisplay);
    },
    sortRow : function(component, event, helper) {
        var colEl = event.currentTarget;

        var selectedColEl = component.get("v.selectedColEl");
        if (selectedColEl) {
            $A.util.removeClass(selectedColEl,"slds-is-sorted");
        }
        component.set("v.selectedColEl", colEl);
        $A.util.addClass(colEl,"slds-is-sorted");

        component.set("v.selectedTabsoft",colEl.getAttribute('data-row'));
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, colEl.getAttribute('data-row'));
    },
    previousPage: function(component, event, helper) {
        // this function call on click on the previous page button
        var page = component.get("v.page") || 1;
        // get the select option (drop-down) values.  
        var recordToDisplay = component.get("v.pageSize");
        // set the current page,(using ternary operator.)
        page = (page - 1);
        // call the helper function
        helper.getCases(component, helper, page, recordToDisplay);
    },
    nextPage: function(component, event, helper) {
        // this function call on click on the next page button   
        var page = component.get("v.page") || 1;
        // get the select option (drop-down) values.   
        var recordToDisplay = component.get("v.pageSize");
        // set the current page,(using ternary operator.)  "(page + 1)"
        page = (page + 1);
        // call the helper function
        helper.getCases(component, helper, page, recordToDisplay);
    },
    onSelectChange: function(component, event, helper) {
        // this function call on the select opetion change,	 
        var page = 1
        var recordToDisplay = component.get("v.pageSize");
        helper.getCases(component, helper, page, recordToDisplay);
    },

    doSearch : function(component, event, helper) {
        // Only search if ENTER key pressed or if search button selected
        var doSearch = false;
        // Check if key entered
        if(event.getParams().keyCode) {
            // Do search if ENTER key pressed
            if(event.getParams().keyCode === 13) {
                doSearch = true;
            }
        } else {
            // Search button must have been selected
            doSearch = true;
        }

        if(doSearch) {
            event.preventDefault();
            var searchVal = component.get('v.searchStr');
            if(searchVal.length > 0 && searchVal.length < 3) {
                helper.displayErrorDialog('Warning!','Your search term must have 3 or more characters.','warning');
                return;
            }
            // Reset the page Number to 1 for new search terms
            var page = 1;
            // get the select option (drop-down) values.   
            var recordToDisplay = component.get("v.pageSize");
            // call the helper function   
            helper.getCases(component, helper, page, recordToDisplay);
        }
    },
    resetSearch : function(component, event, helper) {
        event.preventDefault();
		component.set("v.searchStr","");
        // Reset the page Number to 1 for cleared search terms
        var page = 1;
        // get the select option (drop-down) values.
        var recordToDisplay = component.get("v.pageSize");
        // call the helper function   
        helper.getCases(component, helper, page, recordToDisplay);
    },
    doOpenTicket : function(component, event, helper) {
        console.log("CCChangeRequestList doOpenTicket");
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "targetView": "Edit",
            "listView": component.get('v.viewSelect')
        });
        console.log("CCChangeRequestList doOpenTicket compEvent: "+compEvent);
        compEvent.fire();  
    },
    onListItemClick: function(component,event,helper) {
        var rowEl = event.currentTarget;
        component.set("v.selectedRecordId",rowEl.getAttribute('data-pk'));
        var selectedRowEl = component.get("v.selectedRowEl");
        if (selectedRowEl) {
            $A.util.removeClass(selectedRowEl,"slds-is-selected");
        }
        component.set("v.selectedRowEl", rowEl);
        $A.util.addClass(rowEl,"slds-is-selected");

        /*
         *  force:navigateToComponent not supported in Communities yet.
		 *  Had to use force:navigateToURL passing in parameter value
		 *  So we will pop the parameter from the URL
        var urlEvent = $A.get("e.force:navigateToComponent");
        urlEvent.setParams({
            "componentDef": "c:CCCaseDetail",
            "componentAttributes": {
                "recordId": component.get("v.selectedRecordId")
            }
        });
        urlEvent.fire();
         */
        var compEvent = component.getEvent("goToTarget");
        compEvent.setParams({
            "sObjectId": rowEl.getAttribute('data-pk'),
            "targetView": "Detail",
            "listView": component.get('v.viewSelect')
        });   
        compEvent.fire();
    },
    doDownLoadCSV : function(component, event, helper) {
        // Need to obtain full list along with paginated list and get full list here
        var caseData = component.get("v.allCases");
        // call helper function that will return the CSV data as string
        var csvData = helper.convertArrayOfObjectsToCSV(component,caseData);
        if(csvData == null) {return;}

        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####
        // IE browser issue with encodeURI.  Getting error "data area passed to a system call is too small"
        if(navigator.msSaveBlob) {
            var filename = component.get('v.viewSelect') + 'ChangeRequestTickets.csv';
            var blob = new Blob([csvData], {"type": "text/csv;charset=utf8;"
                                          });
            navigator.msSaveBlob(blob, filename);
        } else {
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvData);
            hiddenElement.target = '_self';
            hiddenElement.download = component.get('v.viewSelect') + 'ChangeRequestTickets.csv';  // CSV file Name* you can change it.[only name not .csv] 
            document.body.appendChild(hiddenElement); // Required for FireFox browser
            hiddenElement.click(); // using click() js function to download csv file
        }
       
    }
})