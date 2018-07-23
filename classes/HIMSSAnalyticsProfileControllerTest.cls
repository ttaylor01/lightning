@isTest
private class HIMSSAnalyticsProfileControllerTest {

    static testMethod void testPayerReviewList() {
        Test.startTest();
    	
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
		String himssId = HIMSSAnalyticsProfileController.getHIMSSAnalyticsID(testAcc.Id);
        
        Test.stopTest();
    }

    @testSetup static void setup() {
    	CCTestDataFactory.createAccountRecords();
    }    
}