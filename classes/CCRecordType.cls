public with sharing class CCRecordType {

	/*
	 * Returns a Map of the RecordTypes
	 * available to the current user for a given SOBject type
	 * Usage:
	 * Map<Id,RecordType> availableRecordTypes = getAvailableRecordTypeNamesForSObject(Case.SObjectType);
	 */
	public static Map<Id,RecordType> getAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
		List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
		System.debug('[DEBUG-CCRecordType.getAvailableRecordTypeNamesForSObject()]\n=========\nRECORD TYPE INFOS: ' + infos);
		List<ID> ids = new List<ID>();
		// If there are 2 or more RecordTypes...
		if (infos.size() > 1) {
			for (RecordTypeInfo i : infos) {
				// Ignore the Master Record Type
				if (i.isAvailable() && !i.isMaster()) {
					ids.add(i.getRecordTypeId());
				}
			}
		} 
		// Otherwise there's just the Master record type,
		// so add it in, since it MUST always be available
		else {
			ids.add(infos[0].getRecordTypeId());
		}
		System.debug('[DEBUG-CCRecordType.getAvailableRecordTypeNamesForSObject()]\n=========\nRECORD TYPE IDS: ' + ids);
		Map<Id,RecordType> recordTypes = new Map<Id,RecordType>([SELECT Id, Name, Description FROM RecordType WHERE Id IN :ids ORDER BY Name]);
		System.debug('[DEBUG-CCRecordType.getAvailableRecordTypeNamesForSObject()]\n=========\nCASE RECORD TYPES: ' + recordTypes);
		return recordTypes;
	}

	/*
	 * Return Default Record type ID 
	 * available to the current user for a given SOBject type
	 * Usage:
	 * Id defaultRecordTypeId = CCRecordType.getDefaultRecordTypeForSObject(Case.SObjectType);
	 */
	public static String getDefaultRecordTypeForSObject(Schema.SObjectType objType) {
		String returnId = null;
		// Set default record type value
		Schema.DescribeSObjectResult d = objType.getDescribe();
		Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
		for(RecordType rt : getAvailableRecordTypeNamesForSObject(objType).values()) {
			Schema.RecordTypeInfo rtById = rtMapById.get(rt.Id);
			if(rtById.isDefaultRecordTypeMapping()) {
				returnId = rt.Id;
			}
		}
		return returnId;
	}
}