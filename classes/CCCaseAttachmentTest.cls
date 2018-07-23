@isTest
private class CCCaseAttachmentTest {
    static testMethod void testAttachments() {
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			String base64Data = EncodingUtil.base64Encode(Blob.valueOf('file content'));
/*
			CCCaseAttachment.addAttachment(cs.Id, 'testFile', base64Data, 'txt');
			try {
				CCCaseAttachment.addAttachment(null, 'testFile', base64Data, 'txt');
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing Ticket record Id.'));
			}
			try {
				CCCaseAttachment.addAttachment(cs.Id, null, base64Data, 'txt');
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing or empty file attachment.'));
			}
*/
			Id fileId;
			fileId = CCCaseAttachment.saveTheChunk(cs.Id, 'testFile', base64Data, 'txt', '');
			fileId = CCCaseAttachment.saveTheChunk(cs.Id, 'testFile', base64Data, 'txt', fileId);
			try {
				CCCaseAttachment.saveTheChunk(null, 'testFile', base64Data, 'txt', '');
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing Ticket record Id.'));
			}
			try {
				CCCaseAttachment.saveTheChunk(cs.Id, null, base64Data, 'txt', '');
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing or empty file attachment.'));
			}

			try {
				CCCaseAttachment.deleteAttachment(cs.Id,null);
			} catch(AuraHandledException e) {
	            System.assert(e.getMessage().contains('Missing Ticket Id or Attachment Id.'));
			}
			List<Attachment> attachments = CCCaseAttachment.getCaseAttachments(cs.Id);
			Attachment att = null;
			for(Attachment a : attachments) {
				// Must have RIGHTS to delete as owner.
				if(a.CreatedById == testUser.Id) {
					CCCaseAttachment.deleteAttachment(cs.Id,a.Id);
				} else {
					try {
						CCCaseAttachment.deleteAttachment(cs.Id,a.Id);
					} catch(AuraHandledException e) { }
				}
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