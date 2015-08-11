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
private class HSFE_ActionCallBackCustom_TestClass{
    
    static testMethod void testActionCustomCallBack(){
        //Insert the User Role record
            UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
            insert oUserRole;
            
            //Insert the User record
            User ocreateUser = HSFE_TestUtility_Class.createUser(oUserRole);
            insert ocreateUser;
            
            // Run Test Logic as Test User
            system.runAs(ocreateUser){
                Test.StartTest();
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
                insert NewProposal;
                
                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
                NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
                insert NewProductConf;
                system.debug('*************' +NewProductConf); 
                
                Apttus_Config2__ConfigCustomClasses__c oCustomSetting = new Apttus_Config2__ConfigCustomClasses__c();
                oCustomSetting .Name= 'Test';
                oCustomSetting.Apttus_Config2__DisplayActionCallbackCalss__c = 'HSFE_ActionCallBackCustom';
                insert oCustomSetting;
                Apttus_Config2__ConfigCustomDisplayActions__c  actionSO = new Apttus_Config2__ConfigCustomDisplayActions__c();
                actionSo.Apttus_Config2__DisplayType__c = 'Cart Line Item';
                actionSo.Apttus_Config2__ActionName__c = 'Finalize';
                Apttus_Config2.DisplayActionInfo disp  = new Apttus_Config2.DisplayActionInfo(actionSo);
                List<Apttus_Config2.DisplayActionInfo> displayActions = new List<Apttus_Config2.DisplayActionInfo>();
                displayActions.add(disp);
                Apttus_Config2.ProductConfiguration cart;
                Apttus_Config2.CustomClass.ActionParams params = new Apttus_Config2.CustomClass.ActionParams ();
                //Apttus_Config2.ActionParams cClass= new Apttus_Config2.ActionParams();
                HSFE_ActionCallBackCustom contlr= new HSFE_ActionCallBackCustom();
                contlr.start(cart,displayActions);
                contlr.setActionProperties(params);
                //Apttus_Config2.CustomClass.ActionParams params;
                //contlr.setActionProperties(params);
          }
    }
}