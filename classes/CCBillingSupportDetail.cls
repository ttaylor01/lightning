public with sharing class CCBillingSupportDetail extends CCCaseDetailAbstract {
	private static final String DEBUG_STR = 'CCBillingSupportDetail';

    public override void process(CCApexBridgeRequest request, CCApexBridgeResponse response) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.process] ';
    	this.recordTypeName = 'Finance';
    	String method = (String) request.method;
        if (method == 'getCase') {
			String recordId = String.valueOf(request.getInputValue('recordId'));
			String billingAccountId = String.valueOf(request.getInputValue('billingAccountId'));
			if(String.isBlank(billingAccountId)) {
                response.output = CCApexBridgeAbstract.encodeData(getCase(recordId));
			} else {
                response.output = CCApexBridgeAbstract.encodeData(getCaseForBillingAccount(billingAccountId));
			}
        } else if(method == 'saveCase') {
			List<Case> cases = request.records;
			System.debug(FUNC_STR+'\n=========\nCases: ' + cases);
			response.output = CCApexBridgeAbstract.encodeData(saveCase(cases[0]));
        } else if(method == 'saveCaseStatus') {
			List<Case> cases = request.records;
			String status = String.valueOf(request.getInputValue('status'));
			String body = String.valueOf(request.getInputValue('body'));
			response.output = CCApexBridgeAbstract.encodeData(saveCaseStatus(cases[0],status,body));
//			response.output = CCApexBridgeAbstract.encodeData(CCSecuredDB.performDML(CCSecuredDB.Operation.Updatting, cases));
        } else {
            throw new CCException('Unexpected "method" received');
        }
    }

	public Case getCaseForBillingAccount(String billingAccountId) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getCase] ';
		system.debug(FUNC_STR+'\n=========\nbillingAccountId: ' + billingAccountId);
		system.debug(FUNC_STR+'\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
		
		Case cs = new Case();
		User user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
		Contact contact = [Select Id, Name from Contact Where Id = :user.ContactId];
		Account account = [Select Name, Entity_Gen_Key__c, RCM_Office_ID__c from Account Where Id = :user.AccountId];
		Zuora__CustomerAccount__c billingAccount = [Select Id, Name, Zuora__Account__c FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = :billingAccountId];
		cs.CID_Identifier__c = account.RCM_Office_ID__c;
		cs.Contact = contact;
		cs.Account = account;
		cs.AccountId = account.Id;
		cs.Billing_Account__c = billingAccount.Id;
		cs.Billing_Account_Name__c = billingAccount.Name;
		if(String.isNotBlank(this.recordTypeName)) cs.RecordTypeId = CCRecordTypes__c.getInstance(recordTypeName).RecordTypeId__c;
		
		return cs;
	}
	
}