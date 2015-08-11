/* Class Name   : HSFE_Renewal_Lead_Scheduler_TestClass 
 * Description  : Testclass for HSFE_Insert_Renewal_Lead_BatchSchedulerclass
 * Created By   :Chiranth Aradhya
 * Created On   : 06/11/2015 
 * Modification Log:  
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                        Description
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 *
 */
@isTest(SeeAllData= false)
private class HSFE_Renewal_Lead_Scheduler_TestClass {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('HSFE_Insert_Renewal_Lead_BatchScheduler',
                        CRON_EXP, 
                        new HSFE_Insert_Renewal_Lead_BatchScheduler());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      Apttus_Proposal__Proposal__c [] pl = [SELECT Id,HSFE_Renewal_Lead_Created__c FROM Apttus_Proposal__Proposal__c 
                             WHERE HSFE_Renewal_Lead_Created__c= True];
      System.assertEquals(pl.size(),0);
      Test.stopTest();

      
    // Now that the scheduled job has executed after Test.stopTest(),
      //   fetch the new merchandise that got added.
     // Verify the scheduled job hasn't run yet.
      /*pl = [SELECT Id,HSFE_Renewal_Lead_Created__c FROM Apttus_Proposal__Proposal__c 
                             WHERE HSFE_Renewal_Lead_Created__c= True];
      System.assertEquals(pl.size(), 1);
      */
   }
}