/* Class Name :HSFE_LeadReminderReassignment_TestClass
*Description :This is used to test the functionality for HSFE_LeadReminderReassignment class.
*Created By :Sunil  Kumar
*Created On :02/27/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Sunil              2/27/2015                      Created
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest(SeeAllData=True)
private class HSFE_LeadReminderReassignment_TestClass{ 
    static testmethod void test() {
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
        System.runAs(usr){ 
              Test.startTest();     
     
            Datetime dt = Datetime.now().addMinutes(1);
            
            //Dynamically create expression            
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            
            //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr4(terry);
            insert zipToTerr;     
                    
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord1();
            
            insert acc;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
            
            //Insert the Lead record
            Lead lead = HSFE_TestUtility_Class.createLeadRecord2(acc);
            lead.LastName='TBD';
            lead.HSFE_Assign_Primary_Contact__c=true;   
            lead.HSFE_Override_Assignment_Reminder__c =false;
            lead.HSFE_Reminder__c = -1;
            lead.HSFE_Reassignment__c = -1;
            insert lead; 
            Date TodayDate = Date.Today();
            
            
            Lead l = [SELECT Id,OwnerId,Name,HSFE_Reassignment_Date__c  FROM LEAD WHERE id=:lead.id];
            
            //Schedule the class to test the functionality
            HSFE_LeadReminderReassignment  leadReassign = new HSFE_LeadReminderReassignment();
            String jobId = System.schedule('testScheduledApex', CRON_EXP, leadReassign);
            
            //Querying on corntrigger
            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            //To validate job is scheduled
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
         Test.stopTest();
        
    }
    
    }
}