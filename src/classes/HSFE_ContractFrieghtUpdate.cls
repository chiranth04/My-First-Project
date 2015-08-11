/* Class Name :HSFE_ContractFrieghtUpdate
*Description :Update real time contract price and frieght charge on line item and line item extension. 
*Created By :Sunil Kumar
*Created On :07/31/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
* Sunil Kumar            07/31/2015                     Update real time contract price and frieght charge on line item and line item extension. 
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class HSFE_ContractFrieghtUpdate{
    public static String errorMessage='';
    public static String fetchLineItem(String cartId){        
        if(cartId!= null){
            List<Apttus_Config2__LineItem__c> lineItems = new List<Apttus_Config2__LineItem__c>();
            Map<String,Apttus_Config2__LineItem__c> mapLineItems = new Map<String,Apttus_Config2__LineItem__c>();
            lineItems = [Select Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c,
                         Product_Conditions__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id,
                         Apttus_Config2__BasePrice__c, HSFE_Product_Part_Number__c, HSFE_Line_Item_Extension__c,HSFE_Contract_Price__c,Apttus_Config2__ConfigurationId__c    
                        from Apttus_Config2__LineItem__c 
                        where 
                        Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c != null and 
                        Apttus_Config2__BasePrice__c != null and HSFE_Product_Part_Number__c != null and 
                       Apttus_Config2__ConfigurationId__c =:cartId];
           if (null != lineItems && !lineItems.isEmpty()){
                for(Apttus_Config2__LineItem__c line : lineItems){
                    mapLineItems.put(line.HSFE_Line_Item_Extension__c,line);
                }
                String JSONRequestData = HSFE_Utility_Class.serializeListToJSON(lineItems, HSFE_Constant.CONTRACT_PRICING); // JSON Request Data
                System.debug('Request Body*********'+JSONRequestData);
                errorMessage = GetUpdateContractPriceForLineItem(JSONRequestData,lineItems,mapLineItems);    // WebService Call
                
            }
        }
        return errorMessage;
     }
     public static String GetUpdateContractPriceForLineItem(String JSONRequestData,List<Apttus_Config2__LineItem__c> lineItems,Map<String,Apttus_Config2__LineItem__c> mapLineItems){
         Map<String, HSFE_IntegrationEndPointURL__c> endPointUrlMap = HSFE_IntegrationEndPointURL__c.getAll();
         String Url;
         try {
            if (null != endPointUrlMap.get(HSFE_Constant.CONTRACT_PRICING_SYNC)){
                Url = endPointUrlMap.get(HSFE_Constant.CONTRACT_PRICING_SYNC).HSFE_EndPointURL__c;
            }
            System.debug('***************** End Point Url : ' + Url);
            if (!String.isEmpty(JSONRequestData) && null != Url && !String.isEmpty(Url)){
                List<Apttus_Config2__LineItem__c> updateList = new List<Apttus_Config2__LineItem__c>();
                List<HSFE_Line_Item_Extension__c > updateExtensionList = new List<HSFE_Line_Item_Extension__c >();
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
                if(resp.getStatusCode() == HSFE_Constant.STATUS_CODE_SUCCESS){
                                            
                    //Deserialize the response.
                    String responseBody = resp.getBody();
                    //List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> deserializeLineItem = deserializeJSONResponse(responseBody);
                    List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> deserializeLineItem = serializeUntypedResponse(responseBody);
                    System.debug('deserializeLineItem****'+deserializeLineItem);
                    //Mapping and updating the line item extension/line item with Mule response 
                    for(HSFE_MuleSoftIntegrationRequest_Class.LineItem line : deserializeLineItem){
                        HSFE_Line_Item_Extension__c extObj = new HSFE_Line_Item_Extension__c(id = line.lineItemId);
                        extObj.HSFE_Contract_Price__c = line.contractPrice;
                        extObj.HSFE_Contract_Code__c = line.contractCode;
                        extObj.HSFE_Contract_Number__c = line.contractNumber;
                        extObj.HSFE_GSA_Price__c = line.gsaPrice;
                        extObj.HSFE_Inco_Terms__c = line.incoTerms;
                        extObj.HSFE_Contract_Description__c =  line.contractDiscreption;
                        extObj.HSFE_Admin_Update_Flag__c = line.adminFlag;
                        extObj.HSFE_Freight_Terms__c = line.freightTerms;                      
                        updateExtensionList.add(extObj);
                        if(mapLineItems.containsKey(line.lineItemId)){
                            Apttus_Config2__LineItem__c lineObj = new Apttus_Config2__LineItem__c(id = mapLineItems.get(line.lineItemId).id);
                            lineObj.HSFE_Contract_Price__c = line.contractPrice;
                            updateList.add(lineObj);
                        }
                        
                    }
                    
                     if(updateExtensionList.size()>0){
                         update updateExtensionList ;
                      }
                      if(updateList.size()>0){
                        update updateList;
                      }
                        
                }
                else{
                    errorMessage = HSFE_Constant.RESPONSEERROR;                     
                }                
            }
             
         }
         catch (Exception ex){            
            HSFE_ExceptionLogger.createExceptionLog(ex);
         }
         return errorMessage;
     }
     public static List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> deserializeJSONResponse(String JSONRsponseData){
        List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> lineItemUpdatedList = new  List<HSFE_MuleSoftIntegrationRequest_Class.LineItem>();
        if(!String.isEmpty(JSONRsponseData)){
            List<HSFE_MuleSoftIntegrationRequest_Class> muleSoftIntegrationRequestObjList = (List<HSFE_MuleSoftIntegrationRequest_Class>) JSON.deserialize(JSONRsponseData, List<HSFE_MuleSoftIntegrationRequest_Class>.class);
            if (null != muleSoftIntegrationRequestObjList && !muleSoftIntegrationRequestObjList.isEmpty()){
                for(HSFE_MuleSoftIntegrationRequest_Class requestObj : muleSoftIntegrationRequestObjList){
                    for(HSFE_MuleSoftIntegrationRequest_Class.LineItem requestInnerListObj : requestObj.lineItemList){
                        lineItemUpdatedList.add(requestInnerListObj);
                    }
                }
            }                       
        }
        return lineItemUpdatedList;
    }
    
    public static List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> serializeUntypedResponse(String jsondata){
        List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> lineItemUpdatedList = new  List<HSFE_MuleSoftIntegrationRequest_Class.LineItem>();
        if(!String.isEmpty(jsondata)){
            List<Object> results =  (List<Object>)JSON.deserializeUntyped( jsondata);
            if(results != null){
                for(Object obj: results){
                    //Apttus_Config2__LineItem__c line = (Apttus_Config2__LineItem__c)obj;
                    Map<String, Object> data = (Map<String, Object>)obj;
                    //system.debug(data);
                    HSFE_MuleSoftIntegrationRequest_Class.LineItem requestInnerListObj = new HSFE_MuleSoftIntegrationRequest_Class.LineItem();
                    requestInnerListObj.lineItemId = data.get('Id') != null ? (Id)data.get('Id') : null;
                    requestInnerListObj.contractPrice = data.get('HSFE_Contract_Price__c') != null ? Double.valueOf(data.get('HSFE_Contract_Price__c')): 0.0;
                    requestInnerListObj.incoTerms = data.get('HSFE_Inco_Terms__c') != null ? (String)data.get('HSFE_Inco_Terms__c') : '';
                    requestInnerListObj.gsaPrice = data.get('HSFE_GSA_Price__c') != null ? Double.valueOf(data.get('HSFE_GSA_Price__c')) : 0.0;
                    requestInnerListObj.freightTerms = data.get('HSFE_Freight_Terms__c')!= null ? (String)data.get('HSFE_Freight_Terms__c') : '';
                    requestInnerListObj.contractNumber = data.get('HSFE_Contract_Number__c') != null ? (String)data.get('HSFE_Contract_Number__c') : '';
                    requestInnerListObj.adminFlag = data.get('HSFE_Admin_Update_Flag__c') != null ? (boolean)data.get('HSFE_Admin_Update_Flag__c') : false;
                    requestInnerListObj.contractCode = data.get('HSFE_Contract_Code__c') != null ? (String)data.get('HSFE_Contract_Code__c') : '';
                    requestInnerListObj.contractDiscreption = data.get('HSFE_Contract_Description__c') != null ? (String)data.get('HSFE_Contract_Description__c') : '';
                    lineItemUpdatedList.add(requestInnerListObj);
                }
            }
        }
        return lineItemUpdatedList;
    }

}