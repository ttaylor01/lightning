public with sharing class CCPayerSupportList {
    
	@AuraEnabled
	public static CCCasePagerWrapper getCases(String listView, String searchStr, Decimal pageNumber, Integer recordToDisplay) {
		return getCases(listView,searchStr,pageNumber,recordToDisplay,'CreatedDate',false);
	}

	@AuraEnabled
	public static CCCasePagerWrapper getCases(String listView, String searchStr, Decimal pageNumber, Integer recordToDisplay, String sortField, Boolean isAsc) {
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\nlistView: ' + listView);
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\nsearchStr: ' + searchStr);
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\npageNumber: ' + pageNumber);
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\nrecordToDisplay: ' + recordToDisplay);
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\nsortField: ' + sortField);
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\nisAsc: ' + isAsc);

		Integer offset = ((Integer)pageNumber - 1) * recordToDisplay;
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\noffset: ' + offset);
		if(String.isBlank(sortField)) {
			sortField = 'CreatedDate';
		}
		String sortDirection = 'desc NULLS LAST'; // 'asc'
		if(isAsc) {
			sortDirection = 'asc';
		}

		User user = [Select Id, AccountId, ContactId from User Where Id = :UserInfo.getUserId()];
		ApexPages.StandardSetController setCon;
		List<Case> listofcases = new List<Case>();
		List<Case> fullListofcases = new List<Case>();

		// Obtain profile driven available Case Record Types
		Map<Id,CaseType> availableCaseTypes = getCaseTypes();
		System.debug('[DEBUG-CCPayerReviewList.getCases()]\n=========\nCASE RECORD TYPES: ' + availableCaseTypes);
        Set<Id> myRecordTypeIds = availableCaseTypes.keySet();

        String whereClause = '';
        whereClause += 'WHERE AccountId = \'' + user.AccountId + '\' AND RecordTypeId IN :myRecordTypeIds ';
        if(String.isBlank(listView) || listView == 'Open') {
            whereClause += 'AND isClosed = false ';
        } else if(listView != 'All') {
            whereClause += 'AND Status = \'' + listView + '\' ';
        }
        String q = '';
        Integer total = 0;
        if(String.isBlank(searchStr)) {
			// get full list for csv downloads
            q += 'SELECT ' + join(caseFields, ',') + ' ';
            q += 'FROM Case ';
            q += whereClause;
            q += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
            q += ' LIMIT 10000';
			fullListofcases = Database.query(q);
			total = fullListofcases.size();

			q = '';
            q += 'SELECT ' + join(caseFields, ',') + ' ';
            q += 'FROM Case ';
            q += whereClause;
            q += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
            q += ' LIMIT ' + recordToDisplay + ' OFFSET ' + offset;
			System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\nSOQL: ' + q);
			listofcases = Database.query(q);
        } else {
            String escapedQ = String.escapeSingleQuotes(searchStr);
            String orQuery = buildOrQuery(escapedQ);

			// get totals first
            q += 'FIND \'' + orQuery + '\' IN ALL FIELDS RETURNING ';
            q += 'Case(' + join(caseFields, ',') + ' ';
            q += whereClause;
            q += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
            q += ') ';
            List<List<sObject>> searchList = Search.query(q);
			fullListofcases = (List<Case>)searchList[0];
			total = fullListofcases.size();

			q = '';
            q += 'FIND \'' + orQuery + '\' IN ALL FIELDS RETURNING ';
            q += 'Case(' + join(caseFields, ',') + ' ';
            q += whereClause;
            q += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
            q += ' LIMIT ' + recordToDisplay + ' OFFSET ' + offset;
            q += ') ';
            System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\nSOSL : ' + q);
            searchList = Search.query(q);
			listofcases = (List<Case>)searchList[0];
        }

		for(Case c : listofcases) {
			CaseType ct = availableCaseTypes.get(c.RecordTypeId);
			c.Source__c = ct.name;
		}
		System.debug('[DEBUG-CCPayerSupportList.getCases()]\n=========\ncases: ' + listofcases);

		// create a instance of wrapper class.
		CCCasePagerWrapper obj =  new CCCasePagerWrapper();
		// set the pageSize,Page(Number), total records and cases List(using OFFSET)
		obj.pageSize = recordToDisplay;
		obj.page = (Integer) pageNumber;
		obj.total = total;
		obj.cases = listofcases;
		obj.allCases = fullListofcases;

		// return the wrapper class instance .
		return obj;
	}

    public static Set<String> caseFields {
        get {
            if (caseFields == null) {
                caseFields = new Set<String>{
                    'Id',
                    'CaseNumber',
                    'CreatedDate',
                    'ClosedDate',
                    'LastModifiedDate',
                    'Status',
                    'Subject',
                    'Customer_Reference_Number__c',
                    'Payer_Ticket_Number__c',
                    'RecordTypeId','Source__c',
                    'Call_Reason__c',
                    'Contact.Name'
                };
            }
            return caseFields;
        }
        private set;
    }
    // joins elements in the passed list of strings by the passed string c
    // c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
    public static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty()) return null;

        String sep = (String.isBlank(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];

        size = strings.size();
        for (i = 1; i < size; i++) {
            s += (sep + strings[i]);
        }
        return s;
    }
    // version of join method that takes a set of strings
    public static String join(Set<String> strings, String c) {
        return join(new List<String>(strings), c);
    }
    /* Takes entered search string,
     *  breaks into separate words separated by space,
     *  adds wildcard * character
     *  concatenates each with OR operator.
     *  Ex:  foo bar --> foo* OR bar*
     */
    public static String buildOrQuery(String keywords) {
        system.debug('[DEBUG-CCPayerSupportList.buildOrQuery()] keywords: '+keywords);
        if (String.isBlank(keywords)) return null;

        String temp;
        //keywords = keywords.replaceAll('"' ,'\\"');
        List<String> tokens = String.escapeSingleQuotes(keywords).replaceAll('[!.,?<>;:{}@#$%^&*()]', '').split(' ');
        List<String> newTokens = new List<String>();
        
        for (String s : tokens) {
            temp = s.trim();
            newTokens.add(temp + '*');
        }
        tokens = newTokens;

        if (tokens.isEmpty()) {
            system.debug('[DEBUG-CCPayerSupportList.buildOrQuery()]  returned EMPTY KEYWORDS ');
            return null;
        } else if (tokens.size() == 1) {
            system.debug('[DEBUG-CCPayerSupportList.buildOrQuery()]  returned KEYWORD TOKENS \n===='+tokens[0]+'=====\n');
            return tokens[0];
        } else {
            String returnStr = join(tokens, ' OR ');
            system.debug('[DEBUG-CCPayerSupportList.buildOrQuery()]  returned KEYWORD TOKENS \n===='+returnStr+'=====\n');
            return returnStr;
        }
    }
    
	/*
	 * Now that community profiles can act on different types of cases (Case Record Types),
	 * I can't just obtain the case record types that is configured for that profile.
	 * I need to just get the specific Case record types this functionality (ie Customer Support or Payer Support)
	 */
	public static Map<Id, CaseType> getCaseTypes() {
		// Obtain profile driven available Case Record Types
		// Convert to custom CaseType as workaround for inability to display RecordType Description.
		Map<Id,RecordType> availableRecordTypes = CCRecordType.getAvailableRecordTypeNamesForSObject(Case.SObjectType);
		System.debug('[DEBUG-CCPayerReviewList.getCaseTypes()]\n=========\navailableRecordTypes: ' + availableRecordTypes);
		String recordTypeIds = CC_App_Settings__c.getInstance(UserInfo.getProfileId()).Payer_Support_Case_Types__c;
		List<String> typeList = new List<String>();
		if(String.isNotBlank(recordTypeIds)) {
			for(String rtId : recordTypeIds.split(',',0)) {
				typeList.add(rtId);
			}
		}
		System.debug('[DEBUG-CCPayerReviewList.getCaseTypes()]\n=========\ntypeList: ' + typeList);
		Map<Id,CaseType> availableCaseTypes = new Map<Id,CaseType>();
		for(String rtId : typeList) {
			if(availableRecordTypes.containsKey(rtId)) {
				RecordType rt = availableRecordTypes.get(rtId);
				CCRecordTypes__c crt = CCRecordTypes__c.getInstance(rt.name);
				CaseType ct = new CaseType(crt);
				availableCaseTypes.put(ct.id,ct);
			}
		}

		return availableCaseTypes;
	}

	/*
	 * Communities will not display the RecordType Description
	 * So I'm implementing my own custom type
	 */
	public class CaseType {
		public String id { get; set; }
		public String name { get; set; }
		public String description { get; set; }
		public String newPage { get; set; }
		public String detailPage { get; set; }
		
		public CaseType(CCRecordTypes__c rt) {
			this.id = rt.RecordTypeId__c;
			this.name = rt.RecordTypeName__c;
			this.description = rt.RecordTypeDescription__c;
			this.newPage = rt.NewPage__c;
			this.detailPage = rt.DetailPage__c;
		}
	}

}