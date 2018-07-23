public with sharing class CCBillingContactWrapper {

	@AuraEnabled public String id { get; set; }
	@AuraEnabled public String address1 { get; set; }
	@AuraEnabled public String address2 { get; set; }
	@AuraEnabled public String city { get; set; }
	@AuraEnabled public String state { get; set; }
	@AuraEnabled public String postalCode { get; set; }
	@AuraEnabled public String firstName { get; set; }
	@AuraEnabled public String lastName { get; set; }
	@AuraEnabled public String email { get; set; }
	@AuraEnabled public String phone { get; set; }

	public CCBillingContactWrapper() {
		state = '';
	}
	    
}