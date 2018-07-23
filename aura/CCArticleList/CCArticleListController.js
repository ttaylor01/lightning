({
    doInit : function(component, event, helper) {
        var searchVal = component.get('v.searchStr');
		if(searchVal === undefined || (searchVal.length >= 0 && searchVal.length < 3)) {
			return;
        }
        helper.getKavs(component,event,helper);
    },
    onArticleClick : function(component, event) {
        var rowEl = event.currentTarget;
        var rowId = rowEl.getAttribute('data-row');
        var kaId = rowEl.getAttribute('data-pk');
        var kaType = component.get('v.kavs')[rowId].articleType;
        // refresh the article dialog with chosen article
        var cmp = component.find("articleDetailCmp");
        cmp.set('v.articleType', kaType);
        cmp.set('v.knowledgeArticleId', kaId);
        cmp.refresh();
        // Unhide the modal dialog
        $A.util.removeClass(component.find("articleModal"),'hide-modal');
    },
	hideArticleDetailDialog : function(component, event, helper) {
        $A.util.addClass(component.find("articleModal"),'hide-modal');
	},
    clear : function(component, event, helper) {
        component.set("v.kavs", null);
    }
})