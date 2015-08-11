/************************************************************************************** 
 Apex Class  Name    : HSFE_SendEventToLotusNotes
 Version             : 1.0 
 Created Date        : 12 April 2015
 Function            : This class will invoke the service to mule
 Modification Log    :
 * Developer                      Date                                    Description
 * ----------------------------------------------------------------------------                 
 * Kumar Gaurav                04/12/2014                              Original Version
 *************************************************************************************/
public  class HSFE_SendEventToLotusNotes {

	public static Map<String, HSFE_IntegrationEndPointURL__c> endPointUrlMap = HSFE_IntegrationEndPointURL__c.getAll();
	/*
     * Method name  : createOrUpdateCalendarInNotes
     * Description  : This method is called when the salesrep creates an event in salesforce
     * Return Type  : None
     * Parameter    : None
     */ 
    @future (callout=true) 
	public static void createOrUpdateCalendarInNotes(List<Id> evdIds){
		if (null != evdIds && !evdIds.isEmpty()){
			try {
				String Url;
				HTTPResponse resp = null;
				String JSONRequestData;
				if (null != endPointUrlMap.get(HSFE_Constant.LOTUS_NOTES)){
		            Url = endPointUrlMap.get(HSFE_Constant.LOTUS_NOTES).HSFE_EndPointURL__c;
		        }
				JSONRequestData = createJsonRequest(evdIds);
				System.debug('************************* JSON Request Data LOTUS_NOTES : ' + JSONRequestData);
				if (!String.isEmpty(JSONRequestData)){
					
					Http http = new Http(); 
					HTTPRequest req = new HTTPRequest();
					req.setEndpoint(Url);
					req.setMethod('POST');
					req.setTimeOut(120000);
			        req.setHeader('Content-Type', 'application/json');
			        req.setBody(JSONRequestData);
			        resp = http.send(req);
			        System.debug('********************* Request Message : ' + JSONRequestData);
			        System.debug('********************* Response : '+ resp);
					System.debug('********************* Response Code : '+ resp.getStatusCode());
					if(null == resp || HSFE_Constant.STATUS_CODE_SUCCESS != resp.getStatusCode()) {	// Error Scenario
						upsertIntegrationRetryObject(evdIds);
					}
				}
			}
			catch (System.Calloutexception coEx){
	            upsertIntegrationRetryObject(evdIds);
	            HSFE_ExceptionLogger.createExceptionLog(coEx);
	        }
			catch(Exception e){
	        	HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
		    }
		}
	}

	public static void upsertIntegrationRetryObject(List<Id> evdIds){
		if (null != evdIds && !evdIds.isEmpty()){
			List<HSFE_Integration_Retry_Object__c> integrationRetryObjectList = new List<HSFE_Integration_Retry_Object__c>();
			HSFE_Integration_Retry_Object__c integrationRetryObject;
			for(Id IdVar : evdIds){
				integrationRetryObject = new HSFE_Integration_Retry_Object__c();
	            integrationRetryObject.Name = HSFE_Constant.LOTUS_NOTES;
	            integrationRetryObject.HSFE_Object_Name__c = HSFE_Constant.EVENT_OBJECT_API_NAME;
	            integrationRetryObject.HSFE_Record_Id__c = IdVar;
	            integrationRetryObject.HSFFE_Interface_External_Id__c = String.valueOf(IdVar) + HSFE_Constant.LOTUS_NOTES;
	            integrationRetryObject.HSFE_Request_Processed_Flag__c = false;
	            integrationRetryObjectList.add(integrationRetryObject);
			}
			Upsert integrationRetryObjectList HSFFE_Interface_External_Id__c;
		}
	}
	
	public static String createJsonRequest(List<Id> evdIds){
		String JSONString;
		HSFE_LotusNotesRequest_Class req = new HSFE_LotusNotesRequest_Class();
		req.interfaceName = HSFE_Constant.LOTUS_NOTES;
		req.objectAPIName = HSFE_Constant.EVENT_OBJECT_API_NAME;
		req.eventIDs = evdIds;
		JSONString = JSON.serialize(req);
		return JSONString;
	}
}