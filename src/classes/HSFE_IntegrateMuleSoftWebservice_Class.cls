/*Class Name :  HSFE_IntegrateMuleSoftWebservice_Class 
*Description :  This Class will be responsible for calling the MuleSoft services for the different Integration Interfaces. 
*Created By :   Prateek Saxena
*Created On :   05/15/2015
*
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
* Prateek Saxena             05/15/2015                      Calling MuleSoft services for Integration request and updating the object in SFDC with Status or populating the retry Object.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*/
public with sharing class HSFE_IntegrateMuleSoftWebservice_Class {

    public static Map<String, HSFE_IntegrationEndPointURL__c> endPointUrlMap = HSFE_IntegrationEndPointURL__c.getAll();
    
    /***************************************************************************************************************************************
     * Method Name:GetFreightChargesForLineItem
     * Description:Fetches the Freight charges for the Line Item and updates the Integration status based on the response.
     * Return Type: None.
     ***************************************************************************************************************************************/
    @future(callout=true)
    public static void GetFreightChargesForLineItem(String JSONRequestData){
        System.debug('***************In GetFreightChargesForLineItem*********'+JSONRequestData);
        Set<Id> LineItemIdSet;
        List<HSFE_Line_Item_Extension__c> lineItemObjList;
        String Url;
        try {
            if (null != endPointUrlMap.get(HSFE_Constant.FREIGHT_CHARGES)){
                Url = endPointUrlMap.get(HSFE_Constant.FREIGHT_CHARGES).HSFE_EndPointURL__c;
            }
            System.debug('***************** End Point Url : ' + Url);
            if (!String.isEmpty(JSONRequestData) && null != Url && !String.isEmpty(Url)){
                
                System.debug('********************* Request Message : ' + JSONRequestData);
                HttpRequest req = new HttpRequest();
                Http http = new Http(); 
                req.setMethod('POST'); 
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(Url);   // Change it to Freight Charges Endpoint URl....
                req.setTimeout(120000);
                req.setBody(JSONRequestData);
                HTTPResponse resp = http.send(req);
                System.debug('********************* Response Status Code : ' + resp.getStatusCode());
                System.debug('********************* Response Body : ' + resp.getBody());
                
                if (null == resp || HSFE_Constant.STATUS_CODE_SUCCESS != resp.getStatusCode()){      // Error Scenario
                    HSFE_Utility_Class.insertIntegrationRetryObject(JSONRequestData, HSFE_Constant.FREIGHT_CHARGES, HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME);       //Populating the Retry Object
                    LineItemIdSet = HSFE_Utility_Class.deserializeJSONtoList(JSONRequestData);  // Deserializing the Request Data to Fetch the Line Item Id
                    if (LineItemIdSet.size() > 0){
                        lineItemObjList = [Select id,HSFE_Freight_Integration_Status__c from HSFE_Line_Item_Extension__c 
                                            where Id in :LineItemIdSet];
                    }
                    if (null != lineItemObjList && !lineItemObjList.isEmpty()){
                        System.debug('********************** Line Item Object List : ' + lineItemObjList);
                        for (HSFE_Line_Item_Extension__c reqObj : lineItemObjList){
                            reqObj.HSFE_Freight_Integration_Status__c = HSFE_Constant.ERROR;
                        }
                        System.debug('****************** Updated Line Item List with Freight Status: ' + lineItemObjList);
                        update lineItemObjList; // Updating the Status of Line Item for Integration
                    }
                }
            }
        }
        catch (Exception ex){
            HSFE_Utility_Class.insertIntegrationRetryObject(JSONRequestData, HSFE_Constant.FREIGHT_CHARGES, HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME);       //Populating the Retry Object
            HSFE_ExceptionLogger.createExceptionLog(ex);
        }
    }

    /***************************************************************************************************************************************
     * Method Name:GetContractPriceForLineItem
     * Description:Fetches the Contract Price for the Line Item and updates the Integration status based on the response.
     * Return Type: None.
     ***************************************************************************************************************************************/
    @future(callout=true)
    public static void GetContractPriceForLineItem (String JSONRequestData){
        System.debug('***************In GetContractPriceForLineItem*********'+JSONRequestData);
        List<HSFE_Line_Item_Extension__c> lineItemObjList;
        Set<Id> LineItemIdSet;
        String Url;
        try {
            if (null != endPointUrlMap.get(HSFE_Constant.CONTRACT_PRICING)){
                Url = endPointUrlMap.get(HSFE_Constant.CONTRACT_PRICING).HSFE_EndPointURL__c;
            }
            System.debug('***************** End Point Url : ' + Url);
            if (!String.isEmpty(JSONRequestData) && null != Url && !String.isEmpty(Url)){
                
                System.debug('********************* Request Message : ' + JSONRequestData);
                HttpRequest req = new HttpRequest();
                Http http = new Http(); 
                req.setMethod('POST'); 
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(Url);
                req.setBody(JSONRequestData);
                req.setTimeout(120000);
                // create the response object
                HTTPResponse resp = http.send(req);
                System.debug('********************* Response Status Code : ' + resp.getStatusCode());
                System.debug('********************* Response Body : ' + resp.getBody());
                
                if(null == resp || HSFE_Constant.STATUS_CODE_SUCCESS != resp.getStatusCode()) {
                    HSFE_Utility_Class.insertIntegrationRetryObject(JSONRequestData, HSFE_Constant.CONTRACT_PRICING, HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME);       //Populating the Retry Object
                    LineItemIdSet = HSFE_Utility_Class.deserializeJSONtoList(JSONRequestData);  // Deserializing the Request Data to Fetch the Line Item Id
                    if (LineItemIdSet.size() > 0){
                        lineItemObjList = [Select id,HSFE_Contract_Integration_Status__c from HSFE_Line_Item_Extension__c 
                                            where Id in :LineItemIdSet];
                    }
                    System.debug('Line Item Extension Object List : ' + lineItemObjList);
                    if (null != lineItemObjList && !lineItemObjList.isEmpty()){
                        for (HSFE_Line_Item_Extension__c reqObj : lineItemObjList){
                            reqObj.HSFE_Contract_Integration_Status__c = HSFE_Constant.ERROR;
                        }
                        System.debug('****************** Updated Line Item List with Status: ' + lineItemObjList);
                        update lineItemObjList; // Updating the Status of Line Item for Integration
                    }
                }
            }
        }
        catch (Exception ex){
            HSFE_Utility_Class.insertIntegrationRetryObject(JSONRequestData, HSFE_Constant.CONTRACT_PRICING, HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME);       //Populating the Retry Object  
            HSFE_ExceptionLogger.createExceptionLog(ex);
        }
    }

    /***************************************************************************************************************************************
     * Method Name:ConvertQuotetoOrder
     * Description:Initiates the request to MuleSoft for the Quote to Order interface to process it for Order and updates the integration status.
     * Return Type: None.
     ***************************************************************************************************************************************/
    //@future(Callout=true)
    public static void ConvertQuotetoOrder(String JSONRequestData, String quoteId){
        String JSONResponseData;
        //String quoteId;
        Apttus_Proposal__Proposal__c quoteObjToUpdate;
        HSFE_QuoteToOrderRequest_Class quoteToOrderReqObj;
        String Url;
        try{
            if (null != endPointUrlMap.get(HSFE_Constant.QUOTE_TO_ORDER)){
                Url = endPointUrlMap.get(HSFE_Constant.QUOTE_TO_ORDER).HSFE_EndPointURL__c;
            }
            System.debug('***************** End Point Url : ' + Url);
            if (null != JSONRequestData && null != Url && !String.isEmpty(Url)){
               System.debug('********************* Request Message : ' + JSONRequestData);
                HttpRequest req = new HttpRequest();
                Http http = new Http(); 
                req.setMethod('POST'); 
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(Url+'?quoteId='+quoteId);
                req.setBody(JSONRequestData);
                HTTPResponse resp = http.send(req);     // create the response object
                System.debug('********************* Response Status Code : ' + resp.getStatusCode());
                System.debug('********************* Response Body : ' + resp.getBody());
                quoteToOrderReqObj = HSFE_QuoteToOrderRequest_Class.deserializeRequest(JSONRequestData);    // Deserializing the Request Data to Fetch the Quote ID.
                if (null != quoteToOrderReqObj){
                    quoteObjToUpdate = [Select Id, HSFE_Order_Status__c 
                                            from Apttus_Proposal__Proposal__c 
                                            where Id = :quoteToOrderReqObj.quoteID];
                    System.debug('Quote Object to Update Status : ' + quoteObjToUpdate);
                    if (null != quoteObjToUpdate){
                        quoteObjToUpdate.HSFE_Order_Status__c = HSFE_Constant.FAILED;
                        if(null != resp && HSFE_Constant.STATUS_CODE_SUCCESS == resp.getStatusCode()) {
                            quoteObjToUpdate.HSFE_Order_Status__c = HSFE_Constant.SUBMITTED;
                        }
                        System.debug('****************** Updated Quote object with Status Error: ' + quoteObjToUpdate);
                        update quoteObjToUpdate; // Updating the Quote Object with Status
                    }
                }
            }
        }
        catch (Exception ex){
            HSFE_Utility_Class.insertIntegrationRetryObject(JSONRequestData, HSFE_Constant.QUOTE_TO_ORDER, HSFE_Constant.QUOTE_PROPOSAL_OBJECT_API_NAME);       //Populating the Retry Object
            HSFE_ExceptionLogger.createExceptionLog(ex);
        }
    }
    
    /***************************************************************************************************************************************
     * Method Name:SerialNumberCheckForLineItem
     * Description:Fetches the Serial Number for the Line Item and updates the same.
     * Return Type: None.
     ***************************************************************************************************************************************/
    @future(callout=true)
    public static void SerialNumberCheckForLineItem(String JSONRequestData){
        System.debug('***************In SerialNumberCheckForLineItem*********'+JSONRequestData);
        Set<Id> LineItemIdSet;
        List<HSFE_Line_Item_Extension__c> lineItemObjList;
        String Url;
        try {
            if (null != endPointUrlMap.get(HSFE_Constant.SERIAL_NUM_CHECK)){
                Url = endPointUrlMap.get(HSFE_Constant.SERIAL_NUM_CHECK).HSFE_EndPointURL__c;
            }
            System.debug('***************** End Point Url : ' + Url);
            if (!String.isEmpty(JSONRequestData) && null != Url && !String.isEmpty(Url)){
                
                System.debug('********************* Request Message Ser Num Check: ' + JSONRequestData);
                HttpRequest req = new HttpRequest();
                Http http = new Http(); 
                req.setMethod('POST'); 
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(Url);   // Change it to Freight Charges Endpoint URl....
                req.setTimeout(120000);
                req.setBody(JSONRequestData);
                HTTPResponse resp = http.send(req);
                System.debug('********************* Response Status Code Ser Num Check : ' + resp.getStatusCode());
                System.debug('********************* Response Body Ser Num Check : ' + resp.getBody());
                //Code for response here
                
        }
       }
        catch (Exception ex){
            HSFE_Utility_Class.insertIntegrationRetryObject(JSONRequestData, HSFE_Constant.SERIAL_NUM_CHECK, HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME);       //Populating the Retry Object
            HSFE_ExceptionLogger.createExceptionLog(ex);
        }
        
    }
 
}