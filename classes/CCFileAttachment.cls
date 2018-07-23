public with sharing class CCFileAttachment {

	@AuraEnabled
	public static List<ContentVersion> getFileAttachments(String recordId) {
		String communityId=Network.getNetworkId();//Use community Id to figure logged in Users Current Community
		List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
		cdls = [
			SELECT 
				ContentDocument.Id, 
				ContentDocument.LatestPublishedVersionId, 
				ContentDocument.PublishStatus, 
				ContentDocument.title, 
				Visibility, ShareType 
			FROM ContentDocumentLink WHERE LinkedEntityId =	:recordId
		];
		System.debug('[DEBUG-CCFileAttachment.getFileAttachments()]\n=========\nContentDocumentLinks: ' + cdls);
		
		List<Id> cvIds = new List<Id>();
		for(ContentDocumentLink cdl : cdls) {
			cvIds.add(cdl.ContentDocument.LatestPublishedVersionId);
		}

		List<ContentVersion> attachments = new List<ContentVersion>();
		attachments = [
			SELECT 
				Id, 
				CreatedBy.Name, 
				LastModifiedDate, 
				PathOnClient, Title, FileType
			FROM ContentVersion WHERE Id IN :cvIds
		];

		System.debug('[DEBUG-CCFileAttachment.getFileAttachments()]\n=========\nContentVersions: ' + attachments);
		return attachments;
	}

    @AuraEnabled
    public static Id saveTheChunk(Id recordId, String fileName, String base64Data, String contentType, String fileId) {
		System.debug('[DEBUG-CCFileAttachment.saveTheChunk()]\n=========\nbase64Data:  '+base64Data);
		System.debug('[DEBUG-CCFileAttachment.saveTheChunk()]\n=========\nfileId:  '+fileId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
		ContentVersion cv;
    	if(String.isBlank(fileId)) {
            cv = addFileAttachment(recordId, fileName, base64Data, contentType);
        } else {
            cv = appendToFile(fileId, recordId, base64Data, contentType);
        }
        
		System.debug('[DEBUG-CCFileAttachment.saveTheChunk()]\n=========\nreturning fileId:  '+cv.Id);
        return cv.Id;
    }
    
    private static ContentVersion addFileAttachment(Id recordId, String fileName, String base64Data, String contentType) { 
    	if(String.isBlank(recordId)) {
			AuraHandledException e = new AuraHandledException('Missing Ticket record Id.');
			e.setMessage('Missing Ticket record Id.');
			System.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\nERROR: Missing Ticket record Id.');
			throw e;
    	}
    	if(String.isBlank(fileName) || String.isBlank(base64Data)) {
			AuraHandledException e = new AuraHandledException('Missing or empty file attachment.');
			e.setMessage('Missing or empty file attachment.');
			System.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\nERROR: Missing or empty file attachment.');
			throw e;
    	}
		System.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\nbase64Data:  '+base64Data);

		ContentVersion cVersion =new ContentVersion();
		cVersion.Title =fileName;
		cVersion.VersionData=EncodingUtil.base64Decode(base64Data);
		cVersion.PathOnClient='/' + fileName ;
        Database.SaveResult result = Database.insert(cVersion,false);
        if (result == null || !result.isSuccess()) {
        	String errorMsg;
			for(Database.Error err : result.getErrors()) {
				errorMsg = err.getStatusCode() + ': ' + err.getMessage();
				System.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
				System.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\n Case fields that affected this error: ' + err.getFields());
			}
			throw new AuraHandledException(errorMsg);
        }

		system.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\nContentVersion.id '+ cVersion.id);
		cVersion = [select Id, ContentDocumentId, Title, VersionData, PathOnClient from ContentVersion WHERE Id =: cVersion.Id];
		ContentDocumentLink cl = new ContentDocumentLink();
		cl.ContentDocumentId = cVersion.ContentDocumentId;
		cl.LinkedEntityId = recordId; 
		/**
		 * 'V':  Viewers - can view, download, and share files
		 * 'I':  Set by Record - for a file attached to a record means that access to the file follows access to the record. 
		 *                       People with read/write access to the record have Collaborator access to the file. 
		 *                       People with read-only access to the record have Viewer access to the file.
		 */
		cl.ShareType = 'I'; // or 'I'? 
		cl.Visibility = 'AllUsers';
        result = Database.insert(cl,false);
        if (result == null || !result.isSuccess()) {
        	String errorMsg;
			for(Database.Error err : result.getErrors()) {
				errorMsg = err.getStatusCode() + ': ' + err.getMessage();
				System.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
				System.debug('[DEBUG-CCFileAttachment.addFileAttachment()]\n=========\n Case fields that affected this error: ' + err.getFields());
			}
			throw new AuraHandledException(errorMsg);
        }

		return cVersion;
    }

    private static ContentVersion appendToFile(Id fileId, Id recordId, String base64Data, String contentType) {
		System.debug('[DEBUG-CCFileAttachment.appendToFile()]\n=========\nbase64Data:  '+base64Data);
		System.debug('[DEBUG-CCFileAttachment.appendToFile()]\n=========\nfileId:  '+fileId);

		ContentVersion a = [
			SELECT Id, Title, VersionData, ContentDocumentId
			FROM ContentVersion
			WHERE Id = :fileId
		];

		String existingBody = EncodingUtil.base64Encode(a.VersionData);
		base64Data = existingBody + base64Data;
        ContentVersion cVersion = addFileAttachment(recordId, a.Title, base64Data, contentType);

		// Because I need to chunk documents uploads to create large files AND
		// Because I cannot update the file content (ContentVersion) with each subsequent chunk,
		// I need to stage each chunk as an incomplete ContentVersion and then remove the prior incomplete ContentVersion chunk
		// until the file is completely uploaded.
		// So, remove prior existing document that comprised only a chunk of the document content.
        delete new ContentDocument(Id=a.ContentDocumentId);

		return cVersion;
    }

}