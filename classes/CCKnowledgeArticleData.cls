/*
 * This wrapper class mimics the KnowledgeArticleVersion and its various "types"
 * The lightning framework allows the Apex controller to return a instance of a custom Apex class,
 * which is then automatically converted into a JavaScript object for use client-side.
 * Note that the methods and attributes for use client-side have the AuraEnabled annotation
*/
public with sharing class CCKnowledgeArticleData {

	@AuraEnabled
	public String id                  { get; set; }
	@AuraEnabled
	public String knowledgeArticleId  { get; set; }
	@AuraEnabled
	public String title               { get; set; }
	@AuraEnabled
	public String summary             { get; set; }
	@AuraEnabled
	public String urlName             { get; set; }
	@AuraEnabled
	public String articleNumber       { get; set; }
	@AuraEnabled
	public DateTime lastPublishedDate { get; set; }
	@AuraEnabled
	public String articleType         { get; set; }
	@AuraEnabled
	public String publishStatus       { get; set; }
	@AuraEnabled
	public Date dateAdded             { get; set; }
	@AuraEnabled
	public Date dateResolved          { get; set; }
	@AuraEnabled
	public String issue               { get; set; }
	@AuraEnabled
	public String payerId             { get; set; }
	@AuraEnabled
	public String payer               { get; set; }
	@AuraEnabled
	public String region              { get; set; }
	@AuraEnabled
	public String resolution          { get; set; }
	@AuraEnabled
	public String status              { get; set; }
	@AuraEnabled
	public String description         { get; set; }
	@AuraEnabled
	public String articleTypeName     { get; set; }
	@AuraEnabled
	public String articleTypeLabel    { get; set; }
	@AuraEnabled
	public KnowledgeArticleVersion theAV { get; set; }

    public CCKnowledgeArticleData() { }

    public CCKnowledgeArticleData(KnowledgeArticleVersion kav) {
      init(kav);
    }

    public void init(KnowledgeArticleVersion kav) {
		this.theAV = kav;

		id = this.theAV.Id;
		KnowledgeArticleId = this.theAV.KnowledgeArticleId;
		title = this.theAV.Title;
		summary = this.theAV.Summary;
		urlName = this.theAV.UrlName;
		articleType = this.theAV.ArticleType;
		articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();
		articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();
		lastPublishedDate = this.theAV.LastPublishedDate;
		articleNumber = this.theAV.ArticleNumber;
		publishStatus = this.theAV.PublishStatus;
    }
    
    public void init(Known_Issue__kav kav) {
		id = kav.Id;
		KnowledgeArticleId = kav.KnowledgeArticleId;
		title = kav.Title;
		summary = kav.Summary;
		urlName = kav.UrlName;
		articleType = kav.ArticleType;
		articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();
		articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();
		lastPublishedDate = kav.LastPublishedDate;
		articleNumber = kav.ArticleNumber;
		publishStatus = kav.PublishStatus;

		dateAdded = kav.Date_Added__c;
		dateResolved = kav.Date_Resolved__c;
		payerId = kav.Payer_Id__c;
		payer = kav.Payer__c;
		region = kav.Region__c;
		issue = kav.Issue__c;
		resolution = kav.Resolution__c;
		status = kav.Status__c;
    }
    
    public void init(FAQ__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(Agreements__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(EDI_Guidelines__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(New_Administrator__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(New_User__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(News__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(Newsletter__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(Payer_Alert__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(Registration_and_Change_Form__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(Release_Communication__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    public void init(Tips_and_Guidelines__kav kav) {
		id = kav.Id;KnowledgeArticleId = kav.KnowledgeArticleId;title = kav.Title;summary = kav.Summary;urlName = kav.UrlName;articleType = kav.ArticleType;articleTypeName = getKAVDescribeById(KnowledgeArticleId).getLocalName();articleTypeLabel = getKAVDescribeById(KnowledgeArticleId).getLabel();lastPublishedDate = kav.LastPublishedDate;articleNumber = kav.ArticleNumber;publishStatus = kav.PublishStatus;
		description = kav.Description__c;
    }
    
	@AuraEnabled
	public static List<CCKnowledgeArticleData> getKavs(String searchStr, String numArticles) {
		System.debug('[DEBUG-CCKnowledgeArticleData.getKavs()]\n=========\nsearchStr: ' + searchStr);
        if(String.isBlank(numArticles)) numArticles = '6';

		String sortField = 'LastPublishedDate';
		String sortDirection = 'desc';
		List<KnowledgeArticleVersion> listofarticles = new List<KnowledgeArticleVersion>();
		ApexPages.StandardSetController setCon;
        String whereClause = '';
        whereClause += 'WHERE PublishStatus = :DEFAULT_PUBLISH_STATUS and Language = :DEFAULT_LANGUAGE ';
        String q = '';
        if(String.isBlank(searchStr)) {
            q += 'SELECT ' + join(kavFields, ',') + ' ';
            q += 'FROM KnowledgeArticleVersion ';
            q += whereClause;
            q += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection) + ' LIMIT ' + numArticles + ' ';
			System.debug('[DEBUG-CCKnowledgeArticleData.getKavs()]\n=========\nSOQL: ' + q);
			setCon = new ApexPages.StandardSetController(Database.getQueryLocator(q));
			listofarticles = setCon.getRecords();
			System.debug('[DEBUG-CCKnowledgeArticleData.getKavs()]\n=========\nKnowledgeArticleVersions: ' + listofarticles);
        } else {
            String escapedQ = String.escapeSingleQuotes(searchStr);
            String orQuery = buildOrQuery(escapedQ);
            
            q += 'FIND \'' + orQuery + '\' IN ALL FIELDS RETURNING ';
            q += 'KnowledgeArticleVersion(' + join(kavFields, ',') + ' ';
            q += whereClause;
            q += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection) + ' LIMIT ' + numArticles + ' ';
            q += ') ';
            System.debug('[DEBUG-CCKnowledgeArticleData.getKavs()]\n=========\nSOSL : ' + q);
            List<List<sObject>> searchList = Search.query(q);
			listofarticles = (List<KnowledgeArticleVersion>)searchList[0];
			System.debug('[DEBUG-CCKnowledgeArticleData.getKavs()]\n=========\nKnowledgeArticleVersions: ' + listofarticles);
        }

		List<CCKnowledgeArticleData> kadList = new List<CCKnowledgeArticleData>();
		for(KnowledgeArticleVersion kav : listofarticles) {
			kadList.add(new CCKnowledgeArticleData(kav));
		}
		return kadList;
	}

	@AuraEnabled
	public static CCKnowledgeArticleData getKnowledgeArticle(String articleType, String knowledgeArticleId) {
		System.debug('[DEBUG-CCKnowledgeArticleData.getKnowledgeArticle()]\n=========\narticleType: ' + articleType);
		System.debug('[DEBUG-CCKnowledgeArticleData.getKnowledgeArticle()]\n=========\nknowledgeArticleId: ' + knowledgeArticleId);

		String fieldList = 'Known_Issue__kav'.equals(articleType) ? join(knownIssueFields, ',') : join(kaFields, ',');
		String q = '';
		q += 'SELECT ' + fieldList + ' from ' + articleType + ' ';
		q += 'WHERE PublishStatus = \'' + DEFAULT_PUBLISH_STATUS + '\' and Language = \'' + DEFAULT_LANGUAGE + '\' and KnowledgeArticleId = \'' +  knowledgeArticleId + '\' ';
		system.debug('[DEBUG-CCKnowledgeArticleData.getKnowledgeArticle()]\n=========\nquery: '+q);
		sObject ka = Database.query(q);
		System.debug('[DEBUG-CCKnowledgeArticleData.getKnowledgeArticle()]\n=========\nsObject: ' + ka);
		System.debug('[DEBUG-CCKnowledgeArticleData.getKnowledgeArticle()]\n=========\nsObjectType: '+ka.getSObjectType().getDescribe().getName());

		CCKnowledgeArticleData kad = new CCKnowledgeArticleData();
		if(ka.getSObjectType().getDescribe().getName().equals('Known_Issue__kav')) {
			kad.init((Known_Issue__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('FAQ__kav')) {
			kad.init((FAQ__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('Agreements__kav')) {
			kad.init((Agreements__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('EDI_Guidelines__kav')) {
			kad.init((EDI_Guidelines__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('News__kav')) {
			kad.init((News__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('Newsletter__kav')) {
			kad.init((Newsletter__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('Payer_Alert__kav')) {
			kad.init((Payer_Alert__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('Release_Communication__kav')) {
			kad.init((Release_Communication__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('Tips_and_Guidelines__kav')) {
			kad.init((Tips_and_Guidelines__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('New_Administrator__kav')) {
			kad.init((New_Administrator__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('New_User__kav')) {
			kad.init((New_User__kav)ka);
		} else if(ka.getSObjectType().getDescribe().getName().equals('Registration_and_Change_Form__kav')) {
			kad.init((Registration_and_Change_Form__kav)ka);
		}
		System.debug('[DEBUG-CCKnowledgeArticleData.getKnowledgeArticle()]\n=========\nCCKnowledgeArticleData: ' + kad);
		return kad;
	}

	/***************************************
	 ** UTILITY methods
	 ***************************************/
	private final static String KAV_EXTENSION = '__kav';
	private final static String DEFAULT_PUBLISH_STATUS = 'online';
	private final static String DEFAULT_LANGUAGE = 'en_US';
	/* 
	 * KnowledgeArticleVersion fields used in the sosl and soql queries to ensure that all queries get the right fields
	 */
	public static Set<String> kavFields {
		get {
			if (kavFields == null) {
				kavFields = new Set<String>{
				'Id'
				,'Title'
				,'Summary'
				,'UrlName'
				,'ArticleNumber'
				,'LastModifiedDate'
				,'FirstPublishedDate'
				,'LastPublishedDate'
				,'Language'
				,'PublishStatus'
				,'KnowledgeArticleId'
				,'ArticleType'
				};
			}
			return kavFields;
		}
		private set;
	}
	public static Set<String> knownIssueFields {
		get {
			if (knownIssueFields == null) {
				knownIssueFields = new Set<String>{
				'Id',
				'Title',
				'Summary',
				'UrlName',
				'ArticleNumber',
				'KnowledgeArticleId',
				'LastPublishedDate',
				'ArticleType',
				'PublishStatus',
				'Date_Added__c',
				'Date_Resolved__c',
				'Issue__c',
				'Payer_Id__c',
				'Payer__c',
				'Region__c',
				'Resolution__c',
				'Status__c'
				};
			}
			return knownIssueFields;
		}
		private set;
	}
	public static Set<String> kaFields {
		get {
			if (kaFields == null) {
				kaFields = new Set<String>{
				'Id',
				'Title',
				'Summary',
				'UrlName',
				'ArticleNumber',
				'KnowledgeArticleId',
				'LastPublishedDate',
				'ArticleType',
				'PublishStatus',
				'Description__c'
				};
			}
			return kaFields;
		}
		private set;
	}

	/*
	 * Helper class to retrieve the Schema.DescribeSObjectResult given a KnowlegeArticleId
	 * provides easy access to obtain the sObject name, label, accessibility methods.
	 */
	public static Schema.DescribeSObjectResult getKAVDescribeById(String i) {
		if (String.isBlank(i) || i.length() < 15) return null;
		return kavObjPrefixMap.get(i.substring(0,3).toLowerCase());
	}
	/*
	 * Helper class to retrieve the field map for a given sObject's KnowlegeArticleId
	 * provides easy access to obtain the fields properties.
	 * for example:
			Map<String,Schema.SObjectField> fieldMap = getKAVFieldMapById(kav.KnowledgeArticleId);
			for(Schema.SobjectField f : fieldMap.values()) {
				Schema.DescribeFieldResult fr = f.getDescribe();
				// do something with the schema field result
			}
	public static Map<String,Schema.SObjectField> getKAVFieldMapById(String i) {
		if (String.isBlank(i) || i.length() < 15) return null;
		Schema.DescribeSObjectResult sor = kavObjPrefixMap.get(i.substring(0,3).toLowerCase());
		return sor.fields.getMap();
	}
	 */

	/*
	 * Obtain Set of KnowledgeArticleVersion Article Types
	 */
	public static Set<String> kavNames {
		set;
		get {
			if (kavNames == null) {
				kavNames = new Set<String>();
				Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		
				for (String s : gd.keySet()) {
					if (s.contains(KAV_EXTENSION)) {
						kavNames.add(s);
					}
				}
			}
			return kavNames;
		}
	}
	/*
	 * constructs a Map of sObject results using KnowledgeArticleId as key
	 */
	public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap {
		get {
			if (kavObjPrefixMap == null) {
				kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
				Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
				Schema.DescribeSObjectResult sor;
				for (String s : kavNames) {
					sor = gd.get(s).getDescribe();
					kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
				}
			}
			return kavObjPrefixMap;
		}
	}
    
    /*
     * joins elements in the passed list of strings by the passed string c
     * c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
     */
    public static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty()) return null;

        String sep = (String.isBlank(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];

        size = strings.size();
        for (i = 1; i < size; i++) {
            s += (sep + strings[i]);
        }
        return s;
    }
    /*
     * version of join method that takes a set of strings
     */
    public static String join(Set<String> strings, String c) {
        return join(new List<String>(strings), c);
    }
    /* 
     * Takes entered search string,
     * breaks into separate words separated by space,
     * adds wildcard * character
     * concatenates each with OR operator.
     * Ex:  foo bar --> foo* OR bar*
     */
    public static String buildOrQuery(String keywords) {
        system.debug('[DEBUG-CCKnowledgeArticleData.buildOrQuery()] keywords: '+keywords);
        if (String.isBlank(keywords)) return null;

        String temp;
        //keywords = keywords.replaceAll('"' ,'\\"');
        List<String> tokens = String.escapeSingleQuotes(keywords).replaceAll('[!.,?<>;:{}@#$%^&*()]', '').split(' ');
        List<String> newTokens = new List<String>();
        
        for (String s : tokens) {
            temp = s.trim();
            newTokens.add(temp + '*');
        }
        tokens = newTokens;

        if (tokens.isEmpty()) {
            system.debug('[DEBUG-CCKnowledgeArticleData.buildOrQuery()]  returned EMPTY KEYWORDS ');
            return null;
        } else if (tokens.size() == 1) {
            system.debug('[DEBUG-CCKnowledgeArticleData.buildOrQuery()]  returned KEYWORD TOKENS \n===='+tokens[0]+'=====\n');
            return tokens[0];
        } else {
            String returnStr = join(tokens, ' OR ');
            system.debug('[DEBUG-CCKnowledgeArticleData.buildOrQuery()]  returned KEYWORD TOKENS \n===='+returnStr+'=====\n');
            return returnStr;
        }
    }
}