public with sharing class CCInvoiceWrapper implements Comparable {
    
	@AuraEnabled public Zuora__ZInvoice__c invoice { get; set; }
	@AuraEnabled public Boolean selected { get; set; }
//	@AuraEnabled public decimal internalPaymentAmount;
	@AuraEnabled public decimal inputPaymentAmount { get; set; }
/*
		get;
		set {
			this.inputPaymentAmount = value;
			if(value != null) {
				// set Scale to match currency
				this.internalPaymentAmount = value.setScale(2, System.RoundingMode.HALF_UP);
			} else {
				this.internalPaymentAmount = value;
			}
		}
	}
*/
	@AuraEnabled public Boolean isPayable {
		get {
			if(!(invoice.Zuora__Status__c != 'Posted') && (invoice.Zuora__Balance2__c != 0)) {
				return true;
			} else {
				return false;
			}
		}
		set;
	}
	@AuraEnabled public Boolean isPastDue {
		get {
			if((invoice.Zuora__DueDate__c <= Date.today()) && (invoice.Zuora__Balance2__c != 0)) {
				return true;
			} else {
				return false;
			}
		}
		set;
	}

	public CCInvoiceWrapper() {
		invoice = new Zuora__ZInvoice__c();
		this.inputPaymentAmount = 0.0;
		selected = false;
	}

	public CCInvoiceWrapper(Zuora__ZInvoice__c inv) {
		invoice = inv;
		this.inputPaymentAmount = invoice.Zuora__Balance2__c;
		selected = false;
	}
        
	public Integer compareTo(Object compareTo) {
		// The return value of 0 indicates that both are equal
		Integer returnValue = 0;
		try {
			// cast object to Zuora__ZInvoice__c
			CCInvoiceWrapper compareTozInv = (CCInvoiceWrapper)compareTo;
			if(invoice.Zuora__InvoiceDate__c < compareTozInv.invoice.Zuora__InvoiceDate__c) {
				returnValue = 1;
			} else if(invoice.Zuora__InvoiceDate__c > compareTozInv.invoice.Zuora__InvoiceDate__c) {
				returnValue = -1;
			}
		} catch (Exception ex) {
			system.debug('\n[DEBUG-CCInvoiceWrapper.compareTo()]\n=========\n Unable to Sort List:  '+ex.getMessage());
		}
		return returnValue;
	}
}