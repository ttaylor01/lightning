public with sharing class CCPostChatController {
	private static final String DEBUG_STR = 'CCPostChatController';

	public String chatSatisfactionScore {get;set;}
    public String caseId {get;set;}
    public String attachedRecords {get;set;}
    public String postMsg {get;set;}
    public Case pcCase {get;set;}

	public PageReference initVariables() {
    	final String FUNC_STR = '[' + DEBUG_STR + '.initVariables] ';
        attachedRecords = ApexPages.currentPage().getParameters().get('attachedRecords');
		system.debug(FUNC_STR+'\n=========\nattachedRecords: '+attachedRecords);
        Map<String, Object> records = (Map<String, Object>) JSON.deserializeUntyped(attachedRecords);
        caseId = (String) records.get('CaseId');
        pcCase = [Select Id, Chat_Satisfaction__c From Case Where Id = :caseId];
		system.debug(FUNC_STR+'\n=========\nCase Id: '+caseId);

       	postMsg = 'Thank you for using our live chat service. If you have any more issues, please don’t hesitate to let us know. Have a great day!';
        String disconnectedBy = ApexPages.currentPage().getParameters().get('disconnectedBy');
		system.debug(FUNC_STR+'\n=========\ndisconnectedBy: '+disconnectedBy);
        if(disconnectedBy.equals('agent')) {
        	postMsg = 'Thank you for contacting Availity Customer Support';
        } else if(disconnectedBy.equals('client')) {
        	postMsg = 'Thank you for contacting Availity Customer Support';
        } else if(disconnectedBy.equals('clientIdleTimeout')) {
       	    postMsg = 'We’re sorry, your chat session has timed out. If you need additional assistance, please contact Availity Customer Support';
        } else if(disconnectedBy.equals('agentsUnavailable')) {
        	postMsg = 'We’re sorry, there are no agents available to chat at this time. Please open a ticket or call Availity Customer Support for further help';
        } else if(disconnectedBy.equals('error')) {
        	postMsg = 'We’re sorry, an error has occurred and the chat session has ended unexpectedly. Please contact Availity Customer Support for further help';
        }

		return null;
	}
	
	public PageReference save() {
    	final String FUNC_STR = '[' + DEBUG_STR + '.save] ';
		chatSatisfactionScore = ApexPages.currentPage().getParameters().get('chatSatisfactionScore');
		system.debug(FUNC_STR+'\n=========\nCase Satisfaction: '+chatSatisfactionScore);
		if(chatSatisfactionScore != null) {
			pcCase = new Case(Id=caseId,Chat_Satisfaction__c = Integer.valueOf(chatSatisfactionScore));
			update pcCase;
		}
		return null;
	}
	
	public String[] getScores() {
		return new String[]{'1','2','3','4','5','6','7','8','9','10'};
	}

    public PageReference getSelected() {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getSelected] ';
		system.debug(FUNC_STR+'\n=========\nSTART');
        chatSatisfactionScore = ApexPages.currentPage().getParameters().get('selectedScore');
		system.debug(FUNC_STR+'\n=========\nSelected Score: '+chatSatisfactionScore);
        return null;
    }

}