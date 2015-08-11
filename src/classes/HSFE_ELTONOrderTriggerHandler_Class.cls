/* Class Name : HSFE_ELTONOrderTriggerHandler_Class
*Description :  Trigger Handler class for the Equipment Order SObject, which implements all the logic of Equipment Order trigger.
*Created By :   Divya A N
*Created On :   24-June-2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Divya              6/24/2015                      Created                               
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public with sharing class HSFE_ELTONOrderTriggerHandler_Class{
     /*********************************************************************************
     * Method: handleBeforeInsert
     * Description:Assign approvers based on Opportunity
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeInsert(List<ELTON__Equipment_Order__c> eltonOrderList) {
        try{
            Set<String> setOpptyId= new Set<String>();
            for(ELTON__Equipment_Order__c oEltonOrder:eltonOrderList){
                setOpptyId.add(oEltonOrder.ELTON__Opportunity__c);
            }
            system.debug(setOpptyId+ '**********');
            if(setOpptyId.size()>0){
                //Query for Opportunities that are associated with the ELTON Orders
                List<Opportunity> lstOpportunity=[SELECT Id,HSFE_Approval_AVP_User__c,HSFE_Approval_DVP_User__c,HSFE_Approval_GVP_User__c,HSFE_Approval_RSD_RVP_User__c FROM Opportunity WHERE ID IN:setOpptyId];
                 Map<String,Opportunity> mapEltonOpportunity= new Map<String,Opportunity>();
                    if(lstOpportunity.size()>0 && lstOpportunity!=null){
                        for(Opportunity oOpp:lstOpportunity){
                           mapEltonOpportunity.put(oOpp.Id,oOpp);     
                        }
                     }
                 system.debug('mapEltonOpportunity' +mapEltonOpportunity);
                //Looping over the Elton Orders, assign approvers from the respective Opportunity
                for(ELTON__Equipment_Order__c oEltonEquipmentOrder: eltonOrderList){
                    oEltonEquipmentOrder.HSFE_Approval_Submitter__c=UserInfo.getUserId();
                    if(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c)!=NULL){
                        oEltonEquipmentOrder.HSFE_Approval_AVP_User__c=(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_AVP_User__c!=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_AVP_User__c:Label.HSFE_Backup_Approver_ELTON_Order);
                        oEltonEquipmentOrder.HSFE_Approval_DVP_User__c=(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_DVP_User__c!=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_DVP_User__c:Label.HSFE_Backup_Approver_ELTON_Order);
                        oEltonEquipmentOrder.HSFE_Approval_GVP_User__c=(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_GVP_User__c!=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_GVP_User__c:Label.HSFE_Backup_Approver_ELTON_Order);
                        oEltonEquipmentOrder.HSFE_Approval_RSD_RVP_User__c =(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_RSD_RVP_User__c !=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_RSD_RVP_User__c :Label.HSFE_Backup_Approver_ELTON_Order);
                        
                    }
               }
           }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
    /*********************************************************************************
     * Method: handleAfterInsert
     * Description:Assign approvers based on Opportunity
     * Return Type: None.
     ********************************************************************************/
    public static void handleAfterInsert(List<ELTON__Equipment_Order__c> eltonOrderList) {
        try{
            HSFE_Utility_Class.bEltonAfterInsertTriggerExecuted= True;
            for(ELTON__Equipment_Order__c oEltonEquipmentOrder: eltonOrderList){
                    if(oEltonEquipmentOrder.ELTONOlympus__Exception__c!='None'&& oEltonEquipmentOrder.ELTONOlympus__Stage__c!='In Review'){
                         Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
                         app.setObjectId(oEltonEquipmentOrder.Id);
                         Approval.ProcessResult result = Approval.process(app);
                     }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
    /*********************************************************************************
     * Method: handleBeforeUpdate
     * Description:Assign approvers based on Opportunity
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeUpdate(List<ELTON__Equipment_Order__c> eltonOrderList,Map<Id, ELTON__Equipment_Order__c> oldMap) {
        try{
            //HSFE_Utility_Class.bEltonTriggerExecuted= True;
            Set<String> setOpptyId= new Set<String>();
            Set<String> setEltonOrderId= new Set<String>();
            ELTON__Equipment_Order__c oldEltonOrder;
            
            for(ELTON__Equipment_Order__c oEltonEquipmentOrder:eltonOrderList){
                oldEltonOrder = oldMap.get(oEltonEquipmentOrder.Id);
                if(oEltonEquipmentOrder.ELTONOlympus__Exception__c!='None' && oldEltonOrder.ELTONOlympus__Exception__c !=oEltonEquipmentOrder.ELTONOlympus__Exception__c) 
                    setOpptyId.add(oEltonEquipmentOrder.ELTON__Opportunity__c);
            }
            if(setOpptyId.size() > 0){
                //Query for Opportunities that are associated with the ELTON Orders
                List<Opportunity> lstOpportunity=[SELECT Id,HSFE_Approval_AVP_User__c,HSFE_Approval_DVP_User__c,HSFE_Approval_GVP_User__c,HSFE_Approval_RSD_RVP_User__c FROM Opportunity WHERE ID IN:setOpptyId];
                Map<String,Opportunity> mapEltonOpportunity= new Map<String,Opportunity>();
                if(lstOpportunity.size()>0 && lstOpportunity!=null){
                    for(Opportunity oOpp:lstOpportunity){
                        mapEltonOpportunity.put(oOpp.Id,oOpp);     
                    }
                }
                system.debug('mapEltonOpportunity' +mapEltonOpportunity);
                //Looping over the Elton Orders, assign approvers from the respective Opportunity
                for(ELTON__Equipment_Order__c oEltonEquipmentOrder: eltonOrderList){
                    oEltonEquipmentOrder.HSFE_Approval_Submitter__c=UserInfo.getUserId();
                    if(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c)!=NULL){
                       oEltonEquipmentOrder.HSFE_Approval_AVP_User__c=(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_AVP_User__c!=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_AVP_User__c:Label.HSFE_Backup_Approver_ELTON_Order);
                        oEltonEquipmentOrder.HSFE_Approval_DVP_User__c=(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_DVP_User__c!=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_DVP_User__c:Label.HSFE_Backup_Approver_ELTON_Order);
                        oEltonEquipmentOrder.HSFE_Approval_GVP_User__c=(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_GVP_User__c!=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_GVP_User__c:Label.HSFE_Backup_Approver_ELTON_Order);
                        oEltonEquipmentOrder.HSFE_Approval_RSD_RVP_User__c =(mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_RSD_RVP_User__c !=NULL?mapEltonOpportunity.get(oEltonEquipmentOrder.ELTON__Opportunity__c).HSFE_Approval_RSD_RVP_User__c :Label.HSFE_Backup_Approver_ELTON_Order);
                    }
                }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    /*********************************************************************************
     * Method: handleBeforeUpdate
     * Description:Assign approvers based on Opportunity
     * Return Type: None.
     ********************************************************************************/
    public static void handleAfterUpdate(List<ELTON__Equipment_Order__c> eltonOrderList,Map<Id, ELTON__Equipment_Order__c> oldMap) {
        try{
            HSFE_Utility_Class.bEltonTriggerExecuted= True;
            Set<String> setOpptyId= new Set<String>();
            Set<String> setEltonOrderId= new Set<String>();
            ELTON__Equipment_Order__c oldEltonOrder;
            for(ELTON__Equipment_Order__c oEltonEquipmentOrder: eltonOrderList){
                oldEltonOrder = oldMap.get(oEltonEquipmentOrder.Id);
                if(oEltonEquipmentOrder.ELTONOlympus__Exception__c!='None' && oldEltonOrder.ELTONOlympus__Exception__c !=oEltonEquipmentOrder.ELTONOlympus__Exception__c){
                    Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
                    app.setObjectId(oEltonEquipmentOrder.Id);
                    Approval.ProcessResult result = Approval.process(app);
                }
           }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
}