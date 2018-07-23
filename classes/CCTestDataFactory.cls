@isTest
public class CCTestDataFactory {
	public static final String zAccountId = '12345678901234567890123456789012';
	public static String getZAccountId() { return zAccountId; }

    public static void createTestRecords() {
        Account testAcc = createAccountRecords();
		List<Contact> testContacts = createContactRecords(testAcc);
		Contact testcon = testContacts.get(0);
        system.debug('\n[DEBUG-CCTestDataFactory.createTestRecords()]\n=========\n Contact: ' + testcon);
		User user = createCommunityUserRecord(testcon);
        system.debug('\n[DEBUG-CCTestDataFactory.createTestRecords()]\n=========\n user: ' + user);
		List<Case> cases = createCaseRecords(testAcc,testcon);
		List<CCRecordTypes__c> ccr = createCCRecordTypes();
		List<CC_App_Settings__c> cca = createCCAppSettings();
    }

    public static void createPayerTestRecords() {
        Account testAcc = createAccountRecords();
		List<Contact> testContacts = createContactRecords(testAcc);
		Contact testcon = testContacts.get(1);
		User user = createCommunityPayerRecord(testcon);
		List<Case> cases = createPayerSupportCaseRecords(testAcc,testcon);
		cases = createPayerCaseRecords(testAcc,testContacts.get(1));
		List<CCRecordTypes__c> ccr = createCCRecordTypes();
		List<CC_App_Settings__c> cca = createCCAppSettings();
    }

    public static void createChangeRequestRecords() {
        Account testAcc = createAccountRecords();
		List<Contact> testContacts = createContactRecords(testAcc);
		Contact testcon = testContacts.get(1);
		User user = createCommunityPayerRecord(testcon);
		List<Case> cases = createChangeRequestCaseRecords(testAcc,testcon);
		List<CCRecordTypes__c> ccr = createCCRecordTypes();
		List<CC_App_Settings__c> cca = createCCAppSettings();
    }

    public static void createTestIssueRecords() {
        Account testAcc = createAccountRecords();
		List<Contact> testContacts = createContactRecords(testAcc);
		Contact testcon = testContacts.get(1);
		User user = createCommunityProjectRecord(testcon);
		List<Case> cases = createTestIssueCaseRecords(testAcc,testcon);
		List<CCRecordTypes__c> ccr = createCCRecordTypes();
		List<CC_App_Settings__c> cca = createCCAppSettings();
    }

    public static void createTestProviderRecords() {
        Account testAcc = createAccountRecords();
        system.debug('\n[DEBUG-CCTestDataFactory.createTestProviderRecords()]\n=========\n Account: ' + testAcc);
		List<Contact> testContacts = createContactRecords(testAcc);
        system.debug('\n[DEBUG-CCTestDataFactory.createTestProviderRecords()]\n=========\n Contacts: ' + testContacts);
		Contact testcon = testContacts.get(0);
		User user = createCommunityProviderRecord(testcon);
        system.debug('\n[DEBUG-CCTestDataFactory.createTestProviderRecords()]\n=========\n User: ' + user);
		List<Case> cases = createProductSupportCaseRecords(testAcc,testcon);
        system.debug('\n[DEBUG-CCTestDataFactory.createTestProviderRecords()]\n=========\n Product Support Cases: ' + cases);
        cases = createBillingSupportCaseRecords(testAcc,testcon);
        system.debug('\n[DEBUG-CCTestDataFactory.createTestProviderRecords()]\n=========\n Billing Support Cases: ' + cases);
		List<CCRecordTypes__c> ccr = createCCRecordTypes();
		List<CC_App_Settings__c> cca = createCCAppSettings();
    }
    
	public static Account createAccountRecords() {
        Account testAcc = new Account();
        testAcc.Name = 'testAccount';
        testAcc.BillingCity = 'Atlanta';
        testAcc.BillingState = 'GA';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingStreet = '123';
        testAcc.ShippingStreet = '123';
        testAcc.ShippingCity = 'Atlanta';
        testAcc.ShippingState	 = 'GA';
        testAcc.ShippingPostalCode = '12345';
        testAcc.HA_Unique_ID__c = '123456';
        insert testAcc;
        createBillingAccount(testAcc);
        return testAcc;
	}
	public static Zuora__CustomerAccount__c createBillingAccount(Account acc) {
		Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
		billAcc.Name = 'Test Billing Account';
		billAcc.AvailityLineOfBusiness__c = 'Provider';
		billAcc.Zuora__Account__c = acc.Id;
		billAcc.Zuora__AccountNumber__c = 'A-001';
		billAcc.Zuora__AutoPay__c = false;
		billAcc.Zuora__Batch__c = 'Batch1';
		billAcc.Zuora__BillCycleDay__c = '1';
		billAcc.Zuora__Balance__c = 0;
		billAcc.Zuora__BillToCity__c = 'Atlanta';
		billAcc.Zuora__BillToCountry__c = 'United States';
		billAcc.Zuora__BillToAddress1__c = '123 Main St';
		billAcc.Zuora__BillToState__c = 'Georgia';
		billAcc.Zuora__BillToPostalCode__c = '12345';
		billAcc.Zuora__BillToId__c = '1234567890';
		billAcc.Zuora__BillToName__c = 'Test Name';
		billAcc.Zuora__BillToWorkEmail__c = 'test@availity.com';
		billAcc.Zuora__MRR__c = 100;
		billAcc.Zuora__Credit_Balance__c = 100;
		billAcc.Zuora__Currency__c = 'USD';
		billAcc.Zuora__External_Id__c = zAccountId;
		billAcc.Zuora__PaymentTerm__c = 'Due Upon Receipt';
		billAcc.Zuora__Status__c = 'Active';
		billAcc.Zuora__Zuora_Id__c = zAccountId;
		billAcc.Zuora__DefaultPaymentMethod__c = 'CreditCard';
		insert billAcc;
		return billAcc;
	}

	public static List<Contact> createContactRecords(Account testAcc) {
		List<Contact> testContacts = new List<Contact>();
        Contact testcon = new Contact();
        testcon.firstname = 'testconfirst';
        testcon.lastname = 'testconlast';
        testcon.Phone = '7777777777';
        testcon.MobilePhone = '6666666666';
        testcon.HomePhone = '5555555555';
        testcon.OtherPhone = '4444444444';
        testcon.OtherStreet = 'Other Street';
        testcon.Salutation = 'Mr.';
        testcon.MailingCountry = 'United States';
        testCon.MailingCity = 'Atlanta';
        testCon.MailingState = 'Georgia';
        testCon.MailingStreet = '123 lane';
        testcon.email = 'community.test@availity.com';
        testcon.AccountId = testAcc.Id;
        testContacts.add(testcon);

        Contact testcon2 = new Contact();
        testcon2.firstname = 'testcon2first';
        testcon2.lastname = 'testcon2last';
        testcon2.Phone = '7777777777';
        testcon2.MobilePhone = '6666666666';
        testcon2.HomePhone = '5555555555';
        testcon2.OtherPhone = '4444444444';
        testcon2.OtherStreet = 'Other Street';
        testcon2.Salutation = 'Mr.';
        testcon2.MailingCountry = 'United States';
        testcon2.MailingCity = 'Atlanta';
        testcon2.MailingState = 'Georgia';
        testcon2.MailingStreet = '123 lane';
        testcon2.email = 'community.payer@availity.com';
        testcon2.AccountId = testAcc.Id;
        testContacts.add(testcon2);
        insert testContacts;
        return testContacts;
	}

	public static User createCommunityUserRecord(Contact testcon) {
        String profileName = 'Community User';
        Profile profile = [select Id from Profile where Name=:profileName];
        User user = new User(
            ContactId = testcon.Id,
            Username = 'community.test@availity.com',
            Email = 'community.test@availity.com',
            LastName = testcon.LastName,
            FirstName = testcon.FirstName,
            Alias = 'com.test',
            CommunityNickname = 'comm',
            ProfileId = profile.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey='UTF-8'
        );
        insert user;
        user.IsPortalEnabled = true;
        update user;
        return user;
	}

	public static User createCommunityPayerRecord(Contact testcon) {
        String profileName = 'Community Payer';
        Profile profile = [select Id from Profile where Name=:profileName];
        User user = new User(
            ContactId = testcon.Id,
            Username = 'community.payer@availity.com',
            Email = 'community.payer@availity.com',
            LastName = 'Community',
            FirstName = 'payer',
            Alias = 'com.pay',
            CommunityNickname = 'commpayer',
            ProfileId = profile.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey='UTF-8'
        );
        insert user;
        user.IsPortalEnabled = true;
        update user;
        return user;
	}
	
	public static User createCommunityProjectRecord(Contact testcon) {
        String profileName = 'Community Project Support';
        Profile profile = [select Id from Profile where Name=:profileName];
        User user = new User(
            ContactId = testcon.Id,
            Username = 'community.payer@availity.com',
            Email = 'community.payer@availity.com',
            LastName = 'Community',
            FirstName = 'payer',
            Alias = 'com.pay',
            CommunityNickname = 'commpayer',
            ProfileId = profile.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey='UTF-8'
        );
        insert user;
        user.IsPortalEnabled = true;
        update user;
        return user;
	}
	
	public static User createCommunityProviderRecord(Contact testcon) {
        String profileName = 'Community Provider';
        Profile profile = [select Id from Profile where Name=:profileName];
        User user = new User(
            ContactId = testcon.Id,
            Username = 'community.provider@availity.com',
            Email = 'community.test@availity.com',
            LastName = 'Community',
            FirstName = 'Provider',
            Alias = 'com.prov',
            CommunityNickname = 'commprovider',
            ProfileId = profile.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey='UTF-8'
        );
        insert user;
        user.IsPortalEnabled = true;
        update user;
        return user;
	}
	
	public static List<Case> createCaseRecords(Account testAcc, Contact testcon) {
		List<Case> cases = new List<Case>();

        RecordType newpayerrequestRT = [SELECT Id, Name FROM RecordType WHERE Name = 'New Payer Request' LIMIT 1];
        RecordType customersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Community Support' LIMIT 1];
        Case cs = new Case();
        cs.RecordTypeId = customersupportRT.Id;
        cs.Status ='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.Call_Reason__c = 'Login';
        cs.CID_Identifier__c = '12345';
        cs.Brief_Description__c = '';
        cs.Submission_Method__c = '';
        cs.Payer_Name__c = '';
        cs.Payer_ID__c = '';
        cs.Government_Payer__c = false;
        cs.Provider_Name__c = '';
        cs.NPI_Identifier__c = '';
        cs.Tax_ID__c = '';
        cs.PTAN_Identifier__c = '';
        cs.Atypical_Provider__c = false;
        cs.User_ID__c = 'TestUserId';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.New_Payer_Request_Type__c = '';
        // Transaction Information
        cs.EDI_Batch_ID__c = '';
        cs.Patient_Name__c = '';
        cs.Web_Transaction_ID__c = '';
        cs.Member_ID__c = '';
        cs.EDI_Batch_Reject_Reason__c = '';
        cs.Date_of_Service__c = null;
        cs.Charge_Amount__c = null;
        // Check Information
        cs.Check_Date__c = null;
        cs.Check_Number__c = '';
        cs.Check_Amount__c = null;
        // B2B Transaction Information
        cs.B2B_Vendor_Transaction_ID__c = '';
        cs.B2B_transaction_Date__c = null;
        cs.B2B_Time_of_Transaction__c = '';
        cs.B2B_Vendor_Error_Code__c = '';
        // Details
        cs.Subject = 'New';
        cs.Description = 'New Test Subject';
        insert cs;
        cases.add(cs);
        CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
        insert comment;
        
        createAttachment(cs.Id);
            
        cs = new Case();
        cs.RecordTypeId = customersupportRT.Id;
        cs.Status='Closed';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        cs.Call_Reason__c = 'Login';
        cs.Brief_Description__c = '';
        cs.Submission_Method__c = '';
        cs.Payer_Name__c = '';
        cs.Payer_ID__c = '';
        cs.Government_Payer__c = false;
        cs.Provider_Name__c = '';
        cs.NPI_Identifier__c = '';
        cs.Tax_ID__c = '';
        cs.PTAN_Identifier__c = '';
        cs.Atypical_Provider__c = false;
        cs.User_ID__c = 'TestUserId';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.New_Payer_Request_Type__c = '';
        // Transaction Information
        cs.EDI_Batch_ID__c = '';
        cs.Patient_Name__c = '';
        cs.Web_Transaction_ID__c = '';
        cs.Member_ID__c = '';
        cs.EDI_Batch_Reject_Reason__c = '';
        cs.Date_of_Service__c = null;
        cs.Charge_Amount__c = null;
        // Check Information
        cs.Check_Date__c = null;
        cs.Check_Number__c = '';
        cs.Check_Amount__c = null;
        // B2B Transaction Information
        cs.B2B_Vendor_Transaction_ID__c = '';
        cs.B2B_transaction_Date__c = null;
        cs.B2B_Time_of_Transaction__c = '';
        cs.B2B_Vendor_Error_Code__c = '';
        // Details
        cs.Subject = 'Closed';
        cs.Description = 'Closed Test Subject';
        insert cs;
        cases.add(cs);
            
        cs = new Case();
        cs.RecordTypeId = newpayerrequestRT.Id;
        cs.Status='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        cs.Payer_Name__c = '';
        cs.Payer_ID__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Subject = 'New Payer Request';
        cs.Description = 'New Payer Request Description';
        insert cs;
        cases.add(cs);
        comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
        insert comment;
        createAttachment(cs.Id);
        
		return cases;
	}

	public static List<Case> createPayerCaseRecords(Account testAcc, Contact testcon) {
		List<Case> cases = new List<Case>();

        RecordType payerReviewRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Review' LIMIT 1];
        Case cs = new Case();
        cs.RecordTypeId = payerReviewRT.Id;
        cs.Status ='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.Payer_Name__c = 'Payer Name';
        cs.Payer_ID__c = 'Payer Id';
        cs.Payer_Ticket_Number__c = '123456';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        // Details
        cs.Subject = 'New Payer Review';
        cs.Description = 'New Test Subject';
        insert cs;
        cases.add(cs);
        CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
        insert comment;
        createAttachment(cs.Id);
            
        cs = new Case();
        cs.RecordTypeId = payerReviewRT.Id;
        cs.Status='Closed';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.Payer_Name__c = 'Payer Name';
        cs.Payer_ID__c = 'Payer Id';
        cs.Payer_Ticket_Number__c = '123456';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        // Details
        cs.Subject = 'Closed Payer Review';
        cs.Description = 'Closed Test Subject';
        insert cs;
        cases.add(cs);
      
		return cases;
	}

	public static List<Case> createPayerSupportCaseRecords(Account testAcc, Contact testcon) {
		List<Case> cases = new List<Case>();

        RecordType payersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Support' LIMIT 1];
        Case cs = new Case();
        cs.RecordTypeId = payersupportRT.Id;
        cs.Status ='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.Call_Reason__c = 'ACE Edits';
        cs.CID_Identifier__c = '12345';
        cs.Submission_Method__c = '';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Transaction__c = '';
        // Details
        cs.Subject = 'New';
        cs.Description = 'New Test Subject';
        insert cs;
        cases.add(cs);
        CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
        insert comment;
        createAttachment(cs.Id);
            
        cs = new Case();
        cs.RecordTypeId = payersupportRT.Id;
        cs.Status='Closed';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.Call_Reason__c = 'ACE Edits';
        cs.CID_Identifier__c = '12345';
        cs.Submission_Method__c = '';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Transaction__c = '';
        // Details
        cs.Subject = 'Closed';
        cs.Description = 'Closed Test Subject';
        insert cs;
        cases.add(cs);
            
		return cases;
	}

	public static List<Case> createProductSupportCaseRecords(Account testAcc, Contact testcon) {
		List<Case> cases = new List<Case>();

        RecordType caseRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Provider Customer Support' LIMIT 1];
        Case cs = new Case();
        cs.RecordTypeId = caseRT.Id;
        cs.Status ='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.Call_Reason__c = 'Patient Access';
        cs.CID_Identifier__c = '12345';
        cs.Submission_Method__c = '';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Transaction__c = '';
        // Details
        cs.Subject = 'New';
        cs.Description = 'New Test Subject';
        insert cs;
        cases.add(cs);
        CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
        insert comment;
        createAttachment(cs.Id);
            
        cs = new Case();
        cs.RecordTypeId = caseRT.Id;
        cs.Status='Closed';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.Call_Reason__c = 'Patient Access';
        cs.CID_Identifier__c = '12345';
        cs.Submission_Method__c = '';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Transaction__c = '';
        // Details
        cs.Subject = 'Closed';
        cs.Description = 'Closed Test Subject';
        insert cs;
        cases.add(cs);
            
		return cases;
	}

	public static List<Case> createBillingSupportCaseRecords(Account testAcc, Contact testcon) {
		List<Case> cases = new List<Case>();

        RecordType caseRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Finance' LIMIT 1];
        Case cs = new Case();
        cs.RecordTypeId = caseRT.Id;
        cs.Status ='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        // Details
        cs.Subject = 'New';
        cs.Description = 'New Test Subject';
        insert cs;
        cases.add(cs);
        CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
        insert comment;
        createAttachment(cs.Id);
            
        cs = new Case();
        cs.RecordTypeId = caseRT.Id;
        cs.Status='Closed';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        // Details
        cs.Subject = 'Closed';
        cs.Description = 'Closed Test Subject';
        insert cs;
        cases.add(cs);
            
		return cases;
	}

	public static List<Case> createChangeRequestCaseRecords(Account testAcc, Contact testcon) {
		List<Case> cases = new List<Case>();

        RecordType crRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Change Request' LIMIT 1];
        Case cs = new Case();
        cs.RecordTypeId = crRT.Id;
        cs.Status ='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Transaction__c = 'Payer Spaces';
        // Details
        cs.Subject = 'New';
        cs.Description = 'New Test Subject';
        cs.Priority = 'High';
        cs.Region__c = 'All Regions';
        cs.Health_Plan__c = 'Florida Blue';
        insert cs;
        cases.add(cs);
        CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
        insert comment;
        createAttachment(cs.Id);
            
        cs = new Case();
        cs.RecordTypeId = crRT.Id;
        cs.Status='Closed';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Transaction__c = 'Payer Spaces';
        cs.Priority = 'High';
        cs.Region__c = 'All Regions';
        cs.Health_Plan__c = 'Florida Blue';
        // Details
        cs.Subject = 'Closed';
        cs.Description = 'Closed Test Subject';
        insert cs;
        cases.add(cs);
            
		return cases;
	}

	public static List<Case> createTestIssueCaseRecords(Account testAcc, Contact testcon) {
		List<Case> cases = new List<Case>();

        RecordType crRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Test Issue' LIMIT 1];
        Case cs = new Case();
        cs.RecordTypeId = crRT.Id;
        cs.Status ='New';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        // Details
        cs.Subject = 'New';
        cs.Description = 'New Test Subject';
        cs.Priority = 'High';
        insert cs;
        cases.add(cs);
		System.debug('[DEBUG-CCTestDataFactory.createTestIssueCaseRecords()]\n=========\nCase: ' + cs);

        createAttachment(cs.Id);

        cs = new Case();
        cs.RecordTypeId = crRT.Id;
        cs.Status='Closed';
        cs.AccountId = testAcc.Id;
        cs.ContactId = testCon.Id;
        cs.CID_Identifier__c = '12345';
        cs.Customer_Reference_Number__c = '';
        cs.Alternate_Email__c = '';
        cs.Alternate_Email_2__c = '';
        cs.Priority = 'High';
        // Details
        cs.Subject = 'Closed';
        cs.Description = 'Closed Test Subject';
        insert cs;
        cases.add(cs);
            
		return cases;
	}

	public static List<CCRecordTypes__c> createCCRecordTypes() {
		List<CCRecordTypes__c> ccrTypes = new List<CCRecordTypes__c>();
        List<String> names = new List<String>{'New Payer Request','Community Support','Payer Review','Payer Support','Change Request',
            'Test Issue','Provider Customer Support','Finance'};
        List<RecordType> types = [SELECT Id, Name FROM RecordType WHERE Name IN :names];
        Map<String,Id> rtMap = new Map<String,Id>();
        for(RecordType rt : types) {
        	rtMap.put(rt.Name,rt.Id);
        }
/*
        RecordType newpayerrequestRT = [SELECT Id, Name FROM RecordType WHERE Name = 'New Payer Request' LIMIT 1];
        RecordType customersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Community Support' LIMIT 1];
        RecordType payerreviewRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Review' LIMIT 1];
        RecordType payersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Support' LIMIT 1];
        RecordType changerequestRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Change Request' LIMIT 1];
*/
        CCRecordTypes__c ccRT = new CCRecordTypes__c();
        ccRt.Name = 'Community Support';
//        ccRt.RecordTypeId__c = customersupportRT.Id;
        ccRt.RecordTypeId__c = rtMap.get('Community Support');
        ccRt.RecordTypeName__c = 'Community Support';
        ccRt.NewPage__c = 'CCCase';
        ccRT.DetailPage__c = 'CCCaseDetail';
        ccRT.RecordTypeDescription__c = 'Community Support';
        ccrTypes.add(ccRt);
        ccRT = new CCRecordTypes__c();
        ccRt.Name = 'New Payer Request';
//        ccRt.RecordTypeId__c = newpayerrequestRT.Id;
        ccRt.RecordTypeId__c = rtMap.get('New Payer Request');
        ccRt.RecordTypeName__c = 'Add a Payer';
        ccRt.NewPage__c = 'CCNewPayerRequest';
        ccRT.DetailPage__c = 'CCNewPayerRequestDetail';
        ccRT.RecordTypeDescription__c = 'New Payer Request';
        ccrTypes.add(ccRt);

        ccRT = new CCRecordTypes__c();
        ccRt.Name = 'Payer Review';
//        ccRt.RecordTypeId__c = payerreviewRT.Id;
        ccRt.RecordTypeId__c = rtMap.get('Payer Review');
        ccRt.RecordTypeName__c = 'Payer Review';
        ccRt.NewPage__c = '';
        ccRT.DetailPage__c = '';
        ccRT.RecordTypeDescription__c = 'Review Payer Issues';
        ccrTypes.add(ccRt);

        ccRT = new CCRecordTypes__c();
        ccRt.Name = 'Payer Support';
//        ccRt.RecordTypeId__c = payersupportRT.Id;
        ccRt.RecordTypeId__c = rtMap.get('Payer Support');
        ccRt.RecordTypeName__c = 'Payer Support';
        ccRt.NewPage__c = '';
        ccRT.DetailPage__c = '';
        ccRT.RecordTypeDescription__c = 'Payer Support - Account Management';
        ccrTypes.add(ccRt);

        ccRT = new CCRecordTypes__c();
        ccRt.Name = 'Change Request';
//        ccRt.RecordTypeId__c = changerequestRT.Id;
        ccRt.RecordTypeId__c = rtMap.get('Change Request');
        ccRt.RecordTypeName__c = 'Change Request';
        ccRt.NewPage__c = '';
        ccRT.DetailPage__c = '';
        ccRT.RecordTypeDescription__c = 'Change Request Tickets';
        ccrTypes.add(ccRt);
		
        ccRT = new CCRecordTypes__c();
        ccRt.Name = 'Test Issue';
        ccRt.RecordTypeId__c = rtMap.get('Test Issue');
        ccRt.RecordTypeName__c = 'Test Issue';
        ccRt.NewPage__c = '';
        ccRT.DetailPage__c = '';
        ccRT.RecordTypeDescription__c = 'Test Issue Tickets';
        ccrTypes.add(ccRt);

        ccRT = new CCRecordTypes__c();
        ccRt.Name = 'Provider Customer Support';
        ccRt.RecordTypeId__c = rtMap.get('Provider Customer Support');
        ccRt.RecordTypeName__c = 'Provider Customer Support';
        ccRt.NewPage__c = '';
        ccRT.DetailPage__c = '';
        ccRT.RecordTypeDescription__c = 'Provider Customer Support Tickets';
        ccrTypes.add(ccRt);

        ccRT = new CCRecordTypes__c();
        ccRt.Name = 'Finance';
        ccRt.RecordTypeId__c = rtMap.get('Finance');
        ccRt.RecordTypeName__c = 'Finance';
        ccRt.NewPage__c = '';
        ccRT.DetailPage__c = '';
        ccRT.RecordTypeDescription__c = 'Billing Support Tickets';
        ccrTypes.add(ccRt);

		insert ccrTypes;
		
        return ccrTypes;
	}

	public static List<CC_App_Settings__c> createCCAppSettings() {
		List<CC_App_Settings__c> ccaSettings = new List<CC_App_Settings__c>();
        Profile userProfile = [select Id from Profile where Name='Community User'];
        Profile providerProfile = [select Id from Profile where Name='Community Provider'];
        Profile payerProfile = [select Id from Profile where Name='Community Payer'];
        Profile projectProfile = [select Id from Profile where Name='Community Project Support'];
        List<String> names = new List<String>{'New Payer Request','Community Support','Payer Review','Payer Support',
            'Change Request','Test Issue','Provider Customer Support','Finance'};
        List<RecordType> types = [SELECT Id, Name FROM RecordType WHERE Name IN :names];
        Map<String,Id> rtMap = new Map<String,Id>();
        for(RecordType rt : types) {
        	rtMap.put(rt.Name,rt.Id);
        }
/*
        RecordType newpayerrequestRT = [SELECT Id, Name FROM RecordType WHERE Name = 'New Payer Request' LIMIT 1];
        RecordType customersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Community Support' LIMIT 1];
        RecordType payerreviewRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Review' LIMIT 1];
        RecordType payersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Support' LIMIT 1];
        RecordType changerequestRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Change Request' LIMIT 1];
*/

		// Default setting
        CC_App_Settings__c ccAS = new CC_App_Settings__c();
        ccAs.SetupOwnerId = UserInfo.getOrganizationId();
		ccAS.LOB__c = '';
        ccaSettings.add(ccAS);

        ccAS = new CC_App_Settings__c();
        ccAS.SetupOwnerId = payerProfile.Id;
        ccAS.CaseCreatePage__c = '';
        ccAS.HomePage__c = '';
		ccAS.LOB__c = '';
//        ccAS.Customer_Support_Case_Types__c = customersupportRT.Id + ',' + newpayerrequestRT.Id;
//        ccAS.Payer_Review_Case_Types__c = payerreviewRT.Id;
//        ccAS.Payer_Support_Case_Types__c = payersupportRT.Id;
//        ccAS.Change_Request_Case_Types__c = changerequestRT.Id;
        ccAS.Customer_Support_Case_Types__c = rtMap.get('Community Support') + ',' + rtMap.get('New Payer Request');
        ccAS.Payer_Review_Case_Types__c = rtMap.get('Payer Review');
        ccAS.Payer_Support_Case_Types__c = rtMap.get('Payer Support');
        ccAS.Change_Request_Case_Types__c = rtMap.get('Change Request');
        ccAS.Test_Issue_Case_Types__c = '';
        ccAS.Billing_Support_Case_Types__c = '';
        ccaSettings.add(ccAS);

        ccAS = new CC_App_Settings__c();
        ccAS.SetupOwnerId = userProfile.Id;
        ccAS.CaseCreatePage__c = 'CCCase';
        ccAS.HomePage__c = 'CCListCase';
		ccAS.LOB__c = 'AAC';
//        ccAS.Customer_Support_Case_Types__c = customersupportRT.Id + ',' + newpayerrequestRT.Id;
        ccAS.Customer_Support_Case_Types__c = rtMap.get('Community Support') + ',' + rtMap.get('New Payer Request');
        ccAS.Payer_Review_Case_Types__c = '';
        ccAS.Payer_Support_Case_Types__c = '';
        ccAS.Change_Request_Case_Types__c = '';
        ccAS.Test_Issue_Case_Types__c = '';
        ccAS.Billing_Support_Case_Types__c = rtMap.get('Finance');
        ccaSettings.add(ccAS);

        ccAS = new CC_App_Settings__c();
        ccAS.SetupOwnerId = projectProfile.Id;
        ccAS.CaseCreatePage__c = '';
        ccAS.HomePage__c = '';
		ccAS.LOB__c = '';
//        ccAS.Customer_Support_Case_Types__c = customersupportRT.Id + ',' + newpayerrequestRT.Id;
        ccAS.Customer_Support_Case_Types__c = '';
        ccAS.Payer_Review_Case_Types__c = '';
        ccAS.Payer_Support_Case_Types__c = '';
        ccAS.Change_Request_Case_Types__c = '';
        ccAS.Test_Issue_Case_Types__c = rtMap.get('Test Issue');
        ccAS.Billing_Support_Case_Types__c = '';
        ccaSettings.add(ccAS);

        ccAS = new CC_App_Settings__c();
        ccAS.SetupOwnerId = providerProfile.Id;
        ccAS.CaseCreatePage__c = '';
        ccAS.HomePage__c = '';
		ccAS.LOB__c = 'Provider';
//        ccAS.Customer_Support_Case_Types__c = customersupportRT.Id + ',' + newpayerrequestRT.Id;
        ccAS.Customer_Support_Case_Types__c = rtMap.get('Provider Customer Support');
        ccAS.Payer_Review_Case_Types__c = '';
        ccAS.Payer_Support_Case_Types__c = '';
        ccAS.Change_Request_Case_Types__c = '';
        ccAS.Test_Issue_Case_Types__c = '';
        ccAS.Billing_Support_Case_Types__c = rtMap.get('Finance');
        ccaSettings.add(ccAS);

        insert ccaSettings;

        return ccaSettings;
	}

    public static void createCaseDependentPickListRecords() {
        RecordType customersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Community Support' LIMIT 1];
        RecordType payersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Support' LIMIT 1];
        Case_Reason__c cr = new Case_Reason__c();
        cr.Record_Type_Id__c = customersupportRT.Id;
        cr.Record_Type_Name__c = customersupportRT.Name;
        cr.Name = 'Claims';
        insert cr;

		Case_Brief_Description__c bd = new Case_Brief_Description__c();
        bd.Record_Type_Id__c = customersupportRT.Id;
        bd.Record_Type_Name__c = customersupportRT.Name;
        bd.Name = 'EOB';
        bd.Case_Reason__c = cr.Id;
        insert bd;
        
		Case_Brief_Description_Detail__c bdd = new Case_Brief_Description_Detail__c();
        bdd.Record_Type_Id__c = customersupportRT.Id;
        bdd.Record_Type_Name__c = customersupportRT.Name;
        bdd.Name = 'Denial';
        bdd.Case_Brief_Description__c = bd.Id;
        insert bdd;
        
		Case_Submission_Method__c sm = new Case_Submission_Method__c();
        sm.Record_Type_Id__c = customersupportRT.Id;
        sm.Record_Type_Name__c = customersupportRT.Name;
        sm.Name = 'B2B';
        sm.Case_Reason__c = cr.Id;
        insert sm;
    }
    
    public static void createPayerSupportDependentPickListRecords() {
        RecordType payersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Payer Support' LIMIT 1];
        Case_Reason__c cr = new Case_Reason__c();
        cr.Record_Type_Id__c = payersupportRT.Id;
        cr.Record_Type_Name__c = payersupportRT.Name;
        cr.Name = 'Other';
        insert cr;

		Case_Brief_Description__c bd = new Case_Brief_Description__c();
        bd.Record_Type_Id__c = payersupportRT.Id;
        bd.Record_Type_Name__c = payersupportRT.Name;
        bd.Name = 'Other';
        bd.Case_Reason__c = cr.Id;
        insert bd;
        
		Case_Brief_Description_Detail__c bdd = new Case_Brief_Description_Detail__c();
        bdd.Record_Type_Id__c = payersupportRT.Id;
        bdd.Record_Type_Name__c = payersupportRT.Name;
        bdd.Name = 'Other';
        bdd.Case_Brief_Description__c = bd.Id;
        insert bdd;
        
		Case_Submission_Method__c sm = new Case_Submission_Method__c();
        sm.Record_Type_Id__c = payersupportRT.Id;
        sm.Record_Type_Name__c = payersupportRT.Name;
        sm.Name = 'Other';
        sm.Case_Reason__c = cr.Id;
        insert sm;
    }
    
    public static void createAttachment(Id id) {
        Attachment attachment = new Attachment();
        attachment.Name='Test Attachment';
        Blob bodyBlob=Blob.valueOf('Test Attachment Body');
        attachment.body=bodyBlob;
        attachment.parentId=id;
        insert attachment;

        Blob cvBlob=Blob.valueOf('Test Attachment Body');
		ContentVersion cVersion =new ContentVersion();
		cVersion.Title ='Test Attachment';
		cVersion.VersionData=cvBlob;
		cVersion.PathOnClient='/' + 'Test Attachment';
		insert cVersion;

		cVersion = [select Id, ContentDocumentId, Title, VersionData, PathOnClient from ContentVersion WHERE Id =: cVersion.Id];
		ContentDocumentLink cl = new ContentDocumentLink();
		cl.ContentDocumentId = cVersion.ContentDocumentId;
		cl.LinkedEntityId = id;
		cl.ShareType = 'V'; // or 'I'? 
		cl.Visibility = 'AllUsers';
		insert cl;
    }
    
    public static void createKnowledgeArticleRecords() {
		List<Id> kavIds = new List<Id>();
		for(String objType : kavNames) {
			SObject kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
			kavObj.put('Title','Test Article!!!'+String.valueOf(Crypto.getRandomInteger()));
			kavObj.put('UrlName', 'Test-Article'+String.valueOf(Crypto.getRandomInteger()));
			kavObj.put('Summary', 'This is a summary!!!');
			kavObj.put('Language', 'en_US');
			insert kavObj;
			// Publish Article
			kavIds.add((Id)kavObj.get('Id'));
			String q = 'select KnowledgeArticleId, PublishStatus from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' ';
			kavObj = (KnowledgeArticleVersion)Database.query(q);
			String articleId = (String)kavObj.get('KnowledgeArticleId');
			KbManagement.PublishingService.publishArticle(articleId, true);
		}
    }
	public static Set<String> kavNames {
		set;
		get {
			if (kavNames == null) {
				kavNames = new Set<String>{'Known_Issue__kav',
					'FAQ__kav',
					'Agreements__kav',
					'EDI_Guidelines__kav',
					'News__kav',
					'Newsletter__kav',
					'Payer_Alert__kav',
					'Release_Communication__kav',
					'Tips_and_Guidelines__kav',
					'New_Administrator__kav',
					'New_User__kav',
					'Registration_and_Change_Form__kav'};
/*
				kavNames = new Set<String>();
				Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
				for (String s : gd.keySet()) {
					if (s.contains('__kav')) {
						kavNames.add(s);
					}
				}
*/
			}
			return kavNames;
		}
	}
}