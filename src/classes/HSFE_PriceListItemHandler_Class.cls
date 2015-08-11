/* 
* Class Name  :HSFE_PriceListItemHandler_Class
* Description :Trigger Handler for the Price Line Item SObject, which implements all the logic of Price Line Item trigger.
                   1.
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
public with Sharing class HSFE_PriceListItemHandler_Class{
    

    /*********************************************************************************
     * Method beforeUpdate
     * Description:Updates quote on Line Item
     * Return Type: None.
    ********************************************************************************/
    public static void beforeUpdate(List<Apttus_Config2__PriceListItem__c> itemList,map<id,Apttus_Config2__PriceListItem__c> MapOldRecords){
        
        set<string> CombinationKey = new set<String>();
        map<String,String> PriceMatrixJSON_Map = new map<String,String>();         
        String Temp_Var; 
        String MatrixRecSTR;
        HSFE_PriceMatxEntryJson PrcMatxEnt;
        
        for(Apttus_Config2__PriceListItem__c PLI_Rec : itemList){  
            if(PLI_Rec.HSFE_JSON_Up_to_Date__c  == False && (PLI_Rec.Apttus_Config2__ChargeType__c == 'New' || PLI_Rec.Apttus_Config2__ChargeType__c == 'Trade-In - Competitor')){
                CombinationKey.add(PLI_Rec.id+''+PLI_Rec.Apttus_Config2__ProductId__c);
                PriceMatrixJSON_Map.put(PLI_Rec.id+''+PLI_Rec.Apttus_Config2__ProductId__c,'');                                           
            }
        }

        try{                
            if(CombinationKey.size() > 0){
                for(Apttus_Config2__PriceMatrixEntry__c MatrixRec : [SELECT id,HSFE_Target_Price__c,HSFE_Combination_Key__c,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__Dimension1Value__c 
                                                                    FROM Apttus_Config2__PriceMatrixEntry__c 
                                                                    WHERE HSFE_Combination_Key__c IN: CombinationKey])
                {
                    if(PriceMatrixJSON_Map.ContainsKey(MatrixRec.HSFE_Combination_Key__c)){
                        Temp_Var = PriceMatrixJSON_Map.get(MatrixRec.HSFE_Combination_Key__c);
                        if(Temp_Var != '')
                            Temp_Var = Temp_Var + HSFE_Constant.CUSTOM_SEPRTOR;
                        PrcMatxEnt = new HSFE_PriceMatxEntryJson(MatrixRec);
                        MatrixRecSTR = JSON.serializePretty(PrcMatxEnt);
                        Temp_Var = Temp_Var + MatrixRecSTR;
                        PriceMatrixJSON_Map.put(MatrixRec.HSFE_Combination_Key__c,Temp_Var);
                    }else{
                        PrcMatxEnt = new HSFE_PriceMatxEntryJson(MatrixRec);
                        MatrixRecSTR = JSON.serializePretty(PrcMatxEnt);
                        PriceMatrixJSON_Map.put(MatrixRec.HSFE_Combination_Key__c,MatrixRecSTR);
                    }
                                
                }

                for(Apttus_Config2__PriceListItem__c PLI_Rec : itemList){
                    PLI_Rec.HSFE_Matrix_Entry_JSON_String__c = PriceMatrixJSON_Map.get(PLI_Rec.id+''+PLI_Rec.Apttus_Config2__ProductId__c); 
                    PLI_Rec.HSFE_JSON_Up_to_Date__c  = True;                  
                }
            }
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);        
        }                        
    }    
}