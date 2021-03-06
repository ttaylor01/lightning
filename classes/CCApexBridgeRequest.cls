// This is the communication bridge data between LC and Apex
public class CCApexBridgeRequest {

    @AuraEnabled
    public String controller { get; set; }

    @AuraEnabled
    public String method { get; set; }

    @AuraEnabled
    public Map<String, Object> inputMap { get; set; }

    @AuraEnabled
    public String input { get; set; }

    @AuraEnabled
    public Boolean debug { get; set; }

    @AuraEnabled
    public List<SObject> records {
        get {
            if (records == null) records = new List<SObject>();
            return records;
        }
        set;
    }

    @AuraEnabled
    public boolean doesCallout {
        get {
            if (doesCallout == null) doesCallout = false;
            return doesCallout;
        }
        set;
    }

    public Object getInputValue(String key) {
    	if(String.isBlank(input)) return '';
        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(input);  
        return inputMap.get(key);
    }
    
    public Date getInputDate(String key) {
        DateTime dttm = getInputDateTime(key);
        Date dt = Date.valueOf(dttm);
        return dt;
    }
    
    public DateTime getInputDateTime(String key) {
        String tmp = (String) getInputValue(key);
        // JSON requires this value to be enclosed in double quotes
        if (tmp.left(1) != '"')  tmp = '"' + tmp + '"';
        DateTime dttm = (DateTime) JSON.deserialize(tmp, DateTime.class);
        return dttm;
    }

    public static CCApexBridgeRequest fromJSON(String strJson) {
        System.debug(strJson);
        return (CCApexBridgeRequest) JSON.deserializeStrict(strJson, CCApexBridgeRequest.class);
    }

    public String toJSON() {
        return JSON.serialize(this);
    }

    public CCApexBridgeRequest(String controller, String method) {
        this.controller = controller;
        this.method = method;

        inputMap = new Map<String, Object>();
        input = JSON.serialize(inputMap);
        debug = false;
        records = new List<SObject>();
        doesCallout = false;
    }
}