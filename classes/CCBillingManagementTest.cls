@isTest(SeeAllData=true)
public with sharing class CCBillingManagementTest {
    
    static testMethod void testBillingManagement() {
        Account testAcc;
        Contact testCon;
        Zuora__CustomerAccount__c testBA;
        User testUser;

        // Test with no billing accounts
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testAcc = ZTestDataFactory.createAccountRecords(null, true);
	        testCon = ZTestDataFactory.createTestContact(testAcc, true);
	        testUser = ZTestDataFactory.createCommunityProviderRecord(testCon);
	        testBA = ZTestDataFactory.createBillingAccount(testAcc,true);
		}
    	String accId = ZTestDataFactory.getZAccountId();

		System.runAs(testUser) {
	        system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nCurrent User: ' + UserInfo.getUserName());
	        system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
			try {
				// Test getting Invoices
				List<CCInvoiceWrapper> invoices = CCBillingManagement.getInvoices(accId);
				invoices.sort();
				invoices = CCBillingManagement.getInvoices(accId,'unpaid');
				invoices = CCBillingManagement.getInvoices(accId,'paid');
				
				// Test getting Payments
				List<Zuora__Payment__c> payments = CCBillingManagement.getPayments(accId);

			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nexception: ' + e.getMessage());
			}
		}

		System.runAs(testUser) {
	        system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nCurrent User: ' + UserInfo.getUserName());
	        system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
			try {
				CCBillingManagementWrapper bmWrapper = CCBillingManagement.getBillingManagementWrapper(accId);
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nbmWrapper.total: ' + bmWrapper.total);
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nbmWrapper.paymentMethodOptions: ' + bmWrapper.paymentMethodOptions);
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nexception: ' + e.getMessage());
			}
		}

		// Test make payment
		System.runAs(testUser) {
			try {
				// Test getting Invoices
				CCInvoiceWrapper iWrapper = new CCInvoiceWrapper();
				List<CCInvoiceWrapper> invoices = CCBillingManagement.getInvoices(accId);
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nInvoices: ' + invoices);
				iWrapper = invoices[0];
				iWrapper.inputPaymentAmount = 1;
				String JSONObj = JSON.serialize(invoices);
				CCBillingManagement.savePayments(accId,JSONObj,'CreditCardId');
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nexception: ' + e.getMessage());
			}
		}

		// Test make payment > balance
		System.runAs(testUser) {
			try {
				// Test getting Invoices
				List<CCInvoiceWrapper> invoices = CCBillingManagement.getInvoices(accId);
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nInvoices: ' + invoices);
				invoices[0].inputPaymentAmount = 10000;
				String JSONObj = JSON.serialize(invoices);
				CCBillingManagement.savePayments(accId,JSONObj,'CreditCardId');
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nexception: ' + e.getMessage());
			}
		}

		// Test make payment - missing required field
		System.runAs(testUser) {
			try {
				// Test getting Invoices
				List<CCInvoiceWrapper> invoices = CCBillingManagement.getInvoices(accId);
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nInvoices: ' + invoices);
				invoices[0].inputPaymentAmount = 11;
				String JSONObj = JSON.serialize(invoices);
				CCBillingManagement.savePayments(accId,JSONObj,'');
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nexception: ' + e.getMessage());
			}
		}

		// Test get pdf file
		System.runAs(new User(Id = UserInfo.getUserId())) {
			try {
				// Test getting Invoices
				List<CCInvoiceWrapper> invoices = CCBillingManagement.getInvoices(accId);
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nInvoices: ' + invoices);
				String pdfId = CCBillingManagement.getInvoicePDF(accId);
			} catch(AuraHandledException e) {
				system.debug('\n[DEBUG-CCBillingManagementTest.testBillingManagement()]\n=========\nexception: ' + e.getMessage());
			}
		}

    }

}