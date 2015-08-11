/* 
*Class Name  :HSFE_GetFreightCharge_Contr_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_GetFreightCharges_Controller class.
*Created By  :Prateek Saxena
*Created On  :06/11/2015
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena            06/11/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*/
@isTest
private class HSFE_GetFreightCharge_Contr_TestClass {
    static testmethod void getFreightChargesTest(){
        Test.startTest();
        
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
        System.runAs(NewcreateUser){
            //create Account
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            Insert acc;
            System.debug('************************* acc :' + acc.HSFE_SAP_ID__c);

            //Insert the AccountTeamMember record
            AccountTeamMember ATM=new AccountTeamMember();
            ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(acc.id,NewcreateUser.id,'Test');
            insert ATM;

            //create Opportunity
            Opportunity oppt = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            Insert oppt;
            System.debug('************************* Opportunity : ' + oppt.Id);
            
            // Create Proposal Record
            Apttus_Proposal__Proposal__c newProposal = new Apttus_Proposal__Proposal__c();
            newProposal = HSFE_TestUtility_Class.CreateSingleProposal(oppt, acc, NewcreateUser, 'Q1234567');
            Insert newProposal;

            //create Product
            List<Product2> prodRecList = HSFE_TestUtility_Class.createProductRecords(1,'test');
            Product2 prodRec = prodRecList[0];

            System.debug('************************ Product Rec : ' + prodRec);

            //create Line Item
            Apttus_Config2__LineItem__c lineItem = HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(newProposal);
            lineItem.Apttus_Config2__BasePrice__c = 5608.00;
            lineItem.Apttus_Config2__OptionId__c = prodRec.Id;      
            Insert lineItem;

            System.debug('***************** Apttus_Config2__ConfigurationId__c' + lineItem.Apttus_Config2__ConfigurationId__c);
            System.debug('***************** Base price : ' + lineItem.Apttus_Config2__BasePrice__c);
            System.debug('***************** Product : ' + lineItem.Apttus_Config2__ProductId__c);
            System.debug('***************** Product number: ' + lineItem.HSFE_Product_Part_Number__c);


            PageReference pageRef = Page.Apttus_Config2__CartDetailView;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('id', lineItem.Apttus_Config2__ConfigurationId__c);
            System.currentPageReference().getParameters().put('retId', newProposal.Id);
            System.currentPageReference().getParameters().put('configRequestId', lineItem.Apttus_Config2__ConfigurationId__c);

            HSFE_IntegrationEndPointURL__c custSettObj = new HSFE_IntegrationEndPointURL__c();
            custSettObj.Name = HSFE_Constant.FREIGHT_CHARGES;
            custSettObj.HSFE_EndPointURL__c = 'https://integration.com/stubbingResponse';
            Insert custSettObj;

            // Setting Mock Response for Http Callout
            Test.setMock(HttpCalloutMock.class, new HSFE_MockHttpResponseGenerator_Test());

            HSFE_GetFreightCharges_Controller contrObj = new HSFE_GetFreightCharges_Controller();

            contrObj.productConfigId = lineItem.Apttus_Config2__ConfigurationId__c;
            contrObj.quoteId = newProposal.Id;
            contrObj.configRequestId = lineItem.Apttus_Config2__ConfigurationId__c;
            contrObj.GetFreightCharges();

            PageReference cartDetailPage = System.Page.Apttus_Config2__CartDetailView;
            cartDetailPage.getParameters().put('Id', lineItem.Apttus_Config2__ConfigurationId__c);
            cartDetailPage.getParameters().put('configRequestId', lineItem.Apttus_Config2__ConfigurationId__c);

            Pagereference pgRef = contrObj.redirectToCart();
            System.assert(pgRef.getUrl() == cartDetailPage.getUrl());
        }
        Test.stopTest();
    }

}