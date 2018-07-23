@isTest
public class CCApexBridgeControllerTest {
    @isTest public static void invalidMethodTest() { CCApexBridgeTestHelper.invalidMethodTest('CCApexBridgeDemoEcho'); }

    @isTest
    public static void testBasicData() {
        String value = 'This is a test';
        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory('CCApexBridgeDemoEcho', 'echo');
        client.request.inputMap.put('value', value);
        client.request.doesCallout = true;

        CCApexBridgeResponse response = client.validate();
        System.assertEquals('"' + value + '"', response.output);
    }

    @isTest 
    public static void invalidMethodTest2() {
        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory('CCApexBridgeDemoEcho', 'InvalidMethod');
        client.request.doesCallout = true;
        
        try {
            CCApexBridgeResponse response = client.validate();
            System.assert(false, 'I was expecting to fail (1)');
        } catch (AuraHandledException ex1) {
            System.assertEquals('Script-thrown exception', ex1.getMessage());
        } catch (Exception ex2) {
            System.assert(false, 'I was expecting to fail (2)');
        }
    }

    @isTest
    public static void testRequest() {
        Map<String, String> data = new Map<String, String>{'a'=>'a1','b'=>'b1'};

        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory('CCApexBridgeDemoEcho', 'SampleOperation');
        CCApexBridgeRequest request = client.request;
        request.inputMap = data;
        request.doesCallout = true;
        request.input = CCApexBridgeAbstract.encodeData(request.inputMap);
        request.inputMap = null;
        request.debug = true;
        request.records = new List<Account>();
        String requestJson = request.toJson();
        CCApexBridgeRequest request2 = CCApexBridgeRequest.fromJSON(requestJson);
        System.assertEquals(data.get('a'), (String) request2.getInputValue('a'));
    }
    
    @isTest
    public static void TestMessages() {
        CCApexBridgeResponse response = new CCApexBridgeResponse();
        response.addMessage(CCApexBridgeResponse.MessageType.Information, 'Data was copied over');
        response.addMessage(CCApexBridgeResponse.MessageType.Errors, 'Testing an error');
    }
}