public with sharing class CCProfileMenu {
	//Use @AuraEnabled to enable client- and server-side access to the method
	@AuraEnabled
	public static String getUserName() {
		return UserInfo.getName();
	}
}