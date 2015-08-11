/* 
*Class Name :HSFE_OppTerritoryAssignTest_BatchClass 
*Description :This test class test the functionlity and covers the code for HSFE_OppTerritoryAssignment_BatchClass batch class.
*Created By  :Sunil Kumar
*Created On  :04/17/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Sunil Kumar                 04/17/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_OppTerritoryAssignTest_BatchClass {
    static testmethod void testmethod1(){
         //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        
        UserRole r1 = HSFE_TestUtility_Class.createRoleRVP();
        insert r1;
        
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr; 
        
        User Usr1 =  HSFE_TestUtility_Class.create2User(r1);
        insert Usr1;     
         System.runAs(usr){  
            HSFE_Utility_Class.stopUpdateAccountTerritory = true;
            HSFE_Utility_Class.stopUpdateLeadTerritory = true;  
           
            //Insert Territroy
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;        
            system.debug('**********createHSFEZipterrcombination*********'+zipToTerr.HSFE_Combination_Key__c);
            
             //Insert  account record       
            List<Account> acc = HSFE_TestUtility_Class.createmultipleAccount();
            insert acc;
         
             //Insert Account Team
            AccountTeamMember accteam= HSFE_TestUtility_Class.createAccountTeamMember(acc[0], Usr);
            insert accteam;
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
            insert expectionObj;        
            
            HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
            insert temZipObj;
            
            //Insert Opportunity
            List<Opportunity> oppList = HSFE_TestUtility_Class.createmultipleOpportunityRecord(acc[0].id);
            oppList[0].HSFE_Secondary_Owner__c= Usr1.Id;
            insert oppList;
           
            //Insert Account Territory
            HSFE_Account_Territory__c accTerritory = HSFE_TestUtility_Class.createAccountTerritory(acc[0].id,terry);
            accTerritory.HSFE_Combination_Key__c = String.valueOf(acc[0].id).Left(15)+'Surgical'+'Energy';
            insert accTerritory;
            
            HSFE_Account_Territory__c  oAccTerritory=[SELECT Id,HSFE_Combination_Key__c FROM HSFE_Account_Territory__c WHERE Id=:accTerritory.Id];
            
            System.debug('*************' +oAccTerritory.HSFE_Combination_Key__c);
            List<Opportunity> lstOppty =[SELECT Id,Name,CreatedById,HSFE_Combination_Key__c FROM Opportunity WHERE Id IN:oppList];
            system.debug('&&&&&&&&&&&' +lstOppty [0].HSFE_Combination_Key__c);
            
            System.AssertEquals(oAccTerritory.HSFE_Combination_Key__c,lstOppty[0].HSFE_Combination_Key__c);
            
            Test.startTest();
                HSFE_OppTerritoryAssignment_BatchClass oppBatchObj = new HSFE_OppTerritoryAssignment_BatchClass();
                Database.executeBatch(oppBatchObj);  
                List<OpportunityTeamMember> oppTeamMember = new List<OpportunityTeamMember>([select id,OpportunityId from OpportunityTeamMember where OpportunityId=:oppList]);
                System.assert(oppTeamMember.size()>0,'Team member is not properly inserted');
            Test.stopTest();
         }
    }

}