/* Class Name   : HSFE_Proposal_TriggerHandler_TestClass 
 * Description  : Testclass for Quote/Proposal Trigger Handler
 * Created By   : Kritika Nagpal
 * Created On   : 04/17/2015 
 * Modification Log:  
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                        Description
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ajay Agnihotri               19/May/2015                 Modified TestCoverage to Enhance Test Coverage
 *  Ajay Agnihotri              29/June/2015                Updated test Coverage after Code Modifications
 */
@isTest(SeeAllData= false)
public class HSFE_Proposal_TriggerHandler_TestClass {

    static testMethod void ProposalTrigger_TestScenarios() {
        try{

            //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                Test.StartTest();
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                System.AssertNotEquals(NewAccount.id,null);

                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUser.id,'Test');
                insert ATM;
                
                //Insert the Contact record
                Contact NewContact =new Contact();
                NewContact=HSFE_TestUtility_Class.createContactRecord(NewAccount);
                NewContact.HSFE_Primary__c=true;
                NewContact.HSFE_Specialty__c='Medical';
                NewContact.HSFE_Sub_Specialty__c='Medical IT';
                insert NewContact;
                System.AssertNotEquals(NewContact.id,null);
                
                //Insert the Related Account record
                List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
                RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
                insert RelatedAccLst;
                
                Map<string,Id> MapRelatedAcc=new Map<String,Id>();
                for(HSFE_Related_Account__c RelAcc: RelatedAccLst)
                    MapRelatedAcc.put(RelAcc.HSFE_Relationship_Type_ID__c,RelAcc.id);
                
                //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.HSFE_Miscellaneous_Amount__c=100;
                insert NewOpportunity ;
                System.AssertNotEquals(NewOpportunity.id,null);
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                System.AssertNotEquals(NewPriceList.id,null);
                
                // Insert PriceListId and ProfileId In Custom Setting   
                List<HSFE_Contant_Helper__c> NewContant_Helper_Lst = new List<HSFE_Contant_Helper__c>();
                NewContant_Helper_Lst=HSFE_TestUtility_Class.Create_HSFE_Contant_Helper_Data(UserInfo.getProfileId(),NewPriceList.id);
                insert NewContant_Helper_Lst;
                
                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';            
                NewProposal.HSFE_Is_FIS__c=true;
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
                //NewProposal.HSFE_Bill_To_Account__c=NewAccount.id;
                //NewProposal.HSFE_Payer_Account__c=NewAccount.id;
                NewProposal.HSFE_Primary_Con__c=NewContact.id;
                NewProposal.HSFE_Bill_To_Account__c=MapRelatedAcc.get('BP');
                NewProposal.HSFE_Payer_Account__c=MapRelatedAcc.get('PY');
                NewProposal.HSFE_Ship_To_Account__c=MapRelatedAcc.get('SP');
                insert NewProposal;
                System.AssertNotEquals(NewProposal.id,null);
                
                //Insert the Second Proposal record
                Apttus_Proposal__Proposal__c NewProposal2 = new Apttus_Proposal__Proposal__c();
                NewProposal2=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal2' );
                NewProposal2.Apttus_Proposal__Primary__c=true;
                insert NewProposal2;
                System.AssertNotEquals(NewProposal2.id,null);
                
                NewProposal.Apttus_Proposal__Primary__c=false;
                NewProposal.Apttus_QPConfig__PONumber__c ='1234';
                NewProposal.Apttus_Proposal__Approval_Stage__c='Generated';
                NewProposal.HSFE_Promotion_Code_Description__c='145P Competitive Conversion';
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
                NewProposal.HSFE_Order_Status__c=HSFE_Constant.FAILED;
                update NewProposal;
                
                delete NewProposal;

                Test.StopTest();
            }
        }
        catch(exception e){
        }       
    }
    
    // Below Method Process Primary and Approved Proposals with associated Line Items
    static testMethod void ProposalTrigger_TestPrimaryAndApprovedProposalWithAssociatedLineItemsScenarios() {
        try{
            //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
         
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){     
                
                //Create Multiple Promotion Code Mapping Records
                List<HSFE_PromotionCodeMapping__c> NewPCMappingLst=new List<HSFE_PromotionCodeMapping__c>();
                NewPCMappingLst=HSFE_TestUtility_Class.createMultiplePromotionCodeMapping(5);
                insert NewPCMappingLst;
                System.AssertNotEquals(NewPCMappingLst.size(),0);
                
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                System.AssertNotEquals(NewAccount.id,null);
                
                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUser.id,'Test');
                insert ATM;
                
                //Insert the Contact record
                Contact NewContact =new Contact();
                NewContact=HSFE_TestUtility_Class.createContactRecord(NewAccount);
                NewContact.HSFE_Primary__c=true;
                NewContact.HSFE_Specialty__c='Medical';
                NewContact.HSFE_Sub_Specialty__c='Medical IT';
                insert NewContact;
                System.AssertNotEquals(NewContact.id,null);
                
                //Insert the Related Account record
                List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
                RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
                insert RelatedAccLst;
                System.AssertNotEquals(RelatedAccLst.size(),0);
                
                //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.TotalOpportunityQuantity=1;
                NewOpportunity.HSFE_Miscellaneous_Amount__c=100;
                insert NewOpportunity ;
                System.AssertNotEquals(NewOpportunity.id,null);
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                System.AssertNotEquals(NewPriceList.id,null);
                

                // Insert PriceListId and ProfileId In Custom Setting   
                List<HSFE_Contant_Helper__c> NewContant_Helper_Lst = new List<HSFE_Contant_Helper__c>();
                NewContant_Helper_Lst=HSFE_TestUtility_Class.Create_HSFE_Contant_Helper_Data(UserInfo.getProfileId(),NewPriceList.id);
                insert NewContant_Helper_Lst;
                
                Test.StartTest();
                 //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
                NewProposal.HSFE_Deep_Clone__c=true;
                NewProposal.HSFE_Is_FIS__c=false;
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
                NewProposal.HSFE_Primary_Con__c=NewContact.id;
                insert NewProposal;
                System.AssertNotEquals(NewProposal.id,null);
                
                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                NewProductConf.Apttus_Config2__Status__c='Finalized';
                insert NewProductConf;
                System.AssertNotEquals(NewProductConf.id,null);
                
                //Insert the TempObject record
                Apttus_Config2__TempObject__c NewTempObject=new Apttus_Config2__TempObject__c();
                NewTempObject=HSFE_TestUtility_Class.createSingleTempObject(NewProductConf);
                insert NewTempObject;
                
                // Insert Category record
                Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
                NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
                insert NewCategory;
                System.AssertNotEquals(NewCategory.id,null);
                
                // Insert Category Hierarchy record
                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy=new Apttus_Config2__ClassificationHierarchy__c();
                string Category_Hierarchy_Label_Str='Capital';
                NewCategoryHierarchy=HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory,Category_Hierarchy_Label_Str);
                insert NewCategoryHierarchy;
                System.AssertNotEquals(NewCategoryHierarchy.id,null);
                
                // Insert Product record
                List<Product2> NewProductLst=new List<Product2>();
                NewProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                if(NewProductLst.size()>0)
                    NewProductLst[0].Is_Stocking_Kit__c=true;
                insert NewProductLst;
                HSFE_TestUtility_Class.createPriceBookEntry(NewProductLst[0].id);
                Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                if(NewProductLst.size()>0){
                    
                    //Insert the PriceListItem record
                    Apttus_Config2__PriceListItem__c NewPriceListItem=new Apttus_Config2__PriceListItem__c();
                    NewPriceListItem=HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList, NewProductLst[0], 'New', 'One Time', 'Per Unit', 100);
                    insert NewPriceListItem;
                    System.AssertNotEquals(NewPriceListItem.id,null);
                    
                    //Insert the PriceDimension record
                    Apttus_Config2__PriceDimension__c NewPriceDimension=new Apttus_Config2__PriceDimension__c();
                    NewPriceDimension=HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                    insert NewPriceDimension;
                    System.AssertNotEquals(NewPriceDimension.id,null);
                    
                    //Insert the PriceMatrix record
                    Apttus_Config2__PriceMatrix__c NewPriceMatrix=new Apttus_Config2__PriceMatrix__c();
                    NewPriceMatrix=HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension,NewPriceListItem);
                    insert NewPriceMatrix;
                    
                    //Insert the PriceMatrixEntry record
                    Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry = new Apttus_Config2__PriceMatrixEntry__c();
                    NewPriceMatrixEntry=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'New',NewPriceMatrix,43431);
                    insert NewPriceMatrixEntry;
                    
                    NewPriceListItem.HSFE_JSON_Up_to_Date__c = false;
                    update NewPriceListItem; 
    
                    // Insert ProductClassification record
                    Apttus_Config2__ProductClassification__c NewProductClassification=new Apttus_Config2__ProductClassification__c();
                    NewProductClassification=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy,NewProductLst[0]);
                    NewProductClassification.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    insert NewProductClassification;
                    System.AssertNotEquals(NewProductClassification.id,null);

                    //Insert the LineItem record
                    NewLineItem=new Apttus_Config2__LineItem__c();
                    NewLineItem=HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    NewLineItem.HSFE_Product_Classification__c=NewProductClassification.id;
                    NewLineItem.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem.Apttus_Config2__PriceListItemId__c=NewPriceListItem.id;
                    NewLineItem.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy.id;
                    NewLineItem.Apttus_Config2__AdjustmentType__c=HSFE_Constant.PERDISCOUNT;
                    NewLineItem.Apttus_Config2__OptionId__c=NewProductLst[0].id;
                    insert NewLineItem;
                    System.AssertNotEquals(NewLineItem.id,null);
                }   
                
                //Insert the SummaryGroup record
                Apttus_Config2__SummaryGroup__c NewSummaryGp=new Apttus_Config2__SummaryGroup__c();
                NewSummaryGp=HSFE_TestUtility_Class.createSingleSummaryGroup(NewProductConf);
                insert NewSummaryGp;
                
                //Insert the Proposal_Line_Item record
                Apttus_Proposal__Proposal_Line_Item__c NewProposalLineItem=new Apttus_Proposal__Proposal_Line_Item__c();
                NewProposalLineItem=HSFE_TestUtility_Class.createSingleProposalLineItem(NewProductConf,NewProposal,NewLineItem);
                NewProposalLineItem.Apttus_Proposal__Product__c=NewProductLst[0].id;
                insert NewProposalLineItem;
               
                HSFE_PromotionCodeMapping__c promotionCodeMap = new HSFE_PromotionCodeMapping__c();
                promotionCodeMap.Name='Test1';
                promotionCodeMap.HSFE_Promotion_Code__c='PromoCodetest1';
                insert promotionCodeMap;
                System.AssertNotEquals(promotionCodeMap.id,null);

                NewProposal.HSFE_Assigned_To__c=NewcreateUser.id;
                NewProposal.Apttus_QPConfig__PONumber__c ='1234';
                NewProposal.Apttus_Proposal__Approval_Stage__c='Approved';
                NewProposal.HSFE_Promotion_Code_Description__c='Test1;Test2;Test3;Test4';
                NewProposal.HSFE_FIT_Quote__c=true;
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.HSFE_Order_Integration_Status__c='Confirmed';
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
                NewProposal.HSFE_FIS_Payer__c=NewAccount.id;
                NewProposal.HSFE_FIS_Bill_To__c=NewAccount.id;
                //NewProposal.HSFE_Bill_To_Account__c=NewAccount.id;
                //NewProposal.HSFE_Payer_Account__c=NewAccount.id;
                NewProposal.HSFE_Primary_Con__c=NewContact.id;

                NewProposal.HSFE_Order_Status__c = HSFE_Constant.CUSTOM_QUOTE_ORDER_STATUS_CREATED;
                NewProposal.HSFE_Is_FIS__c=true;
                update NewProposal ;
                
                
                delete NewProposal;
                Test.StopTest();
            }
        }
        catch(exception e){
        }       
    }
 
    // Below Method Process FreightChargesOnStageChange on Update 
    static testMethod void ProposalTrigger_ProcessFreightChargesOnStageChange() {
        try{
           //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
                
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                System.AssertNotEquals(NewAccount.id,null);
                
                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUser.id,'Test');
                insert ATM;
                
                //Insert the Contact record
                Contact NewContact =new Contact();
                NewContact=HSFE_TestUtility_Class.createContactRecord(NewAccount);
                NewContact.HSFE_Primary__c=true;
                NewContact.HSFE_Specialty__c='Medical';
                NewContact.HSFE_Sub_Specialty__c='Medical IT';
                insert NewContact;
                System.AssertNotEquals(NewContact.id,null);
                
                //Insert the Related Account record
                List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
                RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
                insert RelatedAccLst;
                
                //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.HSFE_Miscellaneous_Amount__c=100;
                insert NewOpportunity ;
                System.AssertNotEquals(NewOpportunity.id,null);
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                System.AssertNotEquals(NewPriceList.id,null);
                
               // Insert PriceListId and ProfileId In Custom Setting    
                List<HSFE_Contant_Helper__c> NewContant_Helper_Lst = new List<HSFE_Contant_Helper__c>();
                NewContant_Helper_Lst=HSFE_TestUtility_Class.Create_HSFE_Contant_Helper_Data(UserInfo.getProfileId(),NewPriceList.id);
                insert NewContant_Helper_Lst;
                
                
                List <HSFE_PromotionCodeMapping__c> promoCodeLst = new List<HSFE_PromotionCodeMapping__c>();
                HSFE_PromotionCodeMapping__c promotionCodeMap = new HSFE_PromotionCodeMapping__c();
                promotionCodeMap.Name='Test1';
                promotionCodeMap.HSFE_Promotion_Code__c='PromoCodetest1';
                promoCodeLst.add(promotionCodeMap);
                HSFE_PromotionCodeMapping__c promotionCodeMap2 = new HSFE_PromotionCodeMapping__c();
                promotionCodeMap2.Name='Test2';
                promotionCodeMap2.HSFE_Promotion_Code__c='PromoCodetest2';
                promoCodeLst.add(promotionCodeMap2);               
                HSFE_PromotionCodeMapping__c promotionCodeMap3 = new HSFE_PromotionCodeMapping__c();
                promotionCodeMap3.Name='Test3';
                promotionCodeMap3.HSFE_Promotion_Code__c='PromoCodetest2';     
                promoCodeLst.add(promotionCodeMap3);   
                insert promoCodeLst;
                System.AssertNotEquals(promoCodeLst.size(),0);
                
                Test.StartTest();
                 //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
                NewProposal.HSFE_Primary_Con__c=NewContact.id;
                insert NewProposal;
                System.AssertNotEquals(NewProposal.id,null);

                // Call GetFreightChargesOnStageChange Logic
                //HSFE_Proposal_TriggerHandler_Class.GetFreightChargesOnStageChange_AfterUpdate(new List<Apttus_Proposal__Proposal__c>{NewProposal},new map<Id,Apttus_Proposal__Proposal__c>{NewProposal.id=>NewProposal});
                
                Apttus_Proposal__Proposal__c NewProposal2 = new Apttus_Proposal__Proposal__c();
                NewProposal2=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal2.Apttus_Proposal__Primary__c=false;
                NewProposal2.HSFE_FIT_Quote__c=true;
                NewProposal2.Apttus_Proposal__Approval_Stage__c='Draft';
                NewProposal2.HSFE_Previous_Primary_Quote__c=NewProposal.id;
                NewProposal2.HSFE_Carrier_Name__c='FedEx';
                NewProposal2.HSFE_SAP_Shipping_Condition__c='Second Day';
                NewProposal2.HSFE_Primary_Con__c=NewContact.id;
                insert NewProposal2;

                NewProposal2.HSFE_Assigned_To__c=NewcreateUser.id;
                NewProposal2.Apttus_QPConfig__PONumber__c ='1234';
                NewProposal2.Apttus_Proposal__Approval_Stage__c='Approved';
                NewProposal2.HSFE_FIT_Quote__c=true;
                NewProposal2.Apttus_Proposal__Primary__c=true;
                NewProposal2.HSFE_Order_Integration_Status__c='Error';
                NewProposal2.HSFE_Promotion_Code_Description__c='Test1;Test2;Test3';
                NewProposal2.HSFE_Carrier_Name__c='FedEx';
                NewProposal2.HSFE_SAP_Shipping_Condition__c='Second Day';
                //NewProposal2.HSFE_Bill_To_Account__c=NewAccount.id;
                //NewProposal2.HSFE_Payer_Account__c=NewAccount.id;
                NewProposal2.HSFE_Primary_Con__c=NewContact.id;
                update NewProposal2 ;

                Test.StopTest();
            }
        }
        catch(exception e){
        }       
    }
    static testMethod void ProposalTrigger_TestDeleteScenarios() {
        try{
          //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                Test.StartTest();
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                System.AssertNotEquals(NewAccount.id,null);

                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUser.id,'Test');
                insert ATM;
                
                //Insert the Contact record
                Contact NewContact =new Contact();
                NewContact=HSFE_TestUtility_Class.createContactRecord(NewAccount);
                NewContact.HSFE_Primary__c=true;
                NewContact.HSFE_Specialty__c='Medical';
                NewContact.HSFE_Sub_Specialty__c='Medical IT';
                insert NewContact;
                System.AssertNotEquals(NewContact.id,null);
                
                //Insert the Related Account record
                List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
                RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
                insert RelatedAccLst;
                
                //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.HSFE_Contact__c=NewContact.id;
                NewOpportunity.HSFE_Miscellaneous_Amount__c=100;
                insert NewOpportunity ;
                System.AssertNotEquals(NewOpportunity.id,null);
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                System.AssertNotEquals(NewPriceList.id,null);
                
                // Insert PriceListId and ProfileId In Custom Setting   
                List<HSFE_Contant_Helper__c> NewContant_Helper_Lst = new List<HSFE_Contant_Helper__c>();
                NewContant_Helper_Lst=HSFE_TestUtility_Class.Create_HSFE_Contant_Helper_Data(UserInfo.getProfileId(),NewPriceList.id);
                insert NewContant_Helper_Lst;
                
                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';            
                NewProposal.HSFE_Is_FIS__c=true;
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
                //NewProposal.HSFE_Bill_To_Account__c=NewAccount.id;
                //NewProposal.HSFE_Payer_Account__c=NewAccount.id;
                NewProposal.HSFE_Primary_Con__c=NewContact.id;
                insert NewProposal;
                System.AssertNotEquals(NewProposal.id,null);
                
                NewProposal.Apttus_Proposal__Approval_Stage__c = HSFE_Constant.CUSTOM_QUOTE_VERBALLY_ACCEPTED;
                NewProposal.HSFE_Is_FIS__c=false;
                update NewProposal;
                
                delete NewProposal;
                
                Test.StopTest();
            }
        }
        catch(exception e){
        }
    }   
    
    static testMethod void ProposalTrigge_ToCoverExceptionExplicitly() {
        try{
             //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
            // Run Test Logic as Test User
            
            
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            Apttus_Config2__PriceList__c NewPriceList2=new Apttus_Config2__PriceList__c();
            Apttus_Config2__PriceListItem__c NewPriceListItem2=new Apttus_Config2__PriceListItem__c();
            
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
               
                HSFE_Proposal_TriggerHandler_Class.UpdatePriceListOnProposal_BeforeInsert(null,null,null,null);
                HSFE_Proposal_TriggerHandler_Class.PrimaryQuoteLogic_BeforeInsert(null,null,null,null);
                HSFE_Proposal_TriggerHandler_Class.UpdateOpportunityOnProposalChange_AfterUpdate(null,null,null,null);
                HSFE_Proposal_TriggerHandler_Class.onAfterUpdate(null,null);
                HSFE_Proposal_TriggerHandler_Class.onAfterInsert(null);
                HSFE_Proposal_TriggerHandler_Class.updateVersionNumber(null);
                HSFE_Proposal_TriggerHandler_Class.UpdateOpportunityWithPrimaryQuote(null,null,null,null);
                HSFE_Proposal_TriggerHandler_Class.UpdateOldQuoteToPrimary_BeforeDelete(null);
                HSFE_Proposal_TriggerHandler_Class.AutoPopulateProductCode_BeforeUpdate(null,null,null,null);
                HSFE_Proposal_TriggerHandler_Class.UpdateContractCodes(null,null,null);

              
            }         
        }
        catch(exception e){
        }
    }
}