@isTest
private class CCChangeRequestDetailTest {

    static testMethod void testCaseCreate() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.payer@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
			Case cs = CCChangeRequestDetail.getCase('');
            cs.Subject = 'new case';
            cs.Description = 'new case';
            cs.Alternate_Email__c = 'foobar@example.com';
            CCChangeRequestDetail.saveCase(cs);

            Test.stopTest();
        }
    }

    static testMethod void testCaseDetail() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.payer@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
			Case testCase = CCChangeRequestDetail.getCase(cs.Id);
            cs.Alternate_Email__c = 'foobar@example.com';
            CCChangeRequestDetail.saveCase(cs);

			try {
	            CCChangeRequestDetail.saveCaseStatus(cs,'Closed','');
			} catch(AuraHandledException e) {
	            System.debug(e.getMessage());
	            System.debug(e.getTypeName());
	            System.assert(e.getMessage().contains('You must first enter a comment value.'));
			}
            CCChangeRequestDetail.saveCaseStatus(cs,'Closed','Test Comment');
			try {
	            cs.Id = null;
	            CCChangeRequestDetail.saveCaseStatus(cs,'Closed','Test Comment');
			} catch(AuraHandledException e) {
	            System.debug(e.getMessage());
			}
 
            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createChangeRequestRecords();
       }
    }    
}