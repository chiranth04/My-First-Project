/* 
* Class Name  :HSFE_MatrixEntry_Handler_Class
* Description :Trigger Handler for the Price Line Item SObject, which implements all the logic of Matrix Entry trigger.
                   1.
                   2.
* Created By  : 
* Created On  : 06/18/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with Sharing class HSFE_MatrixEntry_Handler_Class{

    /*********************************************************************************
     * Method beforeUpdate
     * Description:Updates quote on Line Item
     * Return Type: None.
    ********************************************************************************/
    public static void beforeUpdate(List<Apttus_Config2__PriceMatrixEntry__c> newMatrixList){
        set<id> PriceListItemId = new set<id>();
        List<Apttus_Config2__PriceListItem__c> UpdateRec = new List<Apttus_Config2__PriceListItem__c>();
        for(Apttus_Config2__PriceMatrixEntry__c MatrixRec : newMatrixList){
            PriceListItemId.add(MatrixRec.HSFE_Price_List_Item_Id__c);                        
        }
        for(Apttus_Config2__PriceListItem__c Rec : [select id, HSFE_JSON_Up_to_Date__c from Apttus_Config2__PriceListItem__c where id in: PriceListItemId]){
            Rec.HSFE_JSON_Up_to_Date__c = false;
            UpdateRec.add(Rec);
        }
        try{
            if(UpdateRec != null)
                update UpdateRec;
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);        
        }    
    }
}