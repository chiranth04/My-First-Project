/*
* Class Name :HSFE_Utitlity_Class
* Description : Utility class for all the reusable functionality.
* Created By :Chiranth Aaradhya
* Created On :03/10/2015
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                           Modification Id                       Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Kumar Gaurav               03/23/2015                                                          Added method to stop recursive calls while Apttus Callback
* Chiranth Aradhya           25/5/2015                       Modified                            Added newOrderURL method to construct the New ELton Order URL
* Yunus H Navalur            6/8/2015                        Modified                            Added Future methods and Static Check variables.
*Chiranth Aradhya            Aug 4rth 2015                   Added new Method                    Added method to construct URL for Quick Create Opportunity (Method Name:newOpportunityURL)
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/


global with sharing class HSFE_Utility_Class {

    /************VARIABLE Declaration**************************************/

    private static boolean run = true;
    public static boolean stopUpdateLeadTerritory = false;
    public static boolean stopUpdateOpptyTerritory = false;
    public static boolean stopUpdateAccountTerritory = false;
    private static Boolean alreadyExecuted = false;
    public static boolean bEltonTriggerExecuted=false;
    public static boolean bEltonAfterInsertTriggerExecuted=false;

    public static Boolean alreadyExecutedTriggerUpdate = false;
    public static boolean stopFutureExceution = false;
    public static Boolean alreadyExecuted_Config = false;
    public static Boolean alreadyExecutedCPTrigger = false;

    //Call Back Execution Control Variables
    private static Boolean alreadyExecutedCallBack = false;
    Public  static Boolean alreadyExecutedCallBackBefore = false;
    Public static Boolean alreadyExecutedCallBackFinish = false;

    //Proposal Trigger Execution Control Variables
    public static Boolean proposalBeforeInsert = false;
    public static Boolean proposalBeforeUpdate = false;
    public static Boolean proposalBeforeDelete = false;
    public static Boolean proposalAfterInsert = false;
    public static Boolean proposalAfterUpdate = false;
    public static Boolean proposalAfterDelete = false;
    public static Boolean isProposalIntStatusUpdLineItemExt = false;

    public static Boolean lineItemBeforeInsert = false;
    public static Boolean lineItemBeforeUpdate = false;
    public static Boolean lineItemBeforeDelete = false;
    public static Boolean lineItemAfterInsert = false;
    public static Boolean lineItemAfterUpdate = false;
    public static Boolean lineItemAfterDelete = false; 
    
    public static Boolean ProductBeforeInsert = false;
    public static Boolean ProductBeforeUpdate = false;
    public static Boolean ProductBeforeDelete = false;
    public static Boolean ProductAfterInsert = false;
    public static Boolean ProductAfterUpdate = false;
    public static Boolean ProductAfterDelete = false;       

    //Product
    public static Boolean RunOnceProductLogic_AfterInsert = false;

    //Variable
    public static Map<String, String> constantCategoryMap = assignConstant();
   
    /************VARIABLE Declaration**************************************/
     

     /*********************************************************************************
     * Method Name:runOnce
     * Description:This method is to control the recursive triggers
     * Return Type: boolean.
     ********************************************************************************/
    public static boolean runOnce(){
        if(run){
             run=false;
             return true;
        }else{
            return run;
        }
    }
    
    //-------------------------------------------------------------------------
    //Methods added by Kumar Gaurav for Apttus Callback
    /*
     * Method name  : hasAlreadyExecuted
     * Description  : This method is to prevent recurssive call in callback methods
     * Return Type  : Boolean
     * Parameter    : None
     */
     public static boolean hasAlreadyExecuted() {
        return alreadyExecuted ;
     }
     
     /*
     * Method name  : setAlreadyExecuted
     * Description  : This method will force callback flag to set as its already executed
     * Return Type  : Boolean
     * Parameter    : None
     */
     public static void setAlreadyExecuted() {
        alreadyExecuted = true;
     }  
     
     /*
     * Method name  : setAlreadyExecutedFalse
     * Description  : This method will force callback flag to re-set
     * Return Type  : Boolean
     * Parameter    : None
     */
     public static void setAlreadyExecutedFalse() {
        alreadyExecuted = false;
     }
    //-------------------------------------------------------------------------

    // Method which stores the value from Custom Setting - HSFE_Product_Attribute_Charge_Types__c into constantCategoryMap
    public static Map<String, String> assignConstant () {
        
        // Return Value
        Map<String, String> tempMap = new Map<String, String>(); 
        String tempVal = null;
        // Fetch values from Custom Setting - HSFE_Product_Attribute_Charge_Types__c
        for (HSFE_Product_Attribute_Charge_Types__c consObj : HSFE_Product_Attribute_Charge_Types__c.getAll().values()) {
            tempVal = consObj.HSFE_Name_Long__c;
            Integer Position = tempVal.indexOf(HSFE_Constant.COUSTOM_NEW, 0);            
            if(Position > 0){
                tempVal = HSFE_Constant.COUSTOM_NEW;
            }else{
                tempVal = tempVal.split(';')[0];
            }           
            
            tempMap.put(consObj.Name, tempVal);
        }
        return tempMap;
    }
    
    /*
     * Method name  : convertSobjectToJSON
     * Description  : This method will convert the SObject to JSON
     * Return Type  : JSON
     * Parameter    : SObject
     */
     public static JSON convertSObjectToJSON(SObject obj, String ObjType){
        return null;
     }
     
     /*
     * Method name  : GetPriceMatricRecord
     * Description  : This method will return price matrix Record from JSON String.
     * Return Type  : Boolean
     * Parameter    : String,String
     */
     public static HSFE_PriceMatxEntryJson GetPriceMatricRecord(String JSONString,String Condition){
        list<String> CollectionOfMatrix = JSONString.split(HSFE_Constant.CUSTOM_SEPRTOR,10);
        HSFE_PriceMatxEntryJson MatrixRec;
        for(String Var : CollectionOfMatrix){
            MatrixRec = HSFE_PriceMatxEntryJson.GetProductJsonRecord(Var);
            if(MatrixRec.DimensionValue == Condition)
                break;
        }
        return MatrixRec;
     }     
     
     /*
     * Method name  : checkStringForNullorEmpty
     * Description  : This method will check for Null or Empty String and Returns True if Finds one.
     * Return Type  : Boolean
     * Parameter    : String
     */
     public static Boolean checkStringForNullorEmpty(String checkString){
        return String.isEmpty(checkString);
     }

     /*********************************************************************************
     * Method Name:serializeListToJSON
     * Description:Serializes a list of Line Items to JSON String.
     * Return Type: JSON String.
     ********************************************************************************/
    public static String serializeListToJSON(List<Apttus_Config2__LineItem__c> lineItemList, String interfaceName){
        String JSONString;
        try {
            if (null != lineItemList && !lineItemList.isEmpty()){
                HSFE_MuleSoftIntegrationRequest_Class.LineItem lineItemObj;
                String quoteId;
                List<HSFE_MuleSoftIntegrationRequest_Class> muleSoftIntegrationRequestObjList = new List<HSFE_MuleSoftIntegrationRequest_Class>();
                HSFE_MuleSoftIntegrationRequest_Class muleSoftIntegrationRequestObj;
                List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> lineItemRequestList;
                Map<Id,HSFE_MuleSoftIntegrationRequest_Class> quoteIdMuleSoftRequestMap = new Map<Id,HSFE_MuleSoftIntegrationRequest_Class>();
                for (Apttus_Config2__LineItem__c lineItemVar : lineItemList){
                    quoteId = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id;
                    if(quoteIdMuleSoftRequestMap.containsKey(quoteId)){
                        lineItemRequestList = quoteIdMuleSoftRequestMap.get(quoteId).lineItemList;
                        lineItemObj = new HSFE_MuleSoftIntegrationRequest_Class.LineItem();
                        //lineItemObj.lineItemId = lineItemVar.Id;
                        lineItemObj.lineItemId = lineItemVar.HSFE_Line_Item_Extension__c;   // Changed Prateek
                        lineItemObj.productNumber = lineItemVar.HSFE_Product_Part_Number__c;   // Changed 
                        lineItemObj.productCondition = lineItemVar.Product_Conditions__c;
                        lineItemObj.SAPId = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c;
                        lineItemObj.quoteID = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id;//added by Gaurav on 05-12-2015
                        if (HSFE_Constant.FREIGHT_CHARGES.equals(interfaceName)){
                            lineItemObj.accountZipCode = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__ShipToAccountId__r.HSFE_Physical_Zip__c;
                            //added by Gaurav on //5/26/2015
                            lineItemObj.contractCode = lineItemVar.HSFE_Contract_Code__c;
                            lineItemObj.contractNumber = lineItemVar.HSFE_Contract_Number__c;
                            lineItemObj.freightTerms = lineItemVar.HSFE_Freight_Terms__c;
                            lineItemObj.quantity = lineItemVar.Apttus_Config2__Quantity__c != null ? String.valueOf(lineItemVar.Apttus_Config2__Quantity__c) : '0';
                        }
                        lineItemRequestList.add(lineItemObj);
                    }
                    else {
                        muleSoftIntegrationRequestObj = new HSFE_MuleSoftIntegrationRequest_Class();
                        //muleSoftIntegrationRequestObj.ObjectAPIName = HSFE_Constant.LINE_ITEM_OBJECT_API_NAME; // Changed Prateek
                        muleSoftIntegrationRequestObj.ObjectAPIName = HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME;
                        muleSoftIntegrationRequestObj.interfaceName =  interfaceName;
                        muleSoftIntegrationRequestObj.quoteID = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id;//added by Gaurav on 05-12-2015
                        muleSoftIntegrationRequestObj.SAPId = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c;
                        lineItemRequestList = new List<HSFE_MuleSoftIntegrationRequest_Class.LineItem>();
                        lineItemObj = new HSFE_MuleSoftIntegrationRequest_Class.LineItem();
                        //lineItemObj.lineItemId = lineItemVar.Id;
                        lineItemObj.lineItemId = lineItemVar.HSFE_Line_Item_Extension__c;   // Changed Prateek
                        lineItemObj.productNumber = lineItemVar.HSFE_Product_Part_Number__c;   // Changed
                        lineItemObj.productCondition = lineItemVar.Product_Conditions__c;
                        lineItemObj.SAPId = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c;
                        lineItemObj.quoteID = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id;//added by Gaurav on 05-12-2015
                        if (HSFE_Constant.FREIGHT_CHARGES.equals(interfaceName)){
                            lineItemObj.accountZipCode = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__ShipToAccountId__r.HSFE_Physical_Zip__c;
                            //added by Gaurav on //5/26/2015
                            lineItemObj.contractCode = lineItemVar.HSFE_Contract_Code__c;
                            lineItemObj.contractNumber = lineItemVar.HSFE_Contract_Number__c;
                            lineItemObj.freightTerms = lineItemVar.HSFE_Freight_Terms__c;
                            lineItemObj.quantity = lineItemVar.Apttus_Config2__Quantity__c != null ? String.valueOf(lineItemVar.Apttus_Config2__Quantity__c) : '0';
                        }
                        lineItemRequestList.add(lineItemObj);
                        muleSoftIntegrationRequestObj.lineItemList = lineItemRequestList;
                        quoteIdMuleSoftRequestMap.put(quoteId, muleSoftIntegrationRequestObj);

                    }
                }
                muleSoftIntegrationRequestObjList.addAll(quoteIdMuleSoftRequestMap.values());
                JSONString = JSON.serialize(muleSoftIntegrationRequestObjList);
            }
        }
        catch(System.Jsonexception jsonex){
            HSFE_ExceptionLogger.createExceptionLog(jsonex);
        }
        catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);        
        }
        return JSONString;
    }
    
    /*********************************************************************************
     * Method Name:serializeListToJSON
     * Description:Serializes a list of Line Items to JSON String.
     * Return Type: JSON String.
     ********************************************************************************/
    public static Set<Id> deserializeJSONtoList(String JSONRequestData){
        Set<Id> LineItemIdSet = new Set<Id>();
        if(!String.isEmpty(JSONRequestData)){
            List<HSFE_MuleSoftIntegrationRequest_Class> muleSoftIntegrationRequestObjList = (List<HSFE_MuleSoftIntegrationRequest_Class>) JSON.deserialize(JSONRequestData, List<HSFE_MuleSoftIntegrationRequest_Class>.class);
            if (null != muleSoftIntegrationRequestObjList && !muleSoftIntegrationRequestObjList.isEmpty()){
                for(HSFE_MuleSoftIntegrationRequest_Class requestObj : muleSoftIntegrationRequestObjList){
                    for(HSFE_MuleSoftIntegrationRequest_Class.LineItem requestInnerListObj : requestObj.lineItemList){
                        LineItemIdSet.add(requestInnerListObj.lineItemId);
                    }
                }
            }                       
        }
        return LineItemIdSet;
    }

     /*
     * Method name  : insertIntegrationRetryObject
     * Description  : This method will insert the Integration Retry Object record in case of Error during the Integration.
     * Return Type  : void
     * Parameter    : Serialized String (JSON)
     */
     public static void insertIntegrationRetryObject(String jsonData, String interfaceName, String objectAPIName){
        Set<Id> lineItemIdSet = new Set<ID>();
        try {
            if (HSFE_Constant.QUOTE_TO_ORDER.equals(interfaceName)){
                HSFE_QuoteToOrderRequest_Class quoteToOrderObj = HSFE_QuoteToOrderRequest_Class.deserializeRequest(jsonData);
                lineItemIdSet.add(quoteToOrderObj.quoteID);
            }
            else {
                lineItemIdSet = HSFE_Utility_Class.deserializeJSONtoList(jsonData);
            }
            List<HSFE_Integration_Retry_Object__c> integrationRetryObjectList = new List<HSFE_Integration_Retry_Object__c>();
            HSFE_Integration_Retry_Object__c integrationRetryObject;

            if (null != lineItemIdSet && !lineItemIdSet.isEmpty()){
                for (Id lineItemIDVar : lineItemIdSet){
                    integrationRetryObject = new HSFE_Integration_Retry_Object__c();
                    integrationRetryObject.Name = interfaceName;
                    integrationRetryObject.HSFE_Object_Name__c = objectAPIName;
                    integrationRetryObject.HSFE_Record_Id__c = lineItemIDVar;
                    integrationRetryObject.HSFFE_Interface_External_Id__c = lineItemIDVar + interfaceName;
                    integrationRetryObject.HSFE_Request_Processed_Flag__c = false;
                    integrationRetryObjectList.add(integrationRetryObject);
                }
            }
            if (!integrationRetryObjectList.isEmpty()){
                Upsert integrationRetryObjectList HSFFE_Interface_External_Id__c;
            }
        }
        catch (Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex); 
        }
     }
    
    //Method to construct URL for New Equipment Order, this methid will be caleed when New Elton Order button is clicked on activity
     /******************************************************[Divya 31-7-2015] Commenting out the method for deployment without ELTON***********************************/
    /*webservice static String newOrderURL(Id evetId) { 
        
        String prefix = ELTON__Equipment_Order__c.SObjectType.getDescribe().getKeyPrefix();
        List<Event> lstevet= new List<Event>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Account> accList = new List<Account>();
        List<Lead> leadList = new List<Lead>();
        String What_Id='';
        String objId='';
        String prefix_Account = Account.SObjectType.getDescribe().getKeyPrefix();
        String prefix_Lead = Lead.SObjectType.getDescribe().getKeyPrefix();
        String prefix_Opportunity = Opportunity.SObjectType.getDescribe().getKeyPrefix();
        String formattedDt='';
        
        if(evetId !=null){
            lstevet= [Select Id,WhatId,StartDateTime,WhoId,Who.Name, Meeting_Type__c,createdbyId from Event where Id=: evetId ];
        }
        
        if(lstevet.size()>0){
            What_Id=lstevet[0].WhatId;
            formattedDt = lstevet[0].StartDateTime.date().format();
        }
        
        if(What_Id != null){
            objId= What_Id.substring(0, 3);
        }
        
        if(lstevet.size()>0){
            if(objId == prefix_Opportunity ){
                oppList = [Select Id, Name,Account.Name,AccountId from Opportunity where Id=:lstevet[0].WhatId];
                if(oppList.size()>0){
                     if(lstevet[0].Meeting_Type__c == HSFE_Constant.ON_PATIENT_EVALUATION){
                         String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'&'+System.Label.HSFE_Eq_Commit_Start_Date+'='+formattedDt+'&'+System.Label.HSFE_Eq_Order_Type+'='+HSFE_Constant.Order_Type_Evaluation+'&'+System.Label.HSFE_Eq_Order_Opp_Name+'='+oppList[0].Name +'&'+System.Label.HSFE_Eq_Order_Opp_Id+'='+oppList[0].Id+'');
                         return strURL;
                     }else if(lstevet[0].Meeting_Type__c == HSFE_Constant.DEMONSTRATION){
                         String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'&'+System.Label.HSFE_Eq_Commit_Start_Date+'='+formattedDt+'&'+System.Label.HSFE_Eq_Order_Type+'='+HSFE_Constant.Order_Type_Demonstration+'&'+System.Label.HSFE_Eq_Order_Opp_Name+'='+oppList[0].Name +'&'+System.Label.HSFE_Eq_Order_Opp_Id+'='+oppList[0].Id+'');
                         return strURL;
                     }
                }else{
                    String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'');
                    //String encodedUrl = EncodingUtil.urlEncode('strURL', 'UTF-8');
                    return strURL;
                }
            }else if(objId == prefix_Account ){
                accList =[Select Id, Name from Account where Id=:lstevet[0].WhatId];
                if(accList.size()>0){
                    if(lstevet[0].Meeting_Type__c == HSFE_Constant.ON_PATIENT_EVALUATION){
                        
                        String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'&' +System.Label.HSFE_Eq_Commit_Start_Date+'='+formattedDt+'&'+System.Label.HSFE_Eq_Order_Type+'='+HSFE_Constant.Order_Type_Evaluation+'&'+System.Label.HSFE_Eq_Order_Account_Name+'='+accList[0].Name+'&'+System.Label.HSFE_Eq_Order_Account_Id+'='+accList[0].Id+'');
                        return strURL;
                     }else if(lstevet[0].Meeting_Type__c == HSFE_Constant.DEMONSTRATION){
                         String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'&' +System.Label.HSFE_Eq_Commit_Start_Date+'='+formattedDt+'&'+System.Label.HSFE_Eq_Order_Type+'='+HSFE_Constant.Order_Type_Demonstration+'&'+System.Label.HSFE_Eq_Order_Account_Name+'='+accList[0].Name+'&'+System.Label.HSFE_Eq_Order_Account_Id+'='+accList[0].Id+'');
                         return strURL;
                     }
                }else{
                    String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'');
                    //String encodedUrl = EncodingUtil.urlEncode('strURL', 'UTF-8');
                    return strURL;
                }
            }else if(objId == prefix_Lead){
                leadList = [Select Id, Name from Lead where Id=:lstevet[0].WhoId];
                if(leadList.size()>0){
                    if(lstevet[0].Meeting_Type__c == HSFE_Constant.ON_PATIENT_EVALUATION){
                         
                         String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'&' +System.Label.HSFE_Eq_Commit_Start_Date+'='+formattedDt+'&'+System.Label.HSFE_Eq_Order_Type+'='+HSFE_Constant.Order_Type_Evaluation+'');
                         return strURL;
                    
                    }else if(lstevet[0].Meeting_Type__c == HSFE_Constant.DEMONSTRATION){
                        String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'&' +System.Label.HSFE_Eq_Commit_Start_Date+'='+formattedDt+'&'+System.Label.HSFE_Eq_Order_Type+'='+HSFE_Constant.Order_Type_Demonstration+'');
                        return strURL;
                    }
                }else{
                    String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'');
                    return strURL;
                }
            }
        }
         String strURL=('/'+prefix+'/e?nooverride=1&'+System.Label.HSFE_ELTON_ActivityId+'='+lstevet[0].Id+'&retURL='+lstevet[0].Id+'');
         return strURL;
    }  */
     /************************************************************[Divya 31-7-2015] Commenting out Ends *********************************************************************/                   
     
    /*********************************************************************************
     * Method Name:newOpportunityURL
     * Description:Method to construct URL for Quick Create Opportunity, this methid will be called when Quick Opportunity button is clicked on Account Related List.
     * Return Type: String.
     *Created By: Chiranth Aradhya
     ********************************************************************************/ 
    webservice static String newOpportunityURL(String accName,Id accId){
        List<HSFE_Contant_Helper__c> customsettingList = new List<HSFE_Contant_Helper__c>();
        customsettingList = [Select Name,HSFE_Quick_Create_Opportunities__c,HSFE_Value__c from HSFE_Contant_Helper__c where HSFE_Quick_Create_Opportunities__c = 'True'];
        String prefix_Opportunity = Opportunity.SObjectType.getDescribe().getKeyPrefix();
        String retURL='/'+prefix_Opportunity+'/e?nooverride=1&RecordType='+Label.HSFE_Customer_Record_Type+'&opp4='+accName+'&opp4_lkid='+accId+'&retURL='+accId+'&save_new_url='+accId;
        for(HSFE_Contant_Helper__c conhelp:customsettingList){
            retURL +='&'+conhelp.Name+'='+conhelp.HSFE_Value__c;
        }
        return retURL;
    }
    
      /*********************************************************************************
     * Method Name:serializeListToJSONSerNumCheck
     * Description:Serializes a list of Line Items to JSON String.
     * Return Type: JSON String.
     ********************************************************************************/
    public static String serializeListToJSONSerNumCheck(List<Apttus_Config2__LineItem__c> lineItemList, String interfaceName){
        String JSONString;
        try {
            if (null != lineItemList && !lineItemList.isEmpty()){
                HSFE_MuleIntegSerialNumCheck_Class.LineItem lineItemObj;
                String quoteId;
                List<HSFE_MuleIntegSerialNumCheck_Class> muleSoftIntegrationRequestObjList = new List<HSFE_MuleIntegSerialNumCheck_Class>();
                HSFE_MuleIntegSerialNumCheck_Class muleSoftIntegrationRequestObj;
                List<HSFE_MuleIntegSerialNumCheck_Class.LineItem> lineItemRequestList;
                Map<Id,HSFE_MuleIntegSerialNumCheck_Class> quoteIdMuleSoftRequestMap = new Map<Id,HSFE_MuleIntegSerialNumCheck_Class>();
                for (Apttus_Config2__LineItem__c lineItemVar : lineItemList){
                    quoteId = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id;
                    if(quoteIdMuleSoftRequestMap.containsKey(quoteId)){
                        lineItemRequestList = quoteIdMuleSoftRequestMap.get(quoteId).lineItemList;
                        lineItemObj = new HSFE_MuleIntegSerialNumCheck_Class.LineItem();
                        //lineItemObj.lineItemId = lineItemVar.Id;
                        lineItemObj.lineItemId = lineItemVar.HSFE_Line_Item_Extension__c;   // Changed Prateek
                        lineItemObj.productNumber = lineItemVar.HSFE_Product_Part_Number__c;   // Changed 
                        lineItemObj.serialNumber = lineItemVar.HSFE_Serial_Number__c;
                        lineItemRequestList.add(lineItemObj);
                    }
                    else {
                        muleSoftIntegrationRequestObj = new HSFE_MuleIntegSerialNumCheck_Class();
                        muleSoftIntegrationRequestObj.interfaceName =  interfaceName;
                        muleSoftIntegrationRequestObj.SAPId = lineItemVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c;
                        lineItemRequestList = new List<HSFE_MuleIntegSerialNumCheck_Class.LineItem>();
                        lineItemObj = new HSFE_MuleIntegSerialNumCheck_Class.LineItem();
                        lineItemObj.lineItemId = lineItemVar.HSFE_Line_Item_Extension__c;   // Changed Prateek
                        lineItemObj.productNumber = lineItemVar.HSFE_Product_Part_Number__c;   // Changed 
                        lineItemObj.serialNumber = lineItemVar.HSFE_Serial_Number__c;
                        
                        lineItemRequestList.add(lineItemObj);
                        muleSoftIntegrationRequestObj.lineItemList = lineItemRequestList;
                        quoteIdMuleSoftRequestMap.put(quoteId, muleSoftIntegrationRequestObj);

                    }
                }
                muleSoftIntegrationRequestObjList.addAll(quoteIdMuleSoftRequestMap.values());
                JSONString = JSON.serialize(muleSoftIntegrationRequestObjList);
            }
        }
        catch(System.Jsonexception jsonex){
            HSFE_ExceptionLogger.createExceptionLog(jsonex);
        }
        catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);        
        }
        return JSONString;
    }
}