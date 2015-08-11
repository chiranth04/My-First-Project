/* 
*Class Name :HSFE_NewOpportunityOverride_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_NewOpportunityOverriddenExt class.
*Created By  :Chiranth Aradhya
*Created On  :04/27/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest                    
private class HSFE_NewOpportunityOverride_TestClass {
   
    static  testmethod void testmethod1() {
        
        ///Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
        System.runAs (Usr) {
        
        
            //Insert  account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert Account Team
            AccountTeamMember accteam= HSFE_TestUtility_Class.createAccountTeamMember(acc, Usr);
            insert accteam;
       
            //Insert Opporuntiy record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            HSFE_NewOpportunityOverriddenExt  oppnewbuttoverr = new HSFE_NewOpportunityOverriddenExt(sc);
            oppnewbuttoverr.onLoad();
            insert opp;
            
            Opportunity oppRec = [Select Id, Name, HSFE_Specialty__c,HSFE_Sub_Specialty__c ,StageName,HSFE_Sales_Stage__c from Opportunity where ID =:opp.Id];
            System.assertEquals('Universe',oppRec.HSFE_Sales_Stage__c);
            System.assertEquals('Omitted',oppRec.StageName);

        }
    }
}