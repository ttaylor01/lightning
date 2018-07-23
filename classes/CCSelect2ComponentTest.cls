@isTest
private class CCSelect2ComponentTest {

    static testMethod void testSelectComponent() {
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.payer@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

			List<String> opts = CCSelect2Component.getSelectOptions(new Case(), 'Region__c');
            system.debug('\n[DEBUG-CCSelect2ComponentTest.testSelectComponent()]\n=========\nList Options: ' + opts);

            Test.stopTest();
        }
    }

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
		    Account testAcc = CCTestDataFactory.createAccountRecords();
			List<Contact> testContacts = CCTestDataFactory.createContactRecords(testAcc);
			Contact testcon = testContacts.get(1);
			User user = CCTestDataFactory.createCommunityPayerRecord(testcon);
       }
    }    
}