public class CCApexBridgeController {
	private static final String DEBUG_STR = 'CCApexBridgeController';

    @AuraEnabled
    public static String execute(String requestJson) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.execute] ';
        Savepoint spAllDataChanges;
        CCApexBridgeRequest request;
        CCApexBridgeResponse response = new CCApexBridgeResponse();

        try {
            System.debug(FUNC_STR + 'Input: ' + requestJson);
            response.requestJson = requestJson;
            request = CCApexBridgeRequest.fromJSON(requestJson);
            if (request.debug) System.debug(FUNC_STR + 'Input Processed: ' + request);
            if (!request.doesCallout) {
                // If there are any errors, the data will be reset... so, save a SavePoint
                spAllDataChanges = Database.setSavepoint();
            }
            CCApexBridgeAbstract executor = (CCApexBridgeAbstract) Type.forName(request.controller).newInstance();
            executor.process(request, response);
            if (request.debug) System.debug(FUNC_STR + 'After: ' + request);
        } catch (Exception ex) {
            // Rollback the data changes (Apex automatically rolls back when there are 
            // unhandled exception, but this is being handled)
            if (!request.doesCallout) {
                Database.rollback(spAllDataChanges);
            }

            System.debug(FUNC_STR + 'EXCEPTION -- JSON REQUEST STR: /n'+requestJson);
        	Logger.log(DEBUG_STR,'execute',null,null,'JSON REQUEST STR: '+requestJson,Logger.LogLevel.ERROR);
			Logger.log(DEBUG_STR,'execute',null,null,ex);
            
            System.debug(FUNC_STR + '**** Exception ****');
            System.debug(FUNC_STR + 'Message: ' + ex.getMessage());
            System.debug(FUNC_STR + 'StackTrace: ' + ex.getStackTraceString());
            
            // Build messages to return.
            String strEx = '';
            String st = ex.getStackTraceString();
            strEx += ex.getMessage();
            if (st != null){
                st = st.trim();
                if (st != '()') {
                    strEx += '\r\nStack Trace:\r\n' + ex.getStackTraceString();                
                    if (request.debug) System.debug(FUNC_STR + 'StackTrace: **' + ex.getStackTraceString() + '**');
                }
            }
            
            response.addMessage(CCApexBridgeResponse.MessageType.Errors, strEx);
            if (request.doesCallout) {
                throw new AuraHandledException(strEx);
            }
        }
        
        String output = response.toJSON(); 
        if (request.debug) System.debug(FUNC_STR + 'Output: ' + output);
        return output;
    }
}