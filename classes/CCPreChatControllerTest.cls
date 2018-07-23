@isTest
private class CCPreChatControllerTest {

    static testMethod void testPreChat() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            CCPreChatController ccPreChatCon = new CCPreChatController();
            Test.setCurrentPageReference(new PageReference('Page.CCPreChat'));
            ccPreChatCon.setDependentOptions();

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