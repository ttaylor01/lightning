@isTest
private class CCPostChatControllerTest {

    static testMethod void testPostChat() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            CCPostChatController ccPostChatCon = new CCPostChatController();
            Test.setCurrentPageReference(new PageReference('Page.CCPostChat'));
            System.currentPageReference().getParameters().put('attachedRecords', '{"CaseId":"'+testCase.Id+'","ContactId":"'+testCon.Id+'"}');
            System.currentPageReference().getParameters().put('disconnectedBy', 'agent');
            ccPostChatCon.initVariables();
            System.currentPageReference().getParameters().put('disconnectedBy', 'client');
            ccPostChatCon.initVariables();
            System.currentPageReference().getParameters().put('disconnectedBy', 'clientIdleTimeout');
            ccPostChatCon.initVariables();
            System.currentPageReference().getParameters().put('disconnectedBy', 'agentsUnavailable');
            ccPostChatCon.initVariables();
            System.currentPageReference().getParameters().put('disconnectedBy', 'error');
            ccPostChatCon.initVariables();

            ccPostChatCon.getScores();
            System.currentPageReference().getParameters().put('selectedScore', '9');
            ccPostChatCon.getSelected();
            System.currentPageReference().getParameters().put('chatSatisfactionScore', '9');
            ccPostChatCon.save();

            Test.stopTest();
        }
    }    

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
        	CCTestDataFactory.createTestRecords();
       }
    }    
}