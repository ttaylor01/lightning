public class HIMSSAnalyticsProfileController {
    @AuraEnabled
    public static String getHIMSSAnalyticsID(String accountId) {
        Account currentRecord = [SELECT HIMSS_Analytics_ID__c FROM Account WHERE Id = :accountId];
        return currentRecord.HIMSS_Analytics_ID__c;
    }
}