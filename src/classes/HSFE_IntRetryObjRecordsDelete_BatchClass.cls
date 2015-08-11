/* Class Name :HSFE_IntegrationRetryObjectRecordsDelete_BatchClass
*Description :This class is used to delete all the Integration Retry Object processed by MuleSoft.
*Created By :Prateek Saxena
*Created On :5/29/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena             5/29/2015                                                           Created
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public with sharing class HSFE_IntRetryObjRecordsDelete_BatchClass implements Database.Batchable<sObject>{

    public String query;
    public Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select id from HSFE_Integration_Retry_Object__c where HSFE_Request_Processed_Flag__c = true and CreatedDate < YESTERDAY';
        system.debug('*************************Query*****>' + query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC,List<sObject> scope){
        try{
            System.debug('********************** Records going to be Deleted :' + scope);
            if (null != scope && !scope.isEmpty()){
                delete scope;
            }
        }
        catch(Exception e){
          HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception. 
        }
    }
    public void finish(Database.BatchableContext ctx){
    }
}