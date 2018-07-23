public with sharing class CCSelect2Component {

	@AuraEnabled
	public static List <String> getSelectOptions(sObject objObject, string fld) {
		System.debug('[DEBUG-CCSelect2Component.getselectOptions()]\n=========\nsObject: ' + objObject);
		System.debug('[DEBUG-CCSelect2Component.getselectOptions()]\n=========\nfield: ' + fld);
		List <String> allOpts = new list <String>();
		// Get the object type of the SObject.
		Schema.sObjectType objType = objObject.getSObjectType();
 
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

		// Get a map of fields for the SObject
		Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

		// Get the list of picklist values for this field.
		List <Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();

		// Add these values to the selectoption list.
		for(Schema.PicklistEntry a: values) {
			allOpts.add(a.getValue());
		}
		System.debug('[DEBUG-CCSelect2Component.getselectOptions()]\n=========\nAll Options: ' + allOpts);
		allOpts.sort();
		return allOpts;
	}
}