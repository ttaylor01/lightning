public with sharing class CCChangeRequestDetail {
	@AuraEnabled
	public static Case getCase(String recordId) {
		system.debug('[DEBUG-CCChangeRequestDetail.getCase()]\n=========\nrecordId: ' + recordId);
		system.debug('[DEBUG-CCChangeRequestDetail.getCase()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
		
		Case cs = new Case();
		
		if(String.isNotBlank(recordId)) {
			try {
				cs = [
					SELECT 
					CaseNumber, 
					Customer_Reference_Number__c, Alternate_Email__c, Alternate_Email_2__c,
					Subject, Description, CID_Identifier__c, ContactId, Contact.Name, Status, RecordTypeId, ClosedDate,
					Payer_Ticket_Number__c, Secondary_Ticket_Number__c, Source__c, Owner.Name,
					Transaction__c, Type, 
					Priority,
					Requested_Production_Date__c,
					Requestor_Priority__c,
					Controlled_Deployment_Pilot_Requested__c,
					Release_communication_required__c,
					Region__c,
					Mandate__c,
					Health_Plan__c,
					Health_Plan_Other__c,
					System_Impacted__c,
					Other_Transaction__c,
					Justification_for_Request__c,
					Impact_on_Payer_if_Date_is_Not_Met__c,
					Is_Special_Reporting_Needed__c,	
					Special_Reporting_Needs__c
					FROM Case
					WHERE Id = :recordId
					LIMIT 1
				];

				System.debug('[DEBUG-CCChangeRequestDetail.getCase()]\n=========\nCase: ' + cs);

		    	Map<String, CCRecordTypes__c> recordTypeNames = CCRecordTypes__c.getall();
				System.debug('[DEBUG-CCCaseList.CCListCase()]\n=========\nrecordTypeNames: ' + recordTypeNames);
				for(CCRecordTypes__c rt : recordTypeNames.values()) {
					if(cs.RecordTypeId.equals(rt.RecordTypeId__c)) {
						cs.Source__c = rt.RecordTypeName__c;
					}
				}

				System.debug('[DEBUG-CCChangeRequestDetail.getCase()]\n=========\nCase: ' + cs);
			} catch (Exception e) {
                throw new AuraHandledException('Unable to obtain record for id: '+recordId);
			}
		} else {
			User user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
			Contact contact = [Select Id, Name from Contact Where Id = :user.ContactId];
			Account account = [Select Name, Entity_Gen_Key__c from Account Where Id = :user.AccountId];
			cs.CID_Identifier__c = account.Entity_Gen_Key__c;
			cs.Contact = contact;
			cs.Health_Plan__c = account.Name;
			CCRecordTypes__c rt = CCRecordTypes__c.getInstance('Change Request');
			cs.RecordTypeId = rt.RecordTypeId__c;
		}
		
		return cs;
	}
	
	@AuraEnabled
	public static Case saveCase(Case cs) {
		System.debug('[DEBUG-CCChangeRequestDetail.saveCase()]\n=========\nCase: ' + cs);

        if(String.isNotBlank(cs.Id)) {
			Database.SaveResult sResult = Database.update(cs,false);
            if (sResult == null || !sResult.isSuccess()) {
                // How rude! Gracefully return an error...
				throw new AuraHandledException(getErrorMessage(sResult));
            }
            //		throw new AuraHandledException('BADCODE: Bad mojo bwana happening!');
            
            return cs;
        } else {
			cs.RecordTypeId = CCRecordTypes__c.getInstance('Change Request').RecordTypeId__c;

            Database.SaveResult sResult = Database.insert(cs,false);
            if (sResult == null || !sResult.isSuccess()) {
                // How rude! Gracefully return an error...
				throw new AuraHandledException(getErrorMessage(sResult));
            }
            //		throw new AuraHandledException('BADCODE: Bad mojo bwana happening!');
            
            System.debug('[DEBUG-CCChangeRequestDetail.saveCase()]\n=========\n Created Case: ' + cs);
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
			System.debug('[DEBUG-CCChangeRequestDetail.getErrorMessage()]\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
			System.debug('[DEBUG-CCChangeRequestDetail.getErrorMessage()]\n=========\n Case fields that affected this error: ' + err.getFields());
		}
		return errorMsg;
    }
}