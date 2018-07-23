@isTest
private class CCLookupSObjectTest {

    static testMethod void testLookup() {
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			CCLookupSObjectController.SearchResult[] results = CCLookupSObjectController.lookup('testcon2first', 'Contact');

   			results = CCLookupSObjectController.lookupWithClause('testconfirst', 'Contact', 'Id IN (Select ContactId FROM User)');

            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestRecords();
       }
    }    
}