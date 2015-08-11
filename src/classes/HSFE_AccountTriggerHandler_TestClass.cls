/* 
*Class Name :HSFE_AccountTriggerHandler_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_AccountTriggerHandler trigger.
*Created By  :Chiranth Aradhya
*Created On  :03/18/2015
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest                    
private class HSFE_AccountTriggerHandler_TestClass {
   
    static testmethod void testmethod1() {
    
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        //Insert User2
        User oUser=HSFE_TestUtility_Class.create2User(r);
        Insert oUser;
        System.runAs(usr){       
            //Insert Territory
            HSEF_Territory__c terr = HSFE_TestUtility_Class.createTerritory();
            insert terr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipTerr =  HSFE_TestUtility_Class.createHSFEZipterr(terr);
            insert zipTerr;
            
            //insert Zipt to Terr multiple records
            List<HSFE_Zip_To_Territory__c> zipTerrList = HSFE_TestUtility_Class.createMultipleZiptoTerr(terr);
            insert zipTerrList;
            
            
             //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipTerr2= HSFE_TestUtility_Class.createHSFEZipterr2(terr);
            insert zipTerr2;
            
            //Insert territory to User
            HSFE_Territory_To_User__c terrToUser = HSFE_TestUtility_Class.createTerritoryUser(usr,terr);
            insert terrToUser;
            
            //Insert territory Exception
            HSFE_Territory_Exception__c  terrExcep=HSFE_TestUtility_Class.createTerritoryException(terr);
            insert terrExcep;
            
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account not insert, please check validation rules and other mechanisms');        
            
            
            //Insert Opporuntiy record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            insert opp;
            
            //Insert Multiple Account record
            List<Account> accs = HSFE_TestUtility_Class.createmultipleAccount();
            insert accs;
            
            //update multiple accounts
            for (Account a : accs) {
              a.BillingPostalCode = '1234789';
              a.OwnerId=oUser.Id;
            }
            update accs;
            
          
             //check whether account is inserted properly
            System.assertEquals(accs[0].BillingPostalCode, '1234789');
            
            acc.BillingPostalCode='1234789';
            update acc;
            
            //check whether account is inserted properly
            System.assertEquals(acc.BillingPostalCode, '1234789');
           
            //Insert Account Team
            AccountTeamMember accteam= HSFE_TestUtility_Class.createAccountTeamMember(acc, Usr);
            insert accteam;
            
            //check whether account is inserted properly
            System.Assert(accteam.Id != null, 'Account team not inserted, please check validation rules and other mechanisms');
           
            //Insert AccountTerritory
            HSFE_Account_Territory__c accter = HSFE_TestUtility_Class.createAccountTerritory(acc,terr);
            insert accter;
            
            //check whether account is inserted properly
            System.Assert(accter.Id != null, 'Account territory not inserted, please check validation rules and other mechanisms');
        }  

    }
}