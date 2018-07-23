({
    getArticle : function(component, event, helper) {
        // Display all cases for selected status
        helper.callServer(component,"c.getKnowledgeArticle",function(response,error) {
            if(error) {
                // do some error processing
	            helper.displayErrorDialog('IMPORTANT!',error,'error');
            } else {
	            component.set("v.kad", response);
                console.log("article type: "+component.get("v.kad.articleType"));
                var articleType = component.get("v.kad.articleType");
                if(component.get("v.kad.articleType") === "Known_Issue__kav") {
                    component.set("v.knownIssueVisibility",true);
                    component.set("v.articleTypeVisibility",false);
                } else {
                    component.set("v.knownIssueVisibility",false);
                    component.set("v.articleTypeVisibility",true);
                }
            }
        },
        {
            articleType: component.get('v.articleType'),
            knowledgeArticleId: component.get('v.knowledgeArticleId')
        });
    },
})