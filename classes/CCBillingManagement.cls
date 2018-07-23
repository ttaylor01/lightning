public with sharing class CCBillingManagement {
	private static final String DEBUG_STR = 'CCBillingManagement';

	@AuraEnabled
	public static CCBillingManagementWrapper getBillingManagementWrapper(String recordId) {
		return getBillingManagementWrapper(recordId,'all');
	}

	@AuraEnabled
	public static CCBillingManagementWrapper getBillingManagementWrapper(String recordId, String listView) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getBillingManagementWrapper] ';
		system.debug(FUNC_STR+'recordId: ' + recordId);
		system.debug(FUNC_STR+'listView: ' + listView);
		CCBillingManagementWrapper wrapper = new CCBillingManagementWrapper();
		
        Zuora.zApi zApiInstance = CCZUtility.zlogin();

		// Need to obtain the payment methods defined for the billing account
        String queryStr = 'SELECT Id, CreditCardMaskNumber, CreditCardType, CreditCardHolderName, PaymentMethodStatus, ' +
            'AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName, Type, ' +
            'CreditCardAddress1, CreditCardAddress2, CreditCardCity, CreditCardCountry, CreditCardExpirationMonth, ' +
            'CreditCardExpirationYear, CreditCardPostalCode, CreditCardState ' + 
            'FROM PaymentMethod WHERE AccountId = \'' + recordId + '\'';
        List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
        Map<String,Zuora__PaymentMethod__c> paymentMethods = new Map<String, Zuora__PaymentMethod__c>();
        // Place Credit Card methods first
        for(Zuora.zObject pm : pms) {
            if(('CreditCard').equals((String)pm.getValue('Type'))) {
                Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
                paymentMethod.Zuora__Type__c = (String)pm.getValue('Type');
                paymentMethod.Zuora__CreditCardMaskNumber__c = (String)pm.getValue('CreditCardMaskNumber');
                paymentMethod.Zuora__CreditCardHolderName__c = (String)pm.getValue('CreditCardHolderName');
                paymentMethod.Zuora__CreditCardType__c = (String)pm.getValue('CreditCardType');
                paymentMethod.Zuora__CreditCardAddress1__c = (String)pm.getValue('CreditCardAddress1');
                paymentMethod.Zuora__CreditCardAddress2__c = (String)pm.getValue('CreditCardAddress2');
                paymentMethod.Zuora__CreditCardCity__c = (String)pm.getValue('CreditCardCity');
                paymentMethod.Zuora__CreditCardCountry__c = (String)pm.getValue('CreditCardCountry');
                paymentMethod.Zuora__CreditCardExpirationMonth__c = String.valueOf(pm.getValue('CreditCardExpirationMonth'));
                paymentMethod.Zuora__CreditCardExpirationYear__c = String.valueOf(pm.getValue('CreditCardExpirationYear'));
                paymentMethod.Zuora__CreditCardPostalCode__c = (String)pm.getValue('CreditCardPostalCode');
                paymentMethod.Zuora__CreditCardState__c = (String)pm.getValue('CreditCardState');
                paymentMethod.Zuora__External_Id__c = (String)pm.getValue('Id');
                paymentMethods.put(paymentMethod.Zuora__External_Id__c,paymentMethod);
            }
        }
        // Then place ACH methods
        for(Zuora.zObject pm : pms) {
            if(('ACH').equals((String)pm.getValue('Type'))) {
                Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
                paymentMethod.Zuora__Type__c = (String)pm.getValue('Type');
                paymentMethod.Zuora__AchAbaCode__c = (String)pm.getValue('AchAbaCode');
                paymentMethod.Zuora__AchAccountName__c = (String)pm.getValue('AchAccountName');
                paymentMethod.Zuora__AchAccountNumberMask__c = (String)pm.getValue('AchAccountNumberMask');
                paymentMethod.Zuora__AchAccountType__c = (String)pm.getValue('AchAccountType');
                paymentMethod.Zuora__AchBankName__c = (String)pm.getValue('AchBankName');
                paymentMethod.Zuora__External_Id__c = (String)pm.getValue('Id');
                paymentMethods.put(paymentMethod.Zuora__External_Id__c,paymentMethod);
            }
        }
        wrapper.paymentMethods = paymentMethods;

		// Need to obtain the default payment method of billing account object.
		// Could be set to default, non electronic method,
		// So compare to CC and ACH payment methods defined for billing account and set accordingly
		queryStr = 'SELECT Id, DefaultPaymentMethodId, PaymentGateway ' +
			'FROM Account WHERE Id = \'' + recordId + '\'';
		List<Zuora.zObject> accounts = CCZUtility.zquery(zApiInstance, queryStr, 'Account');
		system.debug(FUNC_STR+'Accounts: ' + accounts);
		String pmId = '';
		for(Zuora.zObject a : accounts) {
			pmId = (String)a.getValue('DefaultPaymentMethodId');
		}
		Zuora__PaymentMethod__c defaultPaymentMethod;
		if(String.isNotBlank(pmId)) {
			defaultPaymentMethod = paymentMethods.get(pmId);
		}
		if(defaultPaymentMethod != null) {
			wrapper.paymentMethodId = defaultPaymentMethod.Zuora__External_Id__c;
		}

		// Need to get all the invoices posted for the billing account
		wrapper.invoices = getInvoices(recordId,listView);

		return wrapper;
	}
	 
	@AuraEnabled
	public static List<CCInvoiceWrapper> getInvoices(String recordId) {
		return getInvoices(recordId,'all');
	}

	@AuraEnabled
	public static List<CCInvoiceWrapper> getInvoices(String recordId, String listView) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getInvoices] ';
		system.debug(FUNC_STR+'listView: ' + listView);
		List<CCInvoiceWrapper> invoiceList = new List<CCInvoiceWrapper>();

		try {
			system.debug(FUNC_STR+'\n=========\nrecordId: '+ recordId);
			system.debug(FUNC_STR+'\n=========\nlistView: '+ listView);

            Zuora.zApi zApiInstance = CCZUtility.zlogin();
            String zuoraDateTime = Zuora.zUtil.getZuoraDate(System.now());
            system.debug(FUNC_STR+'\n=========\nCurrent zuoraDateTime: ' + zuoraDateTime);
            String queryStr = 'SELECT Id, AccountId, Amount, Balance, DueDate, InvoiceDate, InvoiceNumber, PaymentAmount, ' +
                'Status, TaxAmount, LastEmailSentDate ' +
                'FROM Invoice WHERE AccountId = \'' + recordId + '\' AND Status = \'Posted\' ';
//              'FROM Invoice WHERE AccountId = \'' + recordId + '\' AND Status = \'Posted\' ' +
//              'AND LastEmailSentDate != null AND LastEmailSentDate < \'' + zuoraDateTime + '\'';
			if(String.isNotBlank(listView)) {
				if(listView.equals('unpaid')) {
					queryStr += 'AND Balance > 0.0 ';
				} else if(listView.equals('paid')) {
					queryStr += 'ANd Balance = 0.0 ';
				}
			}

            List<Zuora.zObject> objs = CCZUtility.zquery(zApiInstance, queryStr, 'Invoice');
            system.debug(FUNC_STR+'\n=========\nInvoices: ' + objs);
            for(Zuora.zObject obj : objs) {
                Zuora__ZInvoice__c i = new Zuora__ZInvoice__c();
                i.Zuora__Zuora_Id__c = (String)obj.getValue('Id');
//                i.Zuora__BillingAccount__c = '';
                i.Zuora__Balance2__c  = (decimal)obj.getValue('Balance');
                i.Zuora__PaymentAmount__c  = (decimal)obj.getValue('PaymentAmount');
                i.Zuora__TotalAmount__c  = (decimal)obj.getValue('Amount');
                i.Zuora__TaxAmount__c  = (decimal)obj.getValue('TaxAmount');
                i.Name = (String)obj.getValue('InvoiceNumber');
                i.Zuora__Status__c = (String)obj.getValue('Status');
                i.Zuora__InvoiceDate__c = (Date)obj.getValue('InvoiceDate');
                i.Zuora__DueDate__c = (Date)obj.getValue('DueDate');
                invoiceList.add(new CCInvoiceWrapper(i));
//                system.debug(FUNC_STR+'\n=========\nLastEmailSentDate: ' + i.Name + ' : ' + Date.valueOf((DateTime)obj.getValue('LastEmailSentDate')));
            }

		} catch (Exception ex) {
			system.debug(FUNC_STR+'\n=========\nException catch block: '+ex.getMessage());
			throw getAuraException('Exception: ---- ' + ex.getMessage());
		}
		invoiceList.sort();
		return invoiceList;
	}

	@AuraEnabled
    public static List<Zuora__Payment__c> getPayments(String recordId) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getPayments] ';
        List<Zuora__Payment__c> paymentList = new List<Zuora__Payment__c>();
		system.debug(FUNC_STR+'\n=========\nrecordId: '+ recordId);
		
		try {
			Zuora__CustomerAccount__c acc = [SELECT Id, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = :recordId LIMIT 1];
	        for(Zuora__Payment__c p : Database.query(
	            'SELECT Id, Zuora__Account__c, Zuora__Amount__c, Zuora__InvoiceNumber__c, Name, Zuora__EffectiveDate__c, Zuora__Status__c, Zuora__PaymentMethod__c ' +
	            'FROM Zuora__Payment__c ' +
	            'WHERE Zuora__BillingAccount__c = \'' + acc.Id + '\' ' +
	            'ORDER BY Zuora__EffectiveDate__c DESC'
	        )) {
	            paymentList.add(p);
	        }
		} catch (Exception ex) {
			system.debug(FUNC_STR+'\n=========\nException catch block: '+ex.getMessage());
			throw getAuraException('Exception: ---- ' + ex.getMessage());
		}
        return paymentList;
    }
    
	@AuraEnabled
	public static CCBillingManagementWrapper savePayments(String recordId, String jsonObject, String paymentMethodId) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.savePayments] ';
		system.debug(FUNC_STR+'RecordId: '+recordId);
		system.debug(FUNC_STR+'paymentMethodId: '+paymentMethodId);
		system.debug(FUNC_STR+'jsonObject: '+jsonObject);
		List<Object> ListObj = (List<Object>) JSON.deserializeUntyped(jsonObject);
		system.debug(FUNC_STR+'deserializeUntyped List<Object>: '+ListObj);
		List<CCInvoiceWrapper> invoicePayments = new List<CCInvoiceWrapper>();
		for(Object obj : ListObj) {
			CCInvoiceWrapper iw = (CCInvoiceWrapper)JSON.deserialize(JSON.serialize(obj),CCInvoiceWrapper.class);
			invoicePayments.add(iw);
		}
		system.debug(FUNC_STR+'invoicePayments: '+invoicePayments);

//		CCBillingManagementWrapper bw = (CCBillingManagementWrapper)JSON.deserialize(jsonObject, CCBillingManagementWrapper.class);
//		system.debug(FUNC_STR+'CCBillingManagementWrapper: '+bw);

		boolean validInput = true;
		decimal totalAmount = 0.0;
		String errorMsg = '';
		for(CCInvoiceWrapper i : invoicePayments) {
			system.debug(FUNC_STR+'inputPaymentAmount: '+i.inputPaymentAmount);
//			system.debug(FUNC_STR+'internalPaymentAmount: '+i.internalPaymentAmount);
			if(i.inputPaymentAmount != null && i.inputPaymentAmount != 0 ) {
				if(i.inputPaymentAmount > i.invoice.Zuora__Balance2__c) {
					errorMsg = 'Amount of payment for one or more of the Invoices cannot exceed remaining invoice balance.  ';
					validInput = false;
				}
				totalAmount += i.inputPaymentAmount;
			}
		}
		system.debug(FUNC_STR+'\n=========\ntotalAmount: ' + totalAmount);
		if(String.isBlank(paymentMethodId) || totalAmount == 0 ) {
			errorMsg += 'You must enter an Amount and select a Payment Option to apply a payment.  ';
			validInput = false;
		}

		if(!validInput) throw getAuraException(errorMsg);

        try {
            Zuora.zApi zApiInstance = CCZUtility.zlogin();

			String queryStr = 'SELECT Id, Type ' +
				'FROM PaymentMethod WHERE Id = \'' + paymentMethodId + '\'';
			List<Zuora.zObject> pms = CCZUtility.zquery(zApiInstance, queryStr, 'PaymentMethod');
			String paymentMethodType = '';
			// Place Credit Card methods first
			for(Zuora.zObject pm : pms) {
				paymentMethodType = (String)pm.getValue('Type');
			}
			system.debug(FUNC_STR+'paymentMethodType: '+paymentMethodType);

            List<Zuora.zObject> objs = new List<Zuora.zObject>();
            DateTime dt = Date.today();
            String zuoraDate = dt.format('yyyy-MM-dd','EDT');
            for(CCInvoiceWrapper i : invoicePayments) {
            	decimal amt = i.inputPaymentAmount.setScale(2, System.RoundingMode.HALF_UP);
                Zuora.zObject payment = new Zuora.zObject('Payment');
                payment.setValue('AccountId', recordId);
                payment.setValue('InvoiceId', i.invoice.Zuora__Zuora_Id__c);
                payment.setValue('AppliedInvoiceAmount', amt);      // The amount of the payment to apply to an invoice.
                payment.setValue('Amount', amt);                    // Amount of payment
//                payment.setValue('AppliedInvoiceAmount', i.internalPaymentAmount);      // The amount of the payment to apply to an invoice.
//                payment.setValue('Amount', i.internalPaymentAmount);                    // Amount of payment
                /*
                payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateOnly(Date.today()));  // yyyy-MM-dd format only
                 * Zuora.zUtil.getZuoraDateOnly(Date.today()) is not visible for compilation.
                 * I've had this issue before with zuora methods.
                 * Must manipulate manually to get correct format.
                 */
                payment.setValue('EffectiveDate', zuoraDate);   // yyyy-MM-dd format only
                payment.setValue('PaymentMethodId', paymentMethodId);
                payment.setValue('Status', 'Processed');
                payment.setValue('Gateway', getPaymentGateway(paymentMethodType));
                payment.setValue('Type', 'Electronic');
                objs.add(payment);
                system.debug(FUNC_STR+'\n=========\nZuora.zObject to create: ' + payment);
            }

			List<Zuora.zApi.SaveResult> results = CCZUtility.zcreate(zApiInstance,objs);
			for (Zuora.zApi.SaveResult result : results) {
				if (result.Success) {
					CCZUtility.zsync(zApiInstance,recordId);
				} else {
					throw getAuraException('Error applying Payment:  \n' + result.errors);
				}
            }
        } catch (Exception ex) {
            system.debug(FUNC_STR+' \n=========\n Error from CCZUtility.zcreate: '+ex.getMessage());
			throw getAuraException(ex.getMessage());
        }

		return getBillingManagementWrapper(recordId);
	}

	@AuraEnabled
	public static String getInvoicePDF(String recordId) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getInvoicePDF] ';
		system.debug(FUNC_STR+'RecordId: '+recordId);

		String documentId;

		try {
			String base64Data;
			// Get latest invoice pdf (Body field contains the base64 encoded string for pdf file)
	        String queryStr = 'SELECT Id, Body, InvoiceDate, InvoiceNumber ' +
	            'FROM Invoice WHERE Id = \'' + recordId + '\'';
	        Zuora.zApi zApiInstance = CCZUtility.zlogin();
	        List<Zuora.zObject> objs = CCZUtility.zquery(zApiInstance, queryStr, 'Invoice');
	        system.debug(FUNC_STR+'\n=========\nInvoice: ' + objs);
	        for(Zuora.zObject obj : objs) {
	            base64Data = (String)obj.getValue('Body');
	        }
	        system.debug(FUNC_STR+'\n=========\nbase64Data: ' + base64Data);
	
			documentId = getPDFFile(recordId,base64Data);
        } catch (Exception ex) {
            system.debug(FUNC_STR+' \n=========\n Error getting Invoice PDF: '+ex.getMessage());
			Logger.log(DEBUG_STR,'getInvoicePDF',null,recordId,ex);
			throw getAuraException('Unable to obtain Invoice PDF');
        }

        return documentId;
	}
	
	private static String getPDFFile(String invoiceId, String base64Data) {
    	final String FUNC_STR = '[' + DEBUG_STR + '.getPDFFile] ';
    	// get linked invoice
        Zuora__ZInvoice__c invoice = [SELECT Id, Name, Zuora__Zuora_Id__c
            FROM Zuora__ZInvoice__c
            WHERE Zuora__Zuora_Id__c = :invoiceId
            LIMIT 1];
		System.debug(FUNC_STR+'\n=========\nInvoice: ' + invoice);

		String fileName = invoice.Name + '.pdf';
		System.debug(FUNC_STR+'\n=========\nfileName: ' + fileName);
		// get existing invoice pdf file based on linked invoice and file name
		List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
		cdls = [
			SELECT 
				ContentDocument.Id, 
				ContentDocument.LatestPublishedVersionId, 
				ContentDocument.PublishStatus, 
				ContentDocument.title, 
				Visibility, ShareType 
			FROM ContentDocumentLink WHERE LinkedEntityId =	:invoice.Id AND ContentDocument.title = :fileName
		];
		System.debug(FUNC_STR+'\n=========\nContentDocumentLinks: ' + cdls);

		// If document exists, delete
		if(!cdls.isEmpty()) {
			delete new ContentDocument(Id=cdls[0].ContentDocument.Id);
		}
		// Create new document with updated pdf content
		ContentVersion cVersion=new ContentVersion();
		cVersion.Title=fileName;
		cVersion.VersionData=EncodingUtil.base64Decode(base64Data);
		cVersion.PathOnClient='/' + fileName;
		//
		// "Setting FirstPublishLocationId allows you to create a file and share it with an initial 
		// record/group in a single transaction"
		// ContentDocumentLink will create automatically by Salesforce
		//
		cVersion.FirstPublishLocationId = invoice.Id;
		insert cVersion;
		System.debug(FUNC_STR+'\n=========\nContentVersion created: ' + cVersion);
		return cVersion.Id;
	}
	
    private static String getPaymentGateway(String paymentMethodType) {
        String gateway = '';
        if(paymentMethodType.equals('CreditCard')) {
        	gateway = App_Settings__c.getInstance(UserInfo.getProfileId()).CreditCardGateway__c;
        } else {
        	gateway = App_Settings__c.getInstance(UserInfo.getProfileId()).ACHGateway__c;
        }
        return gateway;
    }

	private static AuraHandledException getAuraException(String msg) {
		AuraHandledException e = new AuraHandledException(msg);
		e.setMessage(msg);
		return e;
	}
}