/* 
* Class Name  : HSFE_Proposal_TriggerHandler_Class
* Description : Trigger Handler for the Proposal SObject, which implements all the logic.
* Created By  : Yunus H Navalur
* Created On  : 4/3/2015
*
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                             Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Yunus                      4/3/2015
* Kritika                    4/17/2015                      Update the Quote Version Number on Opportunity
* chiranth                   4/22/2015                      Added logic to update the opportunity status to verbally accepted if quote status is Verbally accepted in UpdateOpportunityOnProposalChange_AfterUpdate method
* Kritika                    4/22/2015                      Added new method to update version on Proposal Insert.
* Teena                      4/27/2015                      Added new method to revert Generated and Preseneted statuses when applicable 
* Kritika                    5/5/2015                       Added the code for Auto Sync Functionality 
* Kumar Gaurav               5/05/2015                      Added try catch for DML statement
* Prateek                    5/11/2015                      Added method GetFreightChargesOnStageChange_AfterUpdate to be triggered on After Update.
* Yunus                      5/12/2015                      Adding FIT logic on Inert and Update. Adding new Method UpdatePrimary_FITLogic_BeforeUpdate
* Ajay Agnihotri             15/05/2015                     Adding Logic to Auto Populate the "Product Code" based on selected "Promotion Code Description".
* Ajay Agnihotri             18/05/2015                     Commented the Logic to query Pricebook as it was not getting used in code.
* Chiranth                   06/09/2015                     Added logic in UpdatePriceListOnProposal_BeforeInsert and UpdateBilltoAccountId_PayerAccountId_beforeUpdate method  (If FIS is true update the Bill to Account Id with FIS Bill To field else from Bill to Account Field and update Payer Account Id with FIS Payer field else from Payer Account field)
* Teena                      22/06/2015                     Updated logic for Opportunity Products such that the Total Amount, Capital etc fields are drawn from Proposal and not Cart 
* Ajay Agnihotri             22/06/2015                     Modified the version Logic To Update Version Count on every Insert (Ajay Agnihotri)
                                                            Fixed the Rollback Logic so that it is executed everytime the status is changed or Primary Checkbox is changed.* Ajay Agnihotri            26/06/2015                      Updated Code w.r.t Code Review.
* Ajay Agnihotri             26/06/2015                     Updated Code w.r.t Code Review.
* Chiranth Aradhya           02/07/2015                     Added one more method to update the opportunity based on proposal order status field (UpdateOpportunitySalesStage)
* Ajay Agnihotri             1/07/2015                      Updated Rollup for Amount while Primary Quote is in 'In Review' Stage
* Ajay Agnihotri             6/07/2014                      Remove or Comment the logic to Updated Amount  and Sync in Opportunity. 
*/

public class HSFE_Proposal_TriggerHandler_Class{
    
        
    /***************************************************************************************************************************************
    * Method Name: UpdatePriceListOnProposal_BeforeInsert
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void UpdatePriceListOnProposal_BeforeInsert(List<Apttus_Proposal__Proposal__c> NewRecords_List, List<Apttus_Proposal__Proposal__c> OldRecords_List, map<id,Apttus_Proposal__Proposal__c> NewProposalRecords, map<id,Apttus_Proposal__Proposal__c> OldProposalRecords){  
        try{
            if(NewRecords_List != null)
                for(Apttus_Proposal__Proposal__c ProposalRecord : NewRecords_List){
                    if(HSFE_Contant_Helper__c.getValues('HSFE_Olympus_MSG_NA').HSFE_Value__c != null)
                        ProposalRecord.Apttus_QPConfig__PriceListId__c = HSFE_Contant_Helper__c.getValues('HSFE_Olympus_MSG_NA').HSFE_Value__c;                
                    //If FIS is true update the Bill to Account Id with FIS Bill To field else from Bill to Account Field and update Payer Account Id with FIS Payer field else from Payer Account field
                    if(ProposalRecord.HSFE_Is_FIS__c == True){
                        ProposalRecord.HSFE_Payer_Account_Id__c=ProposalRecord.HSFE_FIS_Payer__c;
                        ProposalRecord.HSFE_Bill_to_Account_Id__c =ProposalRecord.HSFE_FIS_Bill_To__c;
                    }else{
                        ProposalRecord.HSFE_Payer_Account_Id__c=ProposalRecord.HSFE_Payer_Account__c;
                        ProposalRecord.HSFE_Bill_to_Account_Id__c =ProposalRecord.HSFE_Bill_To_Account__c;
                    }
                }   
        
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }
                 
    }
    
    
    
    /***************************************************************************************************************************************
    * Method Name: PrimaryQuoteLogic_BeforeInsert
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void PrimaryQuoteLogic_BeforeInsert(List<Apttus_Proposal__Proposal__c> NewRecords_List, List<Apttus_Proposal__Proposal__c> OldRecords_List, map<id,Apttus_Proposal__Proposal__c> NewProposalRecords, map<id,Apttus_Proposal__Proposal__c> OldProposalRecords){
        
        map<id,id> Oppr_PrimaryQuoteIds = new map<id,id>();
        map<id,boolean> Oppr_PrimaryQuoteReady = new map<id,boolean>();
        list<Apttus_Proposal__Proposal__c> UpdateProposal = new list<Apttus_Proposal__Proposal__c>();
        
        try{
            for(Apttus_Proposal__Proposal__c ProposalRecord : NewRecords_List){
                if(ProposalRecord.HSFE_FIT_Quote__c == false){
                    Oppr_PrimaryQuoteIds.put(ProposalRecord.Apttus_Proposal__Opportunity__c,null);
                }
            }
            if(Oppr_PrimaryQuoteIds != null){
            
                for(Apttus_Proposal__Proposal__c ProposalRec: [select id, Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c in: Oppr_PrimaryQuoteIds.KeySet() and Apttus_Proposal__Primary__c =: True ]){
                    
                    if(ProposalRec.Apttus_Proposal__Approval_Stage__c != HSFE_Constant.CUSTOM_QUOTE_ACCEPTED){
                        if(Oppr_PrimaryQuoteIds.ContainsKey(ProposalRec.Apttus_Proposal__Opportunity__c)){
                            Oppr_PrimaryQuoteIds.put(ProposalRec.Apttus_Proposal__Opportunity__c,ProposalRec.id);
                            Oppr_PrimaryQuoteReady.put(ProposalRec.id,true);
                            ProposalRec.Apttus_Proposal__Primary__c = false; 
                            UpdateProposal.add(ProposalRec);                    
                        }
                    }else{
                        Oppr_PrimaryQuoteIds.put(ProposalRec.Apttus_Proposal__Opportunity__c,ProposalRec.id);
                        Oppr_PrimaryQuoteReady.put(ProposalRec.id,false);
                    }    
                }
                
                if(UpdateProposal != null){
                    HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = true; // Code Optimization 22
                    Update UpdateProposal;
                    HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = false; // Code Optimization 22
                }
                    
                for(Apttus_Proposal__Proposal__c ProposalRecord : NewRecords_List){
                    //This condition will work only if there are existing Primary quote for a Opportunity. 
                    //If there are no Quotes present under an opportunity then by default Apttus will make it primary                   
                    if(Oppr_PrimaryQuoteIds.containsKey(ProposalRecord.Apttus_Proposal__Opportunity__c)){
                        if(Oppr_PrimaryQuoteReady.ContainsKey(Oppr_PrimaryQuoteIds.get(ProposalRecord.Apttus_Proposal__Opportunity__c))){
                            if(Oppr_PrimaryQuoteReady.get(Oppr_PrimaryQuoteIds.get(ProposalRecord.Apttus_Proposal__Opportunity__c))){
                                ProposalRecord.Apttus_Proposal__Primary__c = true;
                                ProposalRecord.HSFE_Previous_Primary_Quote__c = Oppr_PrimaryQuoteIds.get(ProposalRecord.Apttus_Proposal__Opportunity__c);
                            }else{
                                ProposalRecord.Apttus_Proposal__Primary__c = false;
                            }
                        }else{
                            ProposalRecord.Apttus_Proposal__Primary__c = true;
                        }
                    }
                }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }         
    }    

    
    
    /***************************************************************************************************************************************
    * Method Name: UpdateRelatedAccounts_BeforeInsert
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void UpdateRelatedAccounts_BeforeInsert(List<Apttus_Proposal__Proposal__c> NewRecords_List){       
        try{ 
            Set<Id> accIds = new Set<Id>();
            Map <Id, Id> billToMap = new Map <Id, Id>();       
            Map <Id, Id> shipToMap= new Map <Id, Id>();
            Map <Id, Id> payerMap= new Map <Id, Id>();


            for(Apttus_Proposal__Proposal__c ProposalRecord : NewRecords_List){
             accIds.add(ProposalRecord.Apttus_Proposal__Account__c);
            }

            List <Account> accLst = new List <Account>();
            accLst = [Select id, HSFE_Number_of_Related_BillTo__c, HSFE_Number_of_Related_Ship_To_Accounts__c ,HSFE_Number_of_Related_Payer_Accounts__c from Account where id IN:accIds];
            List <HSFE_Related_Account__c> relAccountsLst = new List<HSFE_Related_Account__c>();
            relAccountsLst= [Select id, HSFE_Relationship_Type__c, HSFE_Sold_To_Account__c,HSFE_Sold_To_Account__r.HSFE_Number_of_Related_BillTo__c, HSFE_Sold_To_Account__r.HSFE_Number_of_Related_Ship_To_Accounts__c,HSFE_Sold_To_Account__r.HSFE_Number_of_Related_Payer_Accounts__c from HSFE_Related_Account__c where HSFE_Sold_To_Account__c IN :accIds];         

            for (HSFE_Related_Account__c relAccount : relAccountsLst) {
                if (relAccount.HSFE_Relationship_Type__c=='Bill To' && relAccount.HSFE_Sold_To_Account__r.HSFE_Number_of_Related_BillTo__c==1)
                    billToMap.put(relAccount.HSFE_Sold_To_Account__r.id, relAccount.id);    
                else if (relAccount.HSFE_Relationship_Type__c=='Ship To' && relAccount.HSFE_Sold_To_Account__r.HSFE_Number_of_Related_Ship_To_Accounts__c==1)
                    shipToMap.put(relAccount.HSFE_Sold_To_Account__r.id, relAccount.id);     
                else if (relAccount.HSFE_Relationship_Type__c=='Payer' && relAccount.HSFE_Sold_To_Account__r.HSFE_Number_of_Related_Payer_Accounts__c==1)
                    payerMap.put(relAccount.HSFE_Sold_To_Account__r.id, relAccount.id);    
            }
  
            for(Apttus_Proposal__Proposal__c newProposalRec: NewRecords_List){
             if(billToMap.get(newProposalRec.Apttus_Proposal__Account__c)!=null) {
                 newProposalRec.HSFE_Bill_To_Account__c=billToMap.get(newProposalRec.Apttus_Proposal__Account__c);
             }    
             if(shipToMap.get(newProposalRec.Apttus_Proposal__Account__c)!=null) {
                 newProposalRec.HSFE_Ship_To_Account__c=shipToMap.get(newProposalRec.Apttus_Proposal__Account__c);
             }

             if(payerMap.get(newProposalRec.Apttus_Proposal__Account__c)!=null) {
                 newProposalRec.HSFE_Payer_Account__c=payerMap.get(newProposalRec.Apttus_Proposal__Account__c);
             }                 
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }   
     }
     
 
/***************************************************************************************************************************************
    * Method Name: UpdatePrimaryContact_BeforeInsert
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void UpdatePrimaryContact_BeforeInsert(List<Apttus_Proposal__Proposal__c> NewRecords_List){
        try{
            Set<Id> accIds = new Set<Id>();
            Set<String> specialtySubSpecialtyLst = new Set <String>();
            Set<Id> oppIds=new Set<Id>();
            List<Opportunity> oppList = new List<Opportunity>();
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
            Map <String, id> conMap = new Map<String, id>();
            List <Contact> relConLst = new List <Contact>();
            
            for(Apttus_Proposal__Proposal__c ProposalRecord : NewRecords_List){
                oppIds.add(ProposalRecord.Apttus_Proposal__Opportunity__c);
                if (ProposalRecord.HSFE_Opp_SpecialtySubSpecialty__c!='') {
                    accIds.add(ProposalRecord.Apttus_Proposal__Account__c);
                    specialtySubSpecialtyLst.add(ProposalRecord.HSFE_Opp_SpecialtySubSpecialty__c);
                }
            }
            
            relConLst = [Select Id, HSFE_Primary__c, HSFE_Specialty__c, HSFE_Sub_Specialty__c, HSFE_AccCon_SpecialtySubSpecialty__c, AccountId FROM Contact where AccountId IN:accIds AND HSFE_AccCon_SpecialtySubSpecialty__c IN:specialtySubSpecialtyLst AND HSFE_Primary__c=TRUE];
            if(relConLst!=null) {
                for (Contact c : relConLst) {
                    // if(c.HSFE_AccCon_SpecialtySubSpecialty__c!=String.(c.AccountId))
                    conMap.put(c.HSFE_AccCon_SpecialtySubSpecialty__c, c.id);
                }
            }
            
            //Query the porposal opportunity
            oppList =[select Id,HSFE_Contact__c  from Opportunity where Id IN:oppIds];
            if(oppList.size()>0){
                for(Opportunity opp:oppList){
                    oppMap.put(opp.Id,opp);
                }
            }
            
            String accId;
            for(Apttus_Proposal__Proposal__c newProposalRec: NewRecords_List){
                accId=newProposalRec.Apttus_Proposal__Account__c;
                //Update primary Contact with opportunity contact
                
                if(oppMap.ContainsKey(newProposalRec.Apttus_Proposal__Opportunity__c)){
                    if(oppMap.get(newProposalRec.Apttus_Proposal__Opportunity__c).HSFE_Contact__c != null)
                        newProposalRec.HSFE_Primary_Con__c = oppMap.get(newProposalRec.Apttus_Proposal__Opportunity__c).HSFE_Contact__c;
                }
                //If opportunity contact is blank the update with Account primary contact with matched opportunities specialty and sub specialty
                else if(conMap.get(newProposalRec.HSFE_Opp_SpecialtySubSpecialty__c)!=null && newProposalRec.HSFE_Opp_SpecialtySubSpecialty__c!=accId){
                    newProposalRec.HSFE_Primary_Con__c=conMap.get(newProposalRec.HSFE_Opp_SpecialtySubSpecialty__c);
                }    
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }   
    }
    /***************************************************************************************************************************************
    * Method Name: InsertIntegrationRetryObject_AfterUpdate
    * Description: Inserts the Integration retry Object in Case of Quote to Order Status is updated to 'Error'.
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void InsertIntegrationRetryObject_AfterUpdate(List<Apttus_Proposal__Proposal__c> NewRecords_List, Map<id,Apttus_Proposal__Proposal__c> OldProposalRecords){
        try{
            System.debug('************************* In Method InsertIntegrationRetryObject_BeforeUpdate');
            Apttus_Proposal__Proposal__c oldQuoteObj;
            HSFE_Integration_Retry_Object__c integrationRetryObject;
            List<HSFE_Integration_Retry_Object__c> integrationRetryObjectList = new List<HSFE_Integration_Retry_Object__c>();
            if (null != NewRecords_List && !NewRecords_List.isEmpty() && null != OldProposalRecords && !OldProposalRecords.isEmpty()){
                for(Apttus_Proposal__Proposal__c quoteObj : NewRecords_List){
                    oldQuoteObj = OldProposalRecords.get(quoteObj.Id);
                    if(quoteObj.HSFE_Order_Status__c != oldQuoteObj.HSFE_Order_Status__c && quoteObj.HSFE_Order_Status__c == HSFE_Constant.FAILED){
                        integrationRetryObject = new HSFE_Integration_Retry_Object__c();
                        integrationRetryObject.Name = HSFE_Constant.QUOTE_TO_ORDER;
                        integrationRetryObject.HSFE_Object_Name__c = HSFE_Constant.QUOTE_PROPOSAL_OBJECT_API_NAME;
                        integrationRetryObject.HSFE_Record_Id__c = quoteObj.Id;
                        integrationRetryObject.HSFFE_Interface_External_Id__c = quoteObj.Id + HSFE_Constant.QUOTE_TO_ORDER;
                        integrationRetryObject.HSFE_Request_Processed_Flag__c = false;
                        integrationRetryObjectList.add(integrationRetryObject);
                    }
                }  
            }
            if (!integrationRetryObjectList.isEmpty()){
                Upsert integrationRetryObjectList HSFFE_Interface_External_Id__c;
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }       
    }
    
    
    /***************************************************************************************************************************************
    * Method Name: UpdateOpportunitySalesStage
    * Description: Update Opportunity Sales stage to Closed Won on Proposal order status changed to Created
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void UpdateOpportunitySalesStage(List<Apttus_Proposal__Proposal__c> NewRecords_List, List<Apttus_Proposal__Proposal__c> OldRecords_List, map<id,Apttus_Proposal__Proposal__c> NewProposalRecords, map<id,Apttus_Proposal__Proposal__c> OldProposalRecords){
        Map<id,boolean> OpportunityIdsWithCondition = new Map<id,boolean>();
        set<id>setOppIDs= new Set<Id>();
        List<Opportunity> UpdateOpp_Records = new List<Opportunity>();
        try{
            for(Apttus_Proposal__Proposal__c PropRec: NewProposalRecords.Values()){
                //check if Order status is completed and Quote is primary
                if(NewProposalRecords.get(PropRec.id).HSFE_Order_Status__c!= OldProposalRecords.get(PropRec.id).HSFE_Order_Status__c && PropRec.HSFE_Order_Status__c == HSFE_Constant.CUSTOM_QUOTE_ORDER_STATUS_CREATED  && PropRec.Apttus_Proposal__Primary__c == true){
                    OpportunityIdsWithCondition.put(PropRec.Apttus_Proposal__Opportunity__c,true);
                    setOppIDs.add(PropRec.Apttus_Proposal__Opportunity__c);
                }
            }
            //Added one more conditon (!setOppIDs.isEmpty()) to check the size of Opportunity set
            if(OpportunityIdsWithCondition != null && !setOppIDs.isEmpty()){
                for(Opportunity OppRec: [Select id,HSFE_Quote_OrderStatus_Completed__c,HSFE_Sales_Stage__c from Opportunity where id IN:setOppIDs ]){
                    if(OpportunityIdsWithCondition.ContainsKey(OppRec.Id)){
                        OppRec.HSFE_Quote_OrderStatus_Completed__c = OpportunityIdsWithCondition.get(OppRec.id);
                        OppRec.HSFE_Sales_Stage__c= HSFE_Constant.Custom_CLOSED_WON;
                        UpdateOpp_Records.add(OppRec);
                        
                    }
                }
                if(UpdateOpp_Records.size()>0){
                    Update UpdateOpp_Records;
                }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }                      
    }

    /***************************************************************************************************************************************
    * Method Name: UpdateOpportunityOnProposalChange_AfterUpdate
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void UpdateOpportunityOnProposalChange_AfterUpdate(List<Apttus_Proposal__Proposal__c> NewRecords_List, List<Apttus_Proposal__Proposal__c> OldRecords_List, map<id,Apttus_Proposal__Proposal__c> NewProposalRecords, map<id,Apttus_Proposal__Proposal__c> OldProposalRecords){
        
        Map<id,boolean> OpportunityIdsWithCondition = new Map<id,boolean>();
        Map<id,String> OpportunityIdsWithStatus = new Map<id,String>();
        set<id>setOppIDs= new Set<Id>();
        List<Opportunity> UpdateOpp_Records = new List<Opportunity>();
        try{
            for(Apttus_Proposal__Proposal__c PropRec: NewProposalRecords.Values()){
                //check if Quote status is verbally accepted and quote is primary
                if(NewProposalRecords.get(PropRec.id).Apttus_Proposal__Approval_Stage__c!= OldProposalRecords.get(PropRec.id).Apttus_Proposal__Approval_Stage__c && PropRec.Apttus_Proposal__Approval_Stage__c == HSFE_Constant.CUSTOM_QUOTE_VERBALLY_ACCEPTED && PropRec.Apttus_Proposal__Primary__c == true){
                    OpportunityIdsWithStatus.put(PropRec.Apttus_Proposal__Opportunity__c,HSFE_Constant.CUSTOM_QUOTE_VERBALLY_ACCEPTED);
                    setOppIDs.add(PropRec.Apttus_Proposal__Opportunity__c);
                }
            }
            if(OpportunityIdsWithStatus != null){
                for(Opportunity OppRec: [Select id,HSFE_Quote_OrderStatus_Completed__c,HSFE_Sales_Stage__c from Opportunity where id IN:setOppIDs ]){
                    if(OpportunityIdsWithStatus.ContainsKey(OppRec.Id)){
                        OppRec.HSFE_Sales_Stage__c = HSFE_Constant.CUSTOM_VERBALLY_ACCEPTED;
                        UpdateOpp_Records.add(OppRec);
                    }
                }
                if(UpdateOpp_Records.size()>0){
                    Update UpdateOpp_Records;
                }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }                      
    }
    
    /***************************************************************************************************************************************
    * Method Name: RevertApprovalStageToDraft_beforeUpdate
    * Description: This section has been added to revert the status from Generated,Presented when prior status of the quote is not Approved
    * Return Type: None.
    ***************************************************************************************************************************************/
    public static void RevertApprovalStageToDraft_beforeUpdate(list<Apttus_Proposal__Proposal__c> listNEWProposal, map<Id, Apttus_Proposal__Proposal__c> mapOLDProposal) {
        try{
            for(Apttus_Proposal__Proposal__c oProposal: listNEWProposal) {
            
                if(oProposal.Apttus_Proposal__Approval_Stage__c <> mapOLDProposal.get(oProposal.id).Apttus_Proposal__Approval_Stage__c){
                    Apttus_Proposal__Proposal__c oOldProposal = mapOLDProposal.get(oProposal.Id);
                    if((oProposal.Apttus_Proposal__Approval_Stage__c == 'Generated' && (oOldProposal.Apttus_Proposal__Approval_Stage__c<>'Approved'))||
                    (oProposal.Apttus_Proposal__Approval_Stage__c == 'Presented' &&(oOldProposal.Apttus_Proposal__Approval_Stage__c<>'Approved')&&(oOldProposal.Apttus_Proposal__Approval_Stage__c<>'Generated'))) {                        
                        oProposal.Apttus_Proposal__Approval_Stage__c = oOldProposal.Apttus_Proposal__Approval_Stage__c;              
                        oProposal.RecordTypeID =oOldProposal.RecordTypeID;
                    }
                }
                
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }   
    }
    
        
    
    /***************************************************************************************************************************************
    * Method Name: UpdateBilltoAccountId_PayerAccountId_beforeUpdate
    * Description: Update the Bill to Account Id and Payer Account ID
    * Return Type: None.
    ***************************************************************************************************************************************/
    public static void UpdateBilltoAccountId_PayerAccountId_beforeUpdate(list<Apttus_Proposal__Proposal__c> listNEWProposal, map<Id, Apttus_Proposal__Proposal__c> mapOLDProposal) {
        try{
            Set<ID> accIdsSet = new Set<ID>();
            Set<Id> accId = new Set<Id>();
            Set<Id> accSetId = new Set<Id>();
            Map<String,String> relatedMap = new Map<String,String>();
            Map<String, Id> QuoteAccIdMap = new Map<String, Id>();      
            for(Apttus_Proposal__Proposal__c oProposal: listNEWProposal) {
                if(oProposal.HSFE_Ship_To_Account__c !=  mapOLDProposal.get(oProposal.id).HSFE_Ship_To_Account__c){
                   accIdsSet.add(oProposal.HSFE_Ship_To_Account__c);
                   QuoteAccIdMap.put(oProposal.id + '|Ship', oProposal.HSFE_Ship_To_Account__c);
                 }          
                
                //If FIS is true update the Bill to Account Id with FIS Bill To field else from Bill to Account Field and update Payer Account Id with FIS Payer field else from Payer Account field
                if(oProposal.HSFE_Is_FIS__c == True && (oProposal.HSFE_Is_FIS__c != mapOLDProposal.get(oProposal.id).HSFE_Is_FIS__c || oProposal.HSFE_FIS_Bill_To__c != mapOLDProposal.get(oProposal.id).HSFE_FIS_Bill_To__c  || oProposal.HSFE_FIS_Payer__c != mapOLDProposal.get(oProposal.id).HSFE_FIS_Payer__c || oProposal.HSFE_Bill_To_Account__c != mapOLDProposal.get(oProposal.id).HSFE_Bill_To_Account__c || oProposal.HSFE_Payer_Account__c != mapOLDProposal.get(oProposal.id).HSFE_Payer_Account__c)){
                    accSetId.add(oProposal.HSFE_FIS_Bill_To__c);
                    accSetId.add(oProposal.HSFE_FIS_Payer__c);
                    QuoteAccIdMap.put(oProposal.id + '|BillTo', oProposal.HSFE_FIS_Bill_To__c);
                    QuoteAccIdMap.put(oProposal.id + '|Payer', oProposal.HSFE_FIS_Payer__c);
                    oProposal.HSFE_Payer_Account_Id__c=oProposal.HSFE_FIS_Payer__c;                
                    oProposal.HSFE_Bill_to_Account_Id__c =oProposal.HSFE_FIS_Bill_To__c;
                }else if(oProposal.HSFE_Is_FIS__c == False && (oProposal.HSFE_Is_FIS__c != mapOLDProposal.get(oProposal.id).HSFE_Is_FIS__c || oProposal.HSFE_FIS_Bill_To__c != mapOLDProposal.get(oProposal.id).HSFE_FIS_Bill_To__c  || oProposal.HSFE_FIS_Payer__c != mapOLDProposal.get(oProposal.id).HSFE_FIS_Payer__c || oProposal.HSFE_Bill_To_Account__c != mapOLDProposal.get(oProposal.id).HSFE_Bill_To_Account__c || oProposal.HSFE_Payer_Account__c != mapOLDProposal.get(oProposal.id).HSFE_Payer_Account__c)){
                    accIdsSet.add(oProposal.HSFE_Bill_To_Account__c);
                    accIdsSet.add(oProposal.HSFE_Payer_Account__c);
                    QuoteAccIdMap.put(oProposal.id + '|BillTo', oProposal.HSFE_Bill_To_Account__c);
                    QuoteAccIdMap.put(oProposal.id + '|Payer', oProposal.HSFE_Payer_Account__c);
                    oProposal.HSFE_Payer_Account_Id__c=oProposal.HSFE_Payer_Account__c;
                    oProposal.HSFE_Bill_to_Account_Id__c =oProposal.HSFE_Bill_To_Account__c;
                }
            }
           
            List<HSFE_Related_Account__c> relatedAcc = new List<HSFE_Related_Account__c>([select id,HSFE_Related_Account__c from HSFE_Related_Account__c where id IN:accIdsSet]);
            accId = accSetId.clone();
            for(HSFE_Related_Account__c rel : relatedAcc){
                relatedMap.put(rel.id,rel.HSFE_Related_Account__c);
                accId.add(rel.HSFE_Related_Account__c);
            }
            Map<Id,Account> accountmap = new Map<Id,Account>([SELECT ID,HSFE_SAP_ID__c from Account where ID IN :accId]);
            String accountId;
            for(Apttus_Proposal__Proposal__c oProposal: listNEWProposal){
                accountId = '';
                if(QuoteAccIdMap.containsKey(oProposal.id + '|Ship') && relatedMap.containskey(oProposal.HSFE_Ship_To_Account__c)){
                    accountId = relatedMap.get(oProposal.HSFE_Ship_To_Account__c);
                    if(accountmap.containskey(accountId))
                        oProposal.HSFE_Ship_To_Account_SAP_ID__c = accountmap.get(accountId).HSFE_SAP_ID__c;
                }
                if(QuoteAccIdMap.containsKey(oProposal.id + '|Payer')  && relatedMap.containskey(oProposal.HSFE_Payer_Account__c)){
                    accountId = relatedMap.get(oProposal.HSFE_Payer_Account__c);
                    if(accountmap.containskey(accountId))
                        oProposal.HSFE_Payer_Account_SAP_ID__c = accountmap.get(accountId).HSFE_SAP_ID__c;
                }
                else if(QuoteAccIdMap.containsKey(oProposal.id + '|Payer') && accountmap.containsKey(oProposal.HSFE_FIS_Payer__c)){
                    oProposal.HSFE_Payer_Account_SAP_ID__c = accountmap.get(oProposal.HSFE_FIS_Payer__c).HSFE_SAP_ID__c;
                }
                if(QuoteAccIdMap.containsKey(oProposal.id + '|BillTo') && relatedMap.containskey(oProposal.HSFE_Bill_To_Account__c)){
                    accountId = relatedMap.get(oProposal.HSFE_Bill_To_Account__c);
                    if(accountmap.containskey(accountId))
                        oProposal.HSFE_Bill_To_Account_SAP_ID__c= accountmap.get(accountId).HSFE_SAP_ID__c;
                }
                else if(QuoteAccIdMap.containsKey(oProposal.id + '|BillTo') && accountmap.containsKey(oProposal.HSFE_FIS_Bill_To__c)){
                    oProposal.HSFE_Bill_To_Account_SAP_ID__c = accountmap.get(oProposal.HSFE_FIS_Bill_To__c).HSFE_SAP_ID__c;
                }
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }     
    }
    /**************************************************************************************************************************************
    * Method Name: UpdateSAPID_beforeInsert
    * Description: 
    * Return Type: None.
   ************************************************************************************************************************************/
   public static void UpdateSAPID_beforeInsert(list<Apttus_Proposal__Proposal__c> listNEWProposal){
       try{
            Set<ID> accIdsSet = new Set<ID>();
            Set<Id> accId = new Set<Id>();
            Set<Id> accSetId = new Set<Id>();
            Map<String,String> relatedMap = new Map<String,String>();
            Map<String, Id> QuoteAccIdMap = new Map<String, Id>();      
            for(Apttus_Proposal__Proposal__c oProposal: listNEWProposal) {
                if(oProposal.HSFE_Ship_To_Account__c !=  null){
                   accIdsSet.add(oProposal.HSFE_Ship_To_Account__c);
                   QuoteAccIdMap.put(oProposal.id + '|Ship', oProposal.HSFE_Ship_To_Account__c);
                 }          
                system.debug('**************oProposal.HSFE_Payer_Account_Id__c****************'+oProposal.HSFE_Payer_Account_Id__c);
                //If FIS is true update the Bill to Account Id with FIS Bill To field else from Bill to Account Field and update Payer Account Id with FIS Payer field else from Payer Account field
                if(oProposal.HSFE_Is_FIS__c == True &&  (oProposal.HSFE_FIS_Bill_To__c != null || oProposal.HSFE_FIS_Payer__c!= null)){
                    accSetId.add(oProposal.HSFE_FIS_Bill_To__c);
                    accSetId.add(oProposal.HSFE_FIS_Payer__c);
                    QuoteAccIdMap.put(oProposal.id + '|BillTo', oProposal.HSFE_FIS_Bill_To__c);
                    QuoteAccIdMap.put(oProposal.id + '|Payer', oProposal.HSFE_FIS_Payer__c);
             
                }else if(oProposal.HSFE_Is_FIS__c == False && (oProposal.HSFE_Bill_To_Account__c != null || oProposal.HSFE_Payer_Account__c!= null)){
                    accIdsSet.add(oProposal.HSFE_Bill_To_Account__c);
                    accIdsSet.add(oProposal.HSFE_Payer_Account__c);
                    QuoteAccIdMap.put(oProposal.id + '|BillTo', oProposal.HSFE_Bill_To_Account__c);
                    QuoteAccIdMap.put(oProposal.id + '|Payer', oProposal.HSFE_Payer_Account__c);
               }
            }
            
            List<HSFE_Related_Account__c> relatedAcc = new List<HSFE_Related_Account__c>([select id,HSFE_Related_Account__c from HSFE_Related_Account__c where id IN:accIdsSet]);
            accId = accSetId.clone();
            for(HSFE_Related_Account__c rel : relatedAcc){
                relatedMap.put(rel.id,rel.HSFE_Related_Account__c);
                accId.add(rel.HSFE_Related_Account__c);
            }
            Map<Id,Account> accountmap = new Map<Id,Account>([SELECT ID,HSFE_SAP_ID__c from Account where ID IN :accId]);
            String accountId;
            for(Apttus_Proposal__Proposal__c oProposal: listNEWProposal){
                accountId = '';
                if(QuoteAccIdMap.containsKey(oProposal.id + '|Ship') && relatedMap.containskey(oProposal.HSFE_Ship_To_Account__c)){
                    accountId = relatedMap.get(oProposal.HSFE_Ship_To_Account__c);
                    if(accountmap.containskey(accountId))
                        oProposal.HSFE_Ship_To_Account_SAP_ID__c = accountmap.get(accountId).HSFE_SAP_ID__c;
                }
                if(QuoteAccIdMap.containsKey(oProposal.id + '|Payer')  && relatedMap.containskey(oProposal.HSFE_Payer_Account__c)){
                    
                    accountId = relatedMap.get(oProposal.HSFE_Payer_Account__c);
                    if(accountmap.containskey(accountId))
                        oProposal.HSFE_Payer_Account_SAP_ID__c = accountmap.get(accountId).HSFE_SAP_ID__c;
                }
                else if(QuoteAccIdMap.containsKey(oProposal.id + '|Payer') && accountmap.containsKey(oProposal.HSFE_FIS_Payer__c)){
                    oProposal.HSFE_Payer_Account_SAP_ID__c = accountmap.get(oProposal.HSFE_FIS_Payer__c).HSFE_SAP_ID__c;
                }
                if(QuoteAccIdMap.containsKey(oProposal.id + '|BillTo') && relatedMap.containskey(oProposal.HSFE_Bill_To_Account__c)){
                    accountId = relatedMap.get(oProposal.HSFE_Bill_To_Account__c);
                    if(accountmap.containskey(accountId))
                        oProposal.HSFE_Bill_To_Account_SAP_ID__c= accountmap.get(accountId).HSFE_SAP_ID__c;
                }
                else if(QuoteAccIdMap.containsKey(oProposal.id + '|BillTo') && accountmap.containsKey(oProposal.HSFE_FIS_Bill_To__c)){
                    oProposal.HSFE_Bill_To_Account_SAP_ID__c = accountmap.get(oProposal.HSFE_FIS_Bill_To__c).HSFE_SAP_ID__c;
                }
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }       
   }

    /***************************************************************************************************************************************
    * Method Name: onAfterUpdate
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void onAfterUpdate(list<Apttus_Proposal__Proposal__c> listNEWProposal, map<Id, Apttus_Proposal__Proposal__c> mapOLDProposal ) {
        try{
            set<Id> setOpportunityId = new set<Id>();
            map<id,string> ProductConfigRecord = new map<id,string>();
            list<Apttus_Config2__LineItem__c> UpdateLine = new list<Apttus_Config2__LineItem__c>();            
            string MatrixRecSTR;

            for(Apttus_Proposal__Proposal__c oProposal: listNEWProposal) {  
                Apttus_Proposal__Proposal__c oOldProposal = mapOLDProposal.get(oProposal.Id);
                if(oOldProposal.HSFE_Assigned_To__c == null && oProposal.HSFE_Assigned_To__c  != null){
                    setOpportunityId.add(oProposal.Apttus_Proposal__Opportunity__c);
                }
                if((mapOLDProposal.get(oProposal.Id).HSFE_FIT_Quote__c != oProposal.HSFE_FIT_Quote__c) || (mapOLDProposal.get(oProposal.Id).HSFE_Proposal_Order_Type__c != oProposal.HSFE_Proposal_Order_Type__c)){
                    ProductConfigRecord.put(oProposal.Id,'');
                }                

            }
            if(ProductConfigRecord != null)
            for (Apttus_Config2__ProductConfiguration__c cartObj : [SELECT id, HSFE_FIT_Quote__c, HSFE_Quote_Order_Type__c, Apttus_QPConfig__Proposald__c,
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_AVP_User__c, 
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_DVP_User__c,
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_GVP_User__c,
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_RSD_RVP_User__c,
                                                                        Apttus_QPConfig__Proposald__r.HSFE_Deep_Clone__c, 
                                                                        Apttus_QPConfig__Proposald__r.HSFE_FIT_Quote__c, 
                                                                        Apttus_QPConfig__Proposald__r.HSFE_Proposal_Order_Type__c, Apttus_QPConfig__Proposald__r.id 
                                                                    FROM Apttus_Config2__ProductConfiguration__c 
                                                                    WHERE Apttus_QPConfig__Proposald__c in : ProductConfigRecord.keySet()])
            {

                MatrixRecSTR = JSON.serializePretty(cartObj);       
                ProductConfigRecord.put(cartObj.Apttus_QPConfig__Proposald__r.id,MatrixRecSTR);            
            }

            if(ProductConfigRecord != null)
            for(Apttus_Config2__LineItem__c LineRec : [select id,HSFE_Quote_Details_JSON_String__c,HSFE_Quote_Id__c 
                                                        from Apttus_Config2__LineItem__c 
                                                        where HSFE_Quote_Id__c in: ProductConfigRecord.KeySet()])
            {

                LineRec.HSFE_Quote_Details_JSON_String__c = ProductConfigRecord.get(LineRec.HSFE_Quote_Id__c);
                UpdateLine.add(LineRec);
            }

            List<Opportunity> lOpportunity = updateVersionNumber(setOpportunityId);

            if(lOpportunity != null)
                update lOpportunity;
            if(UpdateLine != null)
                update UpdateLine; 

        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }               
    }
    
    
    
    /***************************************************************************************************************************************
    * Method Name: onAfterInsert
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void onAfterInsert(list<Apttus_Proposal__Proposal__c> listNEWProposal){
        try{
            set<Id> setOpportunityId = new set<Id>();
            for(Apttus_Proposal__Proposal__c oProposal: listNEWProposal) {  
                //  22/June/2015 : Modified the version Logic To Update Version Count on every Insert (Ajay Agnihotri)
                    setOpportunityId.add(oProposal.Apttus_Proposal__Opportunity__c);
            }
            List<Opportunity> lOpportunity = updateVersionNumber(setOpportunityId);
            if(lOpportunity != null)
                update lOpportunity;
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }              
    }
    
    
    
    /***************************************************************************************************************************************
    * Method Name: updateVersionNumber
    * Description: update Version Number on quote
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static list<Opportunity> updateVersionNumber (set<Id> sOpportunity){
        list<Opportunity> listOpportunity = new list<Opportunity>();
        try{
            for(Opportunity oOpportunity : [ Select Id,HSFE_Quote_Version_Number__c from Opportunity where Id IN:sOpportunity ]){
                if(oOpportunity.HSFE_Quote_Version_Number__c !=null){
                    oOpportunity.HSFE_Quote_Version_Number__c +=1;
                }else {
                    oOpportunity.HSFE_Quote_Version_Number__c=0;
                }
                listOpportunity.add(oOpportunity);
            }
                        
            return listOpportunity;
            //update listOpportunity;       
        }catch(Exception e){
            return null;
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }
        return null; 
    }
    
/***************************************************************************************************************************************
    * Method Name: UpdateOpportunityWithPrimaryQuote
    * Description: AutoSync logic.
    * Return Type: None.
    ***************************************************************************************************************************************/
    public static void UpdateOpportunityWithPrimaryQuote(list<Apttus_Proposal__Proposal__c> lNewProposal, list<Apttus_Proposal__Proposal__c> lOldProposal, map<id,Apttus_Proposal__Proposal__c> NewProposalRecords, map<id,Apttus_Proposal__Proposal__c> OldProposalRecords ) {
        
        set<Id> listProposalUpdateOpptyLineItemID = new set<Id>();

        list<Apttus_Proposal__Proposal__c>  listProposalUpdateOpptyLineItem = new List<Apttus_Proposal__Proposal__c>();        
        list<Id> listProposalDeleteOpptyLineItem = new List<Id>();
        list<Opportunity> OpportunitiesToUpdatePriceBook = new List<Opportunity>(); 
        list<Apttus_Proposal__Proposal_Line_Item__c> listTempProposalLineItem = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        list<OpportunityLineItem> listTempOpportunityLineItem = new list<OpportunityLineItem>();
        list<OpportunityLineItem> listFinalUpdate = new list<OpportunityLineItem>();
        list<OpportunityLineItem> listDeleteOldRecords = new list<OpportunityLineItem>();
        list<Opportunity> listFinalUpdateOppty = new list<Opportunity>();
        list<PricebookEntry> lPriceBookEntry = new list<PricebookEntry>();
        
        map<Id, list<Apttus_Proposal__Proposal_Line_Item__c>> mapProposalUpdateOpptyLineItem = new map <Id,list <Apttus_Proposal__Proposal_Line_Item__c>>();
        map<Id, list<OpportunityLineItem>> mapUpdateOpportunityLineItem = new map<Id, list<OpportunityLineItem>>();
        map<Id, Opportunity> mapOpportunity = new map <Id, Opportunity>();
        map<Id, Id> mapPricebookEntry = new map <Id, Id>();
        map<Id, Id> mapProductId = new map<Id, Id>();
        map<Id, Apttus_Proposal__Proposal__c> mapOpportunityAmountRollup = new map <Id, Apttus_Proposal__Proposal__c>();
        
        //Commented the Logic to query Pricebook as it was not getting used in code.
        //Pricebook2 StandardPriceBooks =  [select id from Pricebook2 where IsStandard = TRUE LIMIT 1];
        for(Apttus_Proposal__Proposal__c oProposal: lNewProposal ){
            // Fixed the Rollback Logic so that it is executed everytime the status is changed or Primary Checkbox is changed.
            if(oProposal.Apttus_Proposal__Approval_Stage__c == HSFE_Constant.Proposal_ApprovalStage_AP && oProposal.Apttus_Proposal__Primary__c == true && oProposal.Apttus_Proposal__Opportunity__c != null && (oProposal.Apttus_Proposal__Approval_Stage__c != OldProposalRecords.get(oProposal.id).Apttus_Proposal__Approval_Stage__c || oProposal.Apttus_Proposal__Primary__c != OldProposalRecords.get(oProposal.id).Apttus_Proposal__Primary__c)) {
                // Add Proposal Line Item to Opportunity Line Item. AND Delete existing Opportunity Line Item.
                listProposalUpdateOpptyLineItemID.add(oProposal.Id);
                listProposalUpdateOpptyLineItem.add(oProposal);           
            }
            //  1/07/2015: Updated Rollup for Amount while Primary Quote is in 'In Review' Stage ( Ajay Agnihotri)
            else if( oProposal.Apttus_Proposal__Approval_Stage__c == HSFE_Constant.Proposal_ApprovalStage_IR  && oProposal.Apttus_Proposal__Primary__c == true && oProposal.Apttus_Proposal__Opportunity__c != null && (oProposal.Apttus_Proposal__Approval_Stage__c != OldProposalRecords.get(oProposal.id).Apttus_Proposal__Approval_Stage__c || oProposal.Apttus_Proposal__Primary__c != OldProposalRecords.get(oProposal.id).Apttus_Proposal__Primary__c)){
            
            listFinalUpdateOppty.add(new Opportunity(id=oProposal.Apttus_Proposal__Opportunity__c, HSFE_Capital_Amount__c = oProposal.HSFE_Total_Capital_Amount__c,HSFE_Service_Amount__c = oProposal.HSFE_Net_Total_Service__c, HSFE_Disposable_Amount__c = oProposal.HSFE_Total_Disposable_Amount__c,HSFE_Miscellaneous_Amount__c=(oProposal.HSFE_Grand_Total_Amount__c-
                     ((oProposal.HSFE_Total_Capital_Amount__c!=null?oProposal.HSFE_Total_Capital_Amount__c:0)
                     +(oProposal.HSFE_Net_Total_Service__c!=null?oProposal.HSFE_Net_Total_Service__c:0)
                     +(oProposal.HSFE_Total_Disposable_Amount__c!=null?oProposal.HSFE_Total_Disposable_Amount__c:0)
                     ))));
                
             
                
            
            // Delete all existing Opportunity Line Item
                listProposalDeleteOpptyLineItem.add(oProposal.Apttus_Proposal__Opportunity__c);
            }
            else if(oProposal.Apttus_Proposal__Primary__c == true && oProposal.Apttus_Proposal__Opportunity__c != null && (oProposal.Apttus_Proposal__Approval_Stage__c == 'Draft' || oProposal.Apttus_Proposal__Approval_Stage__c == 'In Review' || oProposal.Apttus_Proposal__Approval_Stage__c == 'Require Revision' )) {
                // Delete all existing Opportunity Line Item
                listProposalDeleteOpptyLineItem.add(oProposal.Apttus_Proposal__Opportunity__c);
            }                   
        }
        
        if(listProposalUpdateOpptyLineItemID != null){
            //Populate Price book Entry ids against each product. --Start--
            for(Apttus_Proposal__Proposal__c listProposal :[SELECT Apttus_Proposal__Opportunity__c, Id,(SELECT Apttus_Proposal__Product__c, Apttus_QPConfig__DerivedFromId__c, Apttus_QPConfig__OptionId__c, Apttus_QPConfig__ListPrice__c,HSFE_Total_Price__c,Apttus_Proposal__Unit_Net_Price__c,Apttus_QPConfig__Quantity2__c,Apttus_Proposal__Unit_Price__c,Apttus_QPConfig__BasePrice__c,HSFE_Target_Price__c 
                                                                                                        FROM Apttus_Proposal__R00N70000001yUfBEAU__r) 
                                                                                                        FROM Apttus_Proposal__Proposal__c 
                                                                                                        WHERE Id in:listProposalUpdateOpptyLineItemID] ){
                        
                if(listProposal.Apttus_Proposal__R00N70000001yUfBEAU__r != null){
                    
                    for(Apttus_Proposal__Proposal_Line_Item__c oProposalLineItem :listProposal.Apttus_Proposal__R00N70000001yUfBEAU__r){
                          listTempProposalLineItem.add(oProposalLineItem );
                          if(oProposalLineItem.Apttus_QPConfig__OptionId__c==null) 
                              mapProductId.put(oProposalLineItem.Apttus_Proposal__Product__c,oProposalLineItem.Apttus_Proposal__Product__c );
                          else
                              mapProductId.put(oProposalLineItem.Apttus_QPConfig__OptionId__c,oProposalLineItem.Apttus_QPConfig__OptionId__c );
                    }
                    mapProposalUpdateOpptyLineItem.put(listProposal.Apttus_Proposal__Opportunity__c,listTempProposalLineItem );
                    
                }    
            }
        }

        if(!mapProductId.isEmpty()){
           
            for(PricebookEntry oPricebookEntry :[SELECT Id, Product2Id FROM PricebookEntry where Product2Id =: mapProductId.keySet() ]){
               mapProductId.put(oPricebookEntry.Product2Id, oPricebookEntry.Id );
            }
        }    

        //Populate Price book Entry ids against each product. --End--       
        if(mapProposalUpdateOpptyLineItem != null)
            for( OpportunityLineItem listOpportunityLineItem :[SELECT OpportunityId, Quantity, Id, PricebookEntryId, TotalPrice, ListPrice, UnitPrice FROM OpportunityLineItem where OpportunityId =: mapProposalUpdateOpptyLineItem.keySet()]) {
                listTempOpportunityLineItem.add(listOpportunityLineItem);
                mapUpdateOpportunityLineItem.put(listOpportunityLineItem.OpportunityId,listTempOpportunityLineItem );                 
            }

        if(mapProposalUpdateOpptyLineItem != null)
            for(Opportunity oOppty :[SELECT Id, HSFE_Quote_Sync__c ,Amount FROM Opportunity where id=: mapProposalUpdateOpptyLineItem.keySet() ]){
                mapOpportunity.put(oOppty.Id, oOppty);
              
            }
        
        
        if(listProposalUpdateOpptyLineItem != null && listProposalUpdateOpptyLineItem.size()>0){
            listFinalUpdateOppty = new list<Opportunity>();
            for(Apttus_Proposal__Proposal__c oProposal: listProposalUpdateOpptyLineItem ){
                if(mapUpdateOpportunityLineItem.size()>0 && mapUpdateOpportunityLineItem.containsKey(oProposal.Apttus_Proposal__Opportunity__c)){
                    for(OpportunityLineItem oOpptyLineItem:mapUpdateOpportunityLineItem.get(oProposal.Apttus_Proposal__Opportunity__c) ) {
                    listDeleteOldRecords.add(oOpptyLineItem);

                    }
                }
                if(mapProposalUpdateOpptyLineItem.size() >0 && mapProposalUpdateOpptyLineItem.containsKey(oProposal.Apttus_Proposal__Opportunity__c)) {
                    
                    for(Apttus_Proposal__Proposal_Line_Item__c oProposalLineItem :mapProposalUpdateOpptyLineItem.get(oProposal.Apttus_Proposal__Opportunity__c)) {
                        OpportunityLineItem oOpportunityLineItem = new OpportunityLineItem();
                        oOpportunityLineItem.OpportunityId = oProposal.Apttus_Proposal__Opportunity__c;
                        oOpportunityLineItem.Quantity= oProposalLineItem.Apttus_QPConfig__Quantity2__c;
                        oOpportunityLineItem.TotalPrice = oProposalLineItem.HSFE_Total_Price__c;
                        if(oProposalLineItem.Apttus_QPConfig__OptionId__c!=null)
                            oOpportunityLineItem.PricebookEntryId = mapProductId.get(oProposalLineItem.Apttus_QPConfig__OptionId__c);
                        else{
                            if(mapProductId.containsKey(oProposalLineItem.Apttus_Proposal__Product__c))
                                oOpportunityLineItem.PricebookEntryId = mapProductId.get(oProposalLineItem.Apttus_Proposal__Product__c); 
                        }
                        //oOpportunityLineItem.HSFE_Proposal_Line_Item__c = oProposalLineItem.id;
                        //Populating the Derived from Cart Line Items and not Proposal Line items because Proposal Line Items get deleted and inserted again during Approval process
                        oOpportunityLineItem.HSFE_Config_Line_Item__c=oProposalLineItem.Apttus_QPConfig__DerivedFromId__c;

                        listFinalUpdate.add(oOpportunityLineItem);
                        
                    }
                }
                
                if(mapOpportunity.size()>0 && mapOpportunity.containsKey(oProposal.Apttus_Proposal__Opportunity__c) ){
                    Opportunity oOppty = mapOpportunity.get(oProposal.Apttus_Proposal__Opportunity__c);
                    // 6/07/2014 Remove or Comment the logic to Updated Amount  and Sync in Opportunity.( Ajay Agnihotri)
                    oOppty.HSFE_Capital_Amount__c = oProposal.HSFE_Total_Capital_Amount__c;
                    oOppty.HSFE_Service_Amount__c = oProposal.HSFE_Net_Total_Service__c;
                    oOppty.HSFE_Disposable_Amount__c = oProposal.HSFE_Total_Disposable_Amount__c;
                     oOppty.HSFE_Miscellaneous_Amount__c=(oProposal.HSFE_Grand_Total_Amount__c-
                     ((oProposal.HSFE_Total_Capital_Amount__c!=null?oProposal.HSFE_Total_Capital_Amount__c:0)
                     +(oProposal.HSFE_Net_Total_Service__c!=null?oProposal.HSFE_Net_Total_Service__c:0)
                     +(oProposal.HSFE_Total_Disposable_Amount__c!=null?oProposal.HSFE_Total_Disposable_Amount__c:0)
                     ));
                    listFinalUpdateOppty.add(oOppty);
                }
            }
        }   
        if(listProposalDeleteOpptyLineItem != null)
            for(Opportunity oOppty: [SELECT Id, (SELECT Apttus_Approval__Approval_Status__c,ServiceDate,Description,Id,ListPrice,HSFE_Material_Group__c,OpportunityId,PricebookEntryId,Quantity,UnitPrice,SortOrder,TotalPrice FROM OpportunityLineItems) FROM Opportunity where Id =: listProposalDeleteOpptyLineItem ]){
                if(oOppty.OpportunityLineItems != null)
                    for(OpportunityLineItem oOpptyLineItem:oOppty.OpportunityLineItems ){
                        listDeleteOldRecords.add(oOpptyLineItem);
                    }
            }
                   
       try{
            if(listDeleteOldRecords != null)
                delete listDeleteOldRecords;
            if(listFinalUpdate != null) {
                insert listFinalUpdate;

                }
            if(listFinalUpdateOppty != null){
                update listFinalUpdateOppty;
            }   
            
        }catch(DmlException ex){
            if(StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY == ex.getDmlType(0)){
                Trigger.new[ex.getDmlIndex(0)].addError('You are not a member of opportunity team or you do not have access to sumbit this quote.');
            }
        }
    }    



    /***************************************************************************************************************************************
    * Method Name:UpdateOldQuoteToPrimary_BeforeDelete
    * Description: 
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void UpdateOldQuoteToPrimary_BeforeDelete( list<Apttus_Proposal__Proposal__c> lOldProposal ) {
        
        set<id> PreviousPrimaryQID = new set<id>();
        list<Apttus_Proposal__Proposal__c> UpdatePreviousProposalRec = new list<Apttus_Proposal__Proposal__c>();
        
        for(Apttus_Proposal__Proposal__c DeletedRec :lOldProposal){
            PreviousPrimaryQID.add(DeletedRec.HSFE_Previous_Primary_Quote__c);        
        }
        for(Apttus_Proposal__Proposal__c PropRec: [select id, Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c where id in:PreviousPrimaryQID]){
            if(PropRec.Apttus_Proposal__Primary__c  == False){            
                PropRec.Apttus_Proposal__Primary__c = True;
                UpdatePreviousProposalRec.add(PropRec);
            }        
        }
        try{
            if(UpdatePreviousProposalRec != null){
                update UpdatePreviousProposalRec;
            }
        }Catch(DmlException ex){
            if(StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY == ex.getDmlType(0)){
                Trigger.new[ex.getDmlIndex(0)].addError('You are not a member of opportunity team or you do not have access to sumbit this quote.');
            }
            HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception
        }        
    }

    /***************************************************************************************************************************************
    * Method Name: UpdatePrimary_FITLogic_BeforeUpdate
    * Description: Method to check if FIT flag is true. if true, Quote will not be primary and Previous primary quote will be made primary.
    *            : 1. Referring User Story US-0410
    *            : 2.   
    * Return Type: None.
    ***************************************************************************************************************************************/    
    public static void UpdatePrimary_FITLogic_BeforeUpdate(List<Apttus_Proposal__Proposal__c> NewRecords_List, List<Apttus_Proposal__Proposal__c> OldRecords_List, map<id,Apttus_Proposal__Proposal__c> NewProposalRecords, map<id,Apttus_Proposal__Proposal__c> OldProposalRecords){   
        try{
            set<id> ToUpdateOldQuoteToPrimary = new set<id>();
            map<id,boolean> Oppr_PrimaryQuoteReady = new map<id,boolean>();     
            map<id,id> Oppr_PrimaryQuoteIds = new map<id,id>();
            list<Apttus_Proposal__Proposal__c> UpdateProposal = new list<Apttus_Proposal__Proposal__c>();
            
            if(!HSFE_Utility_Class.hasAlreadyExecuted()){
                
                HSFE_Utility_Class.setAlreadyExecutedFalse();

                for(Apttus_Proposal__Proposal__c quoteObj : NewRecords_List){
                    if(NewProposalRecords.get(quoteObj.id).HSFE_FIT_Quote__c != OldProposalRecords.get(quoteObj.id).HSFE_FIT_Quote__c && quoteObj.HSFE_FIT_Quote__c == True){
                        quoteObj.Apttus_Proposal__Primary__c = False;
                        ToUpdateOldQuoteToPrimary.add(quoteObj.HSFE_Previous_Primary_Quote__c);
                        quoteObj.HSFE_Previous_Primary_Quote__c = null;
                    }
                    if(NewProposalRecords.get(quoteObj.id).HSFE_FIT_Quote__c != OldProposalRecords.get(quoteObj.id).HSFE_FIT_Quote__c && quoteObj.HSFE_FIT_Quote__c == False){           
                        //Capture Opportunity Id to uncheck other primary quote under the opportunity
                        //Oppr_PrimaryQuoteIds.put(quoteObj.Apttus_Proposal__Opportunity__c,null);
                    }
                    if(NewProposalRecords.get(quoteObj.id).Apttus_Proposal__Primary__c != OldProposalRecords.get(quoteObj.id).Apttus_Proposal__Primary__c && quoteObj.Apttus_Proposal__Primary__c == True && quoteObj.HSFE_FIT_Quote__c == True){           
                        //Capture Opportunity Id to uncheck other primary quote under the opportunity
                        Oppr_PrimaryQuoteIds.put(quoteObj.Apttus_Proposal__Opportunity__c,null);
                    }               
                }
                
                
                if(ToUpdateOldQuoteToPrimary != null){
                    for(Apttus_Proposal__Proposal__c PrequoteObj : [Select id, Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c where id in: ToUpdateOldQuoteToPrimary AND id not in: NewProposalRecords.keyset()]){
                        PrequoteObj.Apttus_Proposal__Primary__c = true;
                        UpdateProposal.add(PrequoteObj); 
                    }
                
                    if(UpdateProposal != null){
                        HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = true; // Code Optimization 22
                        update UpdateProposal;
                        HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = false;
                    }
                }

                if(Oppr_PrimaryQuoteIds != null){
                
                    for(Apttus_Proposal__Proposal__c ProposalRec: [select id, Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c in: Oppr_PrimaryQuoteIds.KeySet() and Apttus_Proposal__Primary__c =: True AND id not in: NewProposalRecords.keyset()]){
                        if(ProposalRec.Apttus_Proposal__Approval_Stage__c != HSFE_Constant.CUSTOM_QUOTE_ACCEPTED){
                            if(Oppr_PrimaryQuoteIds.ContainsKey(ProposalRec.Apttus_Proposal__Opportunity__c)){
                                Oppr_PrimaryQuoteIds.put(ProposalRec.Apttus_Proposal__Opportunity__c,ProposalRec.id);
                                Oppr_PrimaryQuoteReady.put(ProposalRec.id,true);
                                ProposalRec.Apttus_Proposal__Primary__c = false;
                                ProposalRec.HSFE_Previous_Primary_Quote__c = null;                          
                                UpdateProposal.add(ProposalRec);                    
                            }
                        }else{
                            //If Quote is Accepted and Primary you cannot make new quote as primary.
                            Oppr_PrimaryQuoteIds.put(ProposalRec.Apttus_Proposal__Opportunity__c,ProposalRec.id);
                            Oppr_PrimaryQuoteReady.put(ProposalRec.id,false);
                        }    
                    }
                   
                    if(UpdateProposal != null){
                        HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = true; // Code Optimization 22
                        Update UpdateProposal;
                        HSFE_Utility_Class.isProposalIntStatusUpdLineItemExt = False;
                        
                    }
                        
                    for(Apttus_Proposal__Proposal__c ProposalRecord : NewRecords_List){
                        //This condition will work only if there are existing Primary quote for a Opportunity. 
                        //If there are no Quotes present under an opportunity then by default Apttus will make it primary                   
                        if(Oppr_PrimaryQuoteIds.containsKey(ProposalRecord.Apttus_Proposal__Opportunity__c)){
                            if(Oppr_PrimaryQuoteReady.ContainsKey(Oppr_PrimaryQuoteIds.get(ProposalRecord.Apttus_Proposal__Opportunity__c))){
                                if(Oppr_PrimaryQuoteReady.get(Oppr_PrimaryQuoteIds.get(ProposalRecord.Apttus_Proposal__Opportunity__c))){
                                    ProposalRecord.Apttus_Proposal__Primary__c = true;
                                    ProposalRecord.HSFE_Previous_Primary_Quote__c = Oppr_PrimaryQuoteIds.get(ProposalRecord.Apttus_Proposal__Opportunity__c);
                                }else{
                                    ProposalRecord.Apttus_Proposal__Primary__c = false;
                                }
                            }else{
                                ProposalRecord.Apttus_Proposal__Primary__c = true;
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }   
    }
    
    /***************************************************************************************************************************************
    * Method Name: AutoPopulateProductCode_BeforeUpdate
    * Description: Auto Populate the "Product Code" based on selected "Promotion Code Description".
    *            : 1. Referring User Story US-0399
    *            
    * Return Type: None.
    ***************************************************************************************************************************************/
    public static void AutoPopulateProductCode_BeforeUpdate(List<Apttus_Proposal__Proposal__c> NewRecords_List, List<Apttus_Proposal__Proposal__c> OldRecords_List, map<id,Apttus_Proposal__Proposal__c> NewProposalRecordsMap, map<id,Apttus_Proposal__Proposal__c> OldProposalRecordsMap){
        try{
            for(integer i=0;i<NewRecords_List.size();i++){
                set<string> PromotionCodeSet=new set<string>();
                if(NewRecords_List[i].HSFE_Promotion_Code_Description__c!=OldRecords_List[i].HSFE_Promotion_Code_Description__c){
                    if(NewRecords_List[i].HSFE_Promotion_Code_Description__c!=null && NewRecords_List[i].HSFE_Promotion_Code_Description__c!='' ){
                        for(string PromotionCodeLabel:NewRecords_List[i].HSFE_Promotion_Code_Description__c.split(';')){
                            PromotionCodeSet.add(HSFE_PromotionCodeMapping__c.getInstance(PromotionCodeLabel).HSFE_Promotion_Code__c);
                        }
                        if(PromotionCodeSet.size()>0){
                            integer j=1;
                            string PromotionCodeFinalStr='';
                            for(string PromotionCodeStr:PromotionCodeSet){
                                PromotionCodeFinalStr=j==PromotionCodeSet.size()?PromotionCodeFinalStr+PromotionCodeStr:PromotionCodeFinalStr+PromotionCodeStr+';';
                                j++;
                            }
                            NewRecords_List[i].HSFE_Promotion_Code__c=PromotionCodeFinalStr;
                        }
                        else
                            NewRecords_List[i].HSFE_Promotion_Code__c=null;
                    }
                    else{
                        NewRecords_List[i].HSFE_Promotion_Code__c=null;
                    }
                }
                
            }
        
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }        
    } 
    
  /***************************************************************************************************************************************
    * Method Name: UpdateContractCodes
    * Description: Logic to save all the Contract Codes used in the Line Items on the Quote in concatenated format.
    * Return Type: None.
    ***************************************************************************************************************************************/
    public static void UpdateContractCodes(list<Apttus_Proposal__Proposal__c> lNewProposal, map<id,Apttus_Proposal__Proposal__c> NewProposalRecords, map<id,Apttus_Proposal__Proposal__c> OldProposalRecords ) {
        try{
            List <Apttus_Proposal__Proposal_Line_Item__c > listTempProposalLineItem = new List <Apttus_Proposal__Proposal_Line_Item__c >();        
            Map<Id, String> quoteCodeMap = new Map <Id, String>();
            Set <Id> setProposalIds = new Set<Id>();
        
            // Add Proposal Line Item to Opportunity Line Item. AND Delete existing Opportunity Line Item.
            for(Apttus_Proposal__Proposal__c oProposal: lNewProposal ){
                if(oProposal.Apttus_Proposal__Approval_Stage__c == 'Approved' && (oProposal.Apttus_Proposal__Approval_Stage__c != OldProposalRecords.get(oProposal.id).Apttus_Proposal__Approval_Stage__c)) {                    
                    setProposalIds.add(oProposal.Id);
                    quoteCodeMap.put(oProposal.id, ''); 
                }           
            }   
            
            if(setProposalIds.size()>0){                                                                                                                                                
                for(Apttus_Proposal__Proposal_Line_Item__c oProposalLineItem : [SELECT Apttus_QPConfig__DerivedFromId__c, HSFE_Contract_Code__c, Apttus_Proposal__Proposal__c
                                                                                FROM Apttus_Proposal__Proposal_Line_Item__c
                                                                                where Apttus_Proposal__Proposal__c in: setProposalIds]){
                      listTempProposalLineItem.add(oProposalLineItem );
                      if (oProposalLineItem.HSFE_Contract_Code__c!=null && oProposalLineItem.HSFE_Contract_Code__c!='') {
                        if (quoteCodeMap.get(oProposalLineItem.Apttus_Proposal__Proposal__c)=='') {
                            quoteCodeMap.put(oProposalLineItem.Apttus_Proposal__Proposal__c, oProposalLineItem.HSFE_Contract_Code__c+'\r\n');
                        }
                        else if (quoteCodeMap.get(oProposalLineItem.Apttus_Proposal__Proposal__c)!='') {
                            if(!(quoteCodeMap.get(oProposalLineItem.Apttus_Proposal__Proposal__c)).contains(oProposalLineItem.HSFE_Contract_Code__c))
                                quoteCodeMap.put(oProposalLineItem.Apttus_Proposal__Proposal__c, quoteCodeMap.get(oProposalLineItem.Apttus_Proposal__Proposal__c)+oProposalLineItem.HSFE_Contract_Code__c+'\r\n');
                            
                        }
                      }
                }                                    
            }            
           
            if(setProposalIds != null && quoteCodeMap!=null) {
                for (Apttus_Proposal__Proposal__c newProp :lNewProposal) {
                    if(quoteCodeMap.get(newProp.id)!=null)
                        newProp.HSFE_Line_Con_Codes__c=quoteCodeMap.get(newProp.id);
                }   
            }
        }
        catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }   
    } 
}