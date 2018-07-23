@isTest(SeeAllData=false)
private class CCKnowledgeArticleDataTest {

    static testMethod void testGetKavList() {
        Test.startTest();

		// Adding SOSL Queries to Unit Tests:
		// To ensure SOSL query returns articles, you MUST set the ids that are available.
		// So read the articles setup for this run and pass to the Test.setFixedSearchResults() method.
		String q = 'SELECT Id, KnowledgeArticleId ';
		q += ' FROM KnowledgeArticleVersion where PublishStatus = \'online\' and Language = \'en_US\'';
		List<KnowledgeArticleVersion> aList = (List<KnowledgeArticleVersion>)Database.query(q);
		List<Id> ids = new List<Id>();
		for(KnowledgeArticleVersion kav : aList) {
			ids.add(kav.id);
		}
		Test.setFixedSearchResults(ids);
		List<CCKnowledgeArticleData> kavs = CCKnowledgeArticleData.getKavs('', '5');
		kavs = CCKnowledgeArticleData.getKavs('Test Article', '5');

        Test.stopTest();
    }

    static testMethod void testGetKavArticle() {
        Test.startTest();

		// Adding SOSL Queries to Unit Tests:
		// To ensure SOSL query returns articles, you MUST set the ids that are available.
		// So read the articles setup for this run and pass to the Test.setFixedSearchResults() method.
		String q = 'SELECT Id, KnowledgeArticleId, ArticleType ';
		q += ' FROM KnowledgeArticleVersion where PublishStatus = \'online\' and Language = \'en_US\'';
		List<KnowledgeArticleVersion> aList = (List<KnowledgeArticleVersion>)Database.query(q);
		for(KnowledgeArticleVersion kav : aList) {
			CCKnowledgeArticleData.getKnowledgeArticle(kav.ArticleType, kav.KnowledgeArticleId);
		}

        Test.stopTest();
    }

    @testSetup static void setup() {
		CCTestDataFactory.createKnowledgeArticleRecords();
    }    

}