({
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.chatButtontId") != undefined && component.get("v.chatButtontId") != '')
            || ( component.get("v.endpoint") != undefined && component.get("v.endpoint") != '')
            || ( component.get("v.deploymentId") != undefined && component.get("v.deploymentId") != '')
            || ( component.get("v.deploymentUrl") != undefined && component.get("v.deploymentUrl") != '')
            || ( component.get("v.organizationId") != undefined && component.get("v.organizationId") != '') ;
        }
        return valid;
    },
    bindLiveAgent : function (component,data) {
        console.log("[LiveAgentChatButton.bindLiveAgent] data: "+JSON.stringify(data));
        //custom handler for online/offline update
        function updateLiveAgentButton(component) {
            
            if (component.isValid()) {
                var onlineBtn = document.getElementById('btONline');//component.find("btONline");
                var offlineBtn = document.getElementById('btOFFline');//component.find("btOFFline");
                
                if( (  typeof onlineBtn != "undefined"  ) &&
                   (  typeof offlineBtn != "undefined"  )){
                    
                    if ( component.get("v.isLiveAgentOnline")== true) {
                        $A.util.removeClass(onlineBtn, "toggle");
                        $A.util.addClass(offlineBtn, "toggle");
                    } else {
                        $A.util.removeClass(offlineBtn, "toggle");
                        $A.util.addClass(onlineBtn, "toggle");
                    }
                }
            }
        }
        
        component.set("v.isLiveAgentOnline",false);
        var chatBtn    = data.chatButtontId;
        liveagent.addButtonEventHandler(chatBtn, function(e) {
            if (e == liveagent.BUTTON_EVENT.BUTTON_AVAILABLE) {
                component.set("v.isLiveAgentOnline",true);
            } else if (e == liveagent.BUTTON_EVENT.BUTTON_UNAVAILABLE) {
                component.set("v.isLiveAgentOnline",false);
            }
            if (component.get("v.previousIsLiveAgentOnline") == null) {
                component.set("v.previousIsLiveAgentOnline",false);
            } else {
                component.set("v.previousIsLiveAgentOnline",component.get("v.isLiveAgentOnline"));
            }
            
            updateLiveAgentButton(component);
        });
        
        if (data.userSessionData && typeof data.contactId != undefined) {
            var contactId = data.contactId;
            if (contactId != undefined){
                console.log("[LiveAgentChatButton.bindLiveAgent] setting up contact: "+contactId+" : "+data.contactName);
                liveagent.addCustomDetail('Contact Id', contactId, false);
                // An auto query that searches contacts whose id exactly matches based on
                //the community user's contact. The guid for the contact will be hidden from the agent.
                // The contact will be automatically associated to the chat and opened in the Console for the agent
                liveagent.findOrCreate('Contact').map('Id','Contact Id',true,true,false).saveToTranscript('ContactId').showOnCreate();
                //set the visitor's name to the value of the contact's first and last name
                liveagent.setName(data.contactName);
            }

            var caseRecordTypeId = data.caseRecordTypeId;
            if (data.caseSession && caseRecordTypeId != undefined) {
                console.log("[LiveAgentChatButton.bindLiveAgent] setting up case: "+caseRecordTypeId);
                // This does a non search on cases by the value of the "RecordTypeId" custom detail.
                // It will create a case and set the case's record type and status
                // The case that's found or created will be associated to the chat and the case will open in
                // the Console for the agent when the chat is accepted 
                liveagent.addCustomDetail("Case Status", "New", false);
                liveagent.addCustomDetail("Subject", "Chat Case", false);
                // QA Community Support case type:  012110000000bMfAAI
                liveagent.addCustomDetail('RecordTypeId', caseRecordTypeId, false);
                liveagent.findOrCreate('Case').map('RecordTypeId','RecordTypeId',false,false,true)
                	.map('Status','Case Status',false,false,true)
                	.map('Subject','Subject',false,false,true)
                	.saveToTranscript('CaseId').showOnCreate();
                // Link the case to the contact record */
                liveagent.findOrCreate("Contact").linkToEntity("Case","ContactId");
            }
        }
        liveagent.init( data.LA_chatServerURL, data.LA_deploymentId,  data.organizationId);
    },
})