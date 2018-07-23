public with sharing class CCBillingAccountWrapper {
    
	@AuraEnabled public String id { get; set; }
	@AuraEnabled public String accountNumber { get; set; }
	@AuraEnabled public Boolean autoPay { get; set; }
	@AuraEnabled public decimal balance { get; set; }
	@AuraEnabled public decimal totalInvoiceBalance { get; set; }
	@AuraEnabled public String billToId { get; set; }
	@AuraEnabled public CCBillingContactWrapper billToContact { get; set; }
	@AuraEnabled public String soldToId { get; set; }
	@AuraEnabled public CCBillingContactWrapper soldToContact { get; set; }
	@AuraEnabled public String defaultPaymentMethodId { get; set; }
	@AuraEnabled public String name { get; set; }
	@AuraEnabled public String paymentGateway { get; set; }
//	@AuraEnabled public Zuora__PaymentMethod__c defaultPaymentMethod { get; set; }
	@AuraEnabled public Map<String,Zuora__PaymentMethod__c> paymentMethods;
	@AuraEnabled public Boolean applyAutoPayEdit { get; set; }
	@AuraEnabled public Boolean hasMulitipleBillingAccounts { get; set; }
	@AuraEnabled public Boolean hasBillingAccountAccess { get; set; }
	@AuraEnabled public boolean defaultPayment {
		get {
			Boolean isDefault = false;
			Zuora__PaymentMethod__c defaultPaymentMethod;
			if(String.isNotBlank(defaultPaymentMethodId)) {
				defaultPaymentMethod = paymentMethods.get(defaultPaymentMethodId);
			}
			if(defaultPaymentMethod != null && (String.isNotBlank(defaultPaymentMethod.Zuora__CreditCardMaskNumber__c) || String.isNotBlank(defaultPaymentMethod.Zuora__AchAccountNumberMask__c))) {
				isDefault = true;
			}
			return isDefault;
		}
		set;
	}
	@AuraEnabled public boolean defaultCreditCard {
		get {
			Boolean isDefault = false;
			Zuora__PaymentMethod__c defaultPaymentMethod;
			if(String.isNotBlank(defaultPaymentMethodId)) {
				defaultPaymentMethod = paymentMethods.get(defaultPaymentMethodId);
			}
			if(String.isNotBlank(defaultPaymentMethodId) && defaultPaymentMethod != null && defaultPaymentMethod.Zuora__Type__c.equals('CreditCard')) {
				isDefault = true;
			}
			return isDefault;
		}
		set;
	}
	@AuraEnabled public String paymentMethodString {
		get {
			Zuora__PaymentMethod__c defaultPaymentMethod;
			if(String.isNotBlank(defaultPaymentMethodId)) {
				defaultPaymentMethod = paymentMethods.get(defaultPaymentMethodId);
			}
			System.debug('[DEBUG-CCBillingAccountWrapper.getPaymentMethodString()]\n=========\nDefault Payment Method: ' + defaultPaymentMethod);
			String strValue = '';
			if(defaultPaymentMethod != null) {
				strValue = 'ACH ' + defaultPaymentMethod.Zuora__AchBankName__c + ' ' + defaultPaymentMethod.Zuora__AchAccountNumberMask__c;
				if(defaultCreditCard) {
					strValue = '<img src="'+CCZUtility.getResourceURL('CC' + defaultPaymentMethod.Zuora__CreditCardType__c + 'Logo')+'" align="middle">  ';
	        		strValue += defaultPaymentMethod.Zuora__CreditCardMaskNumber__c;
	        		strValue += '&nbsp;&nbsp;<strong> Expires: </strong>' + defaultPaymentMethod.Zuora__CreditCardExpirationMonth__c + '/' + defaultPaymentMethod.Zuora__CreditCardExpirationYear__c;
				}
			}
    		return strValue;
		}
		set;
	}
	@AuraEnabled public Map<String, String> paymentMethodOptions {
		get {
			Map<String, String> options = new Map<String, String>();
	        // If we have defined payment methods and a selected defaul method, display ability to remove.
			for(Zuora__PaymentMethod__c pm : paymentMethods.values()) {
				String label = '';
				if(('CreditCard').equals(pm.Zuora__Type__c)) {
					label += '<img src="'+CCZUtility.getResourceURL('CC' + pm.Zuora__CreditCardType__c + 'Logo')+'" align="middle">&nbsp;&nbsp;';
		    		label += pm.Zuora__CreditCardMaskNumber__c;
	                label += '&nbsp;&nbsp;<strong> Expires: </strong>' + pm.Zuora__CreditCardExpirationMonth__c + '/' + pm.Zuora__CreditCardExpirationYear__c;
		    		options.put(pm.Zuora__External_Id__c,label);
				} else {
					label += pm.Zuora__AchBankName__c + ' ' + pm.Zuora__AchAccountNumberMask__c;
		    		options.put(pm.Zuora__External_Id__c,label);
				}
			}
			return options;
		}
		set;
	}

	public CCBillingAccountWrapper() {
		defaultPayment = false;
		defaultCreditCard = false;
		applyAutoPayEdit = false;
		hasMulitipleBillingAccounts = false;
		hasBillingAccountAccess = false;
		paymentMethods = new Map<String, Zuora__PaymentMethod__c>();
		billToContact = new CCBillingContactWrapper();
		soldToContact = new CCBillingContactWrapper();
	}
}