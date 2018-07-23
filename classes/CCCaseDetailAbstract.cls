public abstract class CCCaseDetailAbstract extends CCApexBridgeAbstract {
	private static final String DEBUG_STR = 'CCCaseDetailAbstract';
	public String recordTypeName;
    
	public Case getCase(String recordId) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getCase] ';
		system.debug(FUNC_STR+'\n=========\nrecordId: ' + recordId);
		system.debug(FUNC_STR+'\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
		
		Case cs = new Case();
		
		if(String.isNotBlank(recordId)) {
			try {
				String q = '';
				q += 'SELECT ' + join(caseFields, ',') + ' ';
				q += 'FROM Case ';
				q += 'WHERE Id = \'' + recordId + '\' ';
				q += 'LIMIT 1';
				cs = Database.query(q);

		    	Map<String, CCRecordTypes__c> recordTypeNames = CCRecordTypes__c.getall();
				System.debug(FUNC_STR+'\n=========\nrecordTypeNames: ' + recordTypeNames);
				for(CCRecordTypes__c rt : recordTypeNames.values()) {
					if(cs.RecordTypeId.equals(rt.RecordTypeId__c)) {
						cs.Source__c = rt.RecordTypeName__c;
					}
				}

				System.debug(FUNC_STR+'\n=========\nCase: ' + cs);
			} catch (Exception e) { throw new CCException('Unable to obtain record for id: '+recordId);	}
		} else {
			User user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
			Contact contact = [Select Id, Name from Contact Where Id = :user.ContactId];
			Account account = [Select Name, Entity_Gen_Key__c, RCM_Office_ID__c from Account Where Id = :user.AccountId];
			cs.CID_Identifier__c = account.RCM_Office_ID__c;
			cs.Contact = contact;
			cs.Account = account;
			cs.AccountId = account.Id;
			if(String.isNotBlank(this.recordTypeName)) cs.RecordTypeId = CCRecordTypes__c.getInstance(recordTypeName).RecordTypeId__c;
		}
		
		return cs;
	}
	
	public Case saveCase(Case cs) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.saveCase] ';
		System.debug(FUNC_STR+'\n=========\nCase: ' + cs);

        if(String.isNotBlank(cs.Id)) {
			Database.SaveResult sResult = Database.update(cs,false);
            if (sResult == null || !sResult.isSuccess()) { throw new CCException(getErrorMessage(sResult)); }
            
            return cs;
        } else {
            Database.SaveResult sResult = Database.insert(cs,false);
            if (sResult == null || !sResult.isSuccess()) { throw new CCException(getErrorMessage(sResult)); }
            
            System.debug(FUNC_STR+'\n=========\n Created Case: ' + cs);
            return cs;
        }
	}

	public Case saveCaseStatus(Case cs, String status, String body) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getCase] ';
    	if(String.isBlank(body)) {
			CCException e = new CCException('You must first enter a comment value.');
			e.setMessage('You must first enter a comment value.');
			throw e;
    	}
		CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody=body);
        // inser the comment
        Database.SaveResult commentResult = Database.insert(comment, false);
        
        if (commentResult == null || !commentResult.isSuccess()) {
			throw new CCException(getErrorMessage(commentResult));
        }

		cs.Status = status;
		Database.SaveResult sResult = Database.update(cs,false);
        if (sResult == null || !sResult.isSuccess()) { throw new CCException(getErrorMessage(sResult)); }
			        
        return cs;
    }
    
    private String getErrorMessage(Database.SaveResult sResult) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getErrorMessage] ';
    	String errorMsg;
		for(Database.Error err : sResult.getErrors()) {
			errorMsg = err.getStatusCode() + ': ' + err.getMessage();
			System.debug(FUNC_STR+'\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
			System.debug(FUNC_STR+'\n=========\n Case fields that affected this error: ' + err.getFields());
		}
		return errorMsg;
    }

    public Set<String> caseFields {
        get {
            if (caseFields == null) {
                caseFields = new Set<String> {
                	'Id',
					'CaseNumber',
					'Call_Reason__c',
					'Brief_Description__c',
					'Brief_Description_Details__c',
					'Submission_Method__c',
					'Payer_Name__c',
					'Payer_ID__c',
					'Government_Payer__c',
					'Provider_Name__c',
					'Payers__c',
					'NPI_Identifier__c',
					'Tax_ID__c',
					'PTAN_Identifier__c',
					'Atypical_Provider__c',
					'User_ID__c',
					'Customer_Reference_Number__c',
					'Alternate_Email__c',
					'Alternate_Email_2__c',
					'New_Payer_Request_Type__c',
					'EDI_Batch_ID__c',
					'Patient_Name__c',
					'Web_Transaction_ID__c',
					'Member_ID__c',
					'EDI_Batch_Reject_Reason__c',
					'Date_of_Service__c',
					'Charge_Amount__c',
					'Check_Date__c',
					'Check_Number__c',
					'Check_Amount__c',
					'B2B_Vendor_Transaction_ID__c',
					'B2B_transaction_Date__c',
					'B2B_Time_of_Transaction__c',
					'B2B_Vendor_Error_Code__c',
					'Address__c',
					'City__c',
					'State__c',
					'Zip_Code__c',
					'Payer_States__c',
					'New_Payer_Transaction__c',
					'Estimated_Monthly_Volume__c',
					'Subject',
					'Description',
					'CID_Identifier__c',
					'ContactId',
					'AccountId',
					'Contact.Name',
					'Status',
					'RecordTypeId',
					'ClosedDate',
					'Priority',
					'Alternate_Contact__c','Alternate_Contact_2__c',
					'Alternate_Contact__r.Name','Alternate_Contact_2__r.Name',
					'Invoice_Number__c',
					'Billing_Account__c','Billing_Account__r.Name'
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

}