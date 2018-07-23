({
    getKavs : function(component, event, helper){
        // Display all KnowledgeArticleVersions for entered Subject
        helper.callServer(component,"c.getKavs",function(response){
            component.set("v.kavs", response);
        },
        {
            searchStr: component.get('v.searchStr'),
            numArticles: component.get('v.numArticles')
        });
    },
})