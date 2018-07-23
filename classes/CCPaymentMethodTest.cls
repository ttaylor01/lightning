@isTest(SeeAllData=true)
public with sharing class CCPaymentMethodTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account testAcc;
        Contact testCon;
        Zuora__CustomerAccount__c testBA;
        User testUser;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testAcc = createAccount();
	        testCon = createContact(testAcc);
	        testBA = createBillingAccount(testAcc);
	        testUser = createUser(testCon);
		}
        System.runAs(testUser) {
			Test.setCurrentPageReference(new PageReference('Page.CCPaymentMethod'));
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
			System.currentPageReference().getParameters().put('id', testBA.Zuora__Zuora_Id__c);
			System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCBillingAccount');
            CCPaymentMethod cctest = new CCPaymentMethod();
            cctest.goBack();
            cctest.getStates();
            
            // Test toggle page modes
			cctest.taaInput = false;
			cctest.newCreditCard = true;
			cctest.newAch = true;
            cctest.toggleNewCreditCardMode();	// turn on
            cctest.toggleNewCreditCardMode();	// turn off
			cctest.newCreditCard = true;
			cctest.newAch = true;
            cctest.toggleNewAchMode();			// turn on
            cctest.toggleNewAchMode();			// turn off
			System.currentPageReference().getParameters().put('pmId', 'CreditCardId');
			cctest.newCreditCard = true;
			cctest.newAch = true;
            cctest.editCreditCardOn();			// turn on
			cctest.newCreditCard = true;
			cctest.newAch = true;
            cctest.editCreditCardOff();			// turn off
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nnewCreditCard: ' + cctest.newCreditCard);
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nnewAch: ' + cctest.newAch);
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nnewCreditCard: ' + cctest.editCreditCard);

			System.currentPageReference().getParameters().remove('pmId');
			System.currentPageReference().getParameters().put('pmId', 'CreditCardId');
            cctest.editCreditCardOn();			// turn on
            cctest.ccMethodUI.creditCardSecurityCode = '123';
            cctest.acceptTermsAndAgreement();
			cctest.taaInput = true;
            cctest.acceptTermsAndAgreement();
			cctest.editPaymentMethod();
            // test bad input
			System.currentPageReference().getParameters().remove('pmId');
			System.currentPageReference().getParameters().put('pmId', 'CreditCardId');
            cctest.editCreditCardOn();			// turn on
            cctest.ccMethodUI.creditCardSecurityCode = '';
			cctest.editPaymentMethod();

			System.currentPageReference().getParameters().remove('pmId');
			System.currentPageReference().getParameters().put('pmId', 'CreditCardId');
			cctest.removePaymentMethod();

			cctest.ccMethodUI = new CCPaymentMethod.CCMethodUI();
			cctest.ccMethodUI.creditCardType = 'Visa';
			cctest.ccMethodUI.creditCardNumber = '4556801959351405';
			cctest.ccMethodUI.creditCardHolderName = 'CardHolder';
			cctest.ccMethodUI.creditCardCountry  = 'US';
			cctest.ccMethodUI.creditCardExpirationMonth  = '11';
			cctest.ccMethodUI.creditCardExpirationYear  = '2099';
			cctest.ccMethodUI.creditCardSecurityCode = '123';
            cctest.toggleNewCreditCardMode();	// turn on
            cctest.savePaymentMethod();
            // all other card types
			cctest.ccMethodUI.creditCardType = 'MasterCard';
			cctest.ccMethodUI.creditCardNumber = '5523954145651100';
            cctest.toggleNewCreditCardMode();	// turn on
            cctest.savePaymentMethod();
			cctest.ccMethodUI.creditCardType = 'Discover';
			cctest.ccMethodUI.creditCardNumber = '6011968243667328';
            cctest.savePaymentMethod();
			cctest.ccMethodUI.creditCardType = 'AmericanExpress';
			cctest.ccMethodUI.creditCardNumber = '12345';
            cctest.savePaymentMethod();
			cctest.ccMethodUI.creditCardType = 'Bogus';
			cctest.ccMethodUI.creditCardNumber = '1234';
            cctest.savePaymentMethod();
            cctest.ccMethodUI.getExpires();
            cctest.ccMethodUI.getImage();

            cctest.achMethodUI = new CCPaymentMethod.ACHMethodUI();
            cctest.achMethodUI.achAccountName = 'AccountName';
            cctest.achMethodUI.achAccountNumber = '0987654321';
            cctest.achMethodUI.achAccountType = 'Checking';
            cctest.achMethodUI.achBankName = 'BankName';
            cctest.toggleNewAchMode();	// turn on
            cctest.savePaymentMethod();
            cctest.achMethodUI.achAbaCode = '123456789';
            cctest.savePaymentMethod();
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
	public static Zuora__CustomerAccount__c createBillingAccount(Account testAcc) {
		Zuora__CustomerAccount__c testCA = new Zuora__CustomerAccount__c();
		testCA.Zuora__Zuora_Id__c = 'TestZuoraID';
		testCA.Zuora__Account__c = testAcc.Id;
		insert testCA;
		return testCA;
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