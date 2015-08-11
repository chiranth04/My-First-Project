/* 
*Class Name : HSFE_LineItemExtension_TestClass
*Description :This test class test the Line Item Extension Trigger and its Implementation Class i.e. HSFE_LineItemExtension_TrigHandler_Class .
*Created By  :Divya A N
*Created On  :06/12/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Divya                    12 June,2015                                                            Initial Version
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_LineItemExtension_TestClass{
    
    static testMethod void testLineItemInsert(){
    Test.StartTest();
        //Insert the User Role record
        UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
        insert oUserRole;
        
        //Insert the User record
        User ocreateUser = HSFE_TestUtility_Class.createUser(oUserRole);
        insert ocreateUser;
        
        // Run Test Logic as Test User
        system.runAs(ocreateUser){
            //Insert the Account record
            Account oAccount = new Account();
            oAccount = HSFE_TestUtility_Class.createAccountRecord();
            insert oAccount;
            
            //Insert the AccountTeamMember record
            AccountTeamMember ATM=new AccountTeamMember();
            ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(oAccount.id,ocreateUser.id,'Test');
            insert ATM;
            
            //Insert the Opportunity record
            Opportunity oOpportunity = new Opportunity();
            oOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(oAccount);                
            insert oOpportunity ;

            //Insert the Proposal record
            Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
            NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(oOpportunity ,oAccount, ocreateUser,'TestProposal' );
            NewProposal.HSFE_Carrier_Name__c='FedEx';
            NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
            NewProposal.HSFE_Contract_Integration_Status__c='Sent to SAP';
            NewProposal.HSFE_Freight_Integration_Status__c='Sent to SAP';
            insert NewProposal;
            
            //Insert the ProductConfiguration record
            Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
            NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
            insert NewProductConf;
            system.debug('*************' +NewProductConf);
            
            //Insert the LineItem record
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            NewLineItem=HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(NewProposal);
            NewLineItem.Apttus_Config2__BasePrice__c = 1000;
            insert NewLineItem;

            Apttus_Proposal__Proposal__c NewProposalObj = new Apttus_Proposal__Proposal__c();
            NewProposalObj = [Select id, HSFE_Contract_Integration_Status__c, HSFE_Freight_Integration_Status__c from Apttus_Proposal__Proposal__c
                                where id = :NewLineItem.HSFE_Quote_Id__c];

            System.assertEquals(NewProposalObj.HSFE_Contract_Integration_Status__c, HSFE_Constant.SENT_TO_SAP);
          }
    Test.stopTest();
    }
           
    static testMethod void testLineItemInsertErrorCase(){
    Test.StartTest();
        //Insert the User Role record
        UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
        insert oUserRole;

        Profile p = [SELECT Id FROM Profile WHERE Name='Integration User Profile'];
        
        //Insert the User record
        User ocreateUser = HSFE_TestUtility_Class.createIntegrationUserProfileUser(oUserRole);
        insert ocreateUser;
        
        // Run Test Logic as Test User
        system.runAs(ocreateUser){
            //Insert the Account record
            Account oAccount = new Account();
            oAccount = HSFE_TestUtility_Class.createAccountRecord();
            insert oAccount;
            
            //Insert the AccountTeamMember record
            AccountTeamMember ATM=new AccountTeamMember();
            ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(oAccount.id,ocreateUser.id,'Test');
            insert ATM;
            
            //Insert the Opportunity record
            Opportunity oOpportunity = new Opportunity();
            oOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(oAccount);                
            insert oOpportunity ;

            //Insert the Proposal record
            Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
            NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(oOpportunity ,oAccount, ocreateUser,'TestProposal' );
            NewProposal.HSFE_Carrier_Name__c='FedEx';
            NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
            NewProposal.HSFE_Contract_Integration_Status__c='Sent to SAP';
            NewProposal.HSFE_Freight_Integration_Status__c='Sent to SAP';
            insert NewProposal;
            
            //Insert the ProductConfiguration record
            Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
            NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
            insert NewProductConf;
            system.debug('*************' +NewProductConf);
            
            //Insert the LineItem record
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            NewLineItem=HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(NewProposal);
            insert NewLineItem;
            
            NewLineItem.Apttus_Config2__BasePrice__c = 1000;
            Update NewLineItem;

            //Insert Custom Setting
            HSFE_ProfileWithNoExecution__c custSettObj = new HSFE_ProfileWithNoExecution__c();
            custSettObj.Name = p.Id;
            Insert custSettObj;

            //Updating Line Item Extension
            HSFE_Line_Item_Extension__c  updateLineItemExtension = [SELECT id,HSFE_Contract_Integration_Status__c,HSFE_Freight_Integration_Status__c FROM HSFE_Line_Item_Extension__c WHERE HSFE_Line_Item__c =:NewLineItem.Id];
            updateLineItemExtension.HSFE_Contract_Integration_Status__c = HSFE_Constant.ERROR;
            updateLineItemExtension.HSFE_Freight_Integration_Status__c = HSFE_Constant.ERROR;
            updateLineItemExtension.HSFE_Contract_Code__c = 'VA1';
            update updateLineItemExtension;
            
            Apttus_Proposal__Proposal__c NewProposalObj = [Select id, HSFE_Contract_Integration_Status__c, HSFE_Freight_Integration_Status__c from Apttus_Proposal__Proposal__c
                                                            where id = :NewProposal.Id];

            System.debug('****************** NewProposalObj : ' + NewProposalObj.Id);
            System.debug('****************** NewProposalObj : ' + NewProposalObj.HSFE_Contract_Integration_Status__c);
            System.debug('****************** NewProposalObj : ' + NewProposalObj.HSFE_Freight_Integration_Status__c);

            System.assertNotEquals(NewProposalObj.Id, null);                        
            System.assertEquals(NewProposalObj.HSFE_Contract_Integration_Status__c, HSFE_Constant.ERROR);
        }
        Test.stopTest();
       }
       
    static testMethod void testLineItemExtUpdForIntProf(){
    Test.StartTest();
        //Insert the User Role record
        UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
        insert oUserRole;

        Profile p = [SELECT Id FROM Profile WHERE Name='Integration User Profile'];
        
        //Insert the User record
        User ocreateUser = HSFE_TestUtility_Class.createIntegrationUserProfileUser(oUserRole);
        insert ocreateUser;
        
        // Run Test Logic as Test User
        system.runAs(ocreateUser){
            //Insert the Account record
            Account oAccount = new Account();
            oAccount = HSFE_TestUtility_Class.createAccountRecord();
            insert oAccount;
            
            //Insert the AccountTeamMember record
            AccountTeamMember ATM=new AccountTeamMember();
            ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(oAccount.id,ocreateUser.id,'Test');
            insert ATM;
            
            //Insert the Opportunity record
            Opportunity oOpportunity = new Opportunity();
            oOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(oAccount);                
            insert oOpportunity ;

            //Insert the Proposal record
            Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
            NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(oOpportunity ,oAccount, ocreateUser,'TestProposal' );
            NewProposal.HSFE_Carrier_Name__c='FedEx';
            NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
            NewProposal.HSFE_Contract_Integration_Status__c='Sent to SAP';
            NewProposal.HSFE_Freight_Integration_Status__c='Sent to SAP';
            insert NewProposal;
            
            //Insert the ProductConfiguration record
            Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
            NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
            insert NewProductConf;
            system.debug('*************' +NewProductConf);
            
            //Insert the LineItem record
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            NewLineItem=HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(NewProposal);
            insert NewLineItem;
            
            NewLineItem.Apttus_Config2__BasePrice__c = 1000;
            Update NewLineItem;

            //Insert Custom Setting
            HSFE_ProfileWithNoExecution__c custSettObj = new HSFE_ProfileWithNoExecution__c();
            custSettObj.Name = p.Id;
            Insert custSettObj;

            //Updating Line Item Extension
            HSFE_Line_Item_Extension__c  updateLineItemExtension = [SELECT id,HSFE_Contract_Integration_Status__c,HSFE_Freight_Integration_Status__c FROM HSFE_Line_Item_Extension__c WHERE HSFE_Line_Item__c =:NewLineItem.Id];
            updateLineItemExtension.HSFE_Contract_Integration_Status__c = HSFE_Constant.NOT_IN_SAP;
            updateLineItemExtension.HSFE_Freight_Integration_Status__c = HSFE_Constant.NOT_IN_SAP;
            updateLineItemExtension.HSFE_Contract_Code__c = 'VA1';
            update updateLineItemExtension;
            
            Apttus_Proposal__Proposal__c NewProposalObj = [Select id, HSFE_Contract_Integration_Status__c, HSFE_Freight_Integration_Status__c from Apttus_Proposal__Proposal__c
                                                            where id = :NewProposal.Id];

            System.debug('****************** NewProposalObj : ' + NewProposalObj.Id);
            System.debug('****************** NewProposalObj : ' + NewProposalObj.HSFE_Contract_Integration_Status__c);
            System.debug('****************** NewProposalObj : ' + NewProposalObj.HSFE_Freight_Integration_Status__c);

            System.assertNotEquals(NewProposalObj.Id, null);                        
            System.assertEquals(NewProposalObj.HSFE_Contract_Integration_Status__c, HSFE_Constant.SYNCED);
        }
        Test.stopTest();
       }

    static testMethod void testLineItemExtUpdForIntProf2(){
    Test.StartTest();
        //Insert the User Role record
        UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
        insert oUserRole;

        Profile p = [SELECT Id FROM Profile WHERE Name='Integration User Profile'];
        
        //Insert the User record
        User ocreateUser = HSFE_TestUtility_Class.createIntegrationUserProfileUser(oUserRole);
        insert ocreateUser;
        
        // Run Test Logic as Test User
        system.runAs(ocreateUser){
            //Insert the Account record
            Account oAccount = new Account();
            oAccount = HSFE_TestUtility_Class.createAccountRecord();
            insert oAccount;
            
            //Insert the AccountTeamMember record
            AccountTeamMember ATM=new AccountTeamMember();
            ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(oAccount.id,ocreateUser.id,'Test');
            insert ATM;
            
            //Insert the Opportunity record
            Opportunity oOpportunity = new Opportunity();
            oOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(oAccount);                
            insert oOpportunity ;

            //Insert the Proposal record
            Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
            NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(oOpportunity ,oAccount, ocreateUser,'TestProposal' );
            NewProposal.HSFE_Carrier_Name__c='FedEx';
            NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
            NewProposal.HSFE_Contract_Integration_Status__c='Sent to SAP';
            NewProposal.HSFE_Freight_Integration_Status__c='Sent to SAP';
            insert NewProposal;
            
            Apttus_Proposal__Proposal__c updatedProposal=[SELECT Id,HSFE_Contract_Integration_Status__c,HSFE_Freight_Integration_Status__c from Apttus_Proposal__Proposal__c where id=:NewProposal.Id];
            updatedProposal.HSFE_Contract_Integration_Status__c='Synched';
            updatedProposal.HSFE_Freight_Integration_Status__c ='Synched';
            update updatedProposal;
            
            //Insert the ProductConfiguration record
            Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
            NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(updatedProposal);
            insert NewProductConf;
            system.debug('*************' +NewProductConf);
            
            //Insert the LineItem record
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
            NewLineItem=HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(updatedProposal);
            insert NewLineItem;
            
            NewLineItem.Apttus_Config2__BasePrice__c = 1000;
            Update NewLineItem;

            //Insert Custom Setting
            HSFE_ProfileWithNoExecution__c custSettObj = new HSFE_ProfileWithNoExecution__c();
            custSettObj.Name = p.Id;
            Insert custSettObj;

            //Updating Line Item Extension
            HSFE_Line_Item_Extension__c  updateLineItemExtension = [SELECT id, HSFE_Product_Configuration__c, HSFE_Contract_Integration_Status__c,HSFE_Freight_Integration_Status__c FROM HSFE_Line_Item_Extension__c WHERE HSFE_Line_Item__c =:NewLineItem.Id];
            updateLineItemExtension.HSFE_Contract_Integration_Status__c = HSFE_Constant.SYNCED;
            updateLineItemExtension.HSFE_Freight_Integration_Status__c = HSFE_Constant.SYNCED;
            updateLineItemExtension.HSFE_Contract_Code__c = 'VA1';
            update updateLineItemExtension;

            //Update QUote Method Check
            Set<Id> ProductConfigIdSet = new Set<Id>();
            ProductConfigIdSet.add(updateLineItemExtension.HSFE_Product_Configuration__c);
            HSFE_LineItemExtension_TrigHandler_Class.updateQuote(ProductConfigIdSet);
            system.debug('************************TestDivya'+ProductConfigIdSet);
            
            Apttus_Proposal__Proposal__c NewProposalObj = [Select id, HSFE_Is_VA1_VA2__c, HSFE_Contract_Integration_Status__c, HSFE_Freight_Integration_Status__c from Apttus_Proposal__Proposal__c
                                                            where id = :NewProposal.Id];

            System.debug('****************** NewProposalObj : ' + NewProposalObj.Id);
            System.debug('****************** NewProposalObj : ' + NewProposalObj.HSFE_Contract_Integration_Status__c);
            System.debug('****************** NewProposalObj : ' + NewProposalObj.HSFE_Freight_Integration_Status__c);

            System.assertNotEquals(NewProposalObj.Id, null);                        
            System.assertEquals(NewProposalObj.HSFE_Contract_Integration_Status__c, HSFE_Constant.SYNCED);
        }
        Test.stopTest();
       }
  }