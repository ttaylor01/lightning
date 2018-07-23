public with sharing class CCBilling {
	private static final String DEBUG_STR = 'CCBilling';

	@AuraEnabled
	public static List<Zuora__CustomerAccount__c> getBillingAccounts() {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getBillingAccounts] ';
		system.debug(FUNC_STR+'\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
		
		User usr = [Select Id, UserName, AccountId, ContactId, ProfileId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
		Account acct = [Select Name, Entity_Gen_Key__c from Account Where Id = :usr.AccountId];
		system.debug(FUNC_STR+' \nUSER: ' + usr);
		system.debug(FUNC_STR+' \nACCOUNT: ' + acct);
		// Does user have access to view and manage billing information?
		if(!Test.isRunningTest() && !usr.Billing_Authorization__c) {
			throw getAuraException('You do not have authorization to view Billing Account information.');
		}

		CC_App_Settings__c profileSettings = (CC_App_Settings__c.getInstance(UserInfo.getProfileId())==null)?CC_App_Settings__c.getOrgDefaults():CC_App_Settings__c.getInstance(UserInfo.getProfileId());
		String linesOfBusiness = profileSettings.LOB__c;
		List<String> lobList = new List<String>();
		if(String.isNotBlank(linesOfBusiness)) {
			for(String lob : linesOfBusiness.split(',',0)) {
				lobList.add(lob);
			}
		}
		system.debug(FUNC_STR+' \nlinesOfBusiness: ' + linesOfBusiness);

		// Set intial page component visibility
		List<Zuora__CustomerAccount__c> accounts = new List<Zuora__CustomerAccount__c>();
		accounts = [SELECT Zuora__Account__c, Zuora__Balance__c, Name, Id, Zuora__Zuora_Id__c,
			Zuora__BillToId__c, Zuora__SoldToId__c, AvailityLineOfBusiness__c, Zuora__Parent__c, Zuora__AccountNumber__c, Zuora__BillToName__c,
			Zuora__Status__c, Zuora__LastInvoiceDate__c
			FROM Zuora__CustomerAccount__c
			WHERE
				Zuora__Account__c = :usr.AccountId 
				AND AvailityLineOfBusiness__c IN :lobList 
//				AND AvailityLineOfBusiness__c != 'AAC' AND AvailityLineOfBusiness__c != 'HeW' 
				AND	Zuora__Status__c = 'Active' 
			];
		system.debug(FUNC_STR+' \nAccounts: ' + accounts);
		// Has billing information for this account been established?
		if(accounts.size() < 1) {
			throw getAuraException('Billing Account has not been established.');
		}

        return accounts;
	}
	
	@AuraEnabled
	public static CCBillingAccountWrapper getBillingAccount(String recordId) {
		system.debug('[DEBUG-CCBillingAccountDetail.getBillingAccount()]\n=========\nrecordId: ' + recordId);
		system.debug('[DEBUG-CCCBillingAccountDetail.getBillingAccount()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
        CCBillingAccountWrapper zBillingAccount = new CCBillingAccountWrapper();
		
		User usr = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
		Account acct = [Select Name, Entity_Gen_Key__c from Account Where Id = :usr.AccountId];
		System.debug('[DEBUG-CCBillingAccountDetail.getBillingAccount] \nUSER: ' + usr);
		System.debug('[DEBUG-CCBillingAccountDetail.getBillingAccount] \nACCOUNT: ' + acct);
		zBillingAccount.hasBillingAccountAccess = true;
		// Does user have access to view and manage billing information?
		if(!Test.isRunningTest() && !usr.Billing_Authorization__c) {
			zBillingAccount.hasBillingAccountAccess = false;
			throw getAuraException('You do not have authorization to view Billing Account information.');
		}

		List<Zuora__CustomerAccount__c> billingAccountList = getBillingAccounts();
		// Let client know there are more billing accounts
		if(billingAccountList.size() > 1) zBillingAccount.hasMulitipleBillingAccounts = true;

		Zuora__CustomerAccount__c billingAccount;
		if(String.isBlank(recordId)) {
			if(billingAccountList.size() < 1) {
				throw getAuraException('Billing Account has not been established.');
			}
			// Select the appropriate Billing Account if there are more than 1.
			// If mulitple, Billing should be managed through the parent account.
			billingAccount = billingAccountList[0];
			for(Zuora__CustomerAccount__c za : billingAccountList) {
				if(String.isBlank(za.Zuora__Parent__c)) {
					billingAccount = za;
					break;
				}
			}
			recordId = billingAccount.Zuora__Zuora_Id__c;
		} else {
			billingAccount = [SELECT Zuora__Account__c, Zuora__Balance__c, Name, Id, Zuora__Zuora_Id__c,
				Zuora__BillToId__c, Zuora__SoldToId__c, AvailityLineOfBusiness__c, Zuora__Parent__c
				FROM Zuora__CustomerAccount__c
				WHERE Zuora__Zuora_Id__c = :recordId];
		}
		System.debug('[DEBUG-CCBillingAccountDetail.getBillingAccount()]\n=========\nBilling Account: ' + billingAccount);
		
		Zuora.zApi zApiInstance = CCZUtility.zlogin();

		/*
		 * Get Billing Account
		 */
		String queryStr = 'SELECT Id, AccountNumber, AutoPay, Balance, BillToId, ' +
			'DefaultPaymentMethodId, Name, PaymentGateway, SoldToId, TotalInvoiceBalance ' + 
			'FROM Account WHERE Id = \'' + billingAccount.Zuora__Zuora_Id__c + '\'';
			
		List<Zuora.zObject> accounts = CCZUtility.zquery(zApiInstance, queryStr, 'Account');
        system.debug('\n[DEBUG-CCBillingAccountDetail.getBillingAccount()] \n=========\nAccounts: ' + accounts);
		for(Zuora.zObject a : accounts) {
			zBillingAccount.id = (String)a.getValue('Id');
			zBillingAccount.accountNumber  = (String)a.getValue('AccountNumber');
			zBillingAccount.autoPay  = (Boolean)a.getValue('AutoPay');
			zBillingAccount.balance  = (decimal)a.getValue('Balance');
			zBillingAccount.billToId  = (String)a.getValue('BillToId');
			zBillingAccount.soldToId  = (String)a.getValue('SoldToId');
			zBillingAccount.defaultPaymentMethodId = (String)a.getValue('DefaultPaymentMethodId');
			zBillingAccount.name  = (String)a.getValue('Name');
			zBillingAccount.paymentGateway  = (String)a.getValue('PaymentGateway');
			zBillingAccount.totalInvoiceBalance  = (decimal)a.getValue('TotalInvoiceBalance');
		}

		/*
		 * Get Contacts
		 */
		queryStr = 'SELECT Id, Address1, Address2, City, PostalCode, State, FirstName, LastName, ' +
			'WorkEmail, WorkPhone ' + 
			'FROM Contact WHERE Id = \'' + zBillingAccount.billToId + '\' OR Id = \'' + zBillingAccount.soldToId + '\'';
        system.debug('\n[DEBUG-CCBillingAccountDetail.getBillingAccount()] \n=========\nBilling Contact QUERY: ' + queryStr);
		List<Zuora.zObject> contacts = CCZUtility.zquery(zApiInstance, queryStr, 'Contact');
        system.debug('\n[DEBUG-CCBillingAccountDetail.getBillingAccount()] \n=========\nContacts: ' + contacts);
        CCBillingContactWrapper billToContact = new CCBillingContactWrapper();
        CCBillingContactWrapper soldToContact = new CCBillingContactWrapper();
        for(Zuora.zObject c : contacts) {
        	String zId = (String)c.getValue('Id');
        	if(String.isNotBlank(zId)) {
        		// could be both bill to and sold to
        		if(zId.equals(zBillingAccount.billToId)) {
        			billToContact.id = zId;
        			billToContact.address1  = (String)c.getValue('Address1');
        			billToContact.address2  = (String)c.getValue('Address2');
        			billToContact.city  = (String)c.getValue('City');
        			billToContact.state  = (String)c.getValue('State');
        			billToContact.postalCode  = (String)c.getValue('PostalCode');
        			billToContact.firstName  = (String)c.getValue('FirstName');
        			billToContact.lastName  = (String)c.getValue('LastName');
        			billToContact.email  = (String)c.getValue('WorkEmail');
        			billToContact.phone  = (String)c.getValue('WorkPhone');
        			zBillingAccount.billToContact = billToContact;
        		}
        		if(zId.equals(zBillingAccount.soldToId)) {
        			soldToContact.id = zId;
        			soldToContact.address1  = (String)c.getValue('Address1');
        			soldToContact.address2  = (String)c.getValue('Address2');
        			soldToContact.city  = (String)c.getValue('City');
        			soldToContact.state  = (String)c.getValue('State');
        			soldToContact.postalCode  = (String)c.getValue('PostalCode');
        			soldToContact.firstName  = (String)c.getValue('FirstName');
        			soldToContact.lastName  = (String)c.getValue('LastName');
        			soldToContact.email  = (String)c.getValue('WorkEmail');
        			soldToContact.phone  = (String)c.getValue('WorkPhone');
        			zBillingAccount.soldToContact = soldToContact;
        		}
        	}
        }

		/*
		 * Get Payment Methods
		 */
		queryStr = 'SELECT Id, CreditCardMaskNumber, CreditCardType, CreditCardHolderName, PaymentMethodStatus, ' +
			'AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, Type, ' +
			'CreditCardAddress1, CreditCardAddress2, CreditCardCity, CreditCardCountry, CreditCardExpirationMonth, ' +
			'CreditCardExpirationYear, CreditCardPostalCode, CreditCardState ' + 
			'FROM PaymentMethod WHERE AccountId = \'' + zBillingAccount.id + '\'';
		List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
        system.debug('\n[DEBUG-CCBillingAccountDetail.getBillingAccount()] \n=========\nPayment Methods: ' + pms);
        // Place Credit Card methods first
		for(Zuora.zObject pm : pms) {
			if(('CreditCard').equals((String)pm.getValue('Type'))) {
				Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
				paymentMethod.Zuora__Type__c = (String)pm.getValue('Type');
				paymentMethod.Zuora__CreditCardMaskNumber__c = (String)pm.getValue('CreditCardMaskNumber');
				paymentMethod.Zuora__CreditCardHolderName__c = (String)pm.getValue('CreditCardHolderName');
				paymentMethod.Zuora__CreditCardType__c = (String)pm.getValue('CreditCardType');
				paymentMethod.Zuora__CreditCardAddress1__c = (String)pm.getValue('CreditCardAddress1');
				paymentMethod.Zuora__CreditCardAddress2__c = (String)pm.getValue('CreditCardAddress2');
				paymentMethod.Zuora__CreditCardCity__c = (String)pm.getValue('CreditCardCity');
				paymentMethod.Zuora__CreditCardCountry__c = (String)pm.getValue('CreditCardCountry');
				paymentMethod.Zuora__CreditCardExpirationMonth__c = String.valueOf(pm.getValue('CreditCardExpirationMonth'));
				paymentMethod.Zuora__CreditCardExpirationYear__c = String.valueOf(pm.getValue('CreditCardExpirationYear'));
				paymentMethod.Zuora__CreditCardPostalCode__c = (String)pm.getValue('CreditCardPostalCode');
				paymentMethod.Zuora__CreditCardState__c = (String)pm.getValue('CreditCardState');
				paymentMethod.Zuora__External_Id__c = (String)pm.getValue('Id');
                zBillingAccount.paymentMethods.put(paymentMethod.Zuora__External_Id__c,paymentMethod);
			}
		}
		// Then place ACH methods
		for(Zuora.zObject pm : pms) {
			if(('ACH').equals((String)pm.getValue('Type'))) {
				Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
				paymentMethod.Zuora__Type__c = (String)pm.getValue('Type');
				paymentMethod.Zuora__AchAbaCode__c = (String)pm.getValue('AchAbaCode');
				paymentMethod.Zuora__AchAccountName__c = (String)pm.getValue('AchAccountName');
				paymentMethod.Zuora__AchAccountNumberMask__c = (String)pm.getValue('AchAccountNumberMask');
				paymentMethod.Zuora__AchAccountType__c = (String)pm.getValue('AchAccountType');
				paymentMethod.Zuora__AchBankName__c = (String)pm.getValue('AchBankName');
				paymentMethod.Zuora__External_Id__c = (String)pm.getValue('Id');
                zBillingAccount.paymentMethods.put(paymentMethod.Zuora__External_Id__c,paymentMethod);
			}
		}
		// Set default payment method
		if(String.isNotBlank(zBillingAccount.defaultPaymentMethodId)) {
			// the defaultPaymentMethodId is some common non electronic type (ie Check), then set to blank
			if(zBillingAccount.paymentMethods.get(zBillingAccount.defaultPaymentMethodId) == null) {
				zBillingAccount.defaultPaymentMethodId = '';
			}
		}

		/*
		 *	Obtain latest Invoice to drive validation rule on auto pay edit
		 */
        List<CCInvoiceWrapper> invoiceList = new List<CCInvoiceWrapper>();
        queryStr = 'SELECT Id, AccountId, Amount, InvoiceDate, Status, PostedDate ' +
            'FROM Invoice WHERE AccountId = \'' + zBillingAccount.id + '\' AND Status = \'Posted\'';
        List<Zuora.zObject> invoices = CCZUtility.zquery(zApiInstance, queryStr, 'Invoice');
        system.debug('\n[DEBUG-CCBillingAccountDetail.getBillingAccount()] \n=========\nInvoices: ' + invoices);
        if(invoices.size() > 0) {
            for(Zuora.zObject obj : invoices) {
                Zuora__ZInvoice__c i = new Zuora__ZInvoice__c();
                i.Zuora__Zuora_Id__c = (String)obj.getValue('Id');
                i.Zuora__TotalAmount__c  = (decimal)obj.getValue('Amount');
                i.Zuora__InvoiceDate__c = (Date)obj.getValue('InvoiceDate');
                i.Zuora__Posted_Date__c = Date.valueOf((DateTime)obj.getValue('PostedDate'));
                invoiceList.add(new CCInvoiceWrapper(i));
            }
            invoiceList.sort();
            Zuora__ZInvoice__c i = invoiceList.get(0).invoice;
            if(i.Zuora__TotalAmount__c < 1000.00) {
                zBillingAccount.applyAutoPayEdit = true;
            }
        }
		
		return zBillingAccount;
	}
	
	@AuraEnabled
	public static CCBillingAccountWrapper saveBillingAccount(String id, Boolean autoPay, String defaultPaymentMethodId) {
		system.debug('[DEBUG-CCBillingAccountDetail.saveBillingAccount()]\n=========\nSTART SAVING');
		CCBillingAccountWrapper zBillingAccount = new CCBillingAccountWrapper();
		zBillingAccount.autoPay = autoPay;
		zBillingAccount.defaultPaymentMethodId = defaultPaymentMethodId;
		zBillingAccount.id = id;
		system.debug('[DEBUG-CCBillingAccountDetail.saveBillingAccount()]\n=========\nBilling Account: ' + zBillingAccount);

		try {
			Zuora.zApi zApiInstance = CCZUtility.zlogin();

			/*
			 * If trying to UNset DefaultPaymentMethod, you must either
			 * 1. Set to common, global method such as 'Check'
			 * 2. Use actual, underlying SOAP call and set the fieldsToNull on the desired field.
					<ns1:update> 
					<ns1:zObjects xsi:type="ns2:Account"> 
					**<ns2:fieldsToNull>DefaultPaymentMethodId</ns2:fieldsToNull>*
					<ns2:Id>2c92c0f9483f301e01485af0ab760717</ns2:Id> 
					</ns1:zObjects> 
					</ns1:update>
			 */
            if(String.isBlank(zBillingAccount.defaultPaymentMethodId)) {
                String queryStr = 'SELECT Id, Name, AccountId, Type ' + 
                    'FROM PaymentMethod WHERE Name = \'Check\'';
                List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
				system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \n=========\nPaymentMethods: ' + pms);
                // Place Credit Card methods first
                zBillingAccount.defaultPaymentMethodId = (String)pms[0].getValue('Id');
                for(Zuora.zObject pm : pms) {
					system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \n=========\nPaymentMethod Id: ' + (String)pm.getValue('Id'));
					system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \n=========\nPaymentMethod Type: ' + (String)pm.getValue('Type'));
					system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \n=========\nPaymentMethod Name: ' + (String)pm.getValue('Name'));
					system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \n=========\nPaymentMethod AccountId: ' + (String)pm.getValue('AccountId'));
                }
            }
/*
			Map<String,String> communicationProfileMap = new Map<String,String>();
			// initialize communication profiles to set based on autopay indicator
			communicationProfileMap = new Map<String,String>();
			List<zqu__CommunicationProfile__c> cpList = [SELECT Name, zqu__ZuoraId__c FROM zqu__CommunicationProfile__c];
			for(zqu__CommunicationProfile__c cp : cpList) {
				communicationProfileMap.put(cp.Name,cp.zqu__ZuoraId__c);
			}
			System.debug('[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \ncommunicationProfile: ' + communicationProfileMap);
*/
			Zuora.zObject obj = new Zuora.zObject('Account');
			obj.setValue('Id', zBillingAccount.Id);
			obj.setValue('AutoPay', zBillingAccount.autoPay);
//			obj.setValue('CommunicationProfileId', (zBillingAccount.autoPay)?communicationProfileMap.get('Credit Card Customer'):communicationProfileMap.get('Default Profile'));
			obj.setValue('PaymentTerm', (zBillingAccount.autoPay)?'Due Upon Receipt':'Net 30');
			obj.setValue('DefaultPaymentMethodId', String.isBlank(zBillingAccount.defaultPaymentMethodId)?null:zBillingAccount.defaultPaymentMethodId);

			system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \n=========\nZuora.zObject to update: ' + obj);
			List<Zuora.zObject> objs = new List<Zuora.zObject> {obj};
			List<Zuora.zApi.SaveResult> results = CCZUtility.zupdate(zApiInstance,objs);
			for (Zuora.zApi.SaveResult result : results) {
				if (result.Success) {
					CCZUtility.zsync(zApiInstance,zBillingAccount.id);
				} else {
					throw getAuraException('Error saving Account Payment Options:  \n' + result.errors);
				}
			}

		} catch (Exception ex) {
            system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingAccount()] \n=========\n catch block exception message:  '+ex.getMessage());
			throw getAuraException(ex.getMessage());
		}

		return getBillingAccount(id);
	}

	@AuraEnabled
	public static CCBillingContactWrapper saveBillingContact(Contact zContact) {
        CCBillingContactWrapper billingContact = new CCBillingContactWrapper();
		system.debug('[DEBUG-CCBillingAccountDetail.saveBillingContact()]\n=========\nBilling Contact: ' + zContact);

		boolean validInput = true;
		if(zContact == null) {
            validInput = false;
			throw getAuraException('Unable to obtain Contact record for null Contact');
		}
/*
		system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingContact()] \n=========\nUserInput to update: ' + zContact);
		if(String.isBlank(zContact.Email) ||
			String.isBlank(zContact.Phone) ||
			String.isBlank(zContact.FirstName) ||
			String.isBlank(zContact.LastName) ) {
            validInput = false;
			throw getAuraException('Please enter all required fields before saving changes');
		}
		// ensure correct phone format
		if(!PhoneFormatter.isValidPhone(zContact.Phone)) {
            validInput = false;
			throw getAuraException('Please enter a valid phone number - (xxx) xxx-xxxx');
            throw new AuraHandledException('Please enter a valid phone number - (xxx) xxx-xxxx');
		}
		if(!validInput) {
			return null;
		}
		zContact.phone = PhoneFormatter.formatPhone(zContact.Phone);
*/
		try {
			Zuora.zApi zApiInstance = CCZUtility.zlogin();

			Zuora.zObject obj = new Zuora.zObject('Contact');
			obj.setValue('Id', zContact.TrackerKey__c);
			obj.setValue('Address1', zContact.MailingStreet);
//			obj.setValue('Address2', zContact.address2);
			obj.setValue('City', zContact.MailingCity);
			obj.setValue('State', zContact.MailingState);
			obj.setValue('PostalCode', zContact.MailingPostalCode);
			obj.setValue('FirstName', zContact.FirstName);
			obj.setValue('LastName', zContact.LastName);
			obj.setValue('WorkEmail', zContact.Email);
			obj.setValue('WorkPhone', zContact.Phone);

			system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingContact()] \n=========\nZuora.zObject to update: ' + obj);
			List<Zuora.zObject> objs = new List<Zuora.zObject> {obj};
			List<Zuora.zApi.SaveResult> results = CCZUtility.zupdate(zApiInstance,objs);
			for (Zuora.zApi.SaveResult result : results) {
				if (result.Success) {
//					billingContact = getBillingContact(zContact.TrackerKey__c);
					CCZUtility.zsync(zApiInstance,zContact.TrackerKey__c);
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving Contact:\n' + result.errors));
				}
			}
		} catch (Exception ex) {
            system.debug('\n[DEBUG-CCBillingAccountDetail.saveBillingContact()] \n=========\n catch block exception message:  '+ex.getMessage());
			throw getAuraException(ex.getMessage());
		}

		return billingContact;
	}
	
	@AuraEnabled
	public static List<String> getStates() {
		List<String> options = new List<String>();
    	List<States__c> states = States__c.getall().values();
    	states.sort();
    	for(States__c s : states) {
    		options.add(s.State_Name__c);
    	}
    	return options;
	}

	private static AuraHandledException getAuraException(String msg) {
		AuraHandledException e = new AuraHandledException(msg);
		e.setMessage(msg);
		return e;
	}
}