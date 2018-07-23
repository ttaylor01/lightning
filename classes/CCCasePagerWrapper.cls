public class CCCasePagerWrapper {
    
	@AuraEnabled public Integer pageSize {get;set;}
	@AuraEnabled public Integer page {get;set;}
	@AuraEnabled public Integer total {get;set;}
	@AuraEnabled public List<Case> cases {get;set;}
	@AuraEnabled public List<Case> allCases {get;set;}

}