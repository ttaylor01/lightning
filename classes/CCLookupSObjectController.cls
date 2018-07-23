public with sharing class CCLookupSObjectController {

    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    @AuraEnabled
    public static SearchResult[] lookup(String searchString, String sObjectAPIName) {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
 
        List<SearchResult> results = new List<SearchResult>();
 
 /*
        // Build our SOSL query
        String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name) Limit 50'; 
        // Execute the Query
        List<List<SObject>> searchList = search.query(searchQuery);
        // Create a list of matches to return
        for (SObject so : searchList[0])
        {
            results.add(new SearchResult((String)so.get('Name'), so.Id));
        }
*/
		// Build our SOQL query
		String searchQuery = 'SELECT Id, Name FROM ' + sanitizedSObjectAPIName + ' WHERE Name LIKE ' + '\'%' + sanitizedSearchString + '%\'' + ' Limit 50';
		List<SObject> searchList = DataBase.query(searchQuery);
		// Create a list of matches to return
		for (SObject so : searchList) {
			results.add(new SearchResult((String)so.get('Name'), so.Id));
		}
         
        return results;
    }

    @AuraEnabled
    public static SearchResult[] lookupWithClause(String searchString, String sObjectAPIName, String whereClause) {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
 
        List<SearchResult> results = new List<SearchResult>();
 
		// Build our SOQL query
		String searchQuery = 'SELECT Id, Name ' +
			'FROM ' + sanitizedSObjectAPIName + ' ' +
			'WHERE Name LIKE ' + '\'%' + sanitizedSearchString + '%\' ' + 
			'AND ' + whereClause + ' ' +
			'Limit 50';
		List<SObject> searchList = DataBase.query(searchQuery);
        system.debug('\n[DEBUG-CCLookupSObjectController.lookupWithClause()]\n=========\n query: ' + searchQuery);
        system.debug('\n[DEBUG-CCLookupSObjectController.lookupWithClause()]\n=========\n searchList: ' + searchList);
		// Create a list of matches to return
		for (SObject so : searchList) {
			results.add(new SearchResult((String)so.get('Name'), so.Id));
		}
         
        return results;
    }
     
    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class SearchResult
    {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
         
        public SearchResult(String sObjectLabel, Id sObjectId)
        {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}