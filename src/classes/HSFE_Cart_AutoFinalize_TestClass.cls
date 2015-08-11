/* 
*Class Name : HSFE_Cart_AutoFinalize_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_Cart_AutoFinalize class.
*Created By  :Teena Philip
*Created On  :06/12/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest(SeeAllData= false)

private class HSFE_Cart_AutoFinalize_TestClass {   
    
    static testMethod void HSFE_Cart_AutoFinalize_TestMethod_1(){

        try{
             //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
            insert NewcreateUser;

            System.AssertNotEquals(NewcreateUser , null);
            // Run Test Logic as Test User
            
            
            Apttus_Config2__LineItem__c NewLineItem1;
            Apttus_Config2__LineItem__c NewLineItem2;
            Apttus_Config2__LineItem__c NewLineItem3;

            list<Apttus_Config2__LineItem__c> ListLineItem = new list<Apttus_Config2__LineItem__c>();
            list<Apttus_Config2__PriceMatrixEntry__c> InsertPriceMatrixEntry = new list<Apttus_Config2__PriceMatrixEntry__c>();
            // Run Test Logic as Test User
            system.runAs(NewcreateUser){
                
                Test.StartTest();
                
                //Insert the Account record
                Account NewAccount=new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                NewAccount.HSFE_SAP_ID__c='1234';
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
                NewOpportunity.HSFE_Approval_AVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_DVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_GVP_User__c=NewcreateUser.id;
                NewOpportunity.HSFE_Approval_RSD_RVP_User__c=NewcreateUser.id;
                insert NewOpportunity ;
                System.AssertNotEquals(NewOpportunity.id,null);
                
                //----------------------------------------------------Insert the PriceList record-----------------------------------------------------
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                System.AssertNotEquals(NewPriceList.id,null);
                
                // -----------------------------------------------------Insert PriceListId In Custom Setting--------------------------------------------
                
                HSFE_Contant_Helper__c ContactHelperIns = new HSFE_Contant_Helper__c();
                ContactHelperIns.Name='HSFE_Olympus_MSG_NA';
                ContactHelperIns.HSFE_Value__c=NewPriceList.id;
                insert ContactHelperIns;
                System.AssertNotEquals(ContactHelperIns.id,null);
                
                //-----------------------------------------------------Insert the Proposal record -----------------------------------------------------
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.HSFE_FIT_Quote__c = false;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
                insert NewProposal;
                System.AssertNotEquals(NewProposal.id,null);
                
                // ----------------------------------------------------Insert the ProductConfiguration record ---------------------------------------
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                insert NewProductConf;
                System.AssertNotEquals(NewProductConf.id,null);
                
                // -----------------------------------------------------Insert Category record-----------------------------------------------------
                Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
                NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
                insert NewCategory;
                System.AssertNotEquals(NewCategory.id,null);

                Apttus_Config2__ClassificationName__c NewCategory2=new Apttus_Config2__ClassificationName__c();
                NewCategory2=HSFE_TestUtility_Class.createSingleCategory('Mandatory Accessories','Option Group');
                insert NewCategory2;
                System.AssertNotEquals(NewCategory2.id,null);                
                
                // -----------------------------------------------------Insert Category Hierarchy record-----------------------------------------------------
                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy1 = new Apttus_Config2__ClassificationHierarchy__c();
                NewCategoryHierarchy1=HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory,HSFE_Constant.COUSTOM_CAPITAL);
                insert NewCategoryHierarchy1;
                System.AssertNotEquals(NewCategoryHierarchy1.id,null);

                Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy2 = new Apttus_Config2__ClassificationHierarchy__c();
                NewCategoryHierarchy2 = HSFE_TestUtility_Class.createSingleCategoryHeirachy(NewCategory2,HSFE_Constant.COUSTOM_MANDATORY);
                NewCategoryHierarchy2.Apttus_Config2__Label__c = HSFE_Constant.COUSTOM_MANDATORY;
                insert NewCategoryHierarchy2;
                System.AssertNotEquals(NewCategoryHierarchy2.id,null);                
                
                //-----------------------------------------------------Insert the Product record-----------------------------------------------------
                List<Product2> NewProductLst = new List<Product2>();

                NewProductLst = HSFE_TestUtility_Class.createProductRecords(1,'Bundle');
                for(Product2 Prod:NewProductLst){
                    Prod.Apttus_Config2__HasOptions__c=true;
                    Prod.Apttus_Config2__Customizable__c=true;
                    Prod.HSFE_Is_Kit_In_A_Kit__c = True;
                    Prod.HSFE_Is_Batch__c = True;
                    Prod.Is_Stocking_Kit__c = True;
                    Prod.HSFE_Part_Number__c='1';
                }
                insert NewProductLst;

                System.AssertEquals(NewProductLst.size(),1);
                
                //Insert the Option Product record ie Normal product
                List<Product2> NewOptionProductLst=new List<Product2>();
                NewOptionProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                for(Product2 OptionProd:NewOptionProductLst){
                    OptionProd.HSFE_Is_Kit_In_A_Kit__c = True;
                    OptionProd.HSFE_Is_Batch__c = True;
                    OptionProd.HSFE_Part_Number__c='2';
                }
                insert NewOptionProductLst;
                System.AssertNotEquals(NewOptionProductLst.size(),0);
                
               
                if(NewProductLst.size()>0){
                    
                    //-----------------------------------------------------Insert the PriceListItem record-----------------------------------------------------
                    Apttus_Config2__PriceListItem__c NewPriceListItem1 = new Apttus_Config2__PriceListItem__c();
                    NewPriceListItem1 = HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList,NewProductLst[0],'New','One Time','Per Unit',100);
                    NewPriceListItem1.HSFE_Floor_Price__c = 8000;
                    NewPriceListItem1.HSFE_JSON_Up_to_Date__c = false;
                    insert NewPriceListItem1;
                    System.AssertNotEquals(NewPriceListItem1.id,null);   

                    Apttus_Config2__PriceListItem__c NewPriceListItem2 = new Apttus_Config2__PriceListItem__c();
                    NewPriceListItem2 = HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList,NewOptionProductLst[0],'New','One Time','Per Unit',100);
                    NewPriceListItem2.HSFE_Floor_Price__c = 8000;
                    NewPriceListItem2.HSFE_JSON_Up_to_Date__c = false;
                    insert NewPriceListItem2;
                    System.AssertNotEquals(NewPriceListItem2.id,null); 
                    
                    //-----------------------------------------------------Insert the PriceDimension record-----------------------------------------------------
                    Apttus_Config2__PriceDimension__c NewPriceDimension = new Apttus_Config2__PriceDimension__c();
                    NewPriceDimension = HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                    insert NewPriceDimension;
                    System.AssertNotEquals(NewPriceDimension.id,null);

                    Apttus_Config2__PriceDimension__c NewPriceDimension2 = new Apttus_Config2__PriceDimension__c();
                    NewPriceDimension2 = HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                    insert NewPriceDimension2;
                    System.AssertNotEquals(NewPriceDimension2.id,null);                    
                    
                    //-----------------------------------------------------Insert the PriceMatrix record----------------------------------------------------------
                    Apttus_Config2__PriceMatrix__c NewPriceMatrix1 = new Apttus_Config2__PriceMatrix__c();
                    NewPriceMatrix1=HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension,NewPriceListItem1);
                    insert NewPriceMatrix1;
                    
                    Apttus_Config2__PriceMatrix__c NewPriceMatrix2 = new Apttus_Config2__PriceMatrix__c();
                    NewPriceMatrix2 = HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension2,NewPriceListItem2);
                    insert NewPriceMatrix2;                    
                    
                    //-----------------------------------------------------Insert the PriceMatrixEntry record-----------------------------------------------------
                    Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry1 = new Apttus_Config2__PriceMatrixEntry__c();
                    NewPriceMatrixEntry1=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'New',NewPriceMatrix1,43431);
                    NewPriceMatrixEntry1.HSFE_Target_Price__c = 100;
                    InsertPriceMatrixEntry.add(NewPriceMatrixEntry1);

                    Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry2 = new Apttus_Config2__PriceMatrixEntry__c();
                    NewPriceMatrixEntry2=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'New',NewPriceMatrix2,43431);
                    NewPriceMatrixEntry2.HSFE_Target_Price__c = 100;
                    InsertPriceMatrixEntry.add(NewPriceMatrixEntry2); 
                    
                    Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry3 = new Apttus_Config2__PriceMatrixEntry__c();
                    NewPriceMatrixEntry3=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'Trade-In Olympus',NewPriceMatrix2,43431);
                    NewPriceMatrixEntry3.HSFE_Target_Price__c = 100;
                    InsertPriceMatrixEntry.add(NewPriceMatrixEntry3);

                    Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry4 = new Apttus_Config2__PriceMatrixEntry__c();
                    NewPriceMatrixEntry4=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'EC',NewPriceMatrix2,1);
                    InsertPriceMatrixEntry.add(NewPriceMatrixEntry4);

                    Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry5 = new Apttus_Config2__PriceMatrixEntry__c();
                    NewPriceMatrixEntry5=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'PC',NewPriceMatrix2,1);
                    InsertPriceMatrixEntry.add(NewPriceMatrixEntry5);

                    insert InsertPriceMatrixEntry;

                    //-----------------------------------------------------Update the PriceListItem record-------------------------------------------------------
                    
                    NewPriceListItem1.HSFE_JSON_Up_to_Date__c = false;
                    update NewPriceListItem1; 

                    NewPriceListItem2.HSFE_JSON_Up_to_Date__c = false;
                    update NewPriceListItem2;

                    // -----------------------------------------------------Insert ProductClassification record-------------------------------------------------
                    Apttus_Config2__ProductClassification__c NewProductClassification1 = new Apttus_Config2__ProductClassification__c();
                    NewProductClassification1=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy1,NewProductLst[0]);
                    NewProductClassification1.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                    insert NewProductClassification1;

                    Apttus_Config2__ProductClassification__c NewProductClassification2 = new Apttus_Config2__ProductClassification__c();
                    NewProductClassification2=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy2,NewOptionProductLst[0]);
                    NewProductClassification2.Apttus_Config2__ProductId__c=NewOptionProductLst[0].id;
                    insert NewProductClassification2;
                    System.AssertNotEquals(NewProductClassification2.id,null);
                    
                    // -----------------------------------------------------Inset Product Option Group----------------------------------------------------------
                    Apttus_Config2__ProductOptionGroup__c NewProductOptionGroup = new Apttus_Config2__ProductOptionGroup__c(); 
                    NewProductOptionGroup = HSFE_TestUtility_Class.createSingleProductOptionGroup(NewCategoryHierarchy2.id, NewCategoryHierarchy1.id, true, NewProductLst[0].id);
                    insert NewProductOptionGroup;
                    System.AssertNotEquals(NewProductOptionGroup.id,null);                  
                    
                    // -----------------------------------------------------Inset Product Option Component------------------------------------------------------
                    Apttus_Config2__ProductOptionComponent__c NewProductOptionComponent=new Apttus_Config2__ProductOptionComponent__c();
                    NewProductOptionComponent=HSFE_TestUtility_Class.createSingleProductOptionComponent(NewOptionProductLst[0].id, NewProductLst[0].id, NewProductOptionGroup.id, 'Option', 1,0,1,1);
                    insert NewProductOptionComponent;
                    System.AssertNotEquals(NewProductOptionComponent.id,null);
                                     
                    //-----------------------------------------------------Insert the LineItem record-----------------------------------------------------
                    list<Apttus_Config2__LineItem__c> ListLine = new list<Apttus_Config2__LineItem__c>();

                    NewLineItem1 = new Apttus_Config2__LineItem__c();
                    NewLineItem1 = HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem1.Apttus_Config2__ListPrice__c=1000;
                    NewLineItem1.Apttus_Config2__ProductId__c = NewProductLst[0].id;  
                    NewLineItem1.HSFE_Product_Classification__c=NewProductClassification1.id;
                    NewLineItem1.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem1.Apttus_Config2__PriceListItemId__c=NewPriceListItem1.id;
                    NewLineItem1.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy1.id;
                    NewLineItem1.HSFE_Option_Group_Label__c = HSFE_Constant.COUSTOM_CAPITAL;
                    NewLineItem1.HSFE_UOM_Denominator__c=0;
                    NewLineItem1.HSFE_FIT_Quote_Flag__c = 'False';
                    NewLineItem1.Product_Conditions__c='New';
                    NewLineItem1.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem1.Apttus_Config2__AdjustmentAmount__c = 1;
                    NewLineItem1.HSFE_Contract_Price__c = 100;
                    NewLineItem1.HSFE_Target_Price__c = 100;
                    NewLineItem1.Apttus_Config2__Cost__c = 100;
                    NewLineItem1.HSFE_Contract_Code__c = 'VA2';
                    ListLine.add(NewLineItem1);
                    
                    //Insert the LineItem record
                    NewLineItem2 = new Apttus_Config2__LineItem__c();
                    NewLineItem2 = HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem2.Apttus_Config2__ListPrice__c=1000;
                    NewLineItem2.Apttus_Config2__ProductId__c = NewProductLst[0].id;
                    NewLineItem2.Apttus_Config2__OptionId__c = NewOptionProductLst[0].id;
                    NewLineItem2.HSFE_Product_Classification__c=NewProductClassification2.id;
                    NewLineItem2.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem2.Apttus_Config2__PriceListItemId__c=NewPriceListItem2.id;
                    NewLineItem2.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy2.id;
                    NewLineItem2.Apttus_Config2__ProductOptionId__c=NewProductOptionComponent.id;
                    NewLineItem2.HSFE_Option_Group_Label__c = HSFE_Constant.COUSTOM_MANDATORY;
                    NewLineItem2.HSFE_Order_Type__c = 'Integration';
                    NewLineItem2.HSFE_UOM_Denominator__c=0;
                    NewLineItem2.HSFE_FIT_Quote_Flag__c = 'False';
                    NewLineItem2.Product_Conditions__c='Trade-In Olympus';
                    NewLineItem2.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem2.Apttus_Config2__AdjustmentAmount__c = 1;
                    NewLineItem2.HSFE_Contract_Price__c = 100;
                    NewLineItem2.HSFE_Target_Price__c = 100;
                    NewLineItem2.Apttus_Config2__Cost__c = 100;
                    NewLineItem2.HSFE_Contract_Code__c = 'VA2';                    
                    ListLine.add(NewLineItem2);                    

                    NewLineItem3 = new Apttus_Config2__LineItem__c();
                    NewLineItem3 = HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
                    NewLineItem3.Apttus_Config2__ListPrice__c=1000;
                    NewLineItem3.Apttus_Config2__ProductId__c = NewProductLst[0].id;
                    NewLineItem3.Apttus_Config2__OptionId__c = NewOptionProductLst[0].id;
                    NewLineItem3.HSFE_Product_Classification__c=NewProductClassification2.id;
                    NewLineItem3.Apttus_Config2__PriceListId__c=NewPriceList.id;
                    NewLineItem3.Apttus_Config2__PriceListItemId__c=NewPriceListItem2.id;
                    NewLineItem3.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy2.id;
                    NewLineItem3.Apttus_Config2__ProductOptionId__c=NewProductOptionComponent.id;
                    NewLineItem3.HSFE_Option_Group_Label__c = HSFE_Constant.COUSTOM_MANDATORY;
                    NewLineItem3.HSFE_Order_Type__c = 'Integration';
                    NewLineItem3.HSFE_UOM_Denominator__c=0;
                    NewLineItem3.HSFE_FIT_Quote_Flag__c = 'False';
                    NewLineItem3.Product_Conditions__c='Trade-In Olympus';
                    NewLineItem3.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem3.Apttus_Config2__AdjustmentAmount__c = 1;
                    NewLineItem3.HSFE_Contract_Price__c = 100;
                    NewLineItem3.HSFE_Target_Price__c = 100;
                    NewLineItem3.Apttus_Config2__Cost__c = 100;
                    NewLineItem3.HSFE_Contract_Code__c = 'VA2';
                    ListLine.add(NewLineItem3);

                    insert ListLine;

                    System.AssertNotEquals(NewLineItem1.id,null);
                    System.AssertNotEquals(NewLineItem2.id,null);              
                    System.AssertNotEquals(NewLineItem3.id,null);                    

                    update NewProductConf;
                }                
                Test.StopTest(); 
            } 
        }catch(exception e){
            System.debug('____Exception in_ LineItemTrigger_TestScenarios_With_ProductOptionGroupInLineItem Method HSFE_LineItem_TriggerHandler_TestClass Class____'+e.getMessage());
        }        
    }
}