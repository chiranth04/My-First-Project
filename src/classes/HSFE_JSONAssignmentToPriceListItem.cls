/* Class Name  : HSFE_JSONAssignmentToPriceListItem
*  Description : This is used to update JSON Strings on Price List item when JSON Update flag is false.
*  Created By  : Yunus H Navalur
*  Created On  :   03/12/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Sunil              3/12/2015                      Created                               
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/

public with sharing class HSFE_JSONAssignmentToPriceListItem{
    
    public boolean showMsg{get;set;}     
    
    /*********************************************************************************
    * Method Name:runLeadBatchJob
    * Description:Excute batch class
    * Return Type: None.
    ********************************************************************************/
    public void runLeadBatchJob(){
        try{
            showMsg = true;
            HSFE_UpdatePricelistItem_JSON b = new HSFE_UpdatePricelistItem_JSON();
            database.executebatch(b); 
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }   
}