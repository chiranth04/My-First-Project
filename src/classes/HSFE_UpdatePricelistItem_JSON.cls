/* 
* Class Name  : HSFE_UpdatePricelistItem_JSON
* Description : Batch used to Update/Add json string to Price list item
* Created By  : Yunus Navalur
* Created On  : 06/20/2015
*
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                             Description
* 
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
global class HSFE_UpdatePricelistItem_JSON implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT id,HSFE_JSON_Up_to_Date__c,HSFE_Matrix_Entry_JSON_String__c,Apttus_Config2__ProductId__c,Apttus_Config2__ChargeType__c FROM Apttus_Config2__PriceListItem__c where HSFE_JSON_Up_to_Date__c = False AND (Apttus_Config2__ChargeType__c = \'New\' OR Apttus_Config2__ChargeType__c = \'Trade-In - Competitor\')';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Apttus_Config2__PriceListItem__c> PricelistItem_List){
    
        
        set<string> CombinationKey = new set<String>();
        map<String,String> PriceMatrixJSON_Map = new map<String,String>();
        list<Apttus_Config2__PriceListItem__c> UpdatePriceListItem = new list<Apttus_Config2__PriceListItem__c>();
        String Temp_Var; 
        String MatrixRecSTR;
        HSFE_PriceMatxEntryJson PrcMatxEnt;
        
        for(Apttus_Config2__PriceListItem__c PLI_Rec : PricelistItem_List){  
            if(PLI_Rec.HSFE_JSON_Up_to_Date__c  == False){
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
                for(Apttus_Config2__PriceListItem__c PLI_Rec : PricelistItem_List){
                    PLI_Rec.HSFE_Matrix_Entry_JSON_String__c = PriceMatrixJSON_Map.get(PLI_Rec.id+''+PLI_Rec.Apttus_Config2__ProductId__c); 
                    PLI_Rec.HSFE_JSON_Up_to_Date__c  = True;
                    UpdatePriceListItem.add(PLI_Rec);                 
                }
                
                if(UpdatePriceListItem.size() > 0)
                    Update UpdatePriceListItem;
            }           
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);        
        }                        
    }        
       
    global void finish(Database.BatchableContext BC){
    
    }
}