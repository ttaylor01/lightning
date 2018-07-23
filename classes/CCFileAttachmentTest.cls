@isTest
private class CCFileAttachmentTest {

    static testMethod void testAttachments() {
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
//        System.runAs(testUser) {
            Test.startTest();

			String base64Data = EncodingUtil.base64Encode(Blob.valueOf('file content'));

			Id fileId;
			fileId = CCFileAttachment.saveTheChunk(cs.Id, 'testFile', base64Data, 'txt', '');
			fileId = CCFileAttachment.saveTheChunk(cs.Id, 'testFile', base64Data, 'txt', fileId);
			try {
				CCFileAttachment.saveTheChunk(null, 'testFile', base64Data, 'txt', '');
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing Ticket record Id.'));
			}
			try {
				CCFileAttachment.saveTheChunk(cs.Id, null, base64Data, 'txt', '');
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing or empty file attachment.'));
			}

			List<ContentVersion> attachments = CCFileAttachment.getFileAttachments(cs.Id);

            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestIssueRecords();
       }
    }    
}