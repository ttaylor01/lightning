@isTest
private class CCPayerReviewDetailTest {

    static testMethod void testPayerReviewCreate() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.payer@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			Case cs = CCPayerReviewDetail.getCase('');
            cs.Subject = 'new case';
            cs.Description = 'new case';
            cs.Alternate_Email__c = 'foobar@example.com';
            CCPayerReviewDetail.saveCase(cs);

            Test.stopTest();
        }
    }

    static testMethod void testPayerReviewDetail() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.payer@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New Payer Review' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			Case testCase = CCPayerReviewDetail.getCase(cs.Id);
            cs.Alternate_Email__c = 'foobar@example.com';
            CCPayerReviewDetail.saveCase(cs);

			try {
	            CCPayerReviewDetail.saveCaseStatus(cs,'Closed','');
			} catch(AuraHandledException e) {
	            System.debug(e.getMessage());
	            System.debug(e.getTypeName());
	            System.assert(e.getMessage().contains('You must first enter a comment value.'));
			}
            CCPayerReviewDetail.saveCaseStatus(cs,'Closed','Test Comment');
			try {
	            cs.Id = null;
	            CCPayerReviewDetail.saveCaseStatus(cs,'Closed','Test Comment');
			} catch(AuraHandledException e) {
	            System.debug(e.getMessage());
			}
 
            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createPayerTestRecords();
        	CCTestDataFactory.createPayerSupportDependentPickListRecords();
/*
	        Account testAcc = CCTestDataFactory.createAccountRecords();
			List<Contact> testContacts = CCTestDataFactory.createContactRecords(testAcc);
			CCTestDataFactory.createCommunityPayerRecord(testContacts.get(1));
			CCTestDataFactory.createPayerCaseRecords(testAcc,testContacts.get(1));
			List<CCRecordTypes__c> ccr = CCTestDataFactory.createCCRecordTypes();
*/
       }
    }    
}