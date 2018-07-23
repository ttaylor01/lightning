public with sharing class CCPreChatController {
	private static final String DEBUG_STR = 'CCPreChatController';

	public String briefDescriptionFieldMap { get; set; }
	public String submissionMethodFieldMap { get; set; }

	public PageReference setDependentOptions() {
    	final String FUNC_STR = '[' + DEBUG_STR + '.setDependentOptions] ';
		
		Map<String,List<String>> dMap = getDependentPicklistValuesByRecordType('Case', 'Case_Reason__c', 'Case_Brief_Description__c');
		briefDescriptionFieldMap = json.serialize(dMap);
		system.debug(FUNC_STR+'\n=========\nBrief Description Dependent Map: ' + briefDescriptionFieldMap);

		dMap = getDependentPicklistValuesByRecordType('Case', 'Case_Reason__c', 'Case_Submission_Method__c');
		submissionMethodFieldMap = json.serialize(dMap);
		system.debug(FUNC_STR+'\n=========\nSubmission Method Dependent Map: ' + submissionMethodFieldMap);
		return null;
	}

    private Map<String,List<String>> getDependentPicklistValuesByRecordType(String pObjName, String pControllingFieldName, String pDependentFieldName) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getDependentPicklistValuesByRecordType] ';
		System.debug(FUNC_STR+'\n=========\n sObject:ControllingField:DependentField ' + pObjName+':'+pControllingFieldName+':'+pDependentFieldName);
		
		CCRecordTypes__c rt = CCRecordTypes__c.getInstance('Community Support');
        Map<String,List<String>> objResults = new Map<String,List<String>>();
		
		// Get control values
		String q = '';
		q += 'SELECT Id, Name, Record_Type_Id__c, Record_Type_Name__c from ' + pControllingFieldName + ' ';
		q += 'WHERE Record_Type_Id__c = \'' +  rt.RecordTypeId__c + '\' ';
		system.debug(FUNC_STR+'\n=========\nControlling Field query: '+q);
		List<sObject> conFields = Database.query(q);
        System.debug(FUNC_STR+'\n=========\nControlling field values = ' + conFields );

		q = '';
		q += 'SELECT Id, Name, Record_Type_Id__c, Record_Type_Name__c, ' + pControllingFieldName + ' from ' + pDependentFieldName + ' ';
		q += 'WHERE Record_Type_Id__c = \'' +  rt.RecordTypeId__c + '\' ';
		system.debug(FUNC_STR+'\n=========\nDependent Field query: '+q);
		List<sObject> depFields = Database.query(q);
        System.debug(FUNC_STR+'\n=========\nDependent field values = ' + depFields );
        
        //set up the results with controlling field first
        Map<String,String> conIdMap = new Map<String,String>();
        for(sObject obj : conFields) {
        	String objType = obj.getSObjectType().getDescribe().getName();
        	String label;
        	String id;
			if(objType.equals('Case_Reason__c')) {
				Case_Reason__c rec = (Case_Reason__c)obj;
				label = rec.Name;
				id = rec.Id;
//			} else if(objType.equals('Case_Brief_Description__c')) {
//				Case_Brief_Description__c rec = (Case_Brief_Description__c)obj;
//				label = rec.Name;
//				id = rec.Id;
			}
        	objResults.put(label, new List<String>());
        	conIdMap.put(id,label);
        }

		// now add dependent values per controlling value
		for(sObject obj : depFields) {
        	String objType = obj.getSObjectType().getDescribe().getName();
        	String label;
        	String id;
			if(objType.equals('Case_Brief_Description__c')) {
				Case_Brief_Description__c rec = (Case_Brief_Description__c)obj;
				label = rec.Name;
				id = rec.Case_Reason__c;
//			} else if(objType.equals('Case_Brief_Description_Detail__c')) {
//				Case_Brief_Description_Detail__c rec = (Case_Brief_Description_Detail__c)obj;
//				label = rec.Name;
//				id = rec.Case_Brief_Description__c;
			} else if(objType.equals('Case_Submission_Method__c')) {
				Case_Submission_Method__c rec = (Case_Submission_Method__c)obj;
				label = rec.Name;
				id = rec.Case_Reason__c;
			}
			if(conIdMap.containsKey(id)) {
				objResults.get(conIdMap.get(id)).add(label);
			}
		}

        System.debug(FUNC_STR+'\n=========\n Filtered, Dependent Values = ' + objResults );

        return objResults;
    }

}