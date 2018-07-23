public with sharing class CCBillingManagementWrapper {

	@AuraEnabled public List<CCInvoiceWrapper> invoices { get; set; }
	@AuraEnabled public Map<String,Zuora__PaymentMethod__c> paymentMethods;
	@AuraEnabled public String paymentMethodId { get; set; }
    @AuraEnabled public Zuora__ZInvoice__c total {
        get {
            if(total == null) {
                total = new Zuora__ZInvoice__c(Zuora__Balance2__c = 0, Zuora__TotalAmount__c = 0, Zuora__TaxAmount__c = 0);
            }
            if(invoices == null) invoices = new List<CCInvoiceWrapper>();
            for(CCInvoiceWrapper i : invoices) {
                total.Zuora__Balance2__c += i.invoice.Zuora__Balance2__c;
                total.Zuora__TotalAmount__c += i.invoice.Zuora__TotalAmount__c;
                total.Zuora__TaxAmount__c += i.invoice.Zuora__TaxAmount__c==null ? 0 : i.invoice.Zuora__TaxAmount__c;
            }
            return total;
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

	public CCBillingManagementWrapper() {
		paymentMethods = new Map<String, Zuora__PaymentMethod__c>();
		paymentMethodId = '';
	}
}