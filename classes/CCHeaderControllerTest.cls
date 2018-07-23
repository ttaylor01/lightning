@isTest
private class CCHeaderControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account testAcc;
        Contact testCon;
        User testUser;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testAcc = createAccount();
	        testCon = createContact(testAcc);
	        testUser = createUser(testCon);
		}
        System.runAs(testUser) {
			Test.setCurrentPageReference(new PageReference('Page.CCStandardHeader'));
            system.debug('\n[DEBUG-CCHeaderControllerTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
            system.debug('\n[DEBUG-CCHeaderControllerTest.myUnitTest()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
            CCHeaderController ccHeaderController = new CCHeaderController();
        }
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			String profileName = 'Community HeW';
			Profile profile = [select Id from Profile where Name=:profileName];
	        testUser.profileId = profile.Id;
	        update testUser;
		}
        System.runAs(testUser) {
			Test.setCurrentPageReference(new PageReference('Page.CCStandardHeader'));
            system.debug('\n[DEBUG-CCHeaderControllerTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
            system.debug('\n[DEBUG-CCHeaderControllerTest.myUnitTest()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
            CCHeaderController ccHeaderController = new CCHeaderController();
        }
    }

	public static Account createAccount() {
		Account testAcc = new Account();
		testAcc.Name = 'testAccount';
		testAcc.BillingCity = 'Atlanta';
		testAcc.BillingState = 'GA';
		testAcc.BillingCountry = 'United States';
		testAcc.BillingPostalCode = '12345';
		testAcc.BillingStreet = '123';
		testAcc.ShippingStreet = '123';
		testAcc.ShippingCity = 'Atlanta';
		testAcc.ShippingState	 = 'GA';
		testAcc.ShippingPostalCode = '12345';
		//testAcc.zd_ID__c = '123';
		insert testAcc;

		Account_Identifier__c acctId = new Account_Identifier__c();
		acctId.Account_Identifier__c = 'HeW123';
		acctId.Account_Identifier_Type__c = 'HeW Sub ID';
		acctId.Account_Name__c = testAcc.Id;
		insert acctId;

		return testAcc;
	}

	public static Contact createContact(Account account) {
		Contact testcon = new Contact();
		testcon.firstname = 'testconfirst';
		testcon.lastname = 'testconlast';
		testcon.Phone = '7777777777';
		testcon.MobilePhone = '6666666666';
		testcon.HomePhone = '5555555555';
		testcon.OtherPhone = '4444444444';
		testcon.OtherStreet = 'Other Street';
		testcon.Salutation = 'Mr.';
		testcon.MailingCountry = 'United States';
		testCon.MailingCity = 'Atlanta';
		testCon.MailingState = 'Georgia';
		testCon.MailingStreet = '123 lane';
		testcon.email = 'test@test.com';
		testcon.AccountId = account.Id;
		insert testcon;
		return testcon;
	}
	public static User createUser(Contact contact) {
		String profileName = 'Community Provider';
		Profile profile = [select Id from Profile where Name=:profileName];
		User user = new User(
			ContactId = contact.Id,
			Username = 'community.test@availity.com',
			Email = 'community.test@availity.com',
			LastName = 'Community',
			FirstName = 'Test',
			Alias = 'com.test',
			CommunityNickname = 'comm',
			ProfileId = profile.Id,
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles',
			EmailEncodingKey='UTF-8'
		);
		insert user;
		user.IsPortalEnabled = true;
		update user;
		return user;
	}
}