public with sharing class CCBillingPaymentMethod {
    
	private static String VISA_VALIDATION = '^[4]([0-9]{15}$|[0-9]{12}$)';
	private static String MC_VALIDATION = '^[5][1-5][0-9]{14}$';
	private static String AMEX_VALIDATION = '^[34|37][0-9]{14}$';
	private static String DISCOVER_VALIDATION = '^6011-?\\d{4}-?\\d{4}-?\\d{4}$';

	@AuraEnabled
	public static CCPaymentMethodWrapper getPaymentMethodWrapper(String recordId) {
		CCPaymentMethodWrapper method = new CCPaymentMethodWrapper();
		List<CCPaymentMethodObject> creditCards = new List<CCPaymentMethodObject>();
		List<CCPaymentMethodObject> bankAccounts = new List<CCPaymentMethodObject>();
		try {
			system.debug('\n[DEBUG-CCBillingPaymentMethod.getPaymentMethodWrapper()]\n=========\nrecordId: '+ recordId);

			Zuora.zApi zApiInstance = CCZUtility.zlogin();

			String queryStr = 'SELECT Id, DefaultPaymentMethodId ' +
				'FROM Account WHERE Id = \'' + recordId + '\'';
			List<Zuora.zObject> accounts = CCZUtility.zquery(zApiInstance, queryStr, 'Account');
			system.debug('\n[DEBUG-CCBillingPaymentMethod.getPaymentMethodWrapper()] \n=========\nAccounts: ' + accounts);
			String defaultMethod;
			for(Zuora.zObject a : accounts) {
				defaultMethod = (String)a.getValue('DefaultPaymentMethodId');
			}

			queryStr = 'SELECT Id, CreditCardMaskNumber, CreditCardType, CreditCardHolderName, PaymentMethodStatus, ' +
				'AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, Type, ' +
				'CreditCardAddress1, CreditCardAddress2, CreditCardCity, CreditCardCountry, CreditCardExpirationMonth, ' +
				'CreditCardExpirationYear, CreditCardPostalCode, CreditCardState ' + 
				'FROM PaymentMethod WHERE AccountId = \'' + recordId + '\'';
			List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
            // Place Credit Card methods first
			for(Zuora.zObject pm : pms) {
				if(('CreditCard').equals((String)pm.getValue('Type'))) {
					CCPaymentMethodObject cc = new CCPaymentMethodObject();
					cc.paymentMethodType = (String)pm.getValue('Type');
					cc.zuoraId = (String)pm.getValue('Id');
					cc.creditCardType = (String)pm.getValue('CreditCardType');
					cc.creditCardNumber = (String)pm.getValue('CreditCardMaskNumber');
					cc.creditCardHolderName = (String)pm.getValue('CreditCardHolderName');
					cc.creditCardAddress1 = (String)pm.getValue('CreditCardAddress1');
					cc.creditCardAddress2 = (String)pm.getValue('CreditCardAddress2');
					cc.creditCardCity = (String)pm.getValue('CreditCardCity');
					cc.creditCardCountry = (String)pm.getValue('CreditCardCountry');
					cc.creditCardExpirationMonth = String.valueOf(pm.getValue('CreditCardExpirationMonth'));
					cc.creditCardExpirationYear = String.valueOf(pm.getValue('CreditCardExpirationYear'));
					cc.creditCardPostalCode = (String)pm.getValue('CreditCardPostalCode');
					cc.creditCardState = (String)pm.getValue('CreditCardState');
					cc.defaultMethod = (cc.zuoraId.equals(defaultMethod)) ? true : false;
					creditCards.add(cc);
				}
				if(('ACH').equals((String)pm.getValue('Type'))) {
					CCPaymentMethodObject ach = new CCPaymentMethodObject();
					ach.paymentMethodType = (String)pm.getValue('Type');
					ach.zuoraId = (String)pm.getValue('Id');
					ach.achAbaCode = (String)pm.getValue('AchAbaCode');
					ach.achAccountName = (String)pm.getValue('AchAccountName');
					ach.achAccountNumber = (String)pm.getValue('AchAccountNumberMask');
					ach.achAccountType = (String)pm.getValue('AchAccountType');
					ach.achBankName = (String)pm.getValue('AchBankName');
					ach.defaultMethod = (ach.zuoraId.equals(defaultMethod)) ? true : false;
					bankAccounts.add(ach);
				}
			}
		} catch (Exception ex) {
			system.debug('\n[DEBUG-CCBillingPaymentMethod.getPaymentMethods()]\n=========\nException catch block: '+ex.getMessage());
			throw getAuraException(ex.getMessage());
		}
		method.creditCards = creditCards;
		method.bankAccounts = bankAccounts;
		return method;
	}

	@AuraEnabled
	public static CCPaymentMethodWrapper removePaymentMethod(String recordId, String pmId) {
		if(String.isBlank(recordId) || String.isBlank(pmId)) {
			throw getAuraException('Null payment method Id');
		}

		Zuora.zApi zApiInstance = CCZUtility.zlogin();

		List<String> ids = new List<String>();
		ids.add(pmId);
		system.debug('\n[DEBUG-CCBillingPaymentMethod.removePaymentMethod()]\n=========\nids to remove: ' + ids);
		List<Zuora.zApi.DeleteResult> results = CCZUtility.zdelete(zApiInstance,ids,'PaymentMethod');
		for (Zuora.zApi.DeleteResult result : results) {
			if (result.Success) {
				CCZUtility.zsync(zApiInstance,recordId);
			} else {
				system.debug('\n[DEBUG-CCBillingPaymentMethod.removePaymentMethod()]\n=========\nError from CCZUtility.zdelete: '+result.errors);
				throw getAuraException('Error Removing Payment Method: '+ result.errors);
			}
		}

		return getPaymentMethodWrapper(recordId);
	}

	@AuraEnabled
	public static CCPaymentMethodWrapper savePaymentMethod(String recordId, String jsonObject) {
		CCPaymentMethodObject pm = (CCPaymentMethodObject)JSON.deserialize(jsonObject, CCPaymentMethodObject.class);
		system.debug('\n[DEBUG-CCBillingPaymentMethod.saveCreditCard()]\n=========\nPayment Method: '+pm);

		boolean newCreditCard = pm.paymentMethodType.equals('CreditCard');
		if(String.isBlank(pm.paymentMethodType)) {
			system.debug('\n[DEBUG-CCBillingPaymentMethod.savePaymentMethod()]\n=========\nCannot determine payment method type');
			throw getAuraException('Cannot determine payment method type.');
		}
		if(newCreditCard) {
			if(String.isBlank(pm.creditCardType) ||	String.isBlank(pm.creditCardNumber) || String.isBlank(pm.creditCardExpirationMonth) ||
				String.isBlank(pm.creditCardExpirationYear) || String.isBlank(pm.creditCardSecurityCode) ||	String.isBlank(pm.creditCardHolderName) ) {
				throw getAuraException('Please enter all required fields before saving new credit card');
			}
			if(!String.isBlank(pm.creditCardNumber) && !isValidCreditCard(pm.creditCardType,pm.creditCardNumber)) {
				throw getAuraException('Invalid Card Number for the Type selected.');
			}
		} else {
			if(String.isBlank(pm.achAbaCode) || String.isBlank(pm.achAccountName) || String.isBlank(pm.achAccountNumber) ||
				String.isBlank(pm.achAccountType) || String.isBlank(pm.achBankName)	) {
				throw getAuraException('Please enter all required fields before saving new automated clearinghouse account.');
			}
		}

		Zuora.zApi zApiInstance = CCZUtility.zlogin();
		String paymentType = pm.paymentMethodType;

		// update Account gateway to match payment method
		if(!udpateAccount(zApiInstance, recordId, paymentType)) {
			throw getAuraException('Unable to set Account Payment Gateway.');
		}

		Zuora.zObject paymentMethod = new Zuora.zObject('PaymentMethod');
		paymentMethod.setValue('AccountId', recordId);
		paymentMethod.setValue('SkipValidation', App_Settings__c.getInstance(UserInfo.getProfileId()).SkipValidation__c);	// Creates the payment method even if authorization fails with the payment gateway.
		if(newCreditCard) {
			paymentMethod.setValue('Type', 'CreditCard');
			paymentMethod.setValue('CreditCardSecurityCode', pm.creditCardSecurityCode);
			paymentMethod.setValue('UseDefaultRetryRule', true);
			paymentMethod.setValue('CreditCardType', pm.creditCardType);
			paymentMethod.setValue('CreditCardNumber', pm.creditCardNumber);
			paymentMethod.setValue('CreditCardHolderName', pm.creditCardHolderName);
			paymentMethod.setValue('CreditCardExpirationMonth', pm.creditCardExpirationMonth);
			paymentMethod.setValue('CreditCardExpirationYear', pm.creditCardExpirationYear);
			paymentMethod.setValue('CreditCardAddress1', pm.creditCardAddress1);
			paymentMethod.setValue('CreditCardAddress2', pm.creditCardAddress2);
			paymentMethod.setValue('CreditCardCity', pm.creditCardCity);
			paymentMethod.setValue('CreditCardCountry', pm.creditCardCountry);
			paymentMethod.setValue('CreditCardState', pm.creditCardState);
			paymentMethod.setValue('CreditCardPostalCode', pm.creditCardPostalCode);
		} else {
			paymentMethod.setValue('Type', 'ACH');
			paymentMethod.setValue('AchAbaCode', pm.achAbaCode);
			paymentMethod.setValue('AchAccountName', pm.achAccountName);
			paymentMethod.setValue('AchAccountNumber', pm.achAccountNumber);
			paymentMethod.setValue('AchAccountType', pm.achAccountType);
			paymentMethod.setValue('AchBankName', pm.achBankName);
		}

		system.debug('\n[DEBUG-CCBillingPaymentMethod.savePaymentMethod()] \n=========\nZuora.zObject to create: ' + paymentMethod);
		List<Zuora.zObject> objs = new List<Zuora.zObject> {paymentMethod};
		List<Zuora.zApi.SaveResult> results = CCZUtility.zcreate(zApiInstance,objs);
		for (Zuora.zApi.SaveResult result : results) {
			if (result.Success) {
				String mask = '';
				if(newCreditCard) {
					mask = pm.creditCardNumber;
					Integer size = pm.creditCardNumber.length();
					mask = '************' + mask.substring(size-4,size);
				} else {
					mask = pm.achAccountNumber;
					Integer size = pm.achAccountNumber.length();
					mask = '************' + mask.substring(size-4,size);
				}
				// set Terms and Agreement acceptance
				updateAccountTAA(zApiInstance, recordId, paymentType, mask);
				CCZUtility.zsync(zApiInstance,recordId);
			} else {
				system.debug('\n[DEBUG-CCBillingPaymentMethod.removePaymentMethod()]\n=========\nError from CCZUtility.zcreate: '+result.errors);
				throw getAuraException('Error Saving Payment Method:  ' + result.errors);
			}
		}

		return getPaymentMethodWrapper(recordId);
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

	private static boolean isValidCreditCard(String ccType, String ccNum) {

		String regExp = '';
                                                
		if (ccType == 'Visa') {
			regExp = VISA_VALIDATION;
		} else if (ccType == 'MasterCard') {
			regExp = MC_VALIDATION;
		} else if (ccType == 'Discover') {
			regExp = DISCOVER_VALIDATION;
		} else if (ccType == 'AmericanExpress') {
			regExp = AMEX_VALIDATION;
		} else {
			return false;
		}

		Pattern p = Pattern.compile(regExp);
		Matcher m = p.matcher(ccNum);
		if (!m.matches()) {
			return false;
		}

		// Now apply Luhn algorithm
		String[] tempNo = ccNum.split('-');
		ccNum = String.join(tempNo,'');
		Integer checksum = 0;
		Integer len = ccNum.length();
		for(Integer i=len-1 ; i>=0 ; i--) {
			Integer num = Integer.ValueOf(ccNum.substring(i,i+1));
			if(math.mod(i,2) == math.mod(len,2)) {
				Integer n = num * 2;
				checksum += (n/10) + (math.mod(n,10));
			} else {
				checksum += num;
			}
		}
		return ( math.mod(checksum,10) == 0 );
	} 	

	private static boolean udpateAccount(Zuora.zApi zApiInstance, String recordId, String paymentMethodType) {
		// Update Account Gateway to match payment method type
		String gateway = '';
		if(paymentMethodType.equals('CreditCard')) {
        	gateway = App_Settings__c.getInstance(UserInfo.getProfileId()).CreditCardGateway__c;
		} else {
        	gateway = App_Settings__c.getInstance(UserInfo.getProfileId()).ACHGateway__c;
		}
		Zuora.zObject account = new Zuora.zObject('Account');
		account.setValue('Id', recordId);
		account.setValue('PaymentGateway', gateway);
		List<Zuora.zObject> objs = new List<Zuora.zObject> {account};
		List<Zuora.zApi.SaveResult> results = CCZUtility.zupdate(zApiInstance,objs);
		for (Zuora.zApi.SaveResult result : results) {
			if (!result.Success) { 
				return false;
			}
		}
		return true;
	}
	
	private static boolean updateAccountTAA(Zuora.zApi zApiInstance, String recordId, String paymentType, String mask) {
		Zuora.zObject account = new Zuora.zObject('Account');
        DateTime dt = DateTime.now();
		account.setValue('Id', recordId);
		account.setValue('TermsAgreementsDateTime__c', dt.format());
		account.setValue('TermsAgreementsContact__c', UserInfo.getUserName());
		account.setValue('TermsAgreementsPaymentType__c', paymentType);
		account.setValue('TermsAgreementsPaymentNumber__c', mask);
		List<Zuora.zObject> objs = new List<Zuora.zObject> {account};
		List<Zuora.zApi.SaveResult> results = CCZUtility.zupdate(zApiInstance,objs);
		for (Zuora.zApi.SaveResult result : results) {
			if (!result.Success) {
				return false;
			}
		}
		return true;
	}
	
	private static AuraHandledException getAuraException(String msg) {
		AuraHandledException e = new AuraHandledException(msg);
		e.setMessage(msg);
		return e;
	}
}