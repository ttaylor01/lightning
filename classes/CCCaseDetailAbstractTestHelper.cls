public with sharing class CCCaseDetailAbstractTestHelper  extends CCCaseDetailAbstract {
	private static final String DEBUG_STR = 'CCCaseDetailAbstractTestHelper';

    public override void process(CCApexBridgeRequest request, CCApexBridgeResponse response) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.process] ';
    	this.recordTypeName = 'Community Support';
    	String method = (String) request.method;
        if (method == 'getCase') {
			String recordId = String.valueOf(request.getInputValue('recordId'));
            response.output = CCApexBridgeAbstract.encodeData(getCase(recordId));
        } else if(method == 'saveCase') {
			List<Case> cases = request.records;
			System.debug(FUNC_STR+'\n=========\nCases: ' + cases);
			response.output = CCApexBridgeAbstract.encodeData(saveCase(cases[0]));
        } else if(method == 'saveCaseStatus') {
			List<Case> cases = request.records;
			String status = String.valueOf(request.getInputValue('status'));
			String body = String.valueOf(request.getInputValue('body'));
			response.output = CCApexBridgeAbstract.encodeData(saveCaseStatus(cases[0],status,body));
        }
    }
}