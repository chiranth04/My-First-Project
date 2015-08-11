/* 
*Class Name :HSFE_ConvertLeadController_TestClass 
*Description :This test class test the functionlity and covers the code for HSFEContactTriggerHandler trigger.
*Created By  :Chiranth Aradhya
*Created On  :02/17/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest   
private class HSFE_ConvertLeadController_TestClass {
   
    static testMethod void test(){
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
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
            
            //Insert the lead record 
            Lead l = HSFE_TestUtility_Class.createLeadRecord(acc);
            insert l;
            
            //call the custom lead convert controller by passing lead and account Id
            HSFE_CustomConvertLead_Controller.HSFEConvertLeadMethod(l.Id,acc.Id);
           
             
            //Insert the lead record 
            Lead l1 = HSFE_TestUtility_Class.createLeadRecord(acc);
            insert l1;
            
            //call the custom lead convert controller by passing lead and account Id
            HSFE_CustomConvertLead_Controller.HSFEConvertLeadMethod(l1.Id,acc.Id);
            
            //Verify that the Lead is not converted, when its a duplicate
            Lead convertedLead1= [SELECT Id,IsConverted FROM Lead WHERE Id = :l1.Id];
            System.assertEquals(False, convertedLead1.IsConverted);
            
            //Insert the account record without account team   
            Account acc1 = HSFE_TestUtility_Class.createAccountRecord2();
            
            insert acc1;
            
            //insert the lead record by passing account Id
            Lead l2 =  HSFE_TestUtility_Class.createLeadRecord2(acc1);
            insert l2;
            
            //call the custom lead convert controller by passing lead and account Id
            HSFE_CustomConvertLead_Controller.HSFEConvertLeadMethod(l2.Id,acc1.Id);
            
            //Verify that the Lead is not converted,when owner is not the part of the account team
            Lead convertedLead2= [SELECT Id,IsConverted FROM Lead WHERE Id = :l1.Id];
            System.assertEquals(False, convertedLead2.IsConverted);
        }
        
    }
}