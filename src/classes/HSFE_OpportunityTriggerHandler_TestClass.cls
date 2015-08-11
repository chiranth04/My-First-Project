/* 
*Class Name :HSFE_OpportunityTriggerHandler_TestClass 
*Description :This test class test the functionlity and covers the code for HSFEOpportunityTriggerHandler trigger.
*Created By  :Chiranth Aradhya
*Created On  :02/24/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest                    
private class HSFE_OpportunityTriggerHandler_TestClass {
   
    static  testmethod void testmethod1() {
      
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        UserRole r1 = HSFE_TestUtility_Class.createRoleRVP();
        insert r1;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
        //Insert User record
        User Usr2 =  HSFE_TestUtility_Class.create2User(r1);
        insert Usr2;
        
        System.runAs(usr){  
        
             //Insert Territory
            HSEF_Territory__c terr = HSFE_TestUtility_Class.createTerritory();
            insert terr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipTerr =  HSFE_TestUtility_Class.createHSFEZipterr(terr);
            insert zipTerr;
            
            //Insert territory to User
            HSFE_Territory_To_User__c terrToUser = HSFE_TestUtility_Class.createTerritoryUser(usr,terr);                  
            insert terrToUser;
           
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert the account record       
            Account acc1 = HSFE_TestUtility_Class.createAccountRecord2();
            insert acc1;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');        
    
            //Insert AccountTerritory
            HSFE_Account_Territory__c accter = HSFE_TestUtility_Class.createAccountTerritory(acc,terr);
            insert accter;
            
            //Insert  contact record      
            Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
            con.HSFE_Primary__c = True;
            insert con;
            
            //check whether the contact is inserted properly
            System.Assert(con.Id != null, 'The Test Contact did not insert properly, please check validation rules and other mechanisms');
            
            Id pricebookId = Test.getStandardPricebookId();            
            //Insert Opporuntiy record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            opp.HSFE_Secondary_Owner__c = Usr2.id;
            insert opp;
            
            //check whether the opportunity is inserted properly
            System.Assert(opp.Id != null, 'The Test opportunity did not insert properly, please check validation rules and other mechanisms');
            
            opp.HSFE_Opportunity_Type__c='Customer';
            opp.HSFE_Specialty__c='Medical';            
            //opp.AccountId=acc1.Id;
            update opp;
            
            //check whether the opportunity is updated properly
            System.Assert(opp.HSFE_Specialty__c == 'Medical', 'The Test opportunity did not updated , please check validation rules and other mechanisms');
            
            
            //Insert Opporuntiy record
            Opportunity opp1 = HSFE_TestUtility_Class.createOpportunityRecord2(acc);
            opp1.HSFE_Secondary_Owner__c = Usr2.id;
            insert opp1;
           
            //Insert the Opportunity record
            Opportunity NewOpportunity=new Opportunity();
            NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            NewOpportunity.HSFE_Specialty__c='Medical';
            NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
            NewOpportunity.TotalOpportunityQuantity=1;
            //NewOpportunity.HSFE_Opportunity_Won_Date__c =system.Today();
            insert NewOpportunity;
            
            //Insert event with Opportunity and Contact Id
            Event evd5 = new Event(WhatId = NewOpportunity.Id, WhoId=con.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.InService, DurationInMinutes = 30, ActivityDateTime = System.today());
            insert evd5;
            
            Test.Starttest();
            
            //Insert the Proposal record
            Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
            NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,acc, usr,'TestProposal' );
            NewProposal.Apttus_Proposal__Primary__c=true;
            NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';            
            NewProposal.HSFE_Is_FIS__c=true;
            NewProposal.HSFE_Carrier_Name__c='FedEx';
            NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
            NewProposal.HSFE_Primary_Con__c=con.id;
            insert NewProposal;           
            
           
            NewProposal.HSFE_Order_Integration_Status__c =HSFE_Constant.CONFIRMED;
            update NewProposal;
            
            //check whether the opportunity is updated properly
            System.Assert(NewProposal.HSFE_Order_Integration_Status__c == HSFE_Constant.CONFIRMED, 'Proposal is not updated , please check validation rules and other mechanisms');
            Test.Stoptest();        
            
        }
        
     }
}