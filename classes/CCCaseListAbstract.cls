public abstract class CCCaseListAbstract extends CCApexBridgeAbstract {
	private static final String DEBUG_STR = 'CCCaseListAbstract';
	public Map<Id, CCRecordTypes__c> availableCaseTypes;

	/*
	 * Now that community profiles can act on different types of cases (Case Record Types),
	 * I can't just obtain the case record types that is configured for that profile.
	 * I need to just get the specific Case record types this functionality (ie Customer Support or Payer Support)
	 */
	public abstract Map<Id, CCRecordTypes__c> getCaseTypes();
	
    public CCCasePagerWrapper getCases(CCApexBridgeRequest request) {
    	String listView = String.valueOf(request.getInputValue('listView'));
    	String searchStr = String.valueOf(request.getInputValue('searchStr'));
    	Integer pageNumber = Integer.valueOf(request.getInputValue('pageNumber'));
    	Integer recordToDisplay = Integer.valueOf(request.getInputValue('recordToDisplay'));
    	String sortField = String.valueOf((request.getInputValue('sortField')==null)?'CreatedDate':request.getInputValue('sortField'));
    	Boolean isAsc = Boolean.valueOf((request.getInputValue('isAsc')==null)?'false':request.getInputValue('isAsc'));
    	
    	return getCases(listView,searchStr,pageNumber,recordToDisplay,sortField,isAsc);
    }

	private CCCasePagerWrapper getCases(String listView, String searchStr, Decimal pageNumber, Integer recordToDisplay, String sortField, Boolean isAsc) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getCases] ';
		System.debug(FUNC_STR+'\n=========\nlistView: ' + listView);
		System.debug(FUNC_STR+'\n=========\nsearchStr: ' + searchStr);
		System.debug(FUNC_STR+'\n=========\npageNumber: ' + pageNumber);
		System.debug(FUNC_STR+'\n=========\nrecordToDisplay: ' + recordToDisplay);
		System.debug(FUNC_STR+'\n=========\nsortField: ' + sortField);
		System.debug(FUNC_STR+'\n=========\nisAsc: ' + isAsc);

		Integer offset = ((Integer)pageNumber - 1) * recordToDisplay;
		System.debug(FUNC_STR+'\n=========\noffset: ' + offset);
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
//		Map<Id, CCRecordTypes__c> availableCaseTypes = getCaseTypes();
//		Map<Id,CaseType> availableCaseTypes = getCaseTypes();
		System.debug(FUNC_STR+'\n=========\nCASE RECORD TYPES: ' + availableCaseTypes);
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
			System.debug(FUNC_STR+'\n=========\nFULL CASE LIST SOQL: ' + q);
			fullListofcases = Database.query(q);
			total = fullListofcases.size();

			q = '';
            q += 'SELECT ' + join(caseFields, ',') + ' ';
            q += 'FROM Case ';
            q += whereClause;
            q += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
            q += ' LIMIT ' + recordToDisplay + ' OFFSET ' + offset;
			System.debug(FUNC_STR+'\n=========\nOFFSET CASE LIST SOQL: ' + q);
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
            System.debug(FUNC_STR+'\n=========\nSOSL : ' + q);
            searchList = Search.query(q);
			listofcases = (List<Case>)searchList[0];
        }

		for(Case c : listofcases) {
			CCRecordTypes__c ct = availableCaseTypes.get(c.RecordTypeId);
			c.Source__c = ct.RecordTypeName__c;
//			CaseType ct = availableCaseTypes.get(c.RecordTypeId);
//			c.Source__c = ct.name;
		}
		System.debug(FUNC_STR+'\n=========\ncases: ' + listofcases);

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

    public Set<String> caseFields {
        get {
            if (caseFields == null) {
                caseFields = new Set<String> {
                    'Id',
                    'CaseNumber',
                    'CreatedDate',
                    'ClosedDate',
                    'LastModifiedDate',
                    'Priority',
                    'Status',
                    'Subject',
                    'CreatedBy.My_Name__c',
                    'Customer_Reference_Number__c',
                    'CID_Identifier__c',
                    'RecordTypeId','Source__c',
                    'Contact.Name',
                    'Call_Reason__c',
                    'Invoice_Number__c',
                    'Billing_Account__r.Name'
                };
            }
            return caseFields;
        }
        private set;
    }
    // joins elements in the passed list of strings by the passed string c
    // c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
    public String join(List<String> strings, String c) {
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
    public String join(Set<String> strings, String c) {
        return join(new List<String>(strings), c);
    }

    /* Takes entered search string,
     *  breaks into separate words separated by space,
     *  adds wildcard * character
     *  concatenates each with OR operator.
     *  Ex:  foo bar --> foo* OR bar*
     */
    public String buildOrQuery(String keywords) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.buildOrQuery] ';
        system.debug(FUNC_STR+' keywords: '+keywords);
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
            system.debug(FUNC_STR+' returned EMPTY KEYWORDS ');
            return null;
        } else if (tokens.size() == 1) {
            system.debug(FUNC_STR+' returned KEYWORD TOKENS \n===='+tokens[0]+'=====\n');
            return tokens[0];
        } else {
            String returnStr = join(tokens, ' OR ');
            system.debug(FUNC_STR+' returned KEYWORD TOKENS \n===='+returnStr+'=====\n');
            return returnStr;
        }
    }

}