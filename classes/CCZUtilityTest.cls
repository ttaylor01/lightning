@isTest(SeeAllData=true)
private class CCZUtilityTest {

    static testMethod void myUnitTest() {
    	String Id = '1234567890';
 		Zuora.zApi zApiInstance = CCZUtility.zlogin();

		// Query each zuora object type
		String queryStr = 'SELECT Id, AccountNumber, AutoPay, Balance, BillToId, ' +
			'DefaultPaymentMethodId, Name, PaymentGateway, SoldToId, TotalInvoiceBalance ' + 
			'FROM Account WHERE Id = \'1234567890\'';
		List<Zuora.zObject> objs = CCZUtility.zquery(zApiInstance, queryStr, 'Account');
        system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nAccounts: ' + objs);
		queryStr = 'SELECT Id, Address1, Address2, City, PostalCode, State, FirstName, LastName, ' +
			'WorkEmail, WorkPhone ' + 
			'FROM Contact WHERE Id = \'' + Id + '\' OR Id = \'' + Id + '\'';
		objs = CCZUtility.zquery(zApiInstance, queryStr, 'Contact');
        system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nContacts: ' + objs);
		queryStr = 'SELECT Id, CreditCardMaskNumber, CreditCardType, CreditCardHolderName, PaymentMethodStatus, ' +
			'AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, Type, ' +
			'CreditCardAddress1, CreditCardAddress2, CreditCardCity, CreditCardCountry, CreditCardExpirationMonth, ' +
			'CreditCardExpirationYear, CreditCardPostalCode, CreditCardState ' + 
			'FROM PaymentMethod WHERE AccountId = \'' + Id + '\'';
		objs = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
        system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nPayment Methods: ' + objs);
		queryStr = 'SELECT Id, AccountId, Amount, Balance, DueDate, InvoiceDate, InvoiceNumber, PaymentAmount, ' +
			'Status, TaxAmount ' +
			'FROM Invoice WHERE AccountId = \'' + Id + '\'';
		objs = CCZUtility.zquery(zApiInstance, queryStr, 'Invoice');
        system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nInvoices: ' + objs);
		queryStr = 'SELECT Id, ChargeAmount, RatePlanChargeId, ' +
			'Quantity, ServiceEndDate, ServiceStartDate, UnitPrice, TaxAmount ' +
			'FROM InvoiceItem WHERE InvoiceId = \'' + Id + '\' AND ChargeAmount > 0';
		objs = CCZUtility.zquery(zApiInstance, queryStr, 'InvoiceItem');
        system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nInvoice Items: ' + objs);
		queryStr = 'SELECT Id, Name ' +
			'FROM RatePlanCharge WHERE Id = \'' + Id + '\'';
		objs = CCZUtility.zquery(zApiInstance, queryStr, 'RatePlanCharge');
        system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nRatePlanCharges: ' + objs);

		Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
		pm.setValue('AccountId', Id);
		pm.setValue('Type', 'ACH');
		system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nZuora.zObject to create: ' + pm);
		objs = new List<Zuora.zObject> {pm};
		List<Zuora.zApi.SaveResult> sResults = CCZUtility.zcreate(zApiInstance,objs);

		Zuora.zObject obj = new Zuora.zObject('Account');
		obj.setValue('Id', Id);
		obj.setValue('AutoPay', true);
		system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nZuora.zObject to update: ' + obj);
		objs = new List<Zuora.zObject> {obj};
		List<Zuora.zApi.SaveResult> uResults = CCZUtility.zupdate(zApiInstance,objs);

		List<String> ids = new List<String>();
		ids.add(Id);
        system.debug('\n[DEBUG-CCZUtilityTest.myUnitTest()] \n=========\nids to remove: ' + ids);
		List<Zuora.zApi.DeleteResult> dResults = CCZUtility.zdelete(zApiInstance,ids,'PaymentMethod');

		CCZUtility.zsync(zApiInstance,Id);

		String label = CCZUtility.getResourceURL('CCVisaLogo');

/* 
        Account testAcc = createAccount();
        Contact testCon = createContact(testAcc);
        Zuora__CustomerAccount__c testBA = createBillingAccount(testAcc);
        User testUser = createUser(testCon);
        System.runAs(testUser) {
			Test.setCurrentPageReference(new PageReference('Page.CCBillingAccount'));
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
            CCBillingAccount ccBillingAccount = new CCBillingAccount();
            if(ccBillingAccount.zBillingAccount.defaultPayment) {}
            if(ccBillingAccount.zBillingAccount.defaultCreditCard) {}
            if(ccBillingAccount.zBillingAccount.paymentMethodString != null) {}
            
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n========= getMethods()');
            ccBillingAccount.getMethods();
            ccBillingAccount.getStates();

            // Test toggle page modes
			System.currentPageReference().getParameters().put('contactType', 'BillTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.toggleEditContactMode();  // turn off
			System.currentPageReference().getParameters().remove('contactType');
			System.currentPageReference().getParameters().put('contactType', 'SoldTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.toggleEditContactMode();  // turn off
            ccBillingAccount.toggleEditAccountMode();  // turn on
            ccBillingAccount.toggleEditAccountMode();  // turn off

			// test edit contact
			System.currentPageReference().getParameters().remove('contactType');
			System.currentPageReference().getParameters().put('contactType', 'BillTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.editBillingContact();
            // test bad input
			System.currentPageReference().getParameters().remove('contactType');
			System.currentPageReference().getParameters().put('contactType', 'SoldTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.editBillingContact();

			// test edit account        
            ccBillingAccount.toggleEditAccountMode();  // turn on
            ccBillingAccount.editBillingAccount();  // turn on
        }
*/
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
		String profileName = 'Community HeW';
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