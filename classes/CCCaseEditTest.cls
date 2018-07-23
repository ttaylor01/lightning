@isTest
public with sharing class CCCaseEditTest {
    
    @isTest
    public static void testCaseEdit() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.provider@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

	        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory('CCCaseEdit', 'getCase');
	        client.request.inputMap.put('recordId', cs.Id);
	        CCApexBridgeResponse response = client.validate();

	        client = CCApexBridgeTestHelper.factory('CCCaseEdit', 'saveCase');
	        client.request.records = new List<Case>();
	        client.request.records.add(cs);
	        response = client.validate();

	        client = CCApexBridgeTestHelper.factory('CCCaseEdit', 'saveCaseStatus');
	        client.request.inputMap.put('status', 'Closed');
	        client.request.inputMap.put('body', 'Test Comment');
	        client.request.records = new List<Case>();
	        client.request.records.add(cs);
	        response = client.validate();

	        client = CCApexBridgeTestHelper.factory('CCCaseEdit', 'invalidMethod');
	        response = client.validate();
	        
	        Test.stopTest();
        }

    }
    
    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestProviderRecords();
       }
    }    
}