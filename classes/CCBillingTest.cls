@isTest(SeeAllData=true)
public with sharing class CCBillingTest {
    
    static testMethod void testBillingAccountSelect() {
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
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccountSelect()]\n=========\nCurrent User: ' + UserInfo.getUserName());
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccountSelect()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
			try {
				List<Zuora__CustomerAccount__c> accounts = CCBilling.getBillingAccounts();
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingTest.testBillingAccountSelect()]\n=========\nexception: ' + e.getMessage());
			}
		}

        // Test with billing accounts
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testBA = ZTestDataFactory.createBillingAccount(testAcc,true);
		}
		System.runAs(testUser) {
			try {
				List<Zuora__CustomerAccount__c> accounts = CCBilling.getBillingAccounts();
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingTest.testBillingAccountSelect()]\n=========\nexception: ' + e.getMessage());
			}
		}

    }

    static testMethod void testBillingAccount() {
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
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nCurrent User: ' + UserInfo.getUserName());
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());

            List<String> states = CCBilling.getStates();
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nStates: ' + states);

			try {
				// Test for default billing account
				CCBillingAccountWrapper baWrapper = CCBilling.getBillingAccount('');
		        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nbaWrapper: ' + baWrapper);
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingTest.testBillingAccountSelect()]\n=========\nexception: ' + e.getMessage());
			}
        }

        // Test no billing accounts
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testBA = ZTestDataFactory.createBillingAccount(testAcc,true);
		}
        System.runAs(testUser) {
        	String accId = ZTestDataFactory.getZAccountId();

			// Test for default billing account
			CCBillingAccountWrapper baWrapper = CCBilling.getBillingAccount('');
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nbaWrapper: ' + baWrapper);
			// Test for passed billing account
			baWrapper = CCBilling.getBillingAccount(accId);
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nbaWrapper: ' + baWrapper);
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nbaWrapper.defaultPayment: ' + baWrapper.defaultPayment);
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nbaWrapper.defaultCreditCard: ' + baWrapper.defaultCreditCard);
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nbaWrapper.paymentMethodString: ' + baWrapper.paymentMethodString);
	        system.debug('\n[DEBUG-CCBillingTest.testBillingAccount()]\n=========\nbaWrapper.paymentMethodOptions: ' + baWrapper.paymentMethodOptions);

			// Test Save billing acccount
			baWrapper = CCBilling.saveBillingAccount(accId, true, accId);

			// Test Save billing acccount
			baWrapper = CCBilling.saveBillingAccount(accId, true, '');
			baWrapper = CCBilling.saveBillingAccount(accId, true, accId);

			try {
				// Test Save billing contact			
				CCBillingContactWrapper cWrapper = CCBilling.saveBillingContact(testCon);
				// Test Save billing contact
				cWrapper = CCBilling.saveBillingContact(null);
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingTest.testBillingAccountSelect()]\n=========\nexception: ' + e.getMessage());
			}
        }
    }

}