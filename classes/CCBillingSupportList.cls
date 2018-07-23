public with sharing class CCBillingSupportList extends CCCaseListAbstract {
	private static final String DEBUG_STR = 'CCBillingSupportList';

    public override void process(CCApexBridgeRequest request, CCApexBridgeResponse response) {
    	availableCaseTypes = getCaseTypes();
    	String method = (String) request.method;
        if (method == 'getCases') {
            response.output = CCApexBridgeAbstract.encodeData(getCases(request));
        } else {
            throw new CCException('Unexpected "method" received');
        }
    }

	/*
	 * Now that community profiles can act on different types of cases (Case Record Types),
	 * I can't just obtain the case record types that is configured for that profile.
	 * I need to just get the specific Case record types this functionality (ie Customer Support or Payer Support)
	 */
	public override Map<Id, CCRecordTypes__c> getCaseTypes() {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getCaseTypes] ';
		// Obtain profile driven available Case Record Types
		// Convert to custom CaseType as workaround for inability to display RecordType Description.
		Map<Id,RecordType> availableRecordTypes = CCRecordType.getAvailableRecordTypeNamesForSObject(Case.SObjectType);
		System.debug(FUNC_STR+'\n=========\navailableRecordTypes: ' + availableRecordTypes);
		// Get Customer Support Record Types configured for this profile
		String recordTypeIds = CC_App_Settings__c.getInstance(UserInfo.getProfileId()).Billing_Support_Case_Types__c;
		List<String> typeList = new List<String>();
		if(String.isNotBlank(recordTypeIds)) {
			for(String rtId : recordTypeIds.split(',',0)) {
				typeList.add(rtId);
			}
		}
		System.debug(FUNC_STR+'\n=========\ntypeList: ' + typeList);
		Map<Id,CCRecordTypes__c> availableCaseTypes = new Map<Id,CCRecordTypes__c>();
		// populate collection of the intersection of the Customer Support record types and the record types for this profile
		for(String rtId : typeList) {
			if(availableRecordTypes.containsKey(rtId)) {
				RecordType rt = availableRecordTypes.get(rtId);
				CCRecordTypes__c crt = CCRecordTypes__c.getInstance(rt.name);
				availableCaseTypes.put(crt.RecordTypeId__c,crt);
			}
		}

		return availableCaseTypes;
	}
}