public with sharing class CCHeaderController {
 
	public String userName {get; set;}
	public String contactName {get; set;}
	public String accountName {get; set;}
	public String customerId {get; set;}
	public String customerIdLabel {get; set;}
	public Boolean showAddress {get; set;}
 
	public CCHeaderController() {
		showAddress = false;
		userName = UserInfo.getName();
		Profile profile = [Select Id, Name from Profile Where Id = :UserInfo.getProfileId()];
		User user = [Select Id, AccountId, ContactId from User Where Id = :UserInfo.getUserId()];
		Contact contact = [Select Name from Contact Where Id = :user.ContactId];
		Account account = [Select Name, Entity_Gen_Key__c, RCM_Office_ID__c from Account Where Id = :user.AccountId];
		List<Account_Identifier__c> ids = [Select Id, Account_Identifier__c, Account_Name__c
			from Account_Identifier__c
			where Account_Identifier_Type__c = 'HeW Sub ID' AND Account_Name__c = :user.AccountId];

		contactName = contact.Name;
		accountName = account.Name;

		/*
		 * This is kludgy and needs a more configurable design,
		 * but requirements changes are random and subject to change on a whim, so...
		 */
		customerIdLabel = 'Customer Id';
		customerId = account.Entity_Gen_Key__c;
		if(profile.Name.equals('Community HeW')) {
			if(!ids.isEmpty()) {
				customerIdLabel = 'HeW Sub ID';
				customerId = ids[0].Account_Identifier__c;
			}
			showAddress = true;
		} else if(profile.Name.equals('Community Provider')) {
			customerIdLabel = 'Office ID';
			customerId = account.RCM_Office_ID__c;
			showAddress = true;
		}
	}
}