@isTest
private class CCPayerReviewListTest {

    static testMethod void testPayerReviewList() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.payer@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			CCCasePagerWrapper cw = CCPayerReviewList.getCases('Open', '', 1, 5);
            system.debug('\n[DEBUG-CCPayerReviewListTest.testPayerReviewList()]\n=========\nOpen Cases: ' + cw.cases);
			cw = CCPayerReviewList.getCases('Closed', '', 1, 5);
            system.debug('\n[DEBUG-CCPayerReviewListTest.testPayerReviewList()]\n=========\nClosed Cases: ' + cw.cases);
			cw = CCPayerReviewList.getCases('Open', 'Payer Review', 1, 5);
            system.debug('\n[DEBUG-CCPayerReviewListTest.testPayerReviewList()]\n=========\nCases with search term \'Payer Review\': ' + cw.cases);
			cw = CCPayerReviewList.getCases('All', 'Payer Review', 1, 5);
            system.debug('\n[DEBUG-CCPayerReviewListTest.testPayerReviewList()]\n=========\nCases with search term \'Payer Review\': ' + cw.cases);

			// call to sort on Subject in ascending order
			cw = CCPayerReviewList.getCases('Open', '', 1, 5,'',true);

            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createPayerTestRecords();
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