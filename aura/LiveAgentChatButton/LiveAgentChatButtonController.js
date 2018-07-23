({
    init : function(component, event, helper) {
        
        function liveAgentStart() {
            //timeout to initiate liveAgent
            window.setTimeout(
                $A.getCallback(function() {
                    if (component.isValid()) {
                        var data = {};
                        data.LA_chatServerURL =component.get("v.endpoint");
                        data.LA_deploymentId =component.get("v.deploymentId");
                        data.organizationId =component.get("v.organizationId");
                        data.chatButtontId =component.get("v.chatButtontId");
                        data.userSessionData =component.get("v.userSessionData");
                        data.caseSession =component.get("v.caseSession");
                        data.caseRecordTypeId =component.get("v.caseRecordTypeId");
                        if (component.get("v.contact") != null) {
                            data.contactId =component.get("v.contact").Id;
                            data.contactName =component.get("v.contact").Name;
                        }
                        function initLiveAgent (data) {
                            console.log('[LiveAgentChatButton.initLiveAgent]  data: '+JSON.stringify(data));
                            console.log('[LiveAgentChatButton.initLiveAgent]  liveagent: '+JSON.stringify(liveagent));
                            console.log('[LiveAgentChatButton.initLiveAgent]  btONLine: '+document.getElementById('btONline'));
                            var self = this;
                            self.data = data;
                            
                            if ((typeof liveagent == "object") && (document.getElementById('btONline') != null )) {
                                clearInterval(interV);
                                helper.bindLiveAgent(component,data);
                            } else {
                                console.log('[LiveAgentChatButton.init]  timeout to init live agent');
                            }
                        }
                        // setInterval to initiate liveAgent when liveagent object is available
                        var interV = setInterval(initLiveAgent,500,data);
                    } else {
                        console.log('LiveAgentChatButton component is not valid');
                    }
                }), 100
            );
        }
        
        var isValid = helper.validateComponent(component);
        component.set("v.isInvalidInput", !isValid);
        if ( isValid){
            if ( component.get("v.userSessionData") == true || component.get("v.caseSession") == true) {
                //retrieve logged user Contact Details
                var action = component.get("c.getContact");
                action.setCallback(this, function(a) {
                    component.set("v.contact", a.getReturnValue());
                    liveAgentStart();
                });
                $A.enqueueAction(action);
            }else {
                liveAgentStart();
            }
            
            var chatBtn = component.get("v.chatButtontId")+'';
            //adding liveAgent buttons wo global array
            if (!window._laq) { window._laq = []; }
            window._laq.push(function(){
                liveagent.showWhenOnline(
                    (function (chatBtn) {
                        return chatBtn;
                    })(chatBtn)
                    , document.getElementById('btONline'));
                liveagent.showWhenOffline(
                    (function (chatBtn) {
                        return chatBtn;
                    })(chatBtn)
                    , document.getElementById('btOFFline'));
            });
        }

    },
    
    startChat : function(component, event, helper) {
        console.log("[LiveAgentChatButton.startChat]  chatButtonId: "+component.get("v.chatButtontId"));
        liveagent.setChatWindowHeight(640);
        liveagent.setChatWindowWidth(480);
        liveagent.startChat(component.get("v.chatButtontId"));
    }
})