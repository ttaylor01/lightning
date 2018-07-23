({
	doInit : function(component, event, helper) {
        var knowledgeArticleId = component.get('v.knowledgeArticleId');
		if(knowledgeArticleId == undefined || knowledgeArticleId.length === 0) {
			return;
        }
        helper.getArticle(component, event, helper);
	},
    doCancel : function(component, event, helper) {
        var compEvent = component.getEvent("hideArticleDetailDialog");
        compEvent.fire();  
    },
})