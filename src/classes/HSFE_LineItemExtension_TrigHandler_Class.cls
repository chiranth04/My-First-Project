/* Class Name :HSFE_LineItemExtension_TrigHandler_Class 
*Description :Trigger Handler for the Line Item Extension SObject, which implements all the logic of Line Item Extension trigger.
*Created By :Prateek Saxena
*Created On :06/09/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
* Prateek Saxena             06/09/2015                      IntegrationStatus update logic on Quote based on the Line Item status.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class HSFE_LineItemExtension_TrigHandler_Class {

    /*******************************************************************************************************************************************
     * Method Name: updateContractIntegrationStatusOnQuote
     * Description: updates the Contract and Freight Integration Status and Freight Charges on Quote if updated by the MuleSoft Integration User
                    on Line Item Extension object. 
     * Return Type: None.
     ****************************************************************************************************************************************/
    public static void updateContractIntegrationStatusOnQuote (List<HSFE_Line_Item_Extension__c> itemList, Map<Id,HSFE_Line_Item_Extension__c> oldItemMap){
        System.debug('************************* In updateContractIntegrationStatusOnQuote Method ***');
        try {
            HSFE_Line_Item_Extension__c oldItem;
            Set<Id> ProductConfigIdSet = new Set<Id>();
            Set<Id> setProdConfigId= new Set<Id>();
            Set<Id> quoteIdSet = new Set<Id>();
            List<Id> contractErrList = new List<Id>();
            List<Id> freightErrList = new List<Id>();
            map<String,Integer> NumberVALines_Map = new map<String,Integer>(); //Added by Yunus
            map<Id,Boolean> mapQuoteVsSerialCheck= new map<Id,Boolean>();
            
            for (HSFE_Line_Item_Extension__c newItem : itemList){
                
                oldItem = oldItemMap.get(newItem.Id);
                system.debug('newItem.HSFE_Is_Serial_Valid__c' +newItem.HSFE_Is_Serial_Valid__c);
                system.debug('oldItem.HSFE_Is_Serial_Valid__c'+oldItem.HSFE_Is_Serial_Valid__c);
                // Changed Condition for not executing when Contract Price changed by Integration User Profile
                if (newItem.HSFE_Freight_Integration_Status__c != oldItem.HSFE_Freight_Integration_Status__c){
                    ProductConfigIdSet.add(newItem.HSFE_Product_Configuration__c);
                }
                if(newItem.HSFE_Freight_Integration_Status__c != oldItem.HSFE_Freight_Integration_Status__c){
                    if(newItem.HSFE_Contract_Code__c != ''){  //Added by Yunus: 
                         if(HSFE_Constant.stringContractCodes.contains(newItem.HSFE_Contract_Code__c)){
                            if(NumberVALines_Map.ContainsKey(newItem.Quote_Id__c))
                                NumberVALines_Map.put(newItem.Quote_Id__c,NumberVALines_Map.get(newItem.Quote_Id__c)+1);
                            else
                                NumberVALines_Map.put(newItem.Quote_Id__c,1);
                         }
                    }
                    if(newItem.HSFE_Contract_Integration_Status__c == HSFE_Constant.ERROR){     // populating Retry Object In Case of Error From MuleSoft
                        contractErrList.add(newItem.Id);
                    }
                    if(newItem.HSFE_Freight_Integration_Status__c == HSFE_Constant.ERROR){     // populating Retry Object In Case of Error From MuleSoft
                        freightErrList.add(newItem.Id);
                    }
                }
                
            }

            if(contractErrList.size() > 0){
                insertIntegrationRetryObject(contractErrList, HSFE_Constant.CONTRACT_PRICING);
            }
            if(freightErrList.size() > 0){
                insertIntegrationRetryObject(freightErrList, HSFE_Constant.FREIGHT_CHARGES);
            }
            List<HSFE_Line_Item_Extension__c> lineItemExtList = new List<HSFE_Line_Item_Extension__c>();
            if (ProductConfigIdSet.size() > 0){
                lineItemExtList = [Select Id,HSFE_Is_Serial_Valid__c,HSFE_Contract_Integration_Status__c, HSFE_Freight_Integration_Status__c, HSFE_Freight_Charges__c, 
                                HSFE_Product_Configuration__c, HSFE_Line_Item__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,HSFE_Product_Conditions__c
                            from HSFE_Line_Item_Extension__c 
                            where HSFE_Product_Configuration__c in :ProductConfigIdSet];
                System.debug('******************* lineItemExtList :' + lineItemExtList);
                Map<HSFE_Line_Item_Extension__c,Id> lineItemExtQuoteMap = new Map<HSFE_Line_Item_Extension__c,Id>();
                Map<Id,Apttus_Proposal__Proposal__c> quoteIdStatusMap;
                Map<Id,Apttus_Proposal__Proposal__c> quoteIdStatusOrgMap = new Map<Id,Apttus_Proposal__Proposal__c>();  // Added Prateek
                Apttus_Proposal__Proposal__c quoteProposalObj;
                String quoteId;
                for(HSFE_Line_Item_Extension__c lineItemExtObj : lineItemExtList){
                    quoteIdSet.add(lineItemExtObj.HSFE_Line_Item__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c);
                    quoteId = lineItemExtObj.HSFE_Line_Item__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c;
                    lineItemExtQuoteMap.put(lineItemExtObj,quoteId);
                }
                if (quoteIdSet.size() > 0){
                    quoteIdStatusMap = new Map<Id,Apttus_Proposal__Proposal__c>([Select Id,HSFE_Serial_Number_Valid__c ,HSFE_Is_VA1_VA2__c, HSFE_Contract_Integration_Status__c, HSFE_Freight_Charges__c, HSFE_Freight_Integration_Status__c from Apttus_Proposal__Proposal__c where Id in :quoteIdSet]);
                    quoteIdStatusOrgMap = quoteIdStatusMap.deepClone();
                    for(Apttus_Proposal__Proposal__c proposalObj : quoteIdStatusMap.values()){
                        proposalObj.HSFE_Contract_Integration_Status__c = HSFE_Constant.EMPTY_STRING;
                        proposalObj.HSFE_Freight_Integration_Status__c = HSFE_Constant.EMPTY_STRING;
                        proposalObj.HSFE_Serial_Number_Valid__c = true;
                        proposalObj.HSFE_Freight_Charges__c = 0.00;
                    }
                }
                
                if (lineItemExtQuoteMap.size() > 0 && quoteIdStatusMap.size() > 0){
                    String lineItemExtStatus;
                    String lineItemExtFreightStatus;
                    String quoteIdStatus;
                    String quoteIdFreightStatus;
                    Boolean sSerialNumberMatch;
                    Boolean quoteSerialNum;
                    for(HSFE_Line_Item_Extension__c lineItemExtObj : lineItemExtQuoteMap.keySet()){
                        lineItemExtStatus = lineItemExtObj.HSFE_Contract_Integration_Status__c;
                        lineItemExtFreightStatus = lineItemExtObj.HSFE_Freight_Integration_Status__c;
                        quoteId = lineItemExtQuoteMap.get(lineItemExtObj);
                        //check added on 7/30
                        if(quoteIdStatusMap.containsKey(quoteId)){
                          quoteIdStatus = quoteIdStatusMap.get(quoteId).HSFE_Contract_Integration_Status__c;
                          quoteIdFreightStatus = quoteIdStatusMap.get(quoteId).HSFE_Freight_Integration_Status__c;
  
                          if(HSFE_Constant.ERROR.equals(lineItemExtStatus)){
                              quoteIdStatusMap.get(quoteId).HSFE_Contract_Integration_Status__c = lineItemExtStatus;
                          }else if(HSFE_Constant.NOT_SYNCED.equals(lineItemExtStatus) && !HSFE_Constant.ERROR.equals(quoteIdStatus)){
                              quoteIdStatusMap.get(quoteId).HSFE_Contract_Integration_Status__c = lineItemExtStatus;
                          }else if(HSFE_Constant.SENT_TO_SAP.equals(lineItemExtStatus) && !HSFE_Constant.ERROR.equals(quoteIdStatus) &&
                                  !HSFE_Constant.NOT_SYNCED.equals(quoteIdStatus)){
                              quoteIdStatusMap.get(quoteId).HSFE_Contract_Integration_Status__c = lineItemExtStatus;
                          }else if(HSFE_Constant.SYNCED.equals(lineItemExtStatus) && !HSFE_Constant.ERROR.equals(quoteIdStatus) &&
                                  !HSFE_Constant.NOT_SYNCED.equals(quoteIdStatus) && !HSFE_Constant.SENT_TO_SAP.equals(quoteIdStatus)){
                              quoteIdStatusMap.get(quoteId).HSFE_Contract_Integration_Status__c = lineItemExtStatus;
                          }
                          else if(HSFE_Constant.NOT_IN_SAP.equals(lineItemExtStatus) && !HSFE_Constant.ERROR.equals(quoteIdStatus) &&
                                  !HSFE_Constant.NOT_SYNCED.equals(quoteIdStatus) && !HSFE_Constant.SENT_TO_SAP.equals(quoteIdStatus) && 
                                  !HSFE_Constant.SYNCED.equals(quoteIdStatus)){
                              quoteIdStatusMap.get(quoteId).HSFE_Contract_Integration_Status__c = HSFE_Constant.SYNCED;
                          }
  
                          // Freight Status Update
                          if(HSFE_Constant.ERROR.equals(lineItemExtFreightStatus)){
                                      quoteIdStatusMap.get(quoteId).HSFE_Freight_Integration_Status__c = lineItemExtFreightStatus;
                                      quoteIdStatusMap.get(quoteId).HSFE_Freight_Charges__c = 0.00;
                                  }
                          else if(HSFE_Constant.NOT_SYNCED.equals(lineItemExtFreightStatus) && !HSFE_Constant.ERROR.equals(quoteIdFreightStatus)){
                              quoteIdStatusMap.get(quoteId).HSFE_Freight_Integration_Status__c = lineItemExtFreightStatus;
                              quoteIdStatusMap.get(quoteId).HSFE_Freight_Charges__c = 0.00;
                          }
                          else if(HSFE_Constant.SENT_TO_SAP.equals(lineItemExtFreightStatus) && !HSFE_Constant.ERROR.equals(quoteIdFreightStatus) &&
                                      !HSFE_Constant.NOT_SYNCED.equals(quoteIdFreightStatus)){
                                          quoteIdStatusMap.get(quoteId).HSFE_Freight_Integration_Status__c = lineItemExtFreightStatus;
                                          quoteIdStatusMap.get(quoteId).HSFE_Freight_Charges__c = 0.00;
                                      }
                          else if(HSFE_Constant.SYNCED.equals(lineItemExtFreightStatus) && !HSFE_Constant.ERROR.equals(quoteIdFreightStatus) &&
                                      !HSFE_Constant.NOT_SYNCED.equals(quoteIdFreightStatus) && !HSFE_Constant.SENT_TO_SAP.equals(quoteIdFreightStatus)){
                                          quoteIdStatusMap.get(quoteId).HSFE_Freight_Integration_Status__c = lineItemExtFreightStatus;
                                          if (null != lineItemExtObj.HSFE_Freight_Charges__c){
                                              quoteIdStatusMap.get(quoteId).HSFE_Freight_Charges__c = quoteIdStatusMap.get(quoteId).HSFE_Freight_Charges__c + lineItemExtObj.HSFE_Freight_Charges__c;
                                          }
                                          if(NumberVALines_Map.ContainsKey(quoteId)){
                                              if(NumberVALines_Map.get(quoteId) > 0)
                                                  quoteIdStatusMap.get(quoteId).HSFE_Is_VA1_VA2__c = True;
                                                  System.debug('**************************'+NumberVALines_Map);
                                          }else{
                                              quoteIdStatusMap.get(quoteId).HSFE_Is_VA1_VA2__c = False;
                                          }                                                                                   
                                      }
                          else if(HSFE_Constant.NOT_IN_SAP.equals(lineItemExtFreightStatus) && !HSFE_Constant.ERROR.equals(quoteIdFreightStatus) &&
                                      !HSFE_Constant.NOT_SYNCED.equals(quoteIdFreightStatus) && !HSFE_Constant.SENT_TO_SAP.equals(quoteIdFreightStatus)){
                                          quoteIdStatusMap.get(quoteId).HSFE_Freight_Integration_Status__c = HSFE_Constant.SYNCED;
                                      }
                          /******************************Added by Divya*******************************************************************/
                            if(!lineItemExtObj.HSFE_Is_Serial_Valid__c && lineItemExtObj.HSFE_Product_Conditions__c== 'Trade-In - Olympus' ){
                                quoteIdStatusMap.get(quoteId).HSFE_Serial_Number_Valid__c = false;
                            }
                            
                           /**************************************Code added by Divya ends******************************************************************/ 
                       
                        }//End of null check                                
                    }

                    List<Apttus_Proposal__Proposal__c> quoteProposalObjList = new List<Apttus_Proposal__Proposal__c>();
                    for(Id id : quoteIdStatusMap.keySet()){     // If Contract or Freight Status is diffrent from Existing on Quote                        
                        if (quoteIdStatusMap.get(id).HSFE_Contract_Integration_Status__c != quoteIdStatusOrgMap.get(id).HSFE_Contract_Integration_Status__c ||
                                quoteIdStatusMap.get(id).HSFE_Freight_Integration_Status__c != quoteIdStatusOrgMap.get(id).HSFE_Freight_Integration_Status__c||
                                quoteIdStatusMap.get(id).HSFE_Serial_Number_Valid__c != quoteIdStatusOrgMap.get(id).HSFE_Serial_Number_Valid__c){
                                quoteProposalObjList.add(quoteIdStatusMap.get(id));
                        }
                    }
                    if (!quoteProposalObjList.isEmpty()){             //Update The Quote Object
                        HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = true; //setting Flag to restrict executing the Custom Trigger logic on Quote
                        Update quoteProposalObjList;
                    }
                }
            }
            
        }
        catch(Exception ex){
            System.debug('************** Exception in updateContractIntegrationStatusOnQuote method for Line Item Extension Trigger.');
            HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception.
        }
    }

    /*******************************************************************************************************************************************
     * Method Name: insertIntegrationRetryObject
     * Description: Inserts Integration Retry Object in Case of Error Status from Mule or in Case of Callout Exception. 
     * Return Type: None.
     ****************************************************************************************************************************************/
    public static void insertIntegrationRetryObject(List<Id> recList, String interfaceName){
        if (null != recList && !recList.isEmpty()){
            try {
                HSFE_Integration_Retry_Object__c integrationRetryObject;
                List<HSFE_Integration_Retry_Object__c> integrationRetryObjectList = new List<HSFE_Integration_Retry_Object__c>();
                for (Id var : recList){
                    
                    integrationRetryObject = new HSFE_Integration_Retry_Object__c();
                    integrationRetryObject.Name = interfaceName;
                    integrationRetryObject.HSFE_Object_Name__c = HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME;
                    integrationRetryObject.HSFFE_Interface_External_Id__c = String.valueOf(var) + interfaceName;
                    integrationRetryObject.HSFE_Record_Id__c = var;
                    integrationRetryObject.HSFE_Request_Processed_Flag__c = false;
                    integrationRetryObjectList.add(integrationRetryObject);
                }
                if(integrationRetryObjectList.size() > 0){
                    Upsert integrationRetryObjectList HSFFE_Interface_External_Id__c;
                }
            }
            catch (Exception ex){
                System.debug('************** Exception in insertIntegrationRetryObject method for Line Item Extension Trigger.');
                HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception.
            }
            
        }
    }

    /*******************************************************************************************************************************************
     * Method Name: updateIntegrationStatusOnQuote
     * Description: updates the Contract and Freight Integration Status and Freight Charges on Quote if updated by the User
                    on Line Item Extension object. 
     * Return Type: None.
     ****************************************************************************************************************************************/
    public static void updateIntegrationStatusOnQuote(List<HSFE_Line_Item_Extension__c> itemList, Map<Id,HSFE_Line_Item_Extension__c> oldItemMap){
        try {
            System.debug('****************************** In updateIntegrationStatusOnQuote ************************');
            HSFE_Line_Item_Extension__c oldItem;
            Map<Id, Apttus_Proposal__Proposal__c> quoteIdObjMap = new Map<Id, Apttus_Proposal__Proposal__c>();
            Map<Id,Apttus_Proposal__Proposal__c> quoteIdStatusOrgMap = new Map<Id,Apttus_Proposal__Proposal__c>();
            Map<Id, Apttus_Proposal__Proposal__c> mapQuoteIdObj = new Map<Id, Apttus_Proposal__Proposal__c>();
            Map<Id,Apttus_Proposal__Proposal__c> mapQuoteIdStatusOrg = new Map<Id,Apttus_Proposal__Proposal__c>();
            List<Id> contractErrList = new List<Id>();
            List<Id> freightErrList = new List<Id>();
            Set<Id> quoteIdSet = new Set<Id>();

            for (HSFE_Line_Item_Extension__c newItem : itemList){
                quoteIdSet.add(newItem.Quote_Id__c);
            }
            System.debug('************************* Quote ID Set : ' + quoteIdSet);
            quoteIdObjMap = new Map<Id,Apttus_Proposal__Proposal__c>([Select Id, HSFE_Serial_Number_Valid__c ,HSFE_Contract_Integration_Status__c, HSFE_Freight_Charges__c, HSFE_Freight_Integration_Status__c from Apttus_Proposal__Proposal__c where Id in :quoteIdSet]);
            System.debug('************************* quoteIdObjMap : ' + quoteIdObjMap);
            quoteIdStatusOrgMap = quoteIdObjMap.deepClone();
            System.debug('************************* quoteIdStatusOrgMap : ' + quoteIdStatusOrgMap);
            String quoteContractIntStatus;
            String quoteFreightIntStatus;
            Boolean sSerialNumberMatch;
            Boolean quoteSerialNum;
            for (HSFE_Line_Item_Extension__c newItem : itemList){
                
                oldItem = oldItemMap.get(newItem.Id);
                if (newItem.HSFE_Contract_Integration_Status__c != oldItem.HSFE_Contract_Integration_Status__c ||
                    newItem.HSFE_Freight_Integration_Status__c != oldItem.HSFE_Freight_Integration_Status__c ||newItem.HSFE_Is_Serial_Valid__c!= oldItem.HSFE_Is_Serial_Valid__c){

                    System.debug('************************* Inside IF*******************');
                    if(quoteIdObjMap.containsKey(newItem.Quote_Id__c)){
                        quoteContractIntStatus = quoteIdObjMap.get(newItem.Quote_Id__c).HSFE_Contract_Integration_Status__c;
                        quoteFreightIntStatus = quoteIdObjMap.get(newItem.Quote_Id__c).HSFE_Freight_Integration_Status__c;                 
                        //quoteSerialNum=quoteIdObjMap.get(newItem.Quote_Id__c).HSFE_Serial_Number_Valid__c ;
                        
                        System.debug('************************* quoteContractIntStatus' + quoteContractIntStatus);
                        System.debug('************************* quoteFreightIntStatus' + quoteFreightIntStatus);
                        
                        /************************************Divya Added************************************************/
                        if (newItem.HSFE_Is_Serial_Valid__c!= oldItem.HSFE_Is_Serial_Valid__c && newItem.HSFE_Product_Conditions__c== 'Trade-In - Olympus'){                           
                            quoteIdObjMap.get(newItem.Quote_Id__c).HSFE_Serial_Number_Valid__c =newItem.HSFE_Is_Serial_Valid__c;                         
                    
                        }
                        /************************************Divya Code ends************************************************/
                        if ((newItem.HSFE_Contract_Integration_Status__c != oldItem.HSFE_Contract_Integration_Status__c) && 
                            (!HSFE_Constant.ERROR.equals(quoteContractIntStatus) && !HSFE_Constant.SENT_TO_SAP.equals(quoteContractIntStatus))){
                            quoteIdObjMap.get(newItem.Quote_Id__c).HSFE_Contract_Integration_Status__c = newItem.HSFE_Contract_Integration_Status__c == HSFE_Constant.NOT_IN_SAP ? HSFE_Constant.SYNCED : newItem.HSFE_Contract_Integration_Status__c;
                        }
                        System.debug('************************* quoteIdObjMap : ' + quoteIdObjMap);
                        if ((newItem.HSFE_Freight_Integration_Status__c != oldItem.HSFE_Freight_Integration_Status__c) && 
                            (!HSFE_Constant.ERROR.equals(quoteFreightIntStatus) && !HSFE_Constant.SENT_TO_SAP.equals(quoteFreightIntStatus) && !HSFE_Constant.NOT_SYNCED.equals(quoteFreightIntStatus))){ //Sourav 08032015 Changed condition to include not Synched as part of Change to make submit for approval button read only when freight charges are not received
                            quoteIdObjMap.get(newItem.Quote_Id__c).HSFE_Freight_Integration_Status__c = newItem.HSFE_Freight_Integration_Status__c == HSFE_Constant.NOT_IN_SAP ? HSFE_Constant.SYNCED : newItem.HSFE_Freight_Integration_Status__c;
                        }
                    }
                    System.debug('************************** quoteIdObjMap : ' + quoteIdObjMap);
                    if(newItem.HSFE_Contract_Integration_Status__c == HSFE_Constant.ERROR){     // populating Retry Object In Case of Error From MuleSoft
                        contractErrList.add(newItem.Id);
                    }
                    if(newItem.HSFE_Freight_Integration_Status__c == HSFE_Constant.ERROR){     // populating Retry Object In Case of Error From MuleSoft
                        freightErrList.add(newItem.Id);
                    }
                }
            }
            if(contractErrList.size() > 0){
                insertIntegrationRetryObject(contractErrList, HSFE_Constant.CONTRACT_PRICING);
            }
            if(freightErrList.size() > 0){
                insertIntegrationRetryObject(freightErrList, HSFE_Constant.FREIGHT_CHARGES);
            }

            List<Apttus_Proposal__Proposal__c> quoteProposalObjList = new List<Apttus_Proposal__Proposal__c>();
                for(Id id : quoteIdObjMap.keySet()){     // If Contract or Freight Status is diffrent from Existing on Quote                        
                    if (quoteIdObjMap.get(id).HSFE_Contract_Integration_Status__c != quoteIdStatusOrgMap.get(id).HSFE_Contract_Integration_Status__c ||
                            quoteIdObjMap.get(id).HSFE_Freight_Integration_Status__c != quoteIdStatusOrgMap.get(id).HSFE_Freight_Integration_Status__c||quoteIdObjMap.get(id).HSFE_Serial_Number_Valid__c!=quoteIdStatusOrgMap.get(id).HSFE_Serial_Number_Valid__c){
                            quoteProposalObjList.add(quoteIdObjMap.get(id));
                    }
                }
                System.debug('**************************** quoteProposalObjList' +  quoteProposalObjList);
                if (!quoteProposalObjList.isEmpty()){             //Update The Quote Object
                    HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = true; //setting Flag to restrict executing the Custom Trigger logic on Quote
                    Update quoteProposalObjList;
                }
          
        }
        catch (Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);
        }
    }
    
    public static void updateQuote(Set<Id> configSetIds){

        map<id,Boolean> NumberVALines_Map = new map<id,Boolean>();
        List <Apttus_Proposal__Proposal__c> quotelisttoUpdate = new List <Apttus_Proposal__Proposal__c>();
        try {                
            for(HSFE_Line_Item_Extension__c litem : [Select Id,HSFE_Contract_Integration_Status__c,Quote_Id__c, HSFE_Freight_Integration_Status__c, HSFE_Freight_Charges__c, HSFE_Product_Configuration__c,HSFE_Line_Item__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c , HSFE_Contract_Code__c
                                                    from HSFE_Line_Item_Extension__c 
                                                    where HSFE_Product_Configuration__c in :configSetIds]) {
                                                    
                NumberVALines_Map.put(litem.Quote_Id__c,False);
                if(litem.HSFE_Contract_Code__c != null){                            
                    if(HSFE_Constant.stringContractCodes.contains(litem.HSFE_Contract_Code__c)){
                        if(NumberVALines_Map.ContainsKey(litem.Quote_Id__c)){
                            if(HSFE_Constant.stringContractCodes.contains(litem.HSFE_Contract_Code__c))
                                NumberVALines_Map.put(litem.Quote_Id__c,True);               
                        }
                    }
                }  
            }
               
            for(Apttus_Proposal__Proposal__c quote : [Select id, HSFE_Is_VA1_VA2__c from Apttus_Proposal__Proposal__c where id in: NumberVALines_Map.KeySet()]) {
                if(NumberVALines_Map.ContainsKey(quote.id)) 
                    quote.HSFE_Is_VA1_VA2__c = NumberVALines_Map.get(quote.id);
                    quotelisttoUpdate.add(quote);
            }
        
            if(quotelisttoUpdate.size() > 0){
                HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = true;
                update quotelisttoUpdate;
            }    
        }catch (Exception e) {
            HSFE_ExceptionLogger.createExceptionLog(e);
        }   
    }         
}