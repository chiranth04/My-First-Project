/* 
*Class Name  :HSFE_ConvertQuoteToOrd_Contr_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_ConvertQuoteToOrder_Controller class.
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
private class HSFE_ConvertQuoteToOrd_Contr_TestClass {

    static testmethod void convertQuoteToOrderTest(){
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
            System.debug('************************* acc :' + acc.Id);

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

            //create Product Configuration
            Apttus_Config2__ProductConfiguration__c prodConfiguration = new Apttus_Config2__ProductConfiguration__c();
            prodConfiguration = HSFE_TestUtility_Class.createSingleProductConfiguration(newProposal);
            insert prodConfiguration;

            HSFE_IntegrationEndPointURL__c custSettObj = new HSFE_IntegrationEndPointURL__c();
            custSettObj.Name = HSFE_Constant.QUOTE_TO_ORDER;
            custSettObj.HSFE_EndPointURL__c = 'https://integration.com/stubbingResponse';
            Insert custSettObj;

            // Setting Mock Response for Http Callout
            Test.setMock(HttpCalloutMock.class, new HSFE_MockHttpResponseGenerator_Test());

            HSFE_ConvertQuoteToOrder_Controller quoteControllerObj = new HSFE_ConvertQuoteToOrder_Controller();
            String str = HSFE_ConvertQuoteToOrder_Controller.convertQuoteToOrder(newProposal.Id);

            System.assertEquals(HSFE_Constant.SUCCESS, str);
        }
        Test.stopTest();
    }
}