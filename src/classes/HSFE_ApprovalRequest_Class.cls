/* Class Name :HSFE_ApprovalRequest_Class
*Description :Trigger Handler class for the Approval Request SObject, which implements all the logic of Approval Request trigger.
            1. Update the quote id whenever aprroval history record has product configuration id.
*Created By :Sunil Kumar
*Created On :05/21/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
 Sunil Kumar                5/21/2015
 Divya A N                  5/25/2015                                                            Logic to concatenate Approval Steps on Line Item and Product Config
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public class HSFE_ApprovalRequest_Class{
     public static void handleBeforeInsert(List<Apttus_Approval__Approval_Request__c> approvalList){
        try{
             Set<Id> prodConfigId = new Set <Id>();
             Map<Id,Apttus_Config2__ProductConfiguration__c> mapProductConfig = new Map<Id,Apttus_Config2__ProductConfiguration__c>();
            //Add Product Config ID
             for (Apttus_Approval__Approval_Request__c approvalObj : approvalList){
                if(approvalObj .Apttus_CQApprov__CartId__c!= null){
                     prodConfigId.add(approvalObj.Apttus_CQApprov__CartId__c);
                }            
             }
             if(prodConfigId.size()>0){
                 List <Apttus_Config2__ProductConfiguration__c> configLst = new List <Apttus_Config2__ProductConfiguration__c>([Select id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where id in :prodConfigId]);
                 
                 //Store config id against config
                for (Apttus_Config2__ProductConfiguration__c cartObj : configLst) {
                    if(cartObj.Apttus_QPConfig__Proposald__c != null){
                        mapProductConfig.put(cartObj.id,cartObj);                        
                    }             
                }
                for (Apttus_Approval__Approval_Request__c approvalObj : approvalList) {
                    if(mapProductConfig.containsKey(approvalObj.Apttus_CQApprov__CartId__c)){
                        approvalObj.Apttus_QPApprov__ProposalId__c = mapProductConfig.get(approvalObj.Apttus_CQApprov__CartId__c).Apttus_QPConfig__Proposald__c ;
                    }                    
                }
             }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
        
    }
     public static void handleAfterInsert(List<Apttus_Approval__Approval_Request__c> approvalList){
        try{
             Map<String, Set<String>> mapChildObjectIdAndStep = new Map<String, Set<String>>();
             Map<String, Set<String>> mapProductConfigWithSteps = new Map<String, Set<String>>();
             Set<String> lstStep;
             Set<Id> setChildId = new Set<Id>();
             List<Apttus_Config2__LineItem__c> lstLineItem = new List<Apttus_Config2__LineItem__c>();
             List<Apttus_Config2__ProductConfiguration__c> lstProductConfig = new List<Apttus_Config2__ProductConfiguration__c>();
             Apttus_Config2__ProductConfiguration__c oProductConfig = new Apttus_Config2__ProductConfiguration__c();
             system.debug(approvalList + 'approvalList&&&&&');
             for (Apttus_Approval__Approval_Request__c approvalObj : approvalList){
               setChildId.add(approvalObj.Apttus_Approval__ChildObjectId__c);
               system.debug('&&&&&&&&&&&'+setChildId);
               if(mapChildObjectIdAndStep.ContainsKey(approvalObj.Apttus_Approval__ChildObjectId__c)){
                   lstStep= mapChildObjectIdAndStep.get(approvalObj.Apttus_Approval__ChildObjectId__c);
                   lstStep.add(approvalObj.Apttus_Approval__Step_Name__c);
               }
               else{
                   lstStep= new Set<String>();
                   lstStep.add(approvalObj.Apttus_Approval__Step_Name__c);
               }
                system.debug('*##############'+lstStep);
                mapChildObjectIdAndStep.put(approvalObj.Apttus_Approval__ChildObjectId__c,lstStep);
               //Creating a Map of Product Config Id and the approval steps it qualifies
               if(mapProductConfigWithSteps.ContainsKey(approvalObj.Apttus_Approval__Object_Id__c)){
                   lstStep= mapProductConfigWithSteps.get(approvalObj.Apttus_Approval__Object_Id__c);
                   lstStep.add(approvalObj.Apttus_Approval__Step_Name__c);
               }
               else{
                   lstStep= new Set<String>();
                   lstStep.add(approvalObj.Apttus_Approval__Step_Name__c);
               }
               mapProductConfigWithSteps.put(approvalObj.Apttus_Approval__Object_Id__c,lstStep);
             }
             system.debug('mapChildObjectIdAndStep******>'+mapChildObjectIdAndStep);
            lstLineItem= [SELECT id,HSFE_Concatenated_Steps__c FROM Apttus_Config2__LineItem__c WHERE Id IN:setChildId];
            lstProductConfig = [SELECT Id,HSFE_Concatenated_Steps__c  FROM Apttus_Config2__ProductConfiguration__c WHERE Id IN:mapProductConfigWithSteps.KeySet()];
            if(lstProductConfig.size()>0)
            {
                oProductConfig= lstProductConfig[0];
                if(mapProductConfigWithSteps.ContainsKey(oProductConfig.Id))
                {
                    oProductConfig.HSFE_Concatenated_Steps__c = NULL;
                    Set<String> lstStepString = mapProductConfigWithSteps.get(oProductConfig.Id);
                    String sStepString;
                    Integer i=1;
                    for(String sStr: lstStepString)
                    {
                       if(sStr != 'Pre-Approved Discount'){
                       sStepString= (sStepString== null?i + '. '+ sStr: (sStepString + ';'+ i + '. '+sStr));
                       i=i+1;
                       system.debug(sStepString + 'sStepString*****************');
                       }
                    }
                        oProductConfig.HSFE_Concatenated_Steps__c = sStepString;
                       update oProductConfig;
                }
           
            }
            
                
            
            for(Apttus_Config2__LineItem__c oLineItem: lstLineItem)
            {
                oLineItem.HSFE_Concatenated_Steps__c= NULL;
                if(mapChildObjectIdAndStep.ContainsKey(oLineItem.Id))
                {
                    Set<String> lstStepString = mapChildObjectIdAndStep.get(oLineItem.Id);
                    system.debug(lstStepString  + '##########');
                    String sStepString;
                    Integer i=1;
                    for(String sStr: lstStepString)
                    {
                       if(sStr != 'Pre-Approved Discount'){
                           system.debug(sStr+ '^^');
                           sStepString= (sStepString== null?i + '. '+ sStr: (sStepString + ';'+ i + '. '+sStr));
                           i= i+1;
                           system.debug(sStepString + 'sStepString*****************');
                       }
                    }
                    oLineItem.HSFE_Concatenated_Steps__c = sStepString;
                    system.debug(sStepString.substring(1)+ 'sStepString.substring(1)*****************');
                }
            }
            update lstLineItem;
             
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
        
    }
}