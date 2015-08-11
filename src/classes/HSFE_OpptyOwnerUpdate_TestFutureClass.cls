/* 
*Class Name :HSFE_OpptyOwnerUpdate_TestFutureClass 
*Description :This test class test the functionlity and covers the code for HSFE_OpptyOwnerUpdate_TestFutureClass class.
*Created By  :Sunil Kumar
*Created On  :05/7/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Sunil Kumar                 05/7/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_OpptyOwnerUpdate_TestFutureClass {
    static testmethod void testMethod1(){
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        User accOwner = HSFE_TestUtility_Class.create2User(r);
        insert Usr;
        insert  accOwner;    
         System.runAs(usr){
            //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr; 
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert the opportunity record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            insert opp;
            Set<Id> opportunityId = new Set<Id>();
            opportunityId.add(opp.id);
            Test.startTest();
                HSFE_OpptyOwnerUpdate_FutureClass.updateOpportunityOwner(opportunityId);
            Test.stopTest();
            List<OpportunityTeamMember> opptyTeamMemberList = new List<OpportunityTeamMember>();
            opptyTeamMemberList = [select id,OpportunityId  from OpportunityTeamMember where OpportunityId=:opp.id];
            //Validate opportunity team members are inserted.
            system.assert(opptyTeamMemberList.size()>0, 'Opportunity TeamMember did not inserted properly');
         }
    }
}