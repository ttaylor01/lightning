@isTest
public with sharing class CCApexBridgeRequestTest {
    @isTest
    public static void testDates() {
        Date today = Date.today();
        String todayJson = JSON.serialize(today);

        CCApexBridgeRequest request = new CCApexBridgeRequest('controller',  'method');
        request.inputMap.put('DT', today);
        request.input = JSON.serialize(request.inputMap);
        Date dt2 = request.getInputDate('DT');
    }
}