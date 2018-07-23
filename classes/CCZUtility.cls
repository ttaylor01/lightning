public with sharing class CCZUtility {

	private static List<Zuora.zObject> getTestObjects(String name) {
		List<Zuora.zObject> objs = new List<Zuora.zObject>();
		if(name.equals('Account')) {
			Zuora.zObject obj = new Zuora.zObject(name);
			obj.setValue('Id','AccountId');
			obj.setValue('Balance',100.00);
			obj.setValue('BillToId','BillToId');
			obj.setValue('SoldToId', 'SoldToId');
			obj.setValue('DefaultPaymentMethodId','CreditCardId');
			obj.setValue('Name','Community Test');
			obj.setValue('AutoPay',false);
			objs.add(obj);
		} else if(name.equals('Contact')) {
			Zuora.zObject obj = new Zuora.zObject(name);
			obj.setValue('Id','BillToId');
			obj.setValue('FirstName','Test');
			obj.setValue('LastName','Test');
			obj.setValue('WorkPhone','9045551234');
			obj.setValue('WorkEmail','bill.to@test.com');
			objs.add(obj);
			obj = new Zuora.zObject(name);
			obj.setValue('Id','SoldToId');
			obj.setValue('LastName','Test');
			obj.setValue('WorkPhone','abc');
			obj.setValue('WorkEmail','sold.to@bademail');
			objs.add(obj);
		} else if(name.equals('PaymentMethod')) {
			Zuora.zObject obj = new Zuora.zObject(name);
			obj.setValue('Id','CreditCardId');
			obj.setValue('Type','CreditCard');
			obj.setValue('CreditCardMaskNumber','************1234');
			obj.setValue('CreditCardType','Visa');
			obj.setValue('CreditCardExpirationMonth',01);
			obj.setValue('CreditCardExpirationYear',2099);
			obj.setValue('CreditCardSecurityCode','123');
			obj.setValue('CreditCardHolderName','Test Holder');
			obj.setValue('CreditCardCountry','US');
			obj.setValue('AccountId','AccountId');
			objs.add(obj);
			obj = new Zuora.zObject(name);
			obj.setValue('Id','ACHId');
			obj.setValue('Type','ACH');
			obj.setValue('AchAbaCode','111111111');
			obj.setValue('AchAccountName','TestAccount');
			obj.setValue('AchAccountNumberMask','************1234');
			obj.setValue('AchAccountType','Checking');
			obj.setValue('AchBankName','TestBank');
			obj.setValue('AccountId','AccountId');
			objs.add(obj);
		} else if(name.equals('Invoice')) {
			Zuora.zObject obj = new Zuora.zObject(name);
			obj.setValue('Id','InvoiceId');
			obj.setValue('AccountId','AccountId');
			obj.setValue('Amount',1000.00);
			obj.setValue('Balance',100.00);
			obj.setValue('DueDate',Date.today());
			obj.setValue('InvoiceDate',Date.today());
			obj.setValue('InvoiceNumber','INV0000001');
			obj.setValue('Status','Processed');
			obj.setValue('TaxAmount',0.00);
			obj.setValue('Body','base64Data');
			objs.add(obj);
			obj = new Zuora.zObject(name);
			obj.setValue('Id','InvoiceId2');
			obj.setValue('AccountId','AccountId');
			obj.setValue('Amount',1000.00);
			obj.setValue('Balance',100.00);
			obj.setValue('DueDate',Date.today());
			obj.setValue('InvoiceDate',Date.today());
			obj.setValue('InvoiceNumber','INV0000001');
			obj.setValue('Status','Processed');
			obj.setValue('TaxAmount',0.00);
			obj.setValue('Body','base64Data');
			objs.add(obj);
		} else if(name.equals('InvoiceItem')) {
			Zuora.zObject obj = new Zuora.zObject(name);
			obj.setValue('Id','InvoiceItemId');
			obj.setValue('InvoiceId','InvoiceId');
			obj.setValue('RatePlanChargeId','RatePlanChargeId');
			obj.setValue('ChargeAmount',100.00);
			obj.setValue('UnitPrice',10.00);
			obj.setValue('ServiceEndDate',Date.today());
			obj.setValue('ServiceStartDate',Date.today());
			obj.setValue('Quantity',10);
			obj.setValue('TaxAmount',0.00);
			objs.add(obj);
		} else if(name.equals('RatePlanCharge')) {
			Zuora.zObject obj = new Zuora.zObject(name);
			obj.setValue('Id','InvoiceItemId');
			obj.setValue('Name','RatePlanChargeName');
			objs.add(obj);
		}
		
		return objs;
	}
	public static Zuora.zApi zlogin() {
		try {
			Zuora.zApi zApiInstance = new Zuora.zApi();
			Zuora.zApi.LoginResult loginResult;
			if(!Test.isRunningTest()) {
				loginResult = zApiInstance.zlogin();
				system.debug('\n[DEBUG-CCZUtility.zLogin()]\n=========\nloginResult ServerUrl: ' + loginResult.ServerUrl);
				system.debug('\n[DEBUG-CCZUtility.zLogin()]\n=========\nloginResult Session: ' + loginResult.Session);
			}
			return zApiInstance;
/*
		} catch( Zuora.zForceException ex) {
			system.debug('\n[DEBUG-CCZUtility.zLogin()]\n=========\nzForceException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zAPIException ex) {
			system.debug('\n[DEBUG-CCZUtility.zLogin()]\n=========\nzAPIException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zRemoteException ex) {
			system.debug('\n[DEBUG-CCZUtility.zLogin()]\n=========\nzRemoteException catch block: '+ex.getMessage());
			throw ex;
*/
		} catch (Exception ex) {
			system.debug('\n[DEBUG-CCZUtility.zLogin()]\n=========\nException catch block: '+ex.getMessage());
			throw ex;
		}
	}

	public static void zsync(Zuora.zApi zApiInstance, String id) {
		List<Zuora.SyncResult> results;
		try {
			if(App_Settings__c.getInstance(UserInfo.getProfileId()).OnDemandSync__c) {
				Set<String> accountIds = new Set<String>();
				accountIds.add(id);
				Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
				syncManager.syncZuoraObjectIdSet = accountIds;
				syncManager.emailNotificationEnabled = false;
				if(!Test.isRunningTest()) {
					results = syncManager.sendRequest();
				}
			}
/*
		} catch( Zuora.OnDemandSyncManager.OnDemandSyncException ex ) {
			// just log and consume the exception.  The regularly scheduled sync will take over anyway.
			system.debug('\n[DEBUG-CCZUtility.zsync()]\n=========\nOnDemandSyncException catch block: '+ex.getMessage());
*/
		} catch (Exception ex) {
			// just log and consume the exception.  The regularly scheduled sync will take over anyway.
			system.debug('\n[DEBUG-CCZUtility.zsync()]\n=========\nException catch block: '+ex.getMessage());
		}
	}

	public static List<Zuora.zObject> zquery(Zuora.zApi zApiInstance, String query, String objName) {
		try {
			List<Zuora.zObject> objs;
			if(!Test.isRunningTest()) {
				objs = zApiInstance.zquery(query);
				system.debug('\n{DEBUG-CCZUtility.zquery]\n=========\nSOAP Request\n' + Zuora.zApi.currentLogger.request);
				system.debug('\n{DEBUG-CCZUtility.zquery]\n=========\nSOAP Response\n' + Zuora.zApi.currentLogger.response);
				system.debug('\n{DEBUG-CCZUtility.zquery]\n=========\nSOAP logger\n' + Zuora.zApi.currentLogger.toString());
			}
			else {
				system.debug('\n[DEBUG-CCZUtility.zquery]\n=========\nTEST RUN');
				objs = getTestObjects(objName);
			}
			return objs;
/*
		} catch( Zuora.zForceException ex) {
			system.debug('\n[DEBUG-CCZUtility.zquery()]\n=========\nzForceException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zAPIException ex) {
			system.debug('\n[DEBUG-CCZUtility.zquery()]\n=========\nzAPIException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zRemoteException ex) {
			system.debug('\n[DEBUG-CCZUtility.zquery()]\n=========\nzRemoteException catch block: '+ex.getMessage());
			throw ex;
*/
		} catch (Exception ex) {
			system.debug('\n[DEBUG-CCZUtility.zquery()]\n=========\nException catch block: '+ex.getMessage());
			throw ex;
		}
	}

	public static List<Zuora.zApi.SaveResult> zupdate(Zuora.zApi zApiInstance, List<Zuora.zObject> objs) {
		List<Zuora.zApi.SaveResult> results;
		try {
			if(!Test.isRunningTest()) {
				results = zApiInstance.zupdate(objs);
				system.debug('\n{DEBUG-CCZUtility.zupdate()] SOAP Request\n' + Zuora.zApi.currentLogger.request);
				system.debug('\n{DEBUG-CCZUtility.zupdate()] SOAP Response\n' + Zuora.zApi.currentLogger.response);
				system.debug('\n{DEBUG-CCZUtility.zupdate()] SOAP logger\n' + Zuora.zApi.currentLogger.toString());
			} else {
                system.debug('\n[DEBUG-CCZUtility.zupdate()] \n=========\nTEST RUN');
				results = new List<Zuora.zApi.SaveResult>();
				Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();
				result.Success = true;
				results.add(result);
			}
            system.debug('\n[DEBUG-CCZUtility.zupdate()] \n=========\nresults are: '+results);
			for (Zuora.zApi.SaveResult result : results) {
				if (!result.Success) {
                    system.debug('\n[DEBUG-CCZUtility.zupdate()] \n=========\nUPDATE NOT SUCCSSFUL!OBJECTS: '+objs+'\nERRORS: '+result.errors);
				}
			}
			return results;
/*
		} catch( Zuora.zForceException ex) {
			system.debug('\n[DEBUG-CCZUtility.zupdate()] \n=========\nzForceException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zAPIException ex) {
			system.debug('\n[DEBUG-CCZUtility.zupdate()] \n=========\nzAPIException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zRemoteException ex) {
			system.debug('\n[DEBUG-CCZUtility.zupdate()] \n=========\nzRemoteException catch block: '+ex.getMessage());
			throw ex;
*/
		} catch (Exception ex) {
            system.debug('\n[DEBUG-CCZUtility.zupdate()] \n=========\n catch block exception message:  '+ex.getMessage());
			throw ex;
		}
	}

	public static List<Zuora.zApi.SaveResult> zcreate(Zuora.zApi zApiInstance, List<Zuora.zObject> objs) {
		List<Zuora.zApi.SaveResult> results;
		try {
			if(!Test.isRunningTest()) {
				results = zApiInstance.zcreate(objs);
				system.debug('\n{DEBUG-CCZUtility.zcreate()] SOAP Request\n' + Zuora.zApi.currentLogger.request);
				system.debug('\n{DEBUG-CCZUtility.zcreate()] SOAP Response\n' + Zuora.zApi.currentLogger.response);
				system.debug('\n{DEBUG-CCZUtility.zcreate()] SOAP logger\n' + Zuora.zApi.currentLogger.toString());
			} else {
                system.debug('\n[DEBUG-CCZUtility.zcreate()] editBillingContact\n=========\nTEST RUN');
				results = new List<Zuora.zApi.SaveResult>();
				Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();
				result.Success = true;
				results.add(result);
			}
            system.debug('\n[DEBUG-CCZUtility.zcreate()] \n=========\nresults are: '+results);
			for (Zuora.zApi.SaveResult result : results) {
				if (!result.Success) {
                    system.debug('\n[DEBUG-CCZUtility.zcreate()] \n=========\nCREATE NOT SUCCSSFUL!OBJECTS: '+objs+'\nERRORS: '+result.errors);
				}
			}
			return results;
/*
		} catch( Zuora.zForceException ex) {
			system.debug('\n[DEBUG-CCZUtility.zcreate()] \n=========\nzForceException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zAPIException ex) {
			system.debug('\n[DEBUG-CCZUtility.zcreate()] \n=========\nzAPIException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zRemoteException ex) {
			system.debug('\n[DEBUG-CCZUtility.zcreate()] \n=========\nzRemoteException catch block: '+ex.getMessage());
			throw ex;
*/
		} catch (Exception ex) {
            system.debug('\n[DEBUG-CCZUtility.zcreate()] \n=========\n catch block exception message:  '+ex.getMessage());
			throw ex;
		}
	}

	public static List<Zuora.zApi.DeleteResult> zdelete(Zuora.zApi zApiInstance, List<String> ids, String obj) {
		List<Zuora.zApi.DeleteResult> results;
		try {
			if(!Test.isRunningTest()) {
				results = zApiInstance.zdelete(obj,ids);
				system.debug('\n{DEBUG-CCZUtility.zdelete()] SOAP Request\n' + Zuora.zApi.currentLogger.request);
				system.debug('\n{DEBUG-CCZUtility.zdelete()] SOAP Response\n' + Zuora.zApi.currentLogger.response);
				system.debug('\n{DEBUG-CCZUtility.zdelete()] SOAP logger\n' + Zuora.zApi.currentLogger.toString());
			} else {
	            system.debug('\n[DEBUG-CCZUtility.zdelete()] \n=========\nTEST RUN');
				results = new List<Zuora.zApi.DeleteResult>();
				Zuora.zApi.DeleteResult result = new Zuora.zApi.DeleteResult();
				result.Success = true;
				results.add(result);
			}
            system.debug('\n[DEBUG-CCZUtility.zdelete()] \n=========\nresults are: '+results);
			for (Zuora.zApi.DeleteResult result : results) {
				if (!result.Success) {
                    system.debug('\n[DEBUG-CCZUtility.zdelete()] \n=========\nDELETE NOT SUCCSSFUL!OBJECT: '+obj+' IDs: '+ids+'\nERRORS: '+result.errors);
				}
			}
			return results;
/*
		} catch( Zuora.zForceException ex) {
			system.debug('\n[DEBUG-CCZUtility.zdelete()] \n=========\nzForceException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zAPIException ex) {
			system.debug('\n[DEBUG-CCZUtility.zdelete()] \n=========\nzAPIException catch block: '+ex.getMessage());
			throw ex;
		} catch( Zuora.zRemoteException ex) {
			system.debug('\n[DEBUG-CCZUtility.zdelete()] \n=========\nzRemoteException catch block: '+ex.getMessage());
			throw ex;
*/
		} catch (Exception ex) {
            system.debug('\n[DEBUG-CCZUtility.zdelete()] \n=========\n catch block exception message:  '+ex.getMessage());
			throw ex;
		}
	}

	// Pass the resource name
	public static String getResourceURL(String resourceName) {
		// Fetching the resource
		List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
		// Checking if the result is returned or not
		String URLStr = '';
		if(resourceList.size() == 1) {
			// Getting namespace
			String namespace = resourceList[0].NamespacePrefix;
			// Resource URL
			URLStr = Label.CommunityURL + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
		}
		return URLStr;
	}
	// Pass the resource name
	public static String getResourceURL(String resourceName, String prefixPath) {
		// Fetching the resource
		List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
		
		// Checking if the result is returned or not
		String URLStr = '';
		if(resourceList.size() == 1) {
			// Getting namespace
			String namespace = resourceList[0].NamespacePrefix;
			// Resource URL
			URLStr = '/'+prefixPath+'/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
		}
		return URLStr;
	}
}