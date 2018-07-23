@isTest
public class CCApexBridgeTestHelper {
    public CCApexBridgeRequest request;
    public CCApexBridgeResponse response;

    public List<String> Errors {
        get { return getMessages(CCApexBridgeResponse.MessageType.Errors); }
    }
    public List<String> Warnings {
        get { return getMessages(CCApexBridgeResponse.MessageType.Warnings); }
    }
    public List<String> Information {
        get { return getMessages(CCApexBridgeResponse.MessageType.Information); }
    }

    public static CCApexBridgeTestHelper factory(String controller, String method) {
        CCApexBridgeTestHelper client = new CCApexBridgeTestHelper();
        client.request = new CCApexBridgeRequest(controller, method);
        client.request.debug = true;
        return client;
    }

    public CCApexBridgeResponse validate() {
        System.debug(request);
        
        // Prepare the data to simulate the client calling the controller
        request.debug = true;
        request.input = JSON.serialize(request.inputMap);
        request.inputMap = null;
        System.debug(request);
        String requestJson = request.toJSON();
        
        // Call the controller as the client would do.
        // Test.startTest();
        String responseJson = CCApexBridgeController.execute(requestJson);
        response = CCApexBridgeResponse.fromJSON(responseJson);
        // Test.stopTest();
        
        // Basic asserts
        System.assertEquals(requestJson, response.requestJson);
        return response;
    }

    public static void invalidMethodTest(String controller) {
        invalidMethodTest(controller, null);
    }
    public static void invalidMethodTest(String controller, String method) {
        CCApexBridgeTestHelper client = CCApexBridgeTestHelper.factory(controller, method);
        // client.request.doesCallout = true;
        CCApexBridgeResponse response = client.validate();
		
		System.assertEquals(false, response.isSuccess);       
//        System.assertEquals(1, client.Errors.size());
//        System.assertEquals('Unexpected "method" received', client.Errors[0]);
    }
    
    private List<String> getMessages(CCApexBridgeResponse.MessageType key) {
        List<String> listMessages;
        Map<CCApexBridgeResponse.MessageType, List<String>> mapMessages;
        if (response != null) {
            if (response.messages != null) {
                mapMessages = response.messages;
                if (mapMessages.containsKey(key)) {
                    listMessages = mapMessages.get(key);
                    return listMessages;
                }
            }
        }
        return null;
    }
}