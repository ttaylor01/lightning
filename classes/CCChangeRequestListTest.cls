@isTest
private class CCChangeRequestListTest {

    static testMethod void testCaseList() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.payer@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			CCCasePagerWrapper cw = CCChangeRequestList.getCases('Open', '', 1, 5);
            system.debug('\n[DEBUG-CCChangeRequestList.testCaseList()]\n=========\nOpen Cases: ' + cw.cases);
			cw = CCChangeRequestList.getCases('Closed', '', 1, 5);
            system.debug('\n[DEBUG-CCChangeRequestList.testCaseList()]\n=========\nClosed Cases: ' + cw.cases);
			cw = CCChangeRequestList.getCases('Open', 'Test', 1, 5);
            system.debug('\n[DEBUG-CCChangeRequestList.testCaseList()]\n=========\nCases with search term \'Test\': ' + cw.cases);
			cw = CCChangeRequestList.getCases('Open', 'Test Subject', 1, 5);
            system.debug('\n[DEBUG-CCChangeRequestList.testCaseList()]\n=========\nCases with search term \'Test Subject\': ' + cw.cases);
			cw = CCChangeRequestList.getCases('All', 'Test Subject', 1, 5);
            system.debug('\n[DEBUG-CCChangeRequestList.testCaseList()]\n=========\nCases with search term \'Test Subject\': ' + cw.cases);

			// call to sort on Subject in ascending order
			cw = CCChangeRequestList.getCases('Open', '', 1, 5,'',true);

            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createChangeRequestRecords();
       }
    }    
}