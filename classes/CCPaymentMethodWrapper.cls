public with sharing class CCPaymentMethodWrapper {

	@AuraEnabled public Map<String,String> achTypeOptions { get; set; }
	@AuraEnabled public Map<String,String> ccTypeOptions { get; set; }
	@AuraEnabled public Map<String,String> monthOptions { get; set; }
	@AuraEnabled public Map<String,String> yearOptions { get; set; }

	@AuraEnabled public List<CCPaymentMethodObject> creditCards { get; set; }
	@AuraEnabled public List<CCPaymentMethodObject> bankAccounts { get; set; }
	@AuraEnabled public CCPaymentMethodObject inputCreditCard { get; set; }
	@AuraEnabled public CCPaymentMethodObject inputBankAccount { get; set; }

	public CCPaymentMethodWrapper() {
		// ACH defaults
    	achTypeOptions = new Map<String,String>();
    	Schema.DescribeFieldResult typeFieldDescription = Zuora__PaymentMethod__c.Zuora__AchAccountType__c.getDescribe();
//		achTypeOptions.put('','-Select One-');
    	for(Schema.Picklistentry picklistEntry : typeFieldDescription.getPicklistValues()) {
    		achTypeOptions.put(picklistEntry.getValue(),picklistEntry.getLabel());
    	}

		// CreditCard defaults
    	ccTypeOptions = new Map<String,String>();
    	typeFieldDescription = Zuora__PaymentMethod__c.Zuora__CreditCardType__c.getDescribe();
    	for(Schema.Picklistentry picklistEntry : typeFieldDescription.getPicklistValues()) {
			String label = '<img src="'+CCZUtility.getResourceURL('CC' + picklistEntry.getLabel() + 'Logo')+'" align="middle">';
    		ccTypeOptions.put(picklistEntry.getValue(),label);
    	}
    	monthOptions = new Map<String,String>();
//    	monthOptions.put('','-Select One-');
    	Schema.DescribeFieldResult monthFieldDescription = Zuora__PaymentMethod__c.Zuora__CreditCardExpirationMonth__c.getDescribe();
    	for(Schema.Picklistentry picklistEntry : monthFieldDescription.getPicklistValues()) {
    		monthOptions.put(picklistEntry.getValue(),picklistEntry.getLabel());
    	}
    	yearOptions = new Map<String,String>();
//    	yearOptions.put('','-Select One-');
    	Integer year = Date.today().year();
    	for(Integer i=year; i<(year+20); i++) {
    		yearOptions.put(String.valueOf(i),String.valueOf(i));
    	}

		inputCreditCard = new CCPaymentMethodObject('CreditCard');
		inputBankAccount = new CCPaymentMethodObject('ACH');
	}

}