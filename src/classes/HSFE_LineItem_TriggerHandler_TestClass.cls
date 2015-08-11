/* Class Name   : HSFE_LineItem_TriggerHandler_TestClass 
 * Description  : Testclass for LineItem Trigger Handler
 * Created By   : Ajay Agnihotri
 * Created On   : 20/May/2015
 * Modification Log:  
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                        Description
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 *
 *
 */
 @isTest(SeeAllData= false)
public class HSFE_LineItem_TriggerHandler_TestClass {
    static testMethod void LineItemTrigger_TestScenarios_With_PreDefinedContantsAndValues() {
        try{
            //Insert the User Role record
            UserRole NewUserRole=new UserRole();
            NewUserRole=  HSFE_TestUtility_Class.createRole();
            insert NewUserRole;
            
            //Insert the User record
            User NewcreateUser=new User();
            NewcreateUser = HSFE_TestUtility_Class.createUser(NewUserRole);
            insert NewcreateUser;
            
            
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            Apttus_Config2__PriceList__c NewPriceList2=new Apttus_Config2__PriceList__c();
            Apttus_Config2__PriceListItem__c NewPriceListItem2=new Apttus_Config2__PriceListItem__c();
            
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
                Test.StartTest();
                
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                
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
                
                //Insert the Related Account record
                List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
                RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
                insert RelatedAccLst;
                
                //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.HSFE_Approval_AVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_DVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_GVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_RSD_RVP_User__c=NewcreateUser.id;
                insert NewOpportunity ;
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                
                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.HSFE_FIT_Quote__c=true;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
                insert NewProposal;
                
                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                //NewProductConf.Apttus_Config2__Status__c='Finalized';
                insert NewProductConf;
                
                // Insert Category record
                Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
                NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
                insert NewCategory;
                
                // Insert Category Hierarchy record
                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy=new Apttus_Config2__ClassificationHierarchy__c();
                string Category_Hierarchy_Label_Str='HSFE_CategoryHierarchy';
                for(string Category_Hierarchy_Label_Ins: HSFE_Constant.CUSTOM_CATEGORYLABEL){
                    Category_Hierarchy_Label_Str=Category_Hierarchy_Label_Ins;
                }
                NewCategoryHierarchy=HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory,Category_Hierarchy_Label_Str);
                insert NewCategoryHierarchy;
                

                //Insert the Product record
                List<Product2> NewProductLst=new List<Product2>();
                NewProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                insert NewProductLst;
               
                if(NewProductLst.size()>0){
                    
                    //Insert the PriceListItem record
                    Apttus_Config2__PriceListItem__c NewPriceListItem=new Apttus_Config2__PriceListItem__c();
                    NewPriceListItem=HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList, NewProductLst[0], 'New Price', 'One Time', 'Per Unit', 100);
                    insert NewPriceListItem;

                    // Insert ProductClassification record
                    Apttus_Config2__ProductClassification__c NewProductClassification=new Apttus_Config2__ProductClassification__c();
                    NewProductClassification=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy,NewProductLst[0]);
                    NewProductClassification.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    insert NewProductClassification;

                
                    //Insert the LineItem record
                    NewLineItem=new Apttus_Config2__LineItem__c();
                    NewLineItem=HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    NewLineItem.HSFE_Product_Classification__c=NewProductClassification.id;
                    NewLineItem.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem.Apttus_Config2__PriceListItemId__c=NewPriceListItem.id;
                    NewLineItem.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy.id;
                    NewLineItem.Apttus_Config2__AdjustmentType__c='Test';
                    //NewLineItem.Apttus_Config2__AdjustmentType__c=HSFE_Constant.PERDISCOUNT;
                    insert NewLineItem;
                    
                    NewCategoryHierarchy.Apttus_Config2__Label__c='Capital';
                    update NewCategoryHierarchy;
                    
                    NewProposal.HSFE_FIT_Quote__c=false;
                    NewProposal.Apttus_Proposal__Approval_Stage__c='Approved';
                    update NewProposal;
                    
  
                    NewLineItem.Apttus_Config2__PriceListId__c=NewPriceList2.id;
                    NewLineItem.Apttus_Config2__PriceListItemId__c=NewPriceListItem2.id;
                    NewLineItem.HSFE_Admin_Update_Flag__c=false;
                    //NewLineItem.HSFE_Freight_Integration_Status__c='Synced';
                    NewLineItem.HSFE_Contract_Price__c=1000;
                    NewLineItem.Apttus_Config2__AdjustmentType__c=HSFE_Constant.PERDISCOUNT;
                    update NewLineItem;

                }
                
                Test.StopTest(); 
            } 
  
        }
        catch(exception e){
            
        }       
    }
    
    //Updating HSFE_Freight_Integration and HSFE_Contract_Integration status to cover logic in updateFreightChargesAndIntegrationStatus_AfterUpdate and updateIntegrationStatus_AfterUpdate respectively
    static testMethod void LineItemTrigger_TestScenarios_HSFE_FreightAndContract_Integration() {
        try{
            //Insert the User Role record
            UserRole NewUserRole=new UserRole();
            NewUserRole=  HSFE_TestUtility_Class.createRole();
            NewUserRole.Name=HSFE_Constant.GVP;
            insert NewUserRole;
            
            //Insert the User record
            User NewcreateUser=new User();
            NewcreateUser = HSFE_TestUtility_Class.createUser(NewUserRole);
            NewcreateUser.HSFE_Specialty__c=HSFE_Constant.MEDICAL;
            insert NewcreateUser;
            
            
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            Apttus_Config2__PriceList__c NewPriceList2=new Apttus_Config2__PriceList__c();
            Apttus_Config2__PriceListItem__c NewPriceListItem2=new Apttus_Config2__PriceListItem__c();
            
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
                Test.StartTest();
                
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                
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
                
                //Insert the Related Account record
                List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
                RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
                insert RelatedAccLst;
                
                //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.HSFE_Approval_AVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_DVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_GVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_RSD_RVP_User__c=NewcreateUser.id;
                insert NewOpportunity ;
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                
                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.HSFE_FIT_Quote__c=false;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
                insert NewProposal;
                
                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                NewProductConf.Apttus_Config2__Status__c='Finalized';
                insert NewProductConf;
                
                // Insert Category record
                Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
                NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
                insert NewCategory;
                
                // Insert Category Hierarchy record
                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy=new Apttus_Config2__ClassificationHierarchy__c();
                string Category_Hierarchy_Label_Str='Capital';
                NewCategoryHierarchy=HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory,Category_Hierarchy_Label_Str);
                insert NewCategoryHierarchy;

                //Insert the Product record
                List<Product2> NewProductLst=new List<Product2>();
                NewProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                if(NewProductLst.size()>0)
                    NewProductLst[0].Is_Stocking_Kit__c=true;
                insert NewProductLst;
               
                if(NewProductLst.size()>0){
                    
                    //Insert the PriceListItem record
                    Apttus_Config2__PriceListItem__c NewPriceListItem=new Apttus_Config2__PriceListItem__c();
                    NewPriceListItem=HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList, NewProductLst[0], 'New Price', 'One Time', 'Per Unit', 100);
                    insert NewPriceListItem;
    
                    // Insert ProductClassification record
                    Apttus_Config2__ProductClassification__c NewProductClassification=new Apttus_Config2__ProductClassification__c();
                    NewProductClassification=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy,NewProductLst[0]);
                    NewProductClassification.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    insert NewProductClassification;
                    
                
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

                    // Updating HSFE_Freight_Integration and HSFE_Contract_Integration status to cover logic in updateFreightChargesAndIntegrationStatus_AfterUpdate and updateIntegrationStatus_AfterUpdate respectively
                    NewLineItem.HSFE_Freight_Integration_Status__c='Synced';
                    NewLineItem.HSFE_Contract_Integration_Status__c='Synced';
                    update NewLineItem;
                }
                
                Test.StopTest(); 
            }         
        }
        catch(exception e){
           
        }
    }

    static testMethod void LineItemTrigger_TestScenarios_Without_PreDefinedContantsAndValues() {
        try{
            //Insert the User Role record
            UserRole NewUserRole=new UserRole();
            NewUserRole=  HSFE_TestUtility_Class.createRole();
            NewUserRole.Name=HSFE_Constant.GVP;
            insert NewUserRole;
            
            //Insert the User record
            User NewcreateUser=new User();
            NewcreateUser = HSFE_TestUtility_Class.createUser(NewUserRole);
            NewcreateUser.HSFE_Specialty__c=HSFE_Constant.SURGICAL;
            insert NewcreateUser;
            
            
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            Apttus_Config2__PriceList__c NewPriceList2=new Apttus_Config2__PriceList__c();
            Apttus_Config2__PriceListItem__c NewPriceListItem2=new Apttus_Config2__PriceListItem__c();
            
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
                Test.StartTest();
                
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                
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
                
                //Insert the Related Account record
                List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
                RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
                insert RelatedAccLst;
                
                //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.HSFE_Approval_AVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_DVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_GVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_RSD_RVP_User__c=NewcreateUser.id;
                insert NewOpportunity ;
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                
                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.HSFE_FIT_Quote__c=false;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
                insert NewProposal;
                
                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                NewProductConf.Apttus_Config2__Status__c='Finalized';
                insert NewProductConf;
                
                // Insert Category record
                Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
                NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
                insert NewCategory;
                
                // Insert Category Hierarchy record
                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy=new Apttus_Config2__ClassificationHierarchy__c();
                string Category_Hierarchy_Label_Str='Capital';
                NewCategoryHierarchy=HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory,Category_Hierarchy_Label_Str);
                insert NewCategoryHierarchy;
                
                
                //Insert the Product record
                List<Product2> NewProductLst=new List<Product2>();
                NewProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                insert NewProductLst;
               
                if(NewProductLst.size()>0){
                    
                    //Insert the PriceListItem record
                    Apttus_Config2__PriceListItem__c NewPriceListItem=new Apttus_Config2__PriceListItem__c();
                    NewPriceListItem=HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList, NewProductLst[0], 'New Price', 'One Time', 'Per Unit', 100);
                    insert NewPriceListItem;
                    
                    //Insert the PriceDimension record
                    Apttus_Config2__PriceDimension__c NewPriceDimension=new Apttus_Config2__PriceDimension__c();
                    NewPriceDimension=HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                    insert NewPriceDimension;
                    
                    //Insert the PriceMatrix record
                    Apttus_Config2__PriceMatrix__c NewPriceMatrix=new Apttus_Config2__PriceMatrix__c();
                    NewPriceMatrix=HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension,NewPriceListItem);
                    insert NewPriceMatrix;
                    
                    //Insert the PriceMatrixEntry record
                    Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry=new Apttus_Config2__PriceMatrixEntry__c();
                    NewPriceMatrixEntry=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'New',NewPriceMatrix,43431);
                    insert NewPriceMatrixEntry;
                    
                    List<Apttus_Config2__PriceMatrixEntry__c> PriceMatrixEntryList=new List<Apttus_Config2__PriceMatrixEntry__c>();
                    
                    
                    /* we are passing the object API name to our custom method to get all the fields API Name*/
                       
                    string PriceMatrixEntryDynamicQuery = 'Select '+ObjectFields('Apttus_Config2__PriceMatrixEntry__c')+' from Apttus_Config2__PriceMatrixEntry__c ';
 
                    /*if you  see the above line its look very simple but its important one .And If you want any related
                    object fields through relationship the you need to use like 'Library__r.Name' and if you want any
                    conditions you can add it */

                    PriceMatrixEntryList= Database.query(PriceMatrixEntryDynamicQuery);
                    if(PriceMatrixEntryList.size()>0)
                        NewPriceMatrixEntry=PriceMatrixEntryList[0];


                    // Insert ProductClassification record
                    Apttus_Config2__ProductClassification__c NewProductClassification=new Apttus_Config2__ProductClassification__c();
                    NewProductClassification=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy,NewProductLst[0]);
                    NewProductClassification.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    insert NewProductClassification;
                    

                    //Insert the LineItem record
                    NewLineItem=new Apttus_Config2__LineItem__c();
                    NewLineItem=HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    NewLineItem.HSFE_Product_Classification__c=NewProductClassification.id;
                    //NewLineItem.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    //NewLineItem.Apttus_Config2__PriceListItemId__c=NewPriceListItem.id;
                    NewLineItem.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy.id;
                    //NewLineItem.Apttus_Config2__AdjustmentType__c=HSFE_Constant.PERDISCOUNT;
                    //NewLineItem.HSFE_UOM__c='CPO';
                    NewLineItem.HSFE_Target_Price__c=2;
                    NewLineItem.Apttus_Config2__Cost__c=2;
                    NewLineItem.Apttus_Config2__ExtendedCost__c=0;
                    NewLineItem.Apttus_Config2__BaseExtendedPrice__c=0;
                    NewLineItem.Apttus_Config2__BaseExtendedCost__c=0;
                    NewLineItem.Apttus_Config2__BaseCost__c=0;
                    NewLineItem.HSFE_UOM_Denominator__c=null;
                    insert NewLineItem;
                    
                    /*
                    NewProposal.HSFE_FIT_Quote__c=true;
                    NewProposal.Apttus_Proposal__Approval_Stage__c='Approved';
                    update NewProposal;
                    
                    
                    //Insert the Sencond LineItem record
                    Apttus_Config2__LineItem__c NewLineItem2=new Apttus_Config2__LineItem__c();
                    NewLineItem2=HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem2.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    NewLineItem2.HSFE_Product_Classification__c=NewProductClassification.id;
                    NewLineItem2.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem2.Apttus_Config2__PriceListItemId__c=NewPriceListItem.id;
                    NewLineItem2.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy.id;
                    NewLineItem2.Apttus_Config2__AdjustmentType__c='ABC';
                    NewLineItem.HSFE_Contract_Price__c=1000;
                    NewLineItem.HSFE_UOM__c='CPO';
                    insert NewLineItem2;
                    */

                    List<Apttus_Config2__LineItem__c> LineItemList=new List<Apttus_Config2__LineItem__c>();
                    
                    
                    /* we are passing the object API name to our custom method to get all the fields API Name*/
                       
                    string LineItemDynamicQuery = 'Select '+ObjectFields('Apttus_Config2__LineItem__c')+' from Apttus_Config2__LineItem__c ';

                    /*if you  see the above line its look very simple but its important one .And If you want any related
                    object fields through relationship the you need to use like 'Library__r.Name' and if you want any
                    conditions you can add it */

                    LineItemList= Database.query(LineItemDynamicQuery);
                    
                    //HSFE_LineItemTriggerHandler_Class.onAfterInsertUpdate(LineItemList); // This is to excecute the logic of onAfterInsertUpdate method

                }
                
                Test.StopTest(); 
            }         
        }
        catch(exception e){
            
        }
    }

    //Getting the fields from object
    public static String ObjectFields(String ObjectNameval){
        string fieldsVal = '';
        SObjectType objToken = Schema.getGlobalDescribe().get(ObjectNameval);

        /* For this method we are getting the object API name both for standard object and cutom object
               getGlobalDescribe()-method returns the map of all sobject names(Keyset) with sobject
               token(value paires)
                e.g. Assume if your org contains one custom object called Book(Book__c) with all standard
                       object.Then the result of getGlobalDescribe method will be 
                        Map<Book__c,Book object tokens> like with all standard objects.
          getGlobalDescribe().get(ObjectNameval)-As we know we get value pairs from map by using
          get() method.This will return an Book__c object type this we collected in SObjectType variable
          token. So the object token value is Book__c*/

          DescribeSObjectResult objDef = objToken.getDescribe();
           
          /*getDescribe()-An object(Book) that contains all the describe properties for the sobject(Book)
             or fields. 
                        e.g. getKeyPrefix, getLabel, getLabelPlural, getLocalName etc.
           */
               
           Map<String, SObjectField> fields = objDef.fields.getMap();
              
           /*Map of the fields value. e.g. {name=Name,author__c=Author__c,etc}*/
                    
           Set<String> fieldSet = fields.keySet();
                
           /*Collecting the fields API  into set variable fieldset.*/
                 
           for(string f : fieldSet){
                fieldsVal += f +',';
           }   
           if(fieldsVal.endsWith(','))
           fieldsVal= fieldsVal.substring(0,fieldsVal.length()-1);
                    
           /*Adding , string after every fields api name.
                e.g  fieldsVal-variable will contains the value like -Name,pincode__c,CreateDate etc.
           */
           return fieldsVal;
        }   
}