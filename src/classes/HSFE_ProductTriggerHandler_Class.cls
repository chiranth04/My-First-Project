/* 
* Class Name  : HSFE_ProductTriggerHandler_Class 
* Description : Trigger Handler for the Product SObject, which implements all the logic.
* Created By  : Yunus H Navalur
* Created On  : 02/20/2015
*
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                             Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Yunus                    3/23/2015
* Yunus                    6/1/2015                             US-490. If product is kit Charge type will be assigned for conditions without trade-in  
* Ajay Agnihotri           9/June/2015                          Add PriceBookEntry to Each Product and associate that to Standard Pricebook
* Ajay Agnihotri            08/July/2015                        Updated Code to bypass insert of standard priceBook Entry for Each Product.
*
*/

public with sharing class HSFE_ProductTriggerHandler_Class{
    
    public void ProductConditionPopulateLogic_Update(map<id,Product2> NewTriggerRecords,Map<id,Product2> OldTriggerRecords){

        //Declarations Section
        map<string,String> ProdAttrConditionMap = new map<string,String>();
        
        
        //Logic Section
        for(product2 LoopProdRec: NewTriggerRecords.values()){
            if(LoopProdRec.HSFE_Product_Type__c != HSFE_Constant.COUSTOM_SKP){
                if(LoopProdRec.HSFE_Product_Conditions_Multi__c != null){
                    List<String> Values = LoopProdRec.HSFE_Product_Conditions_Multi__c.Split(';',5);
                    Values.sort();
                    String strSobjects = null;                 
                    for(integer i=0;i<Values.size();i++){
                        if(strSobjects == null){
                            strSobjects = Values[i];
                        }Else{
                            strSobjects = strSobjects+';'+Values[i];
                        }               
                    }
                    LoopProdRec.HSFE_Product_Conditions_Multi__c = strSobjects;
                    ProdAttrConditionMap.put(strSobjects,'');
                }
            }else if(LoopProdRec.HSFE_Product_Type__c == HSFE_Constant.COUSTOM_SKP){
                if(LoopProdRec.HSFE_Product_Conditions_Multi__c != null){
                    List<String> Values = LoopProdRec.HSFE_Product_Conditions_Multi__c.Split(';',5);
                    Values.sort();
                    String strSobjects = null;                 
                    for(integer i=0;i<Values.size();i++){
                        if(Values[i] != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && Values[i] != HSFE_Constant.COUSTOM_TRADE_OLYMPUS){
                            if(strSobjects == null){
                                strSobjects = Values[i];
                            }Else{
                                strSobjects = strSobjects+';'+Values[i];
                            }
                        }               
                    }
                    LoopProdRec.HSFE_Product_Conditions_Multi__c = strSobjects;
                    ProdAttrConditionMap.put(strSobjects,'');
                }            
            
            }                   
        }
        
        for(HSFE_Product_Attribute_Charge_Types__c CustomSetgRec : [select name,HSFE_Name_Long__c,HSFE_Description__c from HSFE_Product_Attribute_Charge_Types__c where HSFE_Name_Long__c in: ProdAttrConditionMap.KeySet()]){
            if(ProdAttrConditionMap.ContainsKey(CustomSetgRec.HSFE_Name_Long__c)) 
                ProdAttrConditionMap.put(CustomSetgRec.HSFE_Name_Long__c,CustomSetgRec.Name);      
        }
       
        for(product2 LoopProdRec: NewTriggerRecords.values()){
            if(ProdAttrConditionMap.ContainsKey(LoopProdRec.HSFE_Product_Conditions_Multi__c)){
                LoopProdRec.HSFE_Charge_Type__c = ProdAttrConditionMap.get(LoopProdRec.HSFE_Product_Conditions_Multi__c);
            }else if(LoopProdRec.HSFE_Product_Conditions_Multi__c != null && !ProdAttrConditionMap.ContainsKey(LoopProdRec.HSFE_Product_Conditions_Multi__c)){
                LoopProdRec.HSFE_Charge_Type__c = 'N/A - Stocking Kit';
            }else{
                LoopProdRec.HSFE_Charge_Type__c = '';
            }   
        }                          
    }
    
    public void ProductConditionPopulateLogic_Insert(List<Product2> NewTriggerRecords){

        //Declarations Section
        map<string,String> ProdAttrConditionMap = new map<string,String>();
        
        
        //Logic Section
        for(product2 LoopProdRec: NewTriggerRecords){
            if(LoopProdRec.HSFE_Product_Type__c != HSFE_Constant.COUSTOM_SKP){
                if(LoopProdRec.HSFE_Product_Conditions_Multi__c != null){
                    List<String> Values = LoopProdRec.HSFE_Product_Conditions_Multi__c.Split(';',5);
                    Values.sort();
                    String strSobjects = null;                 
                    for(integer i=0;i<Values.size();i++){
                        if(strSobjects == null){
                            strSobjects = Values[i];
                        }Else{
                            strSobjects = strSobjects  +';'+Values[i];
                        }               
                    }
                    LoopProdRec.HSFE_Product_Conditions_Multi__c = strSobjects;
                    ProdAttrConditionMap.put(strSobjects,'');                
                }
            }else if(LoopProdRec.HSFE_Product_Type__c == HSFE_Constant.COUSTOM_SKP){
                if(LoopProdRec.HSFE_Product_Conditions_Multi__c != null){
                    List<String> Values = LoopProdRec.HSFE_Product_Conditions_Multi__c.Split(';',5);
                    Values.sort();
                    String strSobjects = null;                 
                    for(integer i=0;i<Values.size();i++){
                        if(Values[i] != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && Values[i] != HSFE_Constant.COUSTOM_TRADE_OLYMPUS){
                            if(strSobjects == null){
                                strSobjects = Values[i];
                            }Else{
                                strSobjects = strSobjects  +';'+Values[i];
                            }
                        }                       
                    }
                    LoopProdRec.HSFE_Product_Conditions_Multi__c = strSobjects;
                    ProdAttrConditionMap.put(strSobjects,'');                
                }
            }           
        }
        for(HSFE_Product_Attribute_Charge_Types__c CustomSetgRec : [select name,HSFE_Name_Long__c,HSFE_Description__c from HSFE_Product_Attribute_Charge_Types__c where HSFE_Name_Long__c in: ProdAttrConditionMap.KeySet()]){
            if(ProdAttrConditionMap.ContainsKey(CustomSetgRec.HSFE_Name_Long__c)) 
                ProdAttrConditionMap.put(CustomSetgRec.HSFE_Name_Long__c,CustomSetgRec.Name);      
        }
        for(product2 LoopProdRec: NewTriggerRecords){
            if(ProdAttrConditionMap.ContainsKey(LoopProdRec.HSFE_Product_Conditions_Multi__c)){
                LoopProdRec.HSFE_Charge_Type__c = ProdAttrConditionMap.get(LoopProdRec.HSFE_Product_Conditions_Multi__c);
            }else if(LoopProdRec.HSFE_Product_Conditions_Multi__c != null && !ProdAttrConditionMap.ContainsKey(LoopProdRec.HSFE_Product_Conditions_Multi__c)){
                LoopProdRec.HSFE_Charge_Type__c = 'N/A - Stocking Kit';
            }else{
                LoopProdRec.HSFE_Charge_Type__c = '';
            }   
        }                          
    } 

    /**
    Method Name : ProductLogic_AfterInsert
    Arguments : List<Product2> TriggerNew, Map<Id,Product2> TriggerNewMap
    Return Type : None
    Description : This Method have below features
                    1. Add PriceBookEntry to Each Product and associate that to Standard Pricebook
    **/
    public void ProductLogic_AfterInsert(List<Product2> TriggerNew, Map<Id,Product2> TriggerNewMap){
        try{
            if(!HSFE_Utility_Class.ProductAfterInsert){
                
                HSFE_Utility_Class.ProductAfterInsert = true; // to stop recursion
                List<PricebookEntry> PriceBookEntry_Lst=new List<PricebookEntry>();
                Id StandardPriceBookId=null;
                
                for(Pricebook2 Pricebook2Inst:[SELECT Id,IsActive,IsStandard FROM Pricebook2 WHERE IsStandard=true and IsActive=true Limit 1]){
                    StandardPriceBookId=Pricebook2Inst.Id;
                }
                if(StandardPriceBookId!=null){
                    /*This Logic Runs To insert PribookEntry Records for Each new Product.*/
                    for(Product2 NewProdInst:TriggerNew){
                        PriceBookEntry_Lst.add(new PricebookEntry(Pricebook2Id=StandardPriceBookId,Product2Id=NewProdInst.Id,IsActive=true,UseStandardPrice=false,UnitPrice=0));
                    }
                }
                
                if(PriceBookEntry_Lst.size()>=0 && PriceBookEntry_Lst.size()<10000){
                    // 08/July/2015 Updated Code to bypass insert of standard priceBook Entry for Each Product (Ajay Agnihotri)
                    if(PriceBookEntry_Lst.size()>0)
                        insert PriceBookEntry_Lst;
                }       
                else{
                    for(Product2 NewProdInstForError:TriggerNew)
                        NewProdInstForError.addError('Please Filter the Product records to insert less than 10000 records at a time.');
                }
            }
        }
        catch(Exception ExcepitionInProductLogic_AfterInsert){
            for(Product2 NewProdInstForException:TriggerNew)
                NewProdInstForException.addError(ExcepitionInProductLogic_AfterInsert.getMessage());
        }
    }
}