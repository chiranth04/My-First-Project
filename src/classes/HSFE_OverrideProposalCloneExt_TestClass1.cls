/* 
*Class Name : HSFE_OverrideProposalCloneExt_TestClass1 
*Description :This test class test the functionlity and covers the code for HSFE_OverrideProposalCloneExt class.
*Created By  :Ajay Agnihotri
*Created On  :05/18/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest(SeeAllData= false)
private class HSFE_OverrideProposalCloneExt_TestClass1 {
   
    // Below Method is used to Cover Deep Clone Test Senario's With Related Objects
    static testMethod void OverrideProposalCloneExt_DeepClone_WithRelatedObjects_Test(){
            //Insert the User Role record
            
            User NewcreateUserWoRole = HSFE_TestUtility_Class.createUser2();
            insert NewcreateUserWoRole ; 
            system.runAs(NewcreateUserWoRole){
            UserRole NewUserRole=  HSFE_TestUtility_Class.createRole();
            insert NewUserRole;
            //Insert the User record
            User NewcreateUser = HSFE_TestUtility_Class.createUser(NewUserRole);
            insert NewcreateUser;
            }
            List <User> NewcreateUserLst = new List<User>();
            
            NewcreateUserLst =[Select id, UserRoleId  from User where UserRoleId!=null];
            System.AssertNotEquals(NewcreateUserLst , null);
            // Run Test Logic as Test User
            system.runAs(NewcreateUserLst[0]){
                
                //Insert the Account record
                Account NewAccount = new Account();
                NewAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert NewAccount;
                
                Contact con = HSFE_TestUtility_Class.createContactRecord(NewAccount);
                con.HSFE_Primary__c = True;
                con.HSFE_Active__c =true;  
                con.HSFE_Specialty__c='Surgical';
                con.HSFE_Sub_Specialty__c='Energy';  
                insert con;
                
                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUserLst[0].id,'Test');
                insert ATM;
                
                //Insert the Opportunity record
                Opportunity NewOpportunity = new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount); 
                NewOpportunity.HSFE_Contact__c=con.id;              
                insert NewOpportunity ;
                
                //Insert the PriceList record
                Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                insert NewPriceList;
                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUserLst[0],'HSFE-v1Test-v2Test-v4Test-V5' );
                insert NewProposal;
                NewProposal.Apttus_Proposal__Proposal_Name__c='HSFE-v1-v2-v4';
                update NewProposal;
                List <Apttus_Proposal__Proposal__c> NewProposalLst = new List <Apttus_Proposal__Proposal__c>();
                NewProposalLst =[Select id from Apttus_Proposal__Proposal__c];
                Test.StartTest();
                // Associate the DeepClone VF
                PageReference pgRef = Page.HSFE_OverrideProposalClone;
                pgRef.getParameters().put('id', NewProposalLst[0].id);
                pgRef.getParameters().put('retURL', NewProposalLst[0].id);
                Test.setCurrentPageReference(pgRef);
                
                // Make call to Deep Clone Extension
                ApexPAges.StandardController sc = new ApexPages.StandardController(NewProposalLst[0]);
                HSFE_OverrideProposalCloneExt ClsDeepCloneInstance1=new HSFE_OverrideProposalCloneExt(sc);
                ClsDeepCloneInstance1.init();
         
                Test.StopTest();
                }
                
            
        }
     
}