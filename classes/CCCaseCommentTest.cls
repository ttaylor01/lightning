@isTest
private class CCCaseCommentTest {

    static testMethod void testComments() {
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
			List<CaseComment> comments = CCCaseComment.getCaseComments(cs.Id);

			CCCaseComment.addComment(cs.Id,'Test Comment');
			try {
				CCCaseComment.addComment(null,'Test Comment');
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing Ticket record Id.'));
			}
			try {
				CCCaseComment.addComment(cs.Id,null);
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('You must first enter a comment value.'));
			}

            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestRecords();
       }
    }    
}