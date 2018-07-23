public with sharing class CCApexBridgeResponse {
    public enum MessageType {Errors, Warnings, Information}

    @AuraEnabled
    public Boolean isSuccess {
        get {
            if (isSuccess == null) isSuccess = true;
            return isSuccess;
        }
        set;
    }

    @AuraEnabled
    public String requestJson { get; set; }

    @AuraEnabled
    public String output { get; set; }

    @AuraEnabled
    public Map<MessageType, List<String>> messages {
        get {
            if (messages == null) messages = new Map<MessageType, List<String>>();
            return messages;
        }
        set;
    }

    public void addMessage(MessageType msgType, String text) {
        List<String> ls = new List<String>();
        if (messages.containsKey(msgType)) ls = messages.get(msgType);
        ls.add(text);
        messages.put(msgType, ls);
        if (msgType == MessageType.Errors) {
            isSuccess = false;
            // throw new BlogException('Debbuging Error: ' + text);
        }
    }

    public static CCApexBridgeResponse fromJSON(String strJson) {
        System.debug(strJson);
        return (CCApexBridgeResponse) JSON.deserializeStrict(strJson, CCApexBridgeResponse.class);
    }

    public String toJSON() {
        return JSON.serialize(this);
    }

    public CCApexBridgeResponse() {
        isSuccess = null;
        requestJson = '';
        output = '';
        messages = new Map<CCApexBridgeResponse.MessageType, List<String>>();
    }
}