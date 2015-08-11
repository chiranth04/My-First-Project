/* 
*Class Name  :HSFE_IntRetObjRcrdDel_BatSch_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_IntRetryObjectRecDel_BatchScheduler class.
*Created By  :Prateek Saxena
*Created On  :06/11/2015
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena            06/11/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*/
@isTest
private class HSFE_IntRetObjRcrdDel_BatSch_TestClass{
  static testMethod void assignAttributesTest(){
  Test.startTest();
   Datetime dt = Datetime.now().addMinutes(1);            
	//Dynamically create expression            
	String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
   HSFE_IntRetryObjectRecDel_BatchScheduler  intRetrySchedule = new HSFE_IntRetryObjectRecDel_BatchScheduler();
   String jobId = System.schedule('testScheduledApex', CRON_EXP, intRetrySchedule);
                
	//Querying on corntrigger
	CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

	//To validate job is scheduled
	System.assertEquals(CRON_EXP, ct.CronExpression); 
	System.assertEquals(0, ct.TimesTriggered);

  Test.stopTest();
  }
}