@isTest(SeeAllData=true)
public with sharing class CCBillingPaymentMethodTest {
    
    static testMethod void testPaymentMethod() {
        Account testAcc;
        Contact testCon;
        Zuora__CustomerAccount__c testBA;
        User testUser;

        // Test with no billing accounts
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testAcc = ZTestDataFactory.createAccountRecords(null, true);
	        testCon = ZTestDataFactory.createTestContact(testAcc, true);
	        testUser = ZTestDataFactory.createCommunityProviderRecord(testCon);
		}
		System.runAs(testUser) {
	        system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nCurrent User: ' + UserInfo.getUserName());
	        system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
        	String accId = ZTestDataFactory.getZAccountId();

            List<String> states = CCBillingPaymentMethod.getStates();
	        system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nStates: ' + states);

			try {
				CCPaymentMethodWrapper pmWrapper = CCBillingPaymentMethod.getPaymentMethodWrapper(accId);
		        system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\npmWrapper: ' + pmWrapper);
				
				CCPaymentMethodObject cc = pmWrapper.creditCards[0];
				CCPaymentMethodObject ach = pmWrapper.bankAccounts[0];
				cc.creditCardSecurityCode = '123';
				String JSONObj = '';
				
				try {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting No Payment Method Type');
					cc.paymentMethodType = '';
					JSONObj = JSON.serialize(cc);
					pmWrapper = CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);
				} catch(AuraHandledException e) {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nexception: ' + e.getMessage());
				}

				try {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting No Card Type');
					cc.paymentMethodType = 'CreditCard';
					cc.creditCardType = '';
					JSONObj = JSON.serialize(cc);
					pmWrapper = CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);
				} catch(AuraHandledException e) {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nexception: ' + e.getMessage());
				}

				try {
					cc.paymentMethodType = 'CreditCard';

					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Valid Visa');
					cc.creditCardType = 'Visa';
					cc.creditCardNumber = '4556801959351405';
					JSONObj = JSON.serialize(cc);
					CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);
		            // all other card types
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Valid MasterCard');
					cc.creditCardType = 'MasterCard';
					cc.creditCardNumber = '5523954145651100';
					JSONObj = JSON.serialize(cc);
					CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);

					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Valid Discover');
					cc.creditCardType = 'Discover';
					cc.creditCardNumber = '6011968243667328';
					JSONObj = JSON.serialize(cc);
					CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);

					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Invalid AmericanExpress');
					cc.creditCardType = 'AmericanExpress';
					cc.creditCardNumber = '12345';
					JSONObj = JSON.serialize(cc);
					CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);

				} catch(AuraHandledException e) {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nexception: ' + e.getMessage());
				}

				try {
					cc.paymentMethodType = 'CreditCard';

					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Invalid CardType');
					cc.creditCardType = 'Bogus';
					cc.creditCardNumber = '1234';
					JSONObj = JSON.serialize(cc);
					CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);
				} catch(AuraHandledException e) {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nexception: ' + e.getMessage());
				}

				try {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting valid ACH');
					ach.achAccountNumber = '123456789';
					JSONObj = JSON.serialize(ach);
					CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);

					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Invalid ACH');
					ach.achAccountNumber = '';
					JSONObj = JSON.serialize(ach);
					CCBillingPaymentMethod.savePaymentMethod(accId,JSONObj);
				} catch(AuraHandledException e) {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nexception: ' + e.getMessage());
				}

				try {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Removal of ACH');
					CCBillingPaymentMethod.removePaymentMethod(accId,'ACHId');

					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\nTesting Invalid Removal of ACH');
					ach.achAccountNumber = '';
					JSONObj = JSON.serialize(ach);
					CCBillingPaymentMethod.removePaymentMethod(accId,'');
				} catch(AuraHandledException e) {
					system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nexception: ' + e.getMessage());
				}

				
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingPaymentMethodTest.testPaymentMethod()]\n=========\nexception: ' + e.getMessage());
			}

		}
    }
}