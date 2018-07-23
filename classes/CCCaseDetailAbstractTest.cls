@isTest
public with sharing class CCCaseDetailAbstractTest {
    
    @isTest
    public static void testCaseCreate() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

	        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory('CCCaseDetailAbstractTestHelper', 'getCase');
	        client.request.inputMap.put('recordId', '');
	        CCApexBridgeResponse response = client.validate();
	        Case cs = (Case) CCApexBridgeAbstract.decodeData(response.output, Case.class);
            cs.Subject = 'new case';
            cs.Description = 'new case';

	        client = CCApexBridgeTestHelper.factory('CCCaseDetailAbstractTestHelper', 'saveCase');
	        client.request.records = new List<Case>();
	        client.request.records.add(cs);
	        response = client.validate();

	        Test.stopTest();
        }
    }

	@isTest
    public static void testCaseEdit() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case cs = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

	        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory('CCCaseDetailAbstractTestHelper', 'getCase');
	        client.request.inputMap.put('recordId', cs.Id);
	        CCApexBridgeResponse response = client.validate();
	        cs = (Case) CCApexBridgeAbstract.decodeData(response.output, Case.class);

            cs.Subject = 'new case';
	        client = CCApexBridgeTestHelper.factory('CCCaseDetailAbstractTestHelper', 'saveCase');
	        client.request.records = new List<Case>();
	        client.request.records.add(cs);
	        response = client.validate();

	        client = CCApexBridgeTestHelper.factory('CCCaseDetailAbstractTestHelper', 'saveCaseStatus');
	        client.request.inputMap.put('status', 'Closed');
	        client.request.records = new List<Case>();
	        client.request.records.add(cs);
	        response = client.validate();

	        client = CCApexBridgeTestHelper.factory('CCCaseDetailAbstractTestHelper', 'saveCaseStatus');
	        client.request.inputMap.put('status', 'Closed');
	        client.request.inputMap.put('body', 'Test Comment');
	        client.request.records = new List<Case>();
	        client.request.records.add(cs);
	        response = client.validate();

	        client = CCApexBridgeTestHelper.factory('CCCaseDetailAbstractTestHelper', 'saveCaseStatus');
	        client.request.inputMap.put('status', 'Closed');
	        client.request.inputMap.put('body', 'Test Comment');
	        client.request.records = new List<Case>();
	        cs.Id = null;
	        client.request.records.add(cs);
	        response = client.validate();

	        Test.stopTest();
        }

    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestRecords();
       }
    }    
}