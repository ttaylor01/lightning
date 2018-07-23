public class CCApexBridgeDemoEcho extends CCApexBridgeAbstract {
    public override void process(CCApexBridgeRequest request, CCApexBridgeResponse response) {
        String method = (String) request.method;
        if (method == 'echo') {
            response.output = CCApexBridgeAbstract.encodeData(request.getInputValue('value'));
        } else {
            throw new CCException('Unexpected "method" received');
        }
    }
}