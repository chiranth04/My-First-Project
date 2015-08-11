/* 
*Class Name  :HSFE_IntRetryObjRcrdDel_BtchClass_Test
*Description :This test class test the functionlity and covers the code for HSFE_IntRetryObjRecordsDelete_BatchClass class.
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
private class HSFE_IntRetryObjRcrdDel_BtchClass_Test{
  static testMethod void batchExecuteTest(){
  Test.startTest();
  HSFE_Integration_Retry_Object__c intRetry = new HSFE_Integration_Retry_Object__c();
  List<sObject> ls = Test.loadData(HSFE_Integration_Retry_Object__c.sObjectType, 'HSFE_IntRetObj_LoadData');
  HSFE_IntRetryObjRecordsDelete_BatchClass batchObj = new HSFE_IntRetryObjRecordsDelete_BatchClass();
  Database.executeBatch(batchObj);
  Test.stopTest();
  List<HSFE_Integration_Retry_Object__c> deletedObjList = [Select id from HSFE_Integration_Retry_Object__c where HSFE_Request_Processed_Flag__c = true and CreatedDate < YESTERDAY];
  System.assertNotEquals(ls.size(), deletedObjList.size());
  }
}