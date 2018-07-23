public with sharing class CCCaseComment {
    
	/*
	 * Case Comment logic
	 */
	@AuraEnabled
	public static List<CaseComment> getCaseComments(String recordId) {
		List<CaseComment> comments = new List<CaseComment>();
		comments = [
			SELECT Id, CommentBody, CreatedBy.Name, CreatedDate, IsPublished
			FROM CaseComment
			WHERE ParentId = :recordId AND IsPublished = true
			ORDER BY CreatedDate DESC
		];
		System.debug('[DEBUG-CCCaseComment.getCaseComments()]\n=========\ncomments: ' + comments);
		return comments;
	}
	@AuraEnabled
	public static void addComment(String recordId, String body) {
    	if(String.isBlank(recordId)) {
			AuraHandledException e = new AuraHandledException('Missing Ticket record Id.');
			e.setMessage('Missing Ticket record Id.');
			throw e;
    	}
    	if(String.isBlank(body)) {
			AuraHandledException e = new AuraHandledException('You must first enter a comment value.');
			e.setMessage('You must first enter a comment value.');
			throw e;
    	}

		CaseComment comment = new CaseComment(ParentId=recordId,CommentBody=body);
        // inser the comment
        Database.SaveResult commentResult = Database.insert(comment,false);
        
        if (commentResult == null || !commentResult.isSuccess()) {
        	String errorMsg;
			for(Database.Error err : commentResult.getErrors()) {
				errorMsg = err.getStatusCode() + ': ' + err.getMessage();
				System.debug('[DEBUG-CCCaseComment.addComment()]\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
				System.debug('[DEBUG-CCCaseComment.addComment()]\n=========\n Case fields that affected this error: ' + err.getFields());
			}
			throw new AuraHandledException(errorMsg);
        }

    }

}