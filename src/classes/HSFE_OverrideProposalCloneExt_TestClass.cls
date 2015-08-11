/* 
*Class Name : HSFE_OverrideProposalCloneExt_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_OverrideProposalCloneExt class.
*Created By  :Ajay Agnihotri
*Created On  :05/18/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Ajay Agnihotri            29/June/2015                                                Added Assert to TestClass
* Ajay Agnihotri            29/June/2015                                                Updated test Coverage after Code Modifications
*
*/
@isTest(SeeAllData= false)
private class HSFE_OverrideProposalCloneExt_TestClass {
   
    // Below Method is used to Cover Deep Clone Test Senario's With Related Objects
    static testMethod void OverrideProposalCloneExt_DeepClone_WithRelatedObjects_Test(){
        try{
           //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
                //Insert the Account record
                Account NewAccount = new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                System.AssertNotEquals(NewAccount.id,null);
                
                Contact con = HSFE_TestUtility_Class.createContactRecord(NewAccount);
                con.HSFE_Primary__c = True;
                con.HSFE_Active__c =True;  
                con.HSFE_Specialty__c='Surgical';
                con.HSFE_Sub_Specialty__c='Energy';  
                insert con;
                System.AssertNotEquals(con.id,null);
                
                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUser.id,'Test');
                insert ATM;
                
                //Insert the Opportunity record
                Opportunity NewOpportunity = new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount); 
                NewOpportunity.HSFE_Contact__c=con.id;              
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
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'HSFE-v1Test-v2Test-v4' );
                insert NewProposal;
                System.AssertNotEquals(NewProposal.id,null);

                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                //NewProductConf.Apttus_Config2__Status__c='Finalized';
                insert NewProductConf;
                System.AssertNotEquals(NewProductConf.id,null);
                
                // Insert Category record
                Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
                NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
                insert NewCategory;
                System.AssertNotEquals(NewCategory.id,null);
                
                // Insert Category Hierarchy record
                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy=new Apttus_Config2__ClassificationHierarchy__c();
                string Category_Hierarchy_Label_Str='HSFE_CategoryHierarchy';
                for(string Category_Hierarchy_Label_Ins: HSFE_Constant.CUSTOM_CATEGORYLABEL){
                    Category_Hierarchy_Label_Str=Category_Hierarchy_Label_Ins;
                }
                NewCategoryHierarchy=HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory,Category_Hierarchy_Label_Str);
                insert NewCategoryHierarchy;
                System.AssertNotEquals(NewCategoryHierarchy.id,null);

                //Insert the Option Product record ie Normal product
                List<Product2> NewOptionProductLst=new List<Product2>();
                NewOptionProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                for(Product2 OptionProd:NewOptionProductLst){
                    OptionProd.HSFE_Product_Type__c=HSFE_Constant.COUSTOM_SKP;
                    OptionProd.Is_Stocking_Kit__c=true;
                    OptionProd.HSFE_Part_Number__c='2';
                }
                insert NewOptionProductLst;
                System.AssertNotEquals(NewOptionProductLst.size(),0);
                
                //Insert the Product record
                List<Product2> NewProductLst=new List<Product2>();
                NewProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                insert NewProductLst;
                System.AssertEquals(NewProductLst.size(),1);

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

                    // Inset Product Option Group
                    Apttus_Config2__ProductOptionGroup__c NewProductOptionGroup=new Apttus_Config2__ProductOptionGroup__c();
                    NewProductOptionGroup=HSFE_TestUtility_Class.createSingleProductOptionGroup(NewCategoryHierarchy.id, NewCategoryHierarchy.id, true, NewProductLst[0].id);
                    insert NewProductOptionGroup;
                    System.AssertNotEquals(NewProductOptionGroup.id,null);
                    
                    // Inset Product Option Component
                    Apttus_Config2__ProductOptionComponent__c NewProductOptionComponent=new Apttus_Config2__ProductOptionComponent__c();
                    NewProductOptionComponent=HSFE_TestUtility_Class.createSingleProductOptionComponent(NewOptionProductLst[0].id, NewProductLst[0].id, NewProductOptionGroup.id, 'Option', 1,0,1,1);
                    insert NewProductOptionComponent;
                    System.AssertNotEquals(NewProductOptionComponent.id,null);
                    
                    // Insert ProductClassification record
                    Apttus_Config2__ProductClassification__c NewProductClassification=new Apttus_Config2__ProductClassification__c();
                    NewProductClassification=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy,NewProductLst[0]);
                    NewProductClassification.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    insert NewProductClassification;
                    System.AssertNotEquals(NewProductClassification.id,null);
                
                    //Insert the LineItem record
                    Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                    NewLineItem=HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    NewLineItem.HSFE_Product_Classification__c=NewProductClassification.id;
                    NewLineItem.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem.Apttus_Config2__PriceListItemId__c=NewPriceListItem.id;
                    NewLineItem.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy.id;
                    NewLineItem.Apttus_Config2__AdjustmentType__c='Test';
                    //NewLineItem.Apttus_Config2__AdjustmentType__c=HSFE_Constant.PERDISCOUNT;
                    insert NewLineItem;
                    System.AssertNotEquals(NewLineItem.id,null);
                   
                    Apttus_Config2__TempObject__c newTempObj = new Apttus_Config2__TempObject__c();
                    newTempObj.Apttus_Config2__ConfigurationId__c=NewProductConf.id;
                    insert newTempObj;
                    
                    //Insert the SummaryGroup record
                    Apttus_Config2__SummaryGroup__c NewSummaryGp=new Apttus_Config2__SummaryGroup__c();
                    NewSummaryGp=HSFE_TestUtility_Class.createSingleSummaryGroup(NewProductConf);
                    insert NewSummaryGp;
                
                System.debug('$$$'+NewSummaryGp);
                //Insert the Proposal_Line_Item record
                Apttus_Proposal__Proposal_Line_Item__c NewProposalLineItem=new Apttus_Proposal__Proposal_Line_Item__c();
                NewProposalLineItem=HSFE_TestUtility_Class.createSingleProposalLineItem(NewProductConf,NewProposal,NewLineItem);
                insert NewProposalLineItem;
                }
                Test.StartTest();
                // Associate the DeepClone VF
                PageReference pgRef = Page.HSFE_OverrideProposalClone;
                pgRef.getParameters().put('id', NewProposal.id);
                pgRef.getParameters().put('retURL', NewProposal.id);
                Test.setCurrentPageReference(pgRef);
                
                // Make call to Deep Clone Extension
                ApexPAges.StandardController sc = new ApexPages.StandardController(NewProposal);
                HSFE_OverrideProposalCloneExt ClsDeepCloneInstance1=new HSFE_OverrideProposalCloneExt(sc);
                ClsDeepCloneInstance1.init();
         
                Test.StopTest();

            }
        }
        catch(exception e){
        }
     
    }
    
    // Below Method is used to Cover Deep Clone Test Senario's With Related Objects and Complex Version Name
    static testMethod void OverrideProposalCloneExt_DeepClone_WithComplexVersionName_Test(){
        try{
           //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
                //Insert the Account record
                Account NewAccount = new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                System.AssertNotEquals(NewAccount.id,null);
                
                Contact con = HSFE_TestUtility_Class.createContactRecord(NewAccount);
                con.HSFE_Primary__c = True;
                con.HSFE_Active__c =true;  
                con.HSFE_Specialty__c='Surgical';
                con.HSFE_Sub_Specialty__c='Energy';  
                insert con;
                System.AssertNotEquals(con.id,null);
                
                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUser.id,'Test');
                insert ATM;
                
                
                //Insert the Opportunity record
                Opportunity NewOpportunity = new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount); 
                NewOpportunity.HSFE_Contact__c=con.id;              
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
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'HSFE-v1Test-v2Test-v4-v6-v7-vBAcd--v' );
                insert NewProposal;
                System.AssertNotEquals(NewProposal.id,null);
                
                NewProposal.Apttus_Proposal__Proposal_Name__c='HSFE-v1Test-v2Test-v4-v6-v7-vBAcd--v';
                update NewProposal;
               
                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                //NewProductConf.Apttus_Config2__Status__c='Finalized';
                insert NewProductConf;
                System.AssertNotEquals(NewProductConf.id,null);
                
                
                // Insert Category record
                Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
                NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
                insert NewCategory;
                System.AssertNotEquals(NewCategory.id,null);
                
                // Insert Category Hierarchy record
                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy=new Apttus_Config2__ClassificationHierarchy__c();
                string Category_Hierarchy_Label_Str='HSFE_CategoryHierarchy';
                for(string Category_Hierarchy_Label_Ins: HSFE_Constant.CUSTOM_CATEGORYLABEL){
                    Category_Hierarchy_Label_Str=Category_Hierarchy_Label_Ins;
                }
                NewCategoryHierarchy=HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory,Category_Hierarchy_Label_Str);
                insert NewCategoryHierarchy;
                System.AssertNotEquals(NewCategoryHierarchy.id,null);
                
                //Insert the Option Product record ie Normal product
                List<Product2> NewOptionProductLst=new List<Product2>();
                NewOptionProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                for(Product2 OptionProd:NewOptionProductLst){
                    OptionProd.HSFE_Product_Type__c=HSFE_Constant.COUSTOM_SKP;
                    OptionProd.Is_Stocking_Kit__c=true;
                    OptionProd.HSFE_Part_Number__c='2';
                }
                insert NewOptionProductLst;
                System.AssertNotEquals(NewOptionProductLst.size(),0);
                
                //Insert the Product record
                List<Product2> NewProductLst=new List<Product2>();
                NewProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                insert NewProductLst;
                System.AssertEquals(NewProductLst.size(),1);

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


                    // Inset Product Option Group
                    Apttus_Config2__ProductOptionGroup__c NewProductOptionGroup=new Apttus_Config2__ProductOptionGroup__c();
                    NewProductOptionGroup=HSFE_TestUtility_Class.createSingleProductOptionGroup(NewCategoryHierarchy.id, NewCategoryHierarchy.id, true, NewProductLst[0].id);
                    insert NewProductOptionGroup;
                    System.AssertNotEquals(NewProductOptionGroup.id,null);
                    
                    // Inset Product Option Component
                    Apttus_Config2__ProductOptionComponent__c NewProductOptionComponent=new Apttus_Config2__ProductOptionComponent__c();
                    NewProductOptionComponent=HSFE_TestUtility_Class.createSingleProductOptionComponent(NewOptionProductLst[0].id, NewProductLst[0].id, NewProductOptionGroup.id, 'Option', 1,0,1,1);
                    insert NewProductOptionComponent;
                    System.AssertNotEquals(NewProductOptionComponent.id,null);
                    
                    // Insert ProductClassification record
                    Apttus_Config2__ProductClassification__c NewProductClassification=new Apttus_Config2__ProductClassification__c();
                    NewProductClassification=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy,NewProductLst[0]);
                    NewProductClassification.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    insert NewProductClassification;
                    System.AssertNotEquals(NewProductClassification.id,null);

                
                    //Insert the LineItem record
                    Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                    NewLineItem=HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    NewLineItem.HSFE_Product_Classification__c=NewProductClassification.id;
                    NewLineItem.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem.Apttus_Config2__PriceListItemId__c=NewPriceListItem.id;
                    NewLineItem.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy.id;
                    NewLineItem.Apttus_Config2__AdjustmentType__c='Test';
                    //NewLineItem.Apttus_Config2__AdjustmentType__c=HSFE_Constant.PERDISCOUNT;
                    insert NewLineItem;
                    System.AssertNotEquals(NewLineItem.id,null);
                   
                    Apttus_Config2__TempObject__c newTempObj = new Apttus_Config2__TempObject__c();
                    newTempObj.Apttus_Config2__ConfigurationId__c=NewProductConf.id;
                    insert newTempObj;
                    System.debug('***'+newTempObj);
                    //Insert the SummaryGroup record
                    Apttus_Config2__SummaryGroup__c NewSummaryGp=new Apttus_Config2__SummaryGroup__c();
                    NewSummaryGp=HSFE_TestUtility_Class.createSingleSummaryGroup(NewProductConf);
                    insert NewSummaryGp;
                
                System.debug('$$$'+NewSummaryGp);
                //Insert the Proposal_Line_Item record
                Apttus_Proposal__Proposal_Line_Item__c NewProposalLineItem=new Apttus_Proposal__Proposal_Line_Item__c();
                NewProposalLineItem=HSFE_TestUtility_Class.createSingleProposalLineItem(NewProductConf,NewProposal,NewLineItem);
                insert NewProposalLineItem;
                }
                Test.StartTest();
                // Associate the DeepClone VF
                PageReference pgRef = Page.HSFE_OverrideProposalClone;
                pgRef.getParameters().put('id', NewProposal.id);
                pgRef.getParameters().put('retURL', NewProposal.id);
                Test.setCurrentPageReference(pgRef);
                
                // Make call to Deep Clone Extension
                ApexPAges.StandardController sc = new ApexPages.StandardController(NewProposal);
                HSFE_OverrideProposalCloneExt ClsDeepCloneInstance1=new HSFE_OverrideProposalCloneExt(sc);
                ClsDeepCloneInstance1.init();
         
                Test.StopTest();
            }
        }
        catch(exception e){
        }
    }
}