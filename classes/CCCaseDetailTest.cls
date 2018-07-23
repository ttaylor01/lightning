@isTest
private class CCCaseDetailTest {

    static testMethod void testCaseCreate() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			Map<String,List<String>> myMap = CCCaseDetail.getDependentOptions('Case', 'Case_Reason__c', 'Case_Brief_Description__c');
			myMap = CCCaseDetail.getDependentOptions('Case', 'Case_Brief_Description__c', 'Case_Brief_Description_Detail__c');
			myMap = CCCaseDetail.getDependentOptions('Case', 'Case_Reason__c', 'Case_Submission_Method__c');
			List<String> picklist = CCCaseDetail.getPayerStates();
			picklist = CCCaseDetail.getPayerTransactions();

			Case cs = CCCaseDetail.getCase('');
            cs.Subject = 'new case';
            cs.Description = 'new case';
            cs.Call_Reason__c = 'Login';
            cs.Alternate_Email__c = 'foobar@example.com';
            CCCaseDetail.saveCase(cs);

			// Create New Payer Request
			cs = CCCaseDetail.getCase('');
            cs.Call_Reason__c = 'New Payer Request';
			cs.Payer_Name__c = 'TEST PAYER NAME';
            cs.Subject = 'new payer request';
            cs.Description = 'new payer request';
            cs.New_Payer_Transaction__c = '270';
            CCCaseDetail.saveCase(cs);
            
            Test.stopTest();
        }
    }

    static testMethod void testCaseDetail() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
			Case testCase = CCCaseDetail.getCase(cs.Id);
            cs.Alternate_Email__c = 'foobar@example.com';
            CCCaseDetail.saveCase(cs);

			try {
	            CCCaseDetail.saveCaseStatus(cs,'Closed','');
			} catch(AuraHandledException e) {
	            System.debug(e.getMessage());
	            System.debug(e.getTypeName());
	            System.assert(e.getMessage().contains('You must first enter a comment value.'));
			}
            CCCaseDetail.saveCaseStatus(cs,'Closed','Test Comment');
			try {
	            cs.Id = null;
	            CCCaseDetail.saveCaseStatus(cs,'Closed','Test Comment');
			} catch(AuraHandledException e) {
	            System.debug(e.getMessage());
			}
 
            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestRecords();
        	CCTestDataFactory.createCaseDependentPickListRecords();
       }
    }    
}