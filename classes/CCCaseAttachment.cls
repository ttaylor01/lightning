public with sharing class CCCaseAttachment {
    
	/*
	 * Case Attachment logic
	 */
	@AuraEnabled
	public static List<Attachment> getCaseAttachments(String recordId) {
		List<Attachment> attachments = new List<Attachment>();
		attachments = [
			SELECT Id, CreatedBy.Name, ParentId, Name, ContentType, LastModifiedDate, IsPrivate FROM Attachment
			WHERE ParentId = :recordId AND IsPrivate = false
		];
		System.debug('[DEBUG-CCCaseAttachment.getCaseComments()]\n=========\nattachments: ' + attachments);
		return attachments;
	}
    @AuraEnabled
    public static Id addAttachment(Id recordId, String fileName, String base64Data, String contentType) { 
    	if(String.isBlank(recordId)) {
			AuraHandledException e = new AuraHandledException('Missing Ticket record Id.');
			e.setMessage('Missing Ticket record Id.');
			System.debug('[DEBUG-CCCaseAttachment.addAttachment()]\n=========\nERROR: Missing Ticket record Id.');
			throw e;
    	}
    	if(String.isBlank(fileName) || String.isBlank(base64Data)) {
			AuraHandledException e = new AuraHandledException('Missing or empty file attachment.');
			e.setMessage('Missing or empty file attachment.');
			System.debug('[DEBUG-CCCaseAttachment.addAttachment()]\n=========\nERROR: Missing or empty file attachment.');
			throw e;
    	}
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
		System.debug('[DEBUG-CCCaseAttachment.addAttachment()]\n=========\nbase64Data:  '+base64Data);
        
        Attachment attachment = new Attachment();
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
        attachment.parentId = recordId;
        attachment.contentType = contentType;
		System.debug('[DEBUG-CCCaseAttachment.addAttachment()]\n=========\nattachment:  '+attachment);
        // inser the attahcment
        Database.SaveResult result = Database.insert(attachment,false);
        if (result == null || !result.isSuccess()) {
        	String errorMsg;
			for(Database.Error err : result.getErrors()) {
				errorMsg = err.getStatusCode() + ': ' + err.getMessage();
				System.debug('[DEBUG-CCCaseAttachment.addAttachment()]\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
				System.debug('[DEBUG-CCCaseAttachment.addAttachment()]\n=========\n Case fields that affected this error: ' + err.getFields());
			}
			throw new AuraHandledException(errorMsg);
        }
        return attachment.Id;
    }

    @AuraEnabled
    public static Id saveTheChunk(Id recordId, String fileName, String base64Data, String contentType, String fileId) {
		System.debug('[DEBUG-CCCaseAttachment.saveTheChunk()]\n=========\nbase64Data:  '+base64Data);
		System.debug('[DEBUG-CCCaseAttachment.saveTheChunk()]\n=========\nfileId:  '+fileId);
    	if(String.isBlank(fileId)) {
            fileId = addAttachment(recordId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
		System.debug('[DEBUG-CCCaseAttachment.saveTheChunk()]\n=========\nreturning fileId:  '+fileId);
        return Id.valueOf(fileId);
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
		System.debug('[DEBUG-CCCaseAttachment.appendToFile()]\n=========\nbase64Data:  '+base64Data);
		System.debug('[DEBUG-CCCaseAttachment.appendToFile()]\n=========\nfileId:  '+fileId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];
        
     	String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update a;
    }


    @AuraEnabled
    public static List<Attachment> deleteAttachment(Id recordId, Id attachmentId) { 
    	if(String.isBlank(attachmentId) || String.isBlank(recordId)) {
			AuraHandledException e = new AuraHandledException('Missing Ticket Id or Attachment Id.');
			e.setMessage('Missing Ticket Id or Attachment Id.');
			throw e;
    	}

        // delete the attachment
        Database.DeleteResult result = Database.delete(attachmentId,false);
        if (result == null || !result.isSuccess()) {
        	String errorMsg;
			for(Database.Error err : result.getErrors()) {
				errorMsg = err.getStatusCode() + ': ' + err.getMessage();
				System.debug('[DEBUG-CCCaseAttachment.deleteAttachment()]\n=========\n'+err.getStatusCode() + ': ' + err.getMessage());
				System.debug('[DEBUG-CCCaseAttachment.deleteAttachment()]\n=========\n Case fields that affected this error: ' + err.getFields());
			}
			throw new AuraHandledException(errorMsg);
        }
        return getCaseAttachments(recordId);
    }
}