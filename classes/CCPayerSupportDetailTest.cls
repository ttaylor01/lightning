@isTest
private class CCPayerSupportDetailTest {

    static testMethod void testCaseCreate() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.payer@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			Map<String,List<String>> myMap = CCPayerSupportDetail.getDependentOptions('Case', 'Case_Reason__c', 'Case_Submission_Method__c');
			myMap = CCPayerSupportDetail.getDependentOptions('Case', 'Case_Reason__c', 'Case_Brief_Description__c');
			myMap = CCPayerSupportDetail.getDependentOptions('Case', 'Case_Brief_Description__c', 'Case_Brief_Description_Detail__c');
			List<String> priorityList =  CCPayerSupportDetail.getRequestorPriorityValues();

			Case cs = CCPayerSupportDetail.getCase('');
            cs.Subject = 'new case';
            cs.Description = 'new case';
            cs.Call_Reason__c = 'ACE Edits';
            cs.Alternate_Email__c = 'foobar@example.com';
            CCPayerSupportDetail.saveCase(cs);

			// Create New Payer Request
			cs = CCPayerSupportDetail.getCase('');
            cs.Call_Reason__c = 'Other';
            cs.Subject = 'new payer request';
            cs.Description = 'new payer request';
            cs.Transaction__c = '270/271';
            CCPayerSupportDetail.saveCase(cs);
            
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
            
			Case testCase = CCPayerSupportDetail.getCase(cs.Id);
            cs.Alternate_Email__c = 'foobar@example.com';
            CCPayerSupportDetail.saveCase(cs);

			try {
	            CCPayerSupportDetail.saveCaseStatus(cs,'Closed','');
			} catch(AuraHandledException e) {
	            System.debug(e.getMessage());
	            System.debug(e.getTypeName());
	            System.assert(e.getMessage().contains('You must first enter a comment value.'));
			}
            CCPayerSupportDetail.saveCaseStatus(cs,'Closed','Test Comment');
			try {
	            cs.Id = null;
	            CCPayerSupportDetail.saveCaseStatus(cs,'Closed','Test Comment');
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
       }
    }    
}