@isTest
public class CCBillingSupportListTest {

    @isTest
    public static void testCaseList() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.provider@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

	        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory('CCBillingSupportList', 'getCases');
	        client.request.inputMap.put('listView', 'Open');
	        client.request.inputMap.put('searchStr', '');
	        client.request.inputMap.put('pageNumber', '1');
	        client.request.inputMap.put('recordToDisplay', '5');
	        client.request.inputMap.put('sortField', '');
	        client.request.inputMap.put('isAsc', 'true');
	
	        CCApexBridgeResponse response = client.validate();

	        client = CCApexBridgeTestHelper.factory('CCBillingSupportList', 'invalidMethod');
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