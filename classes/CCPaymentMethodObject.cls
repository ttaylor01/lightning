public with sharing class CCPaymentMethodObject {
    
	@AuraEnabled public String zuoraId { get; set; }
	@AuraEnabled public String paymentMethodType { get; set; }
	@AuraEnabled public Boolean defaultMethod { get; set; }
	
	@AuraEnabled public String achAbaCode { get; set; }
	@AuraEnabled public String achAccountName { get; set; }
	@AuraEnabled public String achAccountNumber { get; set; }
	@AuraEnabled public String achAccountType { get; set; }
	@AuraEnabled public String achBankName { get; set; }
	
	@AuraEnabled public String creditCardSecurityCode { get; set; }
	@AuraEnabled public String creditCardType { get; set; }
	@AuraEnabled public String creditCardNumber { get; set; }
	@AuraEnabled public String creditCardHolderName { get; set; }
	@AuraEnabled public String creditCardExpirationMonth { get; set; }
	@AuraEnabled public String creditCardExpirationYear { get; set; }
	@AuraEnabled public String creditCardAddress1 { get; set; }
	@AuraEnabled public String creditCardAddress2 { get; set; }
	@AuraEnabled public String creditCardCity { get; set; }
	@AuraEnabled public String creditCardCountry { get; set; }
	@AuraEnabled public String creditCardState { get; set; }
	@AuraEnabled public String creditCardPostalCode { get; set; }
	@AuraEnabled public String expires {
		get {
			return creditCardExpirationMonth + '/' + creditCardExpirationYear;
		}
		set;
	}
	@AuraEnabled public String image {
		get {
			String image = CCZUtility.getResourceURL('CC' + creditCardType + 'Logo');
			return image;
		}
		set;
	}

	public CCPaymentMethodObject() {
//		paymentMethodType = 'CreditCard';
    	// Default country to US
    	creditCardCountry = 'US';
//    	creditCardType = '';
    	defaultMethod = false;
	}
	public CCPaymentMethodObject(String paymentMethodType) {
		paymentMethodType = paymentMethodType;
    	// Default country to US
    	creditCardCountry = 'US';
//    	creditCardType = '';
    	defaultMethod = false;
	}
}