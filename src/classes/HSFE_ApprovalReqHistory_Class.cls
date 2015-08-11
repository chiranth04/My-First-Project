/* Class Name :HSFE_ApprovalReqHistory_Class
*Description :Trigger Handler class for the Approval Request History SObject, which implements all the logic of Approval Request History trigger.
            1. Update the quote id whenever aprroval history record has product configuration id.
*Created By :Sunil Kumar
*Created On :05/12/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
 Sunil Kumar                5/12/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public class HSFE_ApprovalReqHistory_Class {
    public static void handleBeforeInsert(List<Apttus_Approval__Approval_Request_History__c> approvalList){
        try{
             Set<Id> prodConfigId = new Set <Id>();
             Map<Id,Apttus_Config2__ProductConfiguration__c> mapProductConfig = new Map<Id,Apttus_Config2__ProductConfiguration__c>();
             //Add Product Config ID
             for (Apttus_Approval__Approval_Request_History__c approvalHistObj : approvalList){
                if(approvalHistObj.Apttus_CQApprov__CartId__c != null){
                     prodConfigId.add(approvalHistObj.Apttus_CQApprov__CartId__c);
                }            
             }
             if(prodConfigId.size()>0){
                 List <Apttus_Config2__ProductConfiguration__c> configLst = new List <Apttus_Config2__ProductConfiguration__c>([Select id, Apttus_QPConfig__Proposald__c  from Apttus_Config2__ProductConfiguration__c where id in :prodConfigId]);
                 
                 //Store config id against config
                for (Apttus_Config2__ProductConfiguration__c cartObj : configLst) {
                    if(cartObj.Apttus_QPConfig__Proposald__c != null){
                        mapProductConfig.put(cartObj.id,cartObj);
                    }             
                }
                for (Apttus_Approval__Approval_Request_History__c approvalHistObj : approvalList) {
                    if(mapProductConfig.containsKey(approvalHistObj.Apttus_CQApprov__CartId__c)){
                        approvalHistObj.Apttus_QPApprov__ProposalId__c = mapProductConfig.get(approvalHistObj.Apttus_CQApprov__CartId__c).Apttus_QPConfig__Proposald__c;
                    }
                }
             }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
        
    }
}