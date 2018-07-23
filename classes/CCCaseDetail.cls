public with sharing class CCCaseDetail {
    
	@AuraEnabled
	public static Case getCase(String recordId) {
		system.debug('[DEBUG-CCCaseDetail.getCase()]\n=========\nrecordId: ' + recordId);
		system.debug('[DEBUG-CCCaseDetail.getCase()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
		
		Case cs = new Case();
		
		if(String.isNotBlank(recordId)) {
			try {
				cs = [
					SELECT 
					CaseNumber, Call_Reason__c, Brief_Description__c, Brief_Description_Details__c, Submission_Method__c,
					Payer_Name__c, Payer_ID__c, Government_Payer__c, Provider_Name__c, Payers__c,
					NPI_Identifier__c, Tax_ID__c, PTAN_Identifier__c, Atypical_Provider__c,
					User_ID__c, Customer_Reference_Number__c, Alternate_Email__c, Alternate_Email_2__c,
					New_Payer_Request_Type__c, EDI_Batch_ID__c, Patient_Name__c, Web_Transaction_ID__c,
					Member_ID__c, EDI_Batch_Reject_Reason__c, Date_of_Service__c, Charge_Amount__c,
					Check_Date__c, Check_Number__c, Check_Amount__c, B2B_Vendor_Transaction_ID__c,
					B2B_transaction_Date__c, B2B_Time_of_Transaction__c, B2B_Vendor_Error_Code__c,
					Address__c, City__c, State__c, Zip_Code__c, Payer_States__c, New_Payer_Transaction__c, Estimated_Monthly_Volume__c, 
					Subject, Description, CID_Identifier__c, ContactId, Contact.Name, Status, RecordTypeId, ClosedDate
					FROM Case
					WHERE Id = :recordId
					LIMIT 1
				];

				System.debug('[DEBUG-CCCaseDetail.getCase()]\n=========\nCase: ' + cs);

		    	Map<String, CCRecordTypes__c> recordTypeNames = CCRecordTypes__c.getall();
				System.debug('[DEBUG-CCCaseList.CCListCase()]\n=========\nrecordTypeNames: ' + recordTypeNames);
				for(CCRecordTypes__c rt : recordTypeNames.values()) {
					if(cs.RecordTypeId.equals(rt.RecordTypeId__c)) {
						cs.Source__c = rt.RecordTypeName__c;
					}
				}

				System.debug('[DEBUG-CCCaseDetail.getCase()]\n=========\nCase: ' + cs);
			} catch (Exception e) {
                throw new AuraHandledException('Unable to obtain record for id: '+recordId);
			}
		} else {
			User user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
			Contact contact = [Select Id, Name from Contact Where Id = :user.ContactId];
			Account account = [Select Name, Entity_Gen_Key__c from Account Where Id = :user.AccountId];
			cs.CID_Identifier__c = account.Entity_Gen_Key__c;
			cs.Contact = contact;
			CCRecordTypes__c rt = CCRecordTypes__c.getInstance('Community Support');
			cs.RecordTypeId = rt.RecordTypeId__c;
		}
		
		return cs;
	}
	
	@AuraEnabled
	public static Case saveCase(Case cs) {
		System.debug('[DEBUG-CCCaseDetail.saveCase()]\n=========\nCase: ' + cs);

        if(String.isNotBlank(cs.Id)) {
			Database.SaveResult sResult = Database.update(cs,false);
            if (sResult == null || !sResult.isSuccess()) {
                // How rude! Gracefully return an error...
				throw new AuraHandledException(getErrorMessage(sResult));
            }
            //		throw new AuraHandledException('BADCODE: Bad mojo bwana happening!');
            
            return cs;
        } else {
			if('New Payer Request'.equals(cs.Call_Reason__c)) {
				cs.RecordTypeId = CCRecordTypes__c.getInstance('New Payer Request').RecordTypeId__c;
			}

            Database.SaveResult sResult = Database.insert(cs,false);
            if (sResult == null || !sResult.isSuccess()) {
                // How rude! Gracefully return an error...
				throw new AuraHandledException(getErrorMessage(sResult));
            }
            //		throw new AuraHandledException('BADCODE: Bad mojo bwana happening!');
            
            System.debug('[DEBUG-CCCaseDetail.saveCase()]\n=========\n Created Case: ' + cs);
            return cs;
        }
	}

	@AuraEnabled
	public static Case saveCaseStatus(Case cs, String status, String body) {
    	if(String.isBlank(body)) {
			AuraHandledException e = new AuraHandledException('You must first enter a comment value.');
			e.setMessage('You must first enter a comment value.');
			throw e;
    	}
		CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody=body);
        // inser the comment
        Database.SaveResult commentResult = Database.insert(comment, false);
        
        if (commentResult == null || !commentResult.isSuccess()) {
			throw new AuraHandledException(getErrorMessage(commentResult));
        }

		cs.Status = status;
		Database.SaveResult sResult = Database.update(cs,false);
        if (sResult == null || !sResult.isSuccess()) {
			throw new AuraHandledException(getErrorMessage(sResult));
        }
			        
        return cs;
    }
    
    private static String getErrorMessage(Database.SaveResult sResult) {
    	String errorMsg;
		for(Database.Error err : sResult.getErrors()) {
			errorMsg = err.getStatusCode() + ': ' + err.getMessage();
			System.debug('[DEBUG-CCCaseDetail.getErrorMessage()]\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
			System.debug('[DEBUG-CCCaseDetail.getErrorMessage()]\n=========\n Case fields that affected this error: ' + err.getFields());
		}
		return errorMsg;
    }

	/*
	 *********************************
	 * Dependent Picklist logic
	 *********************************
	 */
/*
	@AuraEnabled
	public static List<SelectOption> getCaseReasons() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult typeFieldDescription = Case.Call_Reason__c.getDescribe();
		options.add(new SelectOption('','--None--'));
		for(Schema.Picklistentry picklistEntry : typeFieldDescription.getPicklistValues()) {
			options.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
		}
		return options;
	}
*/

	@AuraEnabled
	public static List<String> getPayerStates() {
		List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Payer_States__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple) {
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
	}

	@AuraEnabled
	public static List<String> getPayerTransactions() {
		List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.New_Payer_Transaction__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple) {
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
	}

	@AuraEnabled  
	public static Map<String,List<String>> getDependentOptions(string objApiName , string contrfieldApiName , string depfieldApiName){
		system.debug(objApiName + '##' + contrfieldApiName + '###' + depfieldApiName);

		Map<String,List<String>> pickValueMap = getDependentPicklistValuesByRecordType(objApiName,contrfieldApiName,depfieldApiName);
		System.debug('[DEBUG-CCCaseDetail.getDependentOptions()]\n=========\npickValueMap: ' + pickValueMap);
		return pickValueMap;
    }

    private static Map<String,List<String>> getDependentPicklistValuesByRecordType(String pObjName, String pControllingFieldName, String pDependentFieldName) {
		System.debug('[DEBUG-CCCaseDetail.getDependentPicklistValuesByRecordType()]\n=========\n sObject:ControllingField:DependentField ' + pObjName+':'+pControllingFieldName+':'+pDependentFieldName);
		
		CCRecordTypes__c rt = CCRecordTypes__c.getInstance('Community Support');
        Map<String,List<String>> objResults = new Map<String,List<String>>();
		
		// Get control values
		String q = '';
		q += 'SELECT Id, Name, Record_Type_Id__c, Record_Type_Name__c from ' + pControllingFieldName + ' ';
		q += 'WHERE Record_Type_Id__c = \'' +  rt.RecordTypeId__c + '\' ';
		system.debug('[DEBUG-CCCaseDetail.getDependentPicklistValuesByRecordType()]\n=========\nControlling Field query: '+q);
		List<sObject> conFields = Database.query(q);
        System.debug('[DEBUG-CCCaseDetail.getDependentPicklistValuesByRecordType()]\n=========\nControlling field values = ' + conFields );

		q = '';
		q += 'SELECT Id, Name, Record_Type_Id__c, Record_Type_Name__c, ' + pControllingFieldName + ' from ' + pDependentFieldName + ' ';
		q += 'WHERE Record_Type_Id__c = \'' +  rt.RecordTypeId__c + '\' ';
		system.debug('[DEBUG-CCCaseDetail.getDependentPicklistValuesByRecordType()]\n=========\nDependent Field query: '+q);
		List<sObject> depFields = Database.query(q);
        System.debug('[DEBUG-CCCaseDetail.getDependentPicklistValuesByRecordType()]\n=========\nDependent field values = ' + depFields );
        
        //set up the results with controlling field first
        Map<String,String> conIdMap = new Map<String,String>();
        for(sObject obj : conFields) {
        	String objType = obj.getSObjectType().getDescribe().getName();
        	String label;
        	String id;
			if(objType.equals('Case_Reason__c')) {
				Case_Reason__c rec = (Case_Reason__c)obj;
				label = rec.Name;
				id = rec.Id;
			} else if(objType.equals('Case_Brief_Description__c')) {
				Case_Brief_Description__c rec = (Case_Brief_Description__c)obj;
				label = rec.Name;
				id = rec.Id;
			}
        	objResults.put(label, new List<String>());
        	conIdMap.put(id,label);
        }

		// now add dependent values per controlling value
		for(sObject obj : depFields) {
        	String objType = obj.getSObjectType().getDescribe().getName();
        	String label;
        	String id;
			if(objType.equals('Case_Brief_Description__c')) {
				Case_Brief_Description__c rec = (Case_Brief_Description__c)obj;
				label = rec.Name;
				id = rec.Case_Reason__c;
			} else if(objType.equals('Case_Brief_Description_Detail__c')) {
				Case_Brief_Description_Detail__c rec = (Case_Brief_Description_Detail__c)obj;
				label = rec.Name;
				id = rec.Case_Brief_Description__c;
			} else if(objType.equals('Case_Submission_Method__c')) {
				Case_Submission_Method__c rec = (Case_Submission_Method__c)obj;
				label = rec.Name;
				id = rec.Case_Reason__c;
			}
			if(conIdMap.containsKey(id)) {
				objResults.get(conIdMap.get(id)).add(label);
			}
		}

        System.debug('[DEBUG-CCCaseDetail.getDependentPicklistValuesByRecordType()]\n=========\n Filtered, Dependent Values = ' + objResults );

        return objResults;
    }
}