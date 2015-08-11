/* 
*Class Name : HSFE_ActionCallBackCustom_TestClass
*Description :This test class test Action Callback.
*Created By  :Divya A N
*Created On  :06/11/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Divya                    11 June,2015                                                            Initial Version
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_CustomPricingCallBack_TestClass{
    
    static testMethod void HSFE_CustomPricingCallBack_WorkSpace_TestMethod_1(){
        HSFE_CustomPricingCallBack_WorkSpace Instance = new HSFE_CustomPricingCallBack_WorkSpace();
    }


    static testMethod void HSFE_CustomPricingCallBack_TestMethod_1(){
                
         //Insert the User record
        User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
        insert NewcreateUser;

        System.AssertNotEquals(NewcreateUser , null);
        // Run Test Logic as Test User
        
        
        Apttus_Config2__LineItem__c NewLineItem1 = new Apttus_Config2__LineItem__c();
        Apttus_Config2__LineItem__c NewLineItem2 = new Apttus_Config2__LineItem__c();

        list<Apttus_Config2__LineItem__c> ListLineItem = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__PriceMatrixEntry__c> InsertPriceMatrixEntry = new list<Apttus_Config2__PriceMatrixEntry__c>();
        list<HSFE_Line_Item_Extension__c> InsertLineExtension = new list<HSFE_Line_Item_Extension__c>();
        list<Apttus_Config2__PriceListItem__c> UpdatePriceListItem = new list<Apttus_Config2__PriceListItem__c>();
        // Run Test Logic as Test User
        system.runAs(NewcreateUser){
                            
            
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
            NewOpportunity.HSFE_Solution_Category__c = 'Standard';
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
            NewProposal.HSFE_FIT_Quote__c = True;
            NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
            NewProposal.HSFE_Deep_Clone__c = False;
            insert NewProposal;
            System.AssertNotEquals(NewProposal.id,null);
            
            // ----------------------------------------------------Insert the ProductConfiguration record ---------------------------------------
            Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
            NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
            insert NewProductConf;
            System.AssertNotEquals(NewProductConf.id,null);
            
            // -----------------------------------------------------Insert Category record-----------------------------------------------------
            Apttus_Config2__ClassificationName__c NewCategory = new Apttus_Config2__ClassificationName__c();
            NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
            insert NewCategory;
            System.AssertNotEquals(NewCategory.id,null);

            Apttus_Config2__ClassificationName__c NewCategory2 = new Apttus_Config2__ClassificationName__c();
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
                Prod.HSFE_Is_Kit_In_A_Kit__c = False;
                Prod.HSFE_Is_Batch__c = True;
                Prod.Is_Stocking_Kit__c = false;
                Prod.HSFE_Part_Number__c='1';
            }
            insert NewProductLst;

            System.AssertEquals(NewProductLst.size(),1);
            
            //Insert the Option Product record ie Normal product
            List<Product2> NewOptionProductLst = new List<Product2>();
            NewOptionProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
            for(Product2 OptionProd:NewOptionProductLst){
                OptionProd.HSFE_Is_Kit_In_A_Kit__c = false;
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
                UpdatePriceListItem.add(NewPriceListItem1);                    

                Apttus_Config2__PriceListItem__c NewPriceListItem2 = new Apttus_Config2__PriceListItem__c();
                NewPriceListItem2 = HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList,NewOptionProductLst[0],'New','One Time','Per Unit',100);
                NewPriceListItem2.HSFE_Floor_Price__c = 8000;
                NewPriceListItem2.HSFE_JSON_Up_to_Date__c = false;
                UpdatePriceListItem.add(NewPriceListItem2);
              
                insert UpdatePriceListItem;

                System.AssertNotEquals(NewPriceListItem1.id,null); 
                System.AssertNotEquals(NewPriceListItem2.id,null); 
                
                //-----------------------------------------------------Insert the PriceDimension record-----------------------------------------------------

                list<Apttus_Config2__PriceDimension__c> INsertListDimension = new list<Apttus_Config2__PriceDimension__c>();

                Apttus_Config2__PriceDimension__c NewPriceDimension = new Apttus_Config2__PriceDimension__c();
                NewPriceDimension = HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                INsertListDimension.add(NewPriceDimension);
                

                Apttus_Config2__PriceDimension__c NewPriceDimension2 = new Apttus_Config2__PriceDimension__c();
                NewPriceDimension2 = HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                INsertListDimension.add(NewPriceDimension2);
                
                insert INsertListDimension;

                System.AssertNotEquals(NewPriceDimension.id,null);
                System.AssertNotEquals(NewPriceDimension2.id,null);
                
                //-----------------------------------------------------Insert the PriceMatrix record----------------------------------------------------------

                list<Apttus_Config2__PriceMatrix__c> INsertListMatrix = new list<Apttus_Config2__PriceMatrix__c>();                    

                Apttus_Config2__PriceMatrix__c NewPriceMatrix1 = new Apttus_Config2__PriceMatrix__c();
                NewPriceMatrix1=HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension,NewPriceListItem1);
                INsertListMatrix.add(NewPriceMatrix1);
                
                Apttus_Config2__PriceMatrix__c NewPriceMatrix2 = new Apttus_Config2__PriceMatrix__c();
                NewPriceMatrix2 = HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension2,NewPriceListItem2);
                INsertListMatrix.add(NewPriceMatrix2);            
                
                insert INsertListMatrix;

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

                // -----------------------------------------------------Insert ProductClassification record-------------------------------------------------

                list<Apttus_Config2__ProductClassification__c> InsertListProductClass = new list<Apttus_Config2__ProductClassification__c>();

                Apttus_Config2__ProductClassification__c NewProductClassification1 = new Apttus_Config2__ProductClassification__c();
                NewProductClassification1=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy1,NewProductLst[0]);
                NewProductClassification1.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                InsertListProductClass.add(NewProductClassification1);

                Apttus_Config2__ProductClassification__c NewProductClassification2 = new Apttus_Config2__ProductClassification__c();
                NewProductClassification2=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy2,NewOptionProductLst[0]);
                NewProductClassification2.Apttus_Config2__ProductId__c=NewOptionProductLst[0].id;
                InsertListProductClass.add(NewProductClassification2);                  

                insert InsertListProductClass;

                System.AssertNotEquals(NewProductClassification1.id,null);                                       
                System.AssertNotEquals(NewProductClassification2.id,null);


                // -----------------------------------------------------Inset Product Option Group----------------------------------------------------------
                Apttus_Config2__ProductOptionGroup__c NewProductOptionGroup = new Apttus_Config2__ProductOptionGroup__c(); 
                NewProductOptionGroup = HSFE_TestUtility_Class.createSingleProductOptionGroup(NewCategoryHierarchy2.id, NewCategoryHierarchy1.id, true, NewProductLst[0].id);
                insert NewProductOptionGroup;
                System.AssertNotEquals(NewProductOptionGroup.id,null);                  
                
                // -----------------------------------------------------Inset Product Option Component------------------------------------------------------
                Apttus_Config2__ProductOptionComponent__c NewProductOptionComponent = new Apttus_Config2__ProductOptionComponent__c();
                NewProductOptionComponent=HSFE_TestUtility_Class.createSingleProductOptionComponent(NewOptionProductLst[0].id, NewProductLst[0].id, NewProductOptionGroup.id, 'Option', 1,0,1,1);
                insert NewProductOptionComponent;
                System.AssertNotEquals(NewProductOptionComponent.id,null);                 
                
                Test.StartTest();               
                    
                    //-----------------------------------------------------Insert the LineItem record-----------------------------------------------------
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
                    NewLineItem1.HSFE_Order_Type__c = 'Integration';
                    NewLineItem1.Product_Conditions__c='New';
                    NewLineItem1.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem1.Apttus_Config2__AdjustmentAmount__c = 1;
                    NewLineItem1.HSFE_Contract_Price__c = 100;
                    NewLineItem1.HSFE_Target_Price__c = 100;
                    NewLineItem1.Apttus_Config2__Cost__c = 100;
                    NewLineItem1.HSFE_Contract_Code__c = 'VA2';                    

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
                    NewLineItem2.Product_Conditions__c='Trade-In Olympus';
                    NewLineItem2.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem2.Apttus_Config2__AdjustmentAmount__c = 1;
                    NewLineItem2.HSFE_Contract_Price__c = 100;
                    NewLineItem2.HSFE_Target_Price__c = 100;
                    NewLineItem2.Apttus_Config2__Cost__c = 100;
                    NewLineItem2.HSFE_Contract_Code__c = 'VA2';                   

                    Apttus_Config2__ProductConfiguration__c cartObj = [SELECT id, HSFE_FIT_Quote__c, HSFE_Quote_Order_Type__c, Apttus_QPConfig__Proposald__c,
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_AVP_User__c, 
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_DVP_User__c,
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_GVP_User__c,
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_RSD_RVP_User__c,
                                                                Apttus_QPConfig__Proposald__r.HSFE_Deep_Clone__c, 
                                                                Apttus_QPConfig__Proposald__r.HSFE_FIT_Quote__c, 
                                                                Apttus_QPConfig__Proposald__r.HSFE_Proposal_Order_Type__c, Apttus_QPConfig__Proposald__r.id 
                                                            FROM Apttus_Config2__ProductConfiguration__c 
                                                            WHERE id =: NewProductConf.id];

                    HSFE_ProductConfigJson TempJSON = new HSFE_ProductConfigJson(cartObj);
                    TempJSON.QuoteOrderType = 'Integration';
                    TempJSON.FITQuote = false;
                    TempJSON.DeepClone = true;
                    TempJSON.QUOTEFITQuote = false;
                    string TempJSONString = JSON.serializePretty(TempJSON);

                    NewPriceListItem1 = [SELECT id,Apttus_Config2__ChargeType__c,Apttus_Config2__ProductId__c,HSFE_Matrix_Entry_JSON_String__c
                                                                FROM Apttus_Config2__PriceListItem__c 
                                                                where id =: NewPriceListItem1.id];

                    NewPriceListItem2 = [SELECT id,Apttus_Config2__ChargeType__c,Apttus_Config2__ProductId__c,HSFE_Matrix_Entry_JSON_String__c
                                                                FROM Apttus_Config2__PriceListItem__c 
                                                                where id =: NewPriceListItem2.id];                                                              

                    NewProductLst[0] = [SELECT id,HSFE_Charge_Type__c,Is_Stocking_Kit__c,HSFE_Is_Batch__c,HSFE_Is_Serial__c,HSFE_Product_Type__c,HSFE_Product_Conditions_Multi__c 
                                        FROM product2 
                                        WHERE id =: NewProductLst[0].id];

                    NewOptionProductLst = [SELECT id,HSFE_Charge_Type__c,Is_Stocking_Kit__c,HSFE_Is_Batch__c,HSFE_Is_Serial__c,HSFE_Product_Type__c,HSFE_Product_Conditions_Multi__c 
                                        FROM product2 
                                        WHERE id =: NewOptionProductLst[0].id];                                        

                    HSFE_ProductJson Rec1 = new HSFE_ProductJson(NewProductLst[0]);
                    string ProdString = JSON.serializePretty(Rec1);

                    HSFE_ProductJson Rec2 = new HSFE_ProductJson(NewOptionProductLst[0]);
                    string OptionProdString = JSON.serializePretty(Rec2);                                        

                    NewLineItem1.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem2.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem1.HSFE_Price_Matrix_Details_JSON_String__c = NewPriceListItem1.HSFE_Matrix_Entry_JSON_String__c;
                    NewLineItem2.HSFE_Price_Matrix_Details_JSON_String__c = NewPriceListItem2.HSFE_Matrix_Entry_JSON_String__c;
                    NewLineItem1.HSFE_Condition_Modified__c = true;
                    NewLineItem2.HSFE_Condition_Modified__c = true;
                    NewLineItem1.HSFE_Product_Details_JSON_String__c = ProdString;
                    NewLineItem1.HSFE_Parent_Product_Details_JSON_String__c = '';
                    NewLineItem2.HSFE_Option_Group_Label__c = HSFE_Constant.COUSTOM_MANDATORY;
                    NewLineItem2.HSFE_Product_Details_JSON_String__c = OptionProdString;
                    NewLineItem2.HSFE_Parent_Product_Details_JSON_String__c = ProdString;                    
                    NewLineItem1.HSFE_FIT_Quote_Flag__c = 'True';
                    NewLineItem2.HSFE_FIT_Quote_Flag__c = 'True';
                    ListLineItem.add(NewLineItem1);
                    ListLineItem.add(NewLineItem2);

                    NewLineItem1.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem1.Apttus_Config2__AdjustmentAmount__c = 10;
                    NewLineItem1.HSFE_Contract_Price__c = 300;                    
                    NewLineItem1.HSFE_UOM_Denominator__c=2;
                    NewLineItem1.HSFE_Option_Price__c = 10;
                    NewLineItem1.HSFE_RP_Price__c = 10;
                    NewLineItem1.Apttus_Config2__Quantity__c = 2;
                    NewLineItem1.Apttus_Config2__ParentBundleNumber__c = 1;              
                    
                    NewLineItem2.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem2.Apttus_Config2__AdjustmentAmount__c = 10;
                    NewLineItem2.HSFE_Contract_Price__c = 300;                    
                    NewLineItem2.HSFE_UOM_Denominator__c=2;
                    NewLineItem2.HSFE_Option_Price__c = 10;
                    NewLineItem2.HSFE_RP_Price__c = 10;
                    NewLineItem2.Apttus_Config2__Quantity__c  = 1;
                    NewLineItem2.Apttus_Config2__ParentBundleNumber__c = 2;      

                    insert ListLineItem;

                    TempJSON.QuoteOrderType = 'Standard';
                    TempJSON.FITQuote = False;
                    TempJSON.DeepClone = False;
                    TempJSON.QUOTEFITQuote = False;
                    TempJSONString = JSON.serializePretty(TempJSON);

                    NewLineItem1.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem2.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem1.Product_Conditions__c='Trade-In Olympus';
                    NewLineItem2.Product_Conditions__c='Trade-In Olympus';

                    HSFE_Utility_Class.LineItemBeforeUpdate = false;                    
                    update ListLineItem;

                    HSFE_CustomPricingCallBack_Util_Class.beforePricing_Method(ListLineItem);
                    HSFE_CustomPricingCallBack_Util_Class.finish_Method(ListLineItem);
                    
                    HSFE_CustomPricingCallBack_WorkSpace ClassRec = new HSFE_CustomPricingCallBack_WorkSpace();                     

                Test.StopTest();

            }                                 
        }                         
    }

    static testMethod void HSFE_CustomPricingCallBack_TestMethod_2(){
                
         //Insert the User record
        User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
        insert NewcreateUser;

        System.AssertNotEquals(NewcreateUser , null);
        // Run Test Logic as Test User
        
        
        Apttus_Config2__LineItem__c NewLineItem1 = new Apttus_Config2__LineItem__c();
        Apttus_Config2__LineItem__c NewLineItem2 = new Apttus_Config2__LineItem__c();

        list<Apttus_Config2__LineItem__c> ListLineItem = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__PriceMatrixEntry__c> InsertPriceMatrixEntry = new list<Apttus_Config2__PriceMatrixEntry__c>();
        list<HSFE_Line_Item_Extension__c> InsertLineExtension = new list<HSFE_Line_Item_Extension__c>();
        list<Apttus_Config2__PriceListItem__c> UpdatePriceListItem = new list<Apttus_Config2__PriceListItem__c>();
        // Run Test Logic as Test User
        system.runAs(NewcreateUser){
                            
            
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
            NewOpportunity.HSFE_Solution_Category__c = 'Standard';
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
            NewProposal.HSFE_FIT_Quote__c = True;
            NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
            NewProposal.HSFE_Deep_Clone__c = False;
            insert NewProposal;
            System.AssertNotEquals(NewProposal.id,null);
            
            // ----------------------------------------------------Insert the ProductConfiguration record ---------------------------------------
            Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
            NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
            insert NewProductConf;
            System.AssertNotEquals(NewProductConf.id,null);
            
            // -----------------------------------------------------Insert Category record-----------------------------------------------------
            Apttus_Config2__ClassificationName__c NewCategory = new Apttus_Config2__ClassificationName__c();
            NewCategory=HSFE_TestUtility_Class.createSingleCategory('HSFE_Category','Offering');
            insert NewCategory;
            System.AssertNotEquals(NewCategory.id,null);

            Apttus_Config2__ClassificationName__c NewCategory2 = new Apttus_Config2__ClassificationName__c();
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
                Prod.HSFE_Is_Kit_In_A_Kit__c = False;
                Prod.HSFE_Is_Batch__c = True;
                Prod.Is_Stocking_Kit__c = false;
                Prod.HSFE_Part_Number__c='1';
            }
            insert NewProductLst;

            System.AssertEquals(NewProductLst.size(),1);
            
            //Insert the Option Product record ie Normal product
            List<Product2> NewOptionProductLst = new List<Product2>();
            NewOptionProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
            for(Product2 OptionProd:NewOptionProductLst){
                OptionProd.HSFE_Is_Kit_In_A_Kit__c = false;
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
                UpdatePriceListItem.add(NewPriceListItem1);                    

                Apttus_Config2__PriceListItem__c NewPriceListItem2 = new Apttus_Config2__PriceListItem__c();
                NewPriceListItem2 = HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList,NewOptionProductLst[0],'New','One Time','Per Unit',100);
                NewPriceListItem2.HSFE_Floor_Price__c = 8000;
                NewPriceListItem2.HSFE_JSON_Up_to_Date__c = false;
                UpdatePriceListItem.add(NewPriceListItem2);
              
                insert UpdatePriceListItem;

                System.AssertNotEquals(NewPriceListItem1.id,null); 
                System.AssertNotEquals(NewPriceListItem2.id,null); 
                
                //-----------------------------------------------------Insert the PriceDimension record-----------------------------------------------------

                list<Apttus_Config2__PriceDimension__c> INsertListDimension = new list<Apttus_Config2__PriceDimension__c>();

                Apttus_Config2__PriceDimension__c NewPriceDimension = new Apttus_Config2__PriceDimension__c();
                NewPriceDimension = HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                INsertListDimension.add(NewPriceDimension);
                

                Apttus_Config2__PriceDimension__c NewPriceDimension2 = new Apttus_Config2__PriceDimension__c();
                NewPriceDimension2 = HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                INsertListDimension.add(NewPriceDimension2);
                
                insert INsertListDimension;

                System.AssertNotEquals(NewPriceDimension.id,null);
                System.AssertNotEquals(NewPriceDimension2.id,null);
                
                //-----------------------------------------------------Insert the PriceMatrix record----------------------------------------------------------

                list<Apttus_Config2__PriceMatrix__c> INsertListMatrix = new list<Apttus_Config2__PriceMatrix__c>();                    

                Apttus_Config2__PriceMatrix__c NewPriceMatrix1 = new Apttus_Config2__PriceMatrix__c();
                NewPriceMatrix1=HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension,NewPriceListItem1);
                INsertListMatrix.add(NewPriceMatrix1);
                
                Apttus_Config2__PriceMatrix__c NewPriceMatrix2 = new Apttus_Config2__PriceMatrix__c();
                NewPriceMatrix2 = HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension2,NewPriceListItem2);
                INsertListMatrix.add(NewPriceMatrix2);            
                
                insert INsertListMatrix;

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

                // -----------------------------------------------------Insert ProductClassification record-------------------------------------------------

                list<Apttus_Config2__ProductClassification__c> InsertListProductClass = new list<Apttus_Config2__ProductClassification__c>();

                Apttus_Config2__ProductClassification__c NewProductClassification1 = new Apttus_Config2__ProductClassification__c();
                NewProductClassification1=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy1,NewProductLst[0]);
                NewProductClassification1.Apttus_Config2__ProductId__c=NewProductLst[0].id;
                InsertListProductClass.add(NewProductClassification1);

                Apttus_Config2__ProductClassification__c NewProductClassification2 = new Apttus_Config2__ProductClassification__c();
                NewProductClassification2=HSFE_TestUtility_Class.createSingleProductClassification(NewCategoryHierarchy2,NewOptionProductLst[0]);
                NewProductClassification2.Apttus_Config2__ProductId__c=NewOptionProductLst[0].id;
                InsertListProductClass.add(NewProductClassification2);                  

                insert InsertListProductClass;

                System.AssertNotEquals(NewProductClassification1.id,null);                                       
                System.AssertNotEquals(NewProductClassification2.id,null);


                // -----------------------------------------------------Inset Product Option Group----------------------------------------------------------
                Apttus_Config2__ProductOptionGroup__c NewProductOptionGroup = new Apttus_Config2__ProductOptionGroup__c(); 
                NewProductOptionGroup = HSFE_TestUtility_Class.createSingleProductOptionGroup(NewCategoryHierarchy2.id, NewCategoryHierarchy1.id, true, NewProductLst[0].id);
                insert NewProductOptionGroup;
                System.AssertNotEquals(NewProductOptionGroup.id,null);                  
                
                // -----------------------------------------------------Inset Product Option Component------------------------------------------------------
                Apttus_Config2__ProductOptionComponent__c NewProductOptionComponent = new Apttus_Config2__ProductOptionComponent__c();
                NewProductOptionComponent=HSFE_TestUtility_Class.createSingleProductOptionComponent(NewOptionProductLst[0].id, NewProductLst[0].id, NewProductOptionGroup.id, 'Option', 1,0,1,1);
                insert NewProductOptionComponent;
                System.AssertNotEquals(NewProductOptionComponent.id,null);                 
                
                Test.StartTest();               
                    
                    //-----------------------------------------------------Insert the LineItem record-----------------------------------------------------
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
                    NewLineItem1.HSFE_Order_Type__c = 'Integration';
                    NewLineItem1.Product_Conditions__c='New';
                    NewLineItem1.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem1.Apttus_Config2__AdjustmentAmount__c = 1;
                    NewLineItem1.HSFE_Contract_Price__c = 100;
                    NewLineItem1.HSFE_Target_Price__c = 100;
                    NewLineItem1.Apttus_Config2__Cost__c = 100;
                    NewLineItem1.HSFE_Contract_Code__c = 'VA2';                    

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
                    NewLineItem2.Product_Conditions__c='Trade-In Olympus';
                    NewLineItem2.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem2.Apttus_Config2__AdjustmentAmount__c = 1;
                    NewLineItem2.HSFE_Contract_Price__c = 100;
                    NewLineItem2.HSFE_Target_Price__c = 100;
                    NewLineItem2.Apttus_Config2__Cost__c = 100;
                    NewLineItem2.HSFE_Contract_Code__c = 'VA2';                   

                    Apttus_Config2__ProductConfiguration__c cartObj = [SELECT id, HSFE_FIT_Quote__c, HSFE_Quote_Order_Type__c, Apttus_QPConfig__Proposald__c,
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_AVP_User__c, 
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_DVP_User__c,
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_GVP_User__c,
                                                                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_RSD_RVP_User__c,
                                                                Apttus_QPConfig__Proposald__r.HSFE_Deep_Clone__c, 
                                                                Apttus_QPConfig__Proposald__r.HSFE_FIT_Quote__c, 
                                                                Apttus_QPConfig__Proposald__r.HSFE_Proposal_Order_Type__c, Apttus_QPConfig__Proposald__r.id 
                                                            FROM Apttus_Config2__ProductConfiguration__c 
                                                            WHERE id =: NewProductConf.id];

                    HSFE_ProductConfigJson TempJSON = new HSFE_ProductConfigJson(cartObj);
                    TempJSON.QuoteOrderType = 'Integration';
                    TempJSON.FITQuote = false;
                    TempJSON.DeepClone = true;
                    TempJSON.QUOTEFITQuote = false;
                    string TempJSONString = JSON.serializePretty(TempJSON);

                    NewPriceListItem1 = [SELECT id,Apttus_Config2__ChargeType__c,Apttus_Config2__ProductId__c,HSFE_Matrix_Entry_JSON_String__c
                                                                FROM Apttus_Config2__PriceListItem__c 
                                                                where id =: NewPriceListItem1.id];

                    NewPriceListItem2 = [SELECT id,Apttus_Config2__ChargeType__c,Apttus_Config2__ProductId__c,HSFE_Matrix_Entry_JSON_String__c
                                                                FROM Apttus_Config2__PriceListItem__c 
                                                                where id =: NewPriceListItem2.id];                                                              

                    NewProductLst[0] = [SELECT id,HSFE_Charge_Type__c,Is_Stocking_Kit__c,HSFE_Is_Batch__c,HSFE_Is_Serial__c,HSFE_Product_Type__c,HSFE_Product_Conditions_Multi__c 
                                        FROM product2 
                                        WHERE id =: NewProductLst[0].id];

                    NewOptionProductLst = [SELECT id,HSFE_Charge_Type__c,Is_Stocking_Kit__c,HSFE_Is_Batch__c,HSFE_Is_Serial__c,HSFE_Product_Type__c,HSFE_Product_Conditions_Multi__c 
                                        FROM product2 
                                        WHERE id =: NewOptionProductLst[0].id];                                        

                    HSFE_ProductJson Rec1 = new HSFE_ProductJson(NewProductLst[0]);
                    Rec1.IsStocking = true;
                    Rec1.IsBatch = true;
                    string ProdString = JSON.serializePretty(Rec1);

                    HSFE_ProductJson Rec2 = new HSFE_ProductJson(NewOptionProductLst[0]);
                    string OptionProdString = JSON.serializePretty(Rec2);

                    NewLineItem2.HSFE_Option_Group_Label__c = HSFE_Constant.COUSTOM_RECOMMENDED ;  
                    NewLineItem2.HSFE_Serial_Number__c = '1763';                                                    

                    NewLineItem1.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem2.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem1.HSFE_Price_Matrix_Details_JSON_String__c = NewPriceListItem1.HSFE_Matrix_Entry_JSON_String__c;
                    NewLineItem2.HSFE_Price_Matrix_Details_JSON_String__c = NewPriceListItem2.HSFE_Matrix_Entry_JSON_String__c;
                    NewLineItem1.HSFE_Condition_Modified__c = true;
                    NewLineItem2.HSFE_Condition_Modified__c = true;
                    NewLineItem1.HSFE_Product_Details_JSON_String__c = ProdString;
                    NewLineItem1.HSFE_Parent_Product_Details_JSON_String__c = '';
                    NewLineItem2.HSFE_Option_Group_Label__c = HSFE_Constant.COUSTOM_MANDATORY;
                    NewLineItem2.HSFE_Product_Details_JSON_String__c = OptionProdString;
                    NewLineItem2.HSFE_Parent_Product_Details_JSON_String__c = ProdString;                    
                    NewLineItem1.HSFE_FIT_Quote_Flag__c = 'True';
                    NewLineItem2.HSFE_FIT_Quote_Flag__c = 'True';

                    NewLineItem1.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem1.Apttus_Config2__AdjustmentAmount__c = 10;
                    NewLineItem1.HSFE_Contract_Price__c = 300;                    
                    NewLineItem1.HSFE_UOM_Denominator__c=2;
                    NewLineItem1.HSFE_Option_Price__c = 10;
                    NewLineItem1.HSFE_RP_Price__c = 10;
                    NewLineItem1.Apttus_Config2__Quantity__c = 2;
                    NewLineItem1.Apttus_Config2__ParentBundleNumber__c = 1;              
                    
                    NewLineItem2.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                    NewLineItem2.Apttus_Config2__AdjustmentAmount__c = 10;
                    NewLineItem2.HSFE_Contract_Price__c = 300;                    
                    NewLineItem2.HSFE_UOM_Denominator__c=2;
                    NewLineItem2.HSFE_Option_Price__c = 10;
                    NewLineItem2.HSFE_RP_Price__c = 10;
                    NewLineItem2.Apttus_Config2__Quantity__c  = 1;
                    NewLineItem2.Apttus_Config2__ParentBundleNumber__c = 2;  

                    ListLineItem.add(NewLineItem1);
                    ListLineItem.add(NewLineItem2);
                    insert ListLineItem;

                    TempJSON.QuoteOrderType = 'Standard';
                    TempJSON.FITQuote = False;
                    TempJSON.DeepClone = False;
                    TempJSON.QUOTEFITQuote = False;
                    TempJSONString = JSON.serializePretty(TempJSON);

                    NewLineItem1.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem2.HSFE_Quote_Details_JSON_String__c = TempJSONString;
                    NewLineItem1.Product_Conditions__c='Trade-In Olympus';
                    NewLineItem2.Product_Conditions__c='Trade-In Olympus';

                    HSFE_Utility_Class.LineItemBeforeUpdate = false;                    
                    update ListLineItem;

                    HSFE_CustomPricingCallBack_Util_Class.beforePricing_Method(ListLineItem);
                    HSFE_CustomPricingCallBack_Util_Class.finish_Method(ListLineItem);
                    
                    HSFE_CustomPricingCallBack_WorkSpace ClassRec = new HSFE_CustomPricingCallBack_WorkSpace();                     

                Test.StopTest();

            }                                 
        }                         
    }      
}