public with sharing class LiveAgentChatButton {

    @AuraEnabled
    public static Contact getContact(Id contactId) {
        Contact c=null;
        User usr = [Select ContactId from User where Id=: UserInfo.getUserId()];
        if(usr.ContactId !=null) {
            c = [
                    SELECT Id, Name, Email, Phone
                    FROM Contact
                    WHERE Id =:usr.ContactId
                ];
        } else {
            c = new Contact(FirstName='Guest',LastName='User');
        }
        return c;
    }
}