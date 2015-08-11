/* 
* Class Name``:HSFE_LineItemTrigrHdler_Class_WorkSpace
* Description :Trigger Handler for the Line Item SObject, which implements all the logic of Line Item trigger.
                   1. Calculate option price
                   2. Validate Serial/Lot no
                   3. Get price based on Condition
                   4. UOM value assignment
                   5. Populate JSON values on Line item
* Created By  : 
* Created On  : 02/24/2015


* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with Sharing class HSFE_LineItemTrigrHdler_Class_WorkSpace {
    

    /*********************************************************************************
     * Method Name:beforeInsert
     * Description:Updates quote on Line Item
     * Return Type: None.
    ********************************************************************************/
    public static void beforeInsert(List<Apttus_Config2__LineItem__c> itemList){  
        
        
        try{

            //------------------------------------------------Declaration - Section-----------------------------------------

            map<id,string> ProductHierarchyLabelMap = new map<id,String>();
            map<id,string> ProductCategoryLabelMap = new map<id,String>();  
            map<id,String> ProdConfigJSON_Map = new map<id,String>();
            map<id,String> ProductJSON_Map = new map<id,String>();
            map<Id,Apttus_Config2__PriceListItem__c> Product_PricelistItem_Ids = new map <Id,Apttus_Config2__PriceListItem__c>();       
            map<Id, Apttus_Config2__ProductClassification__c> productClassificationMap = new Map<Id, Apttus_Config2__ProductClassification__c>();
            map<Id, Id> cartQuoteMap = new map <Id, Id>();              

            set<string> CombinationKey = new set<String>();
            set<Id> ProductIds = new set<Id>();     
            set<Id> cartLst = new Set <Id>();
            set<String> specialtySet = new Set<String>();

            List<Apttus_Config2__LineItem__c> liSOList = new List<Apttus_Config2__LineItem__c>();
            
            boolean Is_Stocking_Kit = false;
            boolean Is_Kit_In_A_Kit = false;        
            
            Double price;        
            String pcondition = null;
            
            //JSON Variables
            JSONGenerator generator;
            string Temp_Var ;       
            String MatrixRecSTR;        
            HSFE_ProductJson ProductRec;
            HSFE_ProductJson ParentProductRec;      
            HSFE_ProductConfigJson ProdConfigRec;
            HSFE_PriceMatxEntryJson PriceMatricRec;

            //System.debug('-------LOG-------HSFE_LineItemTrigrHdler_Class_WorkSpace----------<Name>----------------->'+<Value>);

            //------------------------------------------------Declaration - Section-----------------------------------------
            

            //--------------------------------Build Data maps and JSON Start ----------------------------------------------------------------------------------

            for (Apttus_Config2__LineItem__c lineItemObj : itemList) 
            {
                lineItemObj.HSFE_Line_Item_Extension__c = null;
                cartLst.add(lineItemObj.Apttus_Config2__ConfigurationId__c);
                
                if(!String.isEmpty(lineItemObj.Apttus_Config2__OptionId__c)){
                    ProductJSON_Map.put(lineItemObj.Apttus_Config2__ProductId__c,'');
                    ProductJSON_Map.put(lineItemObj.Apttus_Config2__OptionId__c,'');
                    Product_PricelistItem_Ids.put(lineItemObj.Apttus_Config2__OptionId__c,null);
                }else{
                    ProductJSON_Map.put(lineItemObj.Apttus_Config2__ProductId__c,'');
                    Product_PricelistItem_Ids.put(lineItemObj.Apttus_Config2__ProductId__c,null);
                }            
            }
            
            //Query Product Classification to get Category Hierarchy and Product Classification
            for(Apttus_Config2__ProductClassification__c ClassifRec : [SELECT id,name,Apttus_Config2__ClassificationId__c,HSFE_Category_Hierarchy_Name__c,HSFE_Category_Hierarchy_Label__c,Apttus_Config2__ProductId__c  
                                                                       FROM Apttus_Config2__ProductClassification__c 
                                                                       WHERE Apttus_Config2__ProductId__c in: ProductJSON_Map.KeySet() AND HSFE_Category_Hierarchy_Label__c in: HSFE_Constant.CUSTOM_CATEGORYLABEL])
            {
                
                ProductHierarchyLabelMap.put(ClassifRec.Apttus_Config2__ProductId__c,ClassifRec.id);
                ProductCategoryLabelMap.put(ClassifRec.id,ClassifRec.Apttus_Config2__ClassificationId__c);
                productClassificationMap.put(ClassifRec.Apttus_Config2__ProductId__c,ClassifRec);
            }      

            //Query product Configuration
            for (Apttus_Config2__ProductConfiguration__c cartObj : [SELECT id, HSFE_FIT_Quote__c, HSFE_Quote_Order_Type__c, Apttus_QPConfig__Proposald__c,
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_AVP_User__c, 
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_DVP_User__c,
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_GVP_User__c,
                                                                        Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_RSD_RVP_User__c,
                                                                        Apttus_QPConfig__Proposald__r.HSFE_Deep_Clone__c, 
                                                                        Apttus_QPConfig__Proposald__r.HSFE_FIT_Quote__c, 
                                                                        Apttus_QPConfig__Proposald__r.HSFE_Proposal_Order_Type__c, Apttus_QPConfig__Proposald__r.id 
                                                                    FROM Apttus_Config2__ProductConfiguration__c 
                                                                    WHERE id in :cartLst])
            {
                cartQuoteMap.put(cartObj.id, cartObj.Apttus_QPConfig__Proposald__c);            
                ProdConfigRec = new HSFE_ProductConfigJson(cartObj);
                MatrixRecSTR = JSON.serializePretty(ProdConfigRec);      
                ProdConfigJSON_Map.put(cartObj.Apttus_QPConfig__Proposald__r.id,MatrixRecSTR);            
            }      

            //Query products
            for(Product2 ProdRec : [SELECT id,HSFE_Charge_Type__c,Is_Stocking_Kit__c,HSFE_Is_Batch__c,HSFE_Is_Serial__c,HSFE_Product_Type__c,HSFE_Product_Conditions_Multi__c 
                                    FROM product2 
                                    WHERE ID in: ProductJSON_Map.KeySet()])
            {
                HSFE_ProductJson jsonReq = new HSFE_ProductJson(ProdRec);
                MatrixRecSTR = JSON.serializePretty(jsonReq); 
                ProductJSON_Map.put(ProdRec.id,MatrixRecSTR);         
            }
            
            //Query Price List Item
            for(Apttus_Config2__PriceListItem__c PriceLTItem : [SELECT id,Apttus_Config2__ChargeType__c,Apttus_Config2__ProductId__c,HSFE_Matrix_Entry_JSON_String__c
                                                                FROM Apttus_Config2__PriceListItem__c 
                                                                where Apttus_Config2__ProductId__c in: Product_PricelistItem_Ids.KeySet() AND Apttus_Config2__ChargeType__c in: HSFE_Constant.CUSTOM_PRICELISTITEM_QUERYSET ])
            {
                if(Product_PricelistItem_Ids.ContainsKey(PriceLTItem.Apttus_Config2__ProductId__c)){
                    Product_PricelistItem_Ids.put(PriceLTItem.Apttus_Config2__ProductId__c,PriceLTItem);
                    CombinationKey.add(PriceLTItem.id+''+PriceLTItem.Apttus_Config2__ProductId__c);
                }   
            }


            //--------------------------------Build Data maps and JSON End ----------------------------------------------------------------------------------
            
            for (Apttus_Config2__LineItem__c lineItemObj : itemList) {

                if(cartQuoteMap.ContainsKey(lineItemObj.Apttus_Config2__ConfigurationId__c)){
                    if(ProdConfigJSON_Map.ContainsKey(cartQuoteMap.get(lineItemObj.Apttus_Config2__ConfigurationId__c))){
                        lineItemObj.HSFE_Quote_Details_JSON_String__c = ProdConfigJSON_Map.get(cartQuoteMap.get(lineItemObj.Apttus_Config2__ConfigurationId__c));                        
                        if(!String.isEmpty(lineItemObj.HSFE_Quote_Details_JSON_String__c)){
                            ProdConfigRec = HSFE_ProductConfigJson.GetProductJsonRecord(lineItemObj.HSFE_Quote_Details_JSON_String__c);
                        }else{ lineItemObj.addError('Error code 001: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                    }   
                }else{ lineItemObj.addError('Error code 001: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }


                if(lineItemObj.Apttus_Config2__OptionGroupLabel__c != null)
                    lineItemObj.HSFE_Option_Group_Label__c = lineItemObj.Apttus_Config2__OptionGroupLabel__c;

                lineItemObj.HSFE_FIT_Quote_Flag__c = ProdConfigRec.FITQuote == true ? 'True' : 'False';
                
                //If the quote is a deep clone, we need to nullify product condition for all line item and reassign.
                if(ProdConfigRec.DeepClone == True)
                    lineItemObj.Product_Conditions__c = null;
                    

                //add approver for approval of Line item
                lineItemObj.HSFE_Quote_Id__c = ProdConfigRec.ProposalID;
                lineItemObj.HSFE_Approval_AVP_User__c = ProdConfigRec.AVP;
                lineItemObj.HSFE_Approval_GVP_User__c  = ProdConfigRec.GVP;
                lineItemObj.HSFE_Approval_DVP_User__c  = ProdConfigRec.DVP;
                lineItemObj.HSFE_Approval_RSD_RVP_User__c = ProdConfigRec.RSDRVP;
                
                //assign Order type based on the quote type
                lineItemObj.HSFE_Order_Type__c = ProdConfigRec.QuoteOrderType;
                
                //Order Type Condition
                if(lineItemObj.HSFE_Order_Type__c == 'Standard')
                    lineItemObj.HSFE_Room_Number__c = 'Not Applicable';
                else
                    lineItemObj.HSFE_Room_Number__c = '';
                                    
                //FIT Logic. 
                if(lineItemObj.HSFE_FIT_Quote_Flag__c == 'True'){
                
                    lineItemObj.Is_Product_Batched__c = false;
                    lineItemObj.Is_Product_Serialized__c = false;
                    lineItemObj.HSFE_Serial_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                    lineItemObj.HSFE_Invalid_Serial_Number__c = false;
                    lineItemObj.HSFE_In_Correct_Serial_Number__c = false;
                    lineItemObj.HSFE_No_Value_in_Serial_Number__c = false;                              
                    lineItemObj.HSFE_UOM__c = 'EA';
                    lineItemObj.HSFE_UOM_Denominator__c = 1; 
                    
                    //Process Option Products first.
                    if(!String.isEmpty(lineItemObj.Apttus_Config2__OptionId__c)){                    
                        
                        if(Product_PricelistItem_Ids.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c)){

                            if(Product_PricelistItem_Ids.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c) && Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c) != null)
                                lineItemObj.Apttus_Config2__PriceListItemId__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c).id;
                            else{ lineItemObj.addError('Error code 002: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                            if(Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c) != null && (!String.isEmpty(Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c).HSFE_Matrix_Entry_JSON_String__c)))
                                lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c).HSFE_Matrix_Entry_JSON_String__c;
                            else{ lineItemObj.addError('Error code 002: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        }else{ lineItemObj.addError('Error code 002: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                        

                        if(ProductHierarchyLabelMap.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c)){
                            lineItemObj.HSFE_Product_Classification__c = ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__OptionId__c);
                            if(ProductCategoryLabelMap.ContainsKey(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__OptionId__c)))
                                lineItemObj.Apttus_Config2__ClassificationId__c = ProductCategoryLabelMap.get(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__OptionId__c));
                        }
                        
                        if(productClassificationMap.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c)){
                            lineItemObj.HSFE_Product_Classification_Label1__c = productClassificationMap.get(lineItemObj.Apttus_Config2__OptionId__c).HSFE_Category_Hierarchy_Label__c;
                        }                        
                        
                        //Option Product JSON String
                        if(ProductJSON_Map.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c)){                    
                            
                            lineItemObj.HSFE_Product_Details_JSON_String__c = ProductJSON_Map.get(lineItemObj.Apttus_Config2__OptionId__c);
                            if(!String.isEmpty(lineItemObj.HSFE_Product_Details_JSON_String__c))                             
                                ProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Product_Details_JSON_String__c);
                            else{ lineItemObj.addError('Error code 003: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        }else{ lineItemObj.addError('Error code 003: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        //Parent Product JSON String
                        if(ProductJSON_Map.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c)){
                            
                            lineItemObj.HSFE_Parent_Product_Details_JSON_String__c = ProductJSON_Map.get(lineItemObj.Apttus_Config2__ProductId__c);
                            if(!String.isEmpty(lineItemObj.HSFE_Parent_Product_Details_JSON_String__c))                   
                                ParentProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Parent_Product_Details_JSON_String__c);
                            else{ lineItemObj.addError('Error code 004: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        }else{ lineItemObj.addError('Error code 004: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }


                        if(ParentProductRec.IsStocking == true)
                            Is_Stocking_Kit = ParentProductRec.IsStocking;
                            
                        lineItemObj.Is_Product_Batched__c = ProductRec.IsBatch;
                        lineItemObj.Is_Product_Serialized__c = ProductRec.IsSerial;

                        
                        if(lineItemObj.Is_Product_Batched__c == True || lineItemObj.Is_Product_Serialized__c == True)
                            lineItemObj.HSFE_Serial_Number__c = ' ';
                        else{
                            lineItemObj.Is_Product_Batched__c = false;
                            lineItemObj.Is_Product_Serialized__c = false;                            
                            lineItemObj.HSFE_Serial_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                        }             
                    
                        //Assign product condition to Option products which have Option group label as Recommended, Optional, Mandatory, Free goods
                        //If its a kit product assign same as kit value to condtions.
                        if(Is_Stocking_Kit){
                            
                            Is_Kit_In_A_Kit = lineItemObj.HSFE_Is_Kit_In_A_Kit__c;
                            
                            if(lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_RECOMMENDED || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_OPTIONAL || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_MANDATORY || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_FREE_GOODS || Is_Kit_In_A_Kit){                                    
                                if(ParentProductRec.ProductType == HSFE_Constant.COUSTOM_SKP){
                                    lineItemObj.Charge_Type__c = HSFE_Product_Attribute_Charge_Types__c.getValues(ProductRec.chargeType).HSFE_SKP_Charge_Type__c ;
                                }else{
                                    if(ProductRec.chargeType != null)
                                        lineItemObj.Charge_Type__c = ProductRec.chargeType;
                                }                               
                            }else{  
                                lineItemObj.Charge_Type__c = HSFE_Constant.CHARGE_TYPE_KIT_OP;
                                lineItemObj.Product_Conditions__c = HSFE_Constant.NA_STOCKING_KIT;
                            }

                        }else{                    
                            lineItemObj.Charge_Type__c = ProductRec.chargeType;                                           
                        }
                        
                        if(!String.isEmpty(lineItemObj.Charge_Type__c)){
                            if(String.isEmpty(lineItemObj.Product_Conditions__c)){
                                pcondition = HSFE_Utility_Class.constantCategoryMap.get(lineItemObj.Charge_Type__c);
                                if(!String.isEmpty(pcondition)){
                                    lineItemObj.Product_Conditions__c = pcondition;
                                }else{
                                    lineItemObj.Product_Conditions__c = HSFE_Constant.COUSTOM_NEW;
                                }
                            } 
                        }

                        // assign price to option products which have Option group label as Recommended, Optional, Mandatory, Free goods 
                        if(Is_Stocking_Kit){

                            if(lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_RECOMMENDED || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_OPTIONAL || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_MANDATORY || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_FREE_GOODS){
                                
                                if(!String.isEmpty(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c)){
                                    
                                    PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.Product_Conditions__c);
                                    lineItemObj.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                                    lineItemObj.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                                    lineItemObj.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;
                                    
                                    PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.HSFE_UOM__c);
                                    lineItemObj.HSFE_UOM_Denominator__c = PriceMatricRec.AdjustAmount;                     
                                
                                }else{ lineItemObj.addError('Error code 005: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                            
                            }else{
                                lineItemObj.HSFE_Target_Price__c = 0.0;                     
                            }
                        }else{

                            if(!String.isEmpty(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c)){

                                PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.Product_Conditions__c);
                                lineItemObj.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                                lineItemObj.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                                lineItemObj.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;
                                
                                PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.HSFE_UOM__c);
                                lineItemObj.HSFE_UOM_Denominator__c = PriceMatricRec.AdjustAmount;

                            }else{ lineItemObj.addError('Error code 005: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                        }

                    }else if(String.isEmpty(lineItemObj.Apttus_Config2__OptionId__c)){
                    
                        if(ProductJSON_Map.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c)){
                            lineItemObj.HSFE_Product_Details_JSON_String__c = ProductJSON_Map.get(lineItemObj.Apttus_Config2__ProductId__c);
                            if(!String.isEmpty(lineItemObj.HSFE_Product_Details_JSON_String__c)){
                                ProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Product_Details_JSON_String__c);
                            }else{ lineItemObj.addError('Error code 006: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        }else{ lineItemObj.addError('Error code 006: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        
                        if(Product_PricelistItem_Ids.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c) && Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__ProductId__c) != null){                                   
                            lineItemObj.Apttus_Config2__PriceListItemId__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__ProductId__c).id;
                        }else{ lineItemObj.addError('Error code 007: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        
                        if(ProductHierarchyLabelMap.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c)){
                            lineItemObj.HSFE_Product_Classification__c = ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__ProductId__c);                        
                            if(ProductCategoryLabelMap.ContainsKey(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__ProductId__c)))
                                lineItemObj.Apttus_Config2__ClassificationId__c = ProductCategoryLabelMap.get(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__ProductId__c));
                        }

                        if(Product_PricelistItem_Ids.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c) && Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__ProductId__c) != null)
                            lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__ProductId__c).HSFE_Matrix_Entry_JSON_String__c;                    
                        else{ lineItemObj.addError('Error code 008: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        lineItemObj.Charge_Type__c = ProductRec.chargeType;
                        
                        if(productClassificationMap.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c))
                            lineItemObj.HSFE_Product_Classification_Label1__c = productClassificationMap.get(lineItemObj.Apttus_Config2__ProductId__c).HSFE_Category_Hierarchy_Label__c;                    
                                             
                        if(String.isEmpty(lineItemObj.Product_Conditions__c)){
                            pcondition = HSFE_Utility_Class.constantCategoryMap.get(lineItemObj.Charge_Type__c);
                            if(!String.isEmpty(pcondition)){
                                lineItemObj.Product_Conditions__c = pcondition;
                            }else{
                                lineItemObj.Product_Conditions__c = HSFE_Constant.COUSTOM_NEW;
                            }
                        }

                        if(!String.isEmpty(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c)){
                            
                            PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.Product_Conditions__c);
                            lineItemObj.HSFE_Target_Price__c    = PriceMatricRec.TargetPrice;
                            lineItemObj.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                            lineItemObj.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;
                            
                            PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.HSFE_UOM__c);
                            lineItemObj.HSFE_UOM_Denominator__c = PriceMatricRec.AdjustAmount;
                        
                        }else{ lineItemObj.addError('Error code 009: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        lineItemObj.Is_Product_Batched__c = ProductRec.IsBatch;
                        lineItemObj.Is_Product_Serialized__c = ProductRec.IsSerial;
                        
                        if(lineItemObj.Is_Product_Batched__c == True || lineItemObj.Is_Product_Serialized__c == True)
                            lineItemObj.HSFE_Serial_Number__c = ' ';
                        else{
                            lineItemObj.Is_Product_Batched__c = false;
                            lineItemObj.Is_Product_Serialized__c = false;                            
                            lineItemObj.HSFE_Serial_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                        }                                          
                    }            
                    
                //Non FIT Log
                }else{
                    
                    lineItemObj.HSFE_UOM__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                    lineItemObj.HSFE_UOM_Denominator__c = null;
                    lineItemObj.Is_Product_Batched__c = false;
                    lineItemObj.Is_Product_Serialized__c = false;
                    if(lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                        lineItemObj.HSFE_Serial_Number__c = 'Not Applicable';
                    else
                        lineItemObj.HSFE_Serial_Number__c = '';
                    lineItemObj.HSFE_Invalid_Serial_Number__c = false;
                    lineItemObj.HSFE_In_Correct_Serial_Number__c = false;
                    lineItemObj.HSFE_No_Value_in_Serial_Number__c = false;
                                            
                    if(!String.isEmpty(lineItemObj.Apttus_Config2__OptionId__c)){ 
                    
                        if(Product_PricelistItem_Ids.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c) && Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c) != null){
                            
                            lineItemObj.Apttus_Config2__PriceListItemId__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c).id; 
                            
                            if(Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c) != null && (!String.isEmpty(Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c).HSFE_Matrix_Entry_JSON_String__c)))                         
                                lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__OptionId__c).HSFE_Matrix_Entry_JSON_String__c;                    
                            else{ lineItemObj.addError('Error code 010: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        }else{ lineItemObj.addError('Error code 010: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }


                        if(ProductHierarchyLabelMap.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c)){
                            lineItemObj.HSFE_Product_Classification__c = ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__OptionId__c);                                         
                            
                            if(ProductCategoryLabelMap.ContainsKey(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__OptionId__c)))                   
                                lineItemObj.Apttus_Config2__ClassificationId__c = ProductCategoryLabelMap.get(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__OptionId__c));                   
                        }
                        
                        if(productClassificationMap.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c))
                            lineItemObj.HSFE_Product_Classification_Label1__c = productClassificationMap.get(lineItemObj.Apttus_Config2__OptionId__c).HSFE_Category_Hierarchy_Label__c;
                        
                        if(ProductJSON_Map.ContainsKey(lineItemObj.Apttus_Config2__OptionId__c)){
                            
                            lineItemObj.HSFE_Product_Details_JSON_String__c = ProductJSON_Map.get(lineItemObj.Apttus_Config2__OptionId__c);

                            if(!String.isEmpty(lineItemObj.HSFE_Product_Details_JSON_String__c))
                                ProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Product_Details_JSON_String__c);
                            else{ lineItemObj.addError('Error code 011: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                                                               
                        }else{ lineItemObj.addError('Error code 011: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        if(ProductJSON_Map.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c)){
                            
                            lineItemObj.HSFE_Parent_Product_Details_JSON_String__c = ProductJSON_Map.get(lineItemObj.Apttus_Config2__ProductId__c);
                            
                            if(!String.isEmpty(lineItemObj.HSFE_Parent_Product_Details_JSON_String__c)){                                        
                                ParentProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Parent_Product_Details_JSON_String__c);
                            }else{ lineItemObj.addError('Error code 012: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                                                                   
                        }else{ lineItemObj.addError('Error code 012: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        if(ParentProductRec.IsStocking == true)
                            Is_Stocking_Kit = ParentProductRec.IsStocking;
                    
                        if(Is_Stocking_Kit){
                            Is_Kit_In_A_Kit = lineItemObj.HSFE_Is_Kit_In_A_Kit__c;

                            if(lineItemObj.Apttus_Config2__OptionGroupLabel__c != null)
                                lineItemObj.HSFE_Option_Group_Label__c = lineItemObj.Apttus_Config2__OptionGroupLabel__c;

                            if(lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_RECOMMENDED || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_OPTIONAL || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_MANDATORY || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_FREE_GOODS || Is_Kit_In_A_Kit){
                                    
                                if(ParentProductRec.ProductType == HSFE_Constant.COUSTOM_SKP){
                                    lineItemObj.Charge_Type__c = HSFE_Product_Attribute_Charge_Types__c.getValues(ProductRec.chargeType).HSFE_SKP_Charge_Type__c ;
                                }else{
                                    if(ProductRec.chargeType != null)
                                        lineItemObj.Charge_Type__c = ProductRec.chargeType;
                                }                               
                            }else{  
                                lineItemObj.Charge_Type__c = HSFE_Constant.CHARGE_TYPE_KIT_OP;
                                lineItemObj.Product_Conditions__c = HSFE_Constant.NA_STOCKING_KIT;
                            }
                        }else{                    
                            lineItemObj.Charge_Type__c = ProductRec.chargeType;                                           
                        }
                        
                        if(!String.isEmpty(lineItemObj.Charge_Type__c)){
                            if(String.isEmpty(lineItemObj.Product_Conditions__c)){
                                pcondition = HSFE_Utility_Class.constantCategoryMap.get(lineItemObj.Charge_Type__c);
                                if(!String.isEmpty(pcondition)){
                                    lineItemObj.Product_Conditions__c = pcondition;
                                }else{
                                    lineItemObj.Product_Conditions__c = HSFE_Constant.COUSTOM_NEW;
                                }
                            } 
                        }

                        if(Is_Stocking_Kit){

                            if(lineItemObj.Apttus_Config2__OptionGroupLabel__c != null)
                                lineItemObj.HSFE_Option_Group_Label__c = lineItemObj.Apttus_Config2__OptionGroupLabel__c;

                            if(lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_RECOMMENDED || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_OPTIONAL || lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_MANDATORY ||lineItemObj.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_FREE_GOODS){
                                
                                if(!String.isEmpty(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c)){
                                    PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.Product_Conditions__c);
                                    lineItemObj.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                                    lineItemObj.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                                    lineItemObj.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;  
                                }else{ lineItemObj.addError('Error code 013: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                            
                            }else{
                                lineItemObj.HSFE_Target_Price__c = 0.0;                     
                            }
                        }else{

                            if(!String.isEmpty(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c)){
                                PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.Product_Conditions__c);
                                lineItemObj.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                                lineItemObj.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                                lineItemObj.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;
                            }else{ lineItemObj.addError('Error code 013: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                        }
                            
                        
                    }else if(String.isEmpty(lineItemObj.Apttus_Config2__OptionId__c)){
                    
                        if(ProductJSON_Map.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c)){
                            lineItemObj.HSFE_Product_Details_JSON_String__c = ProductJSON_Map.get(lineItemObj.Apttus_Config2__ProductId__c);
                            if(!String.isEmpty(lineItemObj.HSFE_Product_Details_JSON_String__c)){
                                ProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Product_Details_JSON_String__c);
                            }else{ lineItemObj.addError('Error code 014: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        }else{ lineItemObj.addError('Error code 014: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }                   
                                            
                        if(Product_PricelistItem_Ids.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c) && Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__ProductId__c) != null){
                            
                            lineItemObj.Apttus_Config2__PriceListItemId__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__ProductId__c).id;
                            lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c = Product_PricelistItem_Ids.get(lineItemObj.Apttus_Config2__ProductId__c).HSFE_Matrix_Entry_JSON_String__c;
                        
                        }else{ lineItemObj.addError('Error code 015: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                        if(ProductHierarchyLabelMap.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c)){
                            lineItemObj.HSFE_Product_Classification__c = ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__ProductId__c);                        
                            if(ProductCategoryLabelMap.ContainsKey(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__ProductId__c)))
                                lineItemObj.Apttus_Config2__ClassificationId__c = ProductCategoryLabelMap.get(ProductHierarchyLabelMap.get(lineItemObj.Apttus_Config2__ProductId__c));
                        }

                        if(productClassificationMap.ContainsKey(lineItemObj.Apttus_Config2__ProductId__c))
                            lineItemObj.HSFE_Product_Classification_Label1__c = productClassificationMap.get(lineItemObj.Apttus_Config2__ProductId__c).HSFE_Category_Hierarchy_Label__c;                    
                        
                        lineItemObj.Charge_Type__c = ProductRec.chargeType;
                        
                        if(String.isEmpty(lineItemObj.Product_Conditions__c)){
                            pcondition = HSFE_Utility_Class.constantCategoryMap.get(lineItemObj.Charge_Type__c);
                            if(!String.isEmpty(pcondition)){
                                lineItemObj.Product_Conditions__c = pcondition;
                            }else{
                                lineItemObj.Product_Conditions__c = HSFE_Constant.COUSTOM_NEW;
                            }
                        }
                        
                        if(!String.isEmpty(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c)){
                            PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c,lineItemObj.Product_Conditions__c);
                            lineItemObj.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                            lineItemObj.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                            lineItemObj.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;   
                        }else{ lineItemObj.addError('Error code 016: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }               
                    }
                }

                if(!String.isEmpty(lineItemObj.HSFE_Product_Details_JSON_String__c))                             
                    ProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Product_Details_JSON_String__c);
                else{ lineItemObj.addError('Error code 020: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                
                //Modify Adjustments based on product condition
                if(HSFE_Constant.CUSTOM_SKIP_ADJUSTMENT.contains(lineItemObj.Product_Conditions__c) || HSFE_Constant.COUSTOM_PKP == ProductRec.ProductType ){
                    lineItemObj.Apttus_Config2__AllowManualAdjustment__c = false;
                    lineItemObj.Apttus_Config2__AdjustmentType__c = null;
                    lineItemObj.Apttus_Config2__AdjustmentAmount__c = null;
                }else if(HSFE_Constant.NA_STOCKING_KIT != lineItemObj.Product_Conditions__c && !HSFE_Constant.CUSTOM_SKIP_ADJUSTMENT.contains(lineItemObj.Product_Conditions__c) && HSFE_Constant.COUSTOM_PKP != ProductRec.ProductType ){
                    lineItemObj.Apttus_Config2__AllowManualAdjustment__c = true;
                    lineItemObj.Apttus_Config2__AllocateGroupAdjustment__c = true;                
                }           
                
                //To show highest approver level on the cart
                lineItemObj.HSFE_Approver_Level__c = '';
                if(lineItemObj.HSFE_Child_Product_Stocking_or_Promo_Kit__c == FALSE){
                    if(lineItemObj.HSFE_Target_Price__c  == 0  ||  lineItemObj.HSFE_List_Price_Below_Floor_Price__c == TRUE || lineItemObj.HSFE_Total_Unit_Price_Below_Floor_Price__c == TRUE){
                        lineItemObj.HSFE_Approver_Level__c = HSFE_Constant.GVP;
                    }
                    else if(lineItemObj.HSFE_Discount_FROM_Threshold_Condition__c == TRUE ){
                        if(lineItemObj.HSFE_Discount_FROM_Threshold__c > 26){
                            lineItemObj.HSFE_Approver_Level__c = HSFE_Constant.GVP;
                        }else if(lineItemObj.HSFE_Discount_FROM_Threshold__c > 16){
                            lineItemObj.HSFE_Approver_Level__c = HSFE_Constant.DVP;
                        }else if(lineItemObj.HSFE_Discount_FROM_Threshold__c > 8){
                            lineItemObj.HSFE_Approver_Level__c = HSFE_Constant.AVP;
                        }else if(lineItemObj.HSFE_Discount_FROM_Threshold__c > 0){
                            lineItemObj.HSFE_Approver_Level__c = HSFE_Constant.RVP;
                        }
                    }else if(lineItemObj.HSFE_Contract_Price_Deviation__c == TRUE){
                        lineItemObj.HSFE_Approver_Level__c = HSFE_Constant.RVP;
                    }
                }            
            }
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception.
        }
    }
    
    public static void BeforeUpdate(List<Apttus_Config2__LineItem__c> itemList, Map<Id,Apttus_Config2__LineItem__c> oldItemMap) {
        
        try{
                        
            set<Id> cartLst = new Set <Id>();
            set<Id> ProductIds = new Set<Id>();
            map<id,String> PriceListItemJSON_Map = new map<id,String>();

            Double price;
            
            //JSON Variables
            JSONGenerator generator;
            string Temp_Var ;       
            String MatrixRecSTR;        
            HSFE_ProductJson ProductRec;
            HSFE_ProductJson ParentProductRec;      
            HSFE_ProductConfigJson ProdConfigRec;
            HSFE_PriceMatxEntryJson PriceMatricRec; 
            
            //---------------------------------------------------Integration Start---------------------------------------------------------
            
            for(Apttus_Config2__LineItem__c newItem : itemList){
                            
                Apttus_Config2__LineItem__c oldItem  = oldItemMap.get(newItem.Id);

                //Added by - Yunus  Description: When quote is in Draft, We have to update Matric on line item to get the latest values
                if(newItem.Apttus_Config2__PriceListItemId__c != null && (newItem.HSFE_Quote_Status__c == 'Draft' || newItem.HSFE_Quote_Status__c == 'Approval Required'))
                    PriceListItemJSON_Map.put(newItem.Apttus_Config2__PriceListItemId__c,'');
                // Contract Pricing details Update Logic : So That Mulesoft will only update the Pricing details in Case of SAP response during Adding Line Item.
                
                if(!String.isEmpty(newItem.HSFE_Product_Details_JSON_String__c))                             
                    ProductRec = HSFE_ProductJson.GetProductJsonRecord(newItem.HSFE_Product_Details_JSON_String__c);
                else{ newItem.addError('Error code 019: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

                if (newItem.HSFE_Contract_Price__c != oldItem.HSFE_Contract_Price__c || newItem.HSFE_GSA_Price__c != oldItem.HSFE_GSA_Price__c || newItem.HSFE_Freight_Terms__c != oldItem.HSFE_Freight_Terms__c || newItem.HSFE_Inco_Terms__c != oldItem.HSFE_Inco_Terms__c || newItem.HSFE_Contract_Code__c != oldItem.HSFE_Contract_Code__c || newItem.HSFE_Contract_Integration_Status__c != oldItem.HSFE_Contract_Integration_Status__c){
                    if(!newItem.HSFE_Admin_Update_Flag__c){
                         newItem.HSFE_Contract_Price__c = oldItem.HSFE_Contract_Price__c;
                         newItem.HSFE_GSA_Price__c = oldItem.HSFE_GSA_Price__c;
                         newItem.HSFE_Freight_Terms__c = oldItem.HSFE_Freight_Terms__c;
                         newItem.HSFE_Inco_Terms__c =   oldItem.HSFE_Inco_Terms__c;
                         newItem.HSFE_Contract_Code__c = oldItem.HSFE_Contract_Code__c;
                         newItem.HSFE_Contract_Integration_Status__c = oldItem.HSFE_Contract_Integration_Status__c;
                    }else{                                                               // Not Required
                        newItem.HSFE_Admin_Update_Flag__c = false;
                    }
                }
                // End Contract Pricing details Update Logic : So That Mulesoft will only update the Pricing details in Case of SAP response during Adding Line Item.
                 // Freight Charges Before Update Logic : Avoid Concurrency
                if (newItem.HSFE_Freight_Charges__c != oldItem.HSFE_Freight_Charges__c || 
                        newItem.HSFE_Freight_Integration_Status__c != oldItem.HSFE_Freight_Integration_Status__c){
                     if(!newItem.HSFE_Admin_Update_Flag__c){
                         newItem.HSFE_Freight_Charges__c = oldItem.HSFE_Freight_Charges__c;
                         newItem.HSFE_Freight_Integration_Status__c = oldItem.HSFE_Freight_Integration_Status__c;
                     }
                }
                newItem.HSFE_Admin_Update_Flag__c = false;
                // End Freight Charges
                if(HSFE_Constant.CUSTOM_SKIP_ADJUSTMENT.contains(newItem.Product_Conditions__c) || ProductRec.ProductType == HSFE_Constant.COUSTOM_PKP){
                    newItem.Apttus_Config2__AllowManualAdjustment__c = false;                    
                    if(HSFE_Constant.CUSTOM_SKIP_ADJUSTMENT.contains(newItem.Product_Conditions__c) && newItem.Product_Conditions__c == HSFE_Constant.COUSTOM_USED){}
                        newItem.Apttus_Config2__AllocateGroupAdjustment__c = false;
                }else if(HSFE_Constant.NA_STOCKING_KIT != newItem.Product_Conditions__c && !HSFE_Constant.CUSTOM_SKIP_ADJUSTMENT.contains(newItem.Product_Conditions__c) && ProductRec.ProductType != HSFE_Constant.COUSTOM_PKP){
                    newItem.Apttus_Config2__AllowManualAdjustment__c = true;
                    newItem.Apttus_Config2__AllocateGroupAdjustment__c = true;
                }
                // Code for updating integration status
                if(newItem.HSFE_Product_Part_Number__c != null && newItem.HSFE_Product_Part_Number__c != HSFE_Constant.NOT_IN_SAP && newItem.Apttus_Config2__BasePrice__c > 0){
                    if((newItem.Product_Conditions__c !=  oldItem.Product_Conditions__c || newItem.HSFE_Product_Part_Number__c !=  oldItem.HSFE_Product_Part_Number__c || newItem.Apttus_Config2__BasePrice__c !=  oldItem.Apttus_Config2__BasePrice__c) || newItem.HSFE_Contract_Price_Request_Flag__c){
                        newItem.HSFE_Contract_Integration_Status__c = HSFE_Constant.SENT_TO_SAP;  // Resetting the Integration Status
                        //newItem.HSFE_Contract_Price_Request_Flag__c = false;       //Resetting the flag
                        newItem.HSFE_Contract_Price__c = 0;
                        //Freight Charges
                        newItem.HSFE_Freight_Charges__c = 0;
                        newItem.HSFE_Freight_Integration_Status__c = HSFE_Constant.NOT_SYNCED;
                    }
                }else{
                    newItem.HSFE_Contract_Integration_Status__c = HSFE_Constant.NOT_IN_SAP;
                    newItem.HSFE_Contract_Price__c = 0;
                    //Freight Charges
                    newItem.HSFE_Freight_Charges__c = 0;
                    newItem.HSFE_Freight_Integration_Status__c = HSFE_Constant.NOT_IN_SAP;
                }
                //End Code for updating integration status               
                
                
                //To show highest approver level on the cart
                newItem.HSFE_Approver_Level__c = '';
                if(newItem.HSFE_Child_Product_Stocking_or_Promo_Kit__c == FALSE){
                    if(newItem.HSFE_Target_Price__c  == 0  ||  newItem.HSFE_List_Price_Below_Floor_Price__c == TRUE || newItem.HSFE_Total_Unit_Price_Below_Floor_Price__c == TRUE){
                        newItem.HSFE_Approver_Level__c = HSFE_Constant.GVP;
                    }
                    else if(newItem.HSFE_Discount_from_Threshold_Condition__c == TRUE ){
                        if(newItem.HSFE_Discount_from_Threshold__c > 26){
                            newItem.HSFE_Approver_Level__c = HSFE_Constant.GVP;
                        }else if(newItem.HSFE_Discount_from_Threshold__c > 16){
                            newItem.HSFE_Approver_Level__c = HSFE_Constant.DVP;
                        }else if(newItem.HSFE_Discount_from_Threshold__c > 8){
                            newItem.HSFE_Approver_Level__c = HSFE_Constant.AVP;
                        }else if(newItem.HSFE_Discount_from_Threshold__c > 0){
                            newItem.HSFE_Approver_Level__c = HSFE_Constant.RVP;
                        }
                    }else if(newItem.HSFE_Contract_Price_Deviation__c == TRUE){
                        newItem.HSFE_Approver_Level__c = HSFE_Constant.RVP;
                    }
                }                   
            }

            if(!PriceListItemJSON_Map.isEmpty())
            for(Apttus_Config2__PriceListItem__c PriceListItemRec: [ SELECT id,HSFE_Matrix_Entry_JSON_String__c 
                                                                     FROM Apttus_Config2__PriceListItem__c 
                                                                     WHERE id in: PriceListItemJSON_Map.keySet()]){                
                if(PriceListItemJSON_Map.containsKey(PriceListItemRec.id)){
                    PriceListItemJSON_Map.put(PriceListItemRec.id,PriceListItemRec.HSFE_Matrix_Entry_JSON_String__c);
                }
            }
            System.debug('-------------------PriceListItemJSON_Map------------------->'+PriceListItemJSON_Map);

           //---------------------------------------------------Integration End---------------------------------------------------------
           
            //Operations:          
            //1. Approval User Assignment
            //2. FIT Logic
            //3. UOM Logic
            //4. Room number Logic
            //5. Serial number and Batch Number logic
            for (Apttus_Config2__LineItem__c lineItemObj : itemList) {
                
                //Assigning Approver from product config
                if(!String.isEmpty(lineItemObj.HSFE_Quote_Details_JSON_String__c)){
                    ProdConfigRec = HSFE_ProductConfigJson.GetProductJsonRecord(lineItemObj.HSFE_Quote_Details_JSON_String__c);
                }else{ lineItemObj.addError('Error code 017: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; } 



                lineItemObj.HSFE_Approval_AVP_User__c = ProdConfigRec.AVP;
                lineItemObj.HSFE_Approval_GVP_User__c = ProdConfigRec.GVP;
                lineItemObj.HSFE_Approval_DVP_User__c = ProdConfigRec.DVP; 
                lineItemObj.HSFE_Approval_RSD_RVP_User__c = ProdConfigRec.RSDRVP;
                                    
                lineItemObj.HSFE_FIT_Quote_Flag__c = ProdConfigRec.FITQuote == true ? 'True' : 'False';
                                                               
                //Update Order Type on Line Item - Order Type Logic - 
                //Order type and Room number fields             
                lineItemObj.HSFE_Order_Type__c = ProdConfigRec.QuoteOrderType;                                

                if(lineItemObj.HSFE_Order_Type__c != oldItemMap.get(lineItemObj.id).HSFE_Order_Type__c){
                    if(lineItemObj.HSFE_Order_Type__c == 'Standard'){
                           lineItemObj.HSFE_Room_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                    }else if(oldItemMap.get(lineItemObj.Id).HSFE_Order_Type__c != lineItemObj.HSFE_Order_Type__c && lineItemObj.HSFE_Order_Type__c == 'Integration'){
                        lineItemObj.HSFE_Room_Number__c = '';
                    }

                } 
                if(lineItemObj.HSFE_Order_Type__c == 'Standard')
                    lineItemObj.HSFE_Room_Number__c = 'Not Applicable';              

                //Update Batch and Serial flag on Line Item
                //HSFE_FIT_Quote_Flag__c, Is_Product_Batched__c, HSFE_Batch_Number__c, Apttus_Config2__Quantity__c
                //Is_Product_Serialized__c and HSFE_Serial_Number__c fields
                //Update FIT on Line Item - FIT Quote Logic - 
                //UOM and Denominator fields
                if(lineItemObj.HSFE_FIT_Quote_Flag__c != oldItemMap.get(lineItemObj.id).HSFE_FIT_Quote_Flag__c){

                    if(lineItemObj.HSFE_FIT_Quote_Flag__c == 'True'){
                    
                        //Only if Quote is changed from Non-FIT to FIT
                        if(oldItemMap.get(lineItemObj.Id).HSFE_FIT_Quote_Flag__c != lineItemObj.HSFE_FIT_Quote_Flag__c){
                            lineItemObj.HSFE_UOM__c = 'EA';
                        }

                        if(lineItemObj.HSFE_Serial_Number__c == HSFE_Constant.COUSTOM_NOT_APPLICABLE && lineItemObj.HSFE_FIT_Quote_Flag__c == 'True'){
                            lineItemObj.HSFE_Serial_Number__c = '';                     
                        }                   
                        
                        //Populate Is_Serial and Is Batch flags for Option Product.
                        if(!String.isEmpty(lineItemObj.Apttus_Config2__OptionId__c)){                       
                            
                            ProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Product_Details_JSON_String__c);
                            
                            if(ProductRec.IsBatch == true)
                                lineItemObj.Is_Product_Batched__c = true;
                            else
                                lineItemObj.Is_Product_Batched__c = false;                                  
                            
                            if(ProductRec.IsSerial == true)
                                lineItemObj.Is_Product_Serialized__c = true;
                            else
                                lineItemObj.Is_Product_Serialized__c = false;                           
                        
                        }else if(String.isEmpty(lineItemObj.Apttus_Config2__OptionId__c)){

                            ProductRec = HSFE_ProductJson.GetProductJsonRecord(lineItemObj.HSFE_Product_Details_JSON_String__c);

                            if(ProductRec.IsBatch == true)
                                lineItemObj.Is_Product_Batched__c = true;
                            else
                                lineItemObj.Is_Product_Batched__c = false;                                  
                            
                            if(ProductRec.IsSerial)
                                lineItemObj.Is_Product_Serialized__c = true;
                            else
                                lineItemObj.Is_Product_Serialized__c = false;                           
                        }                       
                  
                        if(lineItemObj.Is_Product_Batched__c == False && lineItemObj.Is_Product_Serialized__c == False){
                        
                            if(lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                                lineItemObj.HSFE_Serial_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                            else if(lineItemObj.Product_Conditions__c != oldItemMap.get(lineItemObj.Id).Product_Conditions__c && lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR || lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                                lineItemObj.HSFE_Serial_Number__c = ' ';
                        
                        }else if(oldItemMap.get(lineItemObj.Id).Is_Product_Serialized__c != lineItemObj.Is_Product_Serialized__c && lineItemObj.Is_Product_Serialized__c == True && lineItemObj.Is_Product_Batched__c == False){                    
                            
                            lineItemObj.Apttus_Config2__Quantity__c = 1;
                            lineItemObj.HSFE_Serial_Number__c = ''; 
                            
                        }else if(oldItemMap.get(lineItemObj.Id).Is_Product_Batched__c == lineItemObj.Is_Product_Batched__c && lineItemObj.Is_Product_Batched__c == True && lineItemObj.Is_Product_Serialized__c == False){
                            
                            lineItemObj.HSFE_Serial_Number__c = ''; 
                            
                        }                    
                        
                    //If product is NON-FIT
                    //Assign UOM = Not Applicable, Denominator = null
                    //Assign Is Product Batched and Is Product Serialized to false
                    //Assign Batch number and Serial number to Not Applicable            
                    }else if(lineItemObj.HSFE_FIT_Quote_Flag__c == 'False'){
                        lineItemObj.HSFE_UOM__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE; 
                        lineItemObj.HSFE_UOM_Denominator__c = null;             
                        lineItemObj.Is_Product_Batched__c = false;
                        lineItemObj.Is_Product_Serialized__c = false;
                        
                        if(lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                            lineItemObj.HSFE_Serial_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                        else if(lineItemObj.Product_Conditions__c != oldItemMap.get(lineItemObj.Id).Product_Conditions__c && lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR || lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                            if(String.isEmpty(lineItemObj.HSFE_Serial_Number__c))
                                lineItemObj.HSFE_Serial_Number__c = '';                  
                    }
                }else{
                    //issue no #2
                    if(lineItemObj.HSFE_FIT_Quote_Flag__c == 'True'){
                        if(lineItemObj.Is_Product_Batched__c == False && lineItemObj.Is_Product_Serialized__c == False){
                            if(lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                                lineItemObj.HSFE_Serial_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                            else if(lineItemObj.Product_Conditions__c != oldItemMap.get(lineItemObj.Id).Product_Conditions__c && lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR || lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                                lineItemObj.HSFE_Serial_Number__c = ' ';
                        }
                    }else{
                        lineItemObj.HSFE_UOM__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE; 
                        lineItemObj.HSFE_UOM_Denominator__c = null;             
                        lineItemObj.Is_Product_Batched__c = false;
                        lineItemObj.Is_Product_Serialized__c = false;
                        
                        if(lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && lineItemObj.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS){
                            lineItemObj.HSFE_Serial_Number__c = HSFE_Constant.COUSTOM_NOT_APPLICABLE;
                        }else if(lineItemObj.Product_Conditions__c != oldItemMap.get(lineItemObj.Id).Product_Conditions__c && String.isEmpty(lineItemObj.HSFE_Serial_Number__c) &&(lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR || lineItemObj.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS)){
                            lineItemObj.HSFE_Serial_Number__c = '';
                        }
                    }    
                }

                if(lineItemObj.Product_Conditions__c != oldItemMap.get(lineItemObj.id).Product_Conditions__c)
                    lineItemObj.HSFE_Condition_Modified__c = true;
                else{
                    lineItemObj.HSFE_Condition_Modified__c = false;
                }
                if(!PriceListItemJSON_Map.isEmpty()){
                    if(PriceListItemJSON_Map.ContainsKey(lineItemObj.Apttus_Config2__PriceListItemId__c)){
                        lineItemObj.HSFE_Condition_Modified__c = true;
                        lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c = PriceListItemJSON_Map.get(lineItemObj.Apttus_Config2__PriceListItemId__c);
                        if(String.isEmpty(lineItemObj.HSFE_Price_Matrix_Details_JSON_String__c)){
                            lineItemObj.addError('Error code 018: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue;                         
                        }
                    }else{ lineItemObj.addError('Error code 018: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }
                }                    
            }                                                           
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }
    }



    /************************************************************************************************************
     * Method Name: updateIntegrationStatus_AfterUpdate
     * Description: Update the Integration Status on Quote/Proposal on the basis of Line Item Integration Status
     *              changed by MuleSoft for Contract Pricing.
     * Return Type: None.
     * NOTE:: Need to Verify - Preteek to confirm - Added by Yunus/Gaurav
     ************************************************************************************************************/
    public static void updateIntegrationStatus_AfterUpdate(List<Apttus_Config2__LineItem__c> itemList, Map<Id,Apttus_Config2__LineItem__c> oldItemMap){
        //System.debug('@@@ **************** In Updating Integration Status' + itemList);
        try {
            //if(HSFE_Utility_Class.alreadyExecutedCPTrigger){
            //    return;
            //}
            Map<Id,String> LineItemIdAndConditionMap = new Map<Id,String>();
            Set<Id> prodConfigIdSet = new Set<Id>();
            List<Apttus_Config2__LineItem__c> lstLineItems  = new List<Apttus_Config2__LineItem__c>();
            Apttus_Config2__LineItem__c oldItem;
            List<HSFE_Line_Item_Extension__c> extensionList = new List<HSFE_Line_Item_Extension__c>();
            HSFE_Line_Item_Extension__c extensionObj;
            boolean addToList = false;
            for(Apttus_Config2__LineItem__c newItem : itemList){
                addToList = false;
                oldItem = oldItemMap.get(newItem.Id);
                extensionObj = new HSFE_Line_Item_Extension__c(Id = newItem.HSFE_Line_Item_Extension__c);
                if(newItem.HSFE_Product_Part_Number__c != null && newItem.Apttus_Config2__BasePrice__c > 0 && 
                    newItem.HSFE_Account_SAP_Id__c != null){
                    if((newItem.Product_Conditions__c !=  oldItem.Product_Conditions__c || 
                        newItem.HSFE_Product_Part_Number__c !=  oldItem.HSFE_Product_Part_Number__c || 
                        newItem.Apttus_Config2__BasePrice__c !=  oldItem.Apttus_Config2__BasePrice__c || 
                        newItem.HSFE_Contract_Price_Request_Flag__c)){
                            LineItemIdAndConditionMap.put(newItem.Id, newItem.Product_Conditions__c);
                            extensionObj.HSFE_Contract_Integration_Status__c = HSFE_Constant.SENT_TO_SAP;
                            extensionObj.HSFE_Contract_Price_Request_Flag__c = false;
                            addToList = true;
                    }
                }else{
                    if(newItem.Contract_Integration_Status1__c != HSFE_Constant.NOT_IN_SAP){
                        extensionObj.HSFE_Contract_Integration_Status__c = HSFE_Constant.NOT_IN_SAP;
                        addToList = true;
                    }
                }
                //Sourav 08032015 Added code to update freight Integration status to not Synched as part of Change to make submit for approval button read only when freight charges are not received
                if(newItem.HSFE_Product_Part_Number__c != null && newItem.HSFE_Account_SAP_Id__c != null){
                    if(newItem.Apttus_Config2__Quantity__c !=  oldItem.Apttus_Config2__Quantity__c){
                            LineItemIdAndConditionMap.put(newItem.Id, newItem.Product_Conditions__c);
                            extensionObj.HSFE_Freight_Integration_Status__c = HSFE_Constant.NOT_SYNCED;
                            addToList = true;
                    }
                }else{
                    if(newItem.HSFE_Freight_Integration_Status1__c != HSFE_Constant.NOT_IN_SAP){
                        extensionObj.HSFE_Freight_Integration_Status__c = HSFE_Constant.NOT_IN_SAP;
                        addToList = true;
                    }
                }
                
                /***************************************[DIVYA 05/08/2015]*******************************************************/
                system.debug('newItem.Product_Conditions__c --> '+newItem.Product_Conditions__c + '  newItem.HSFE_Serial_Check__c --> '+newItem.HSFE_Serial_Check__c + '  newItem.HSFE_Serial_Number__c --> '+newItem.HSFE_Serial_Number__c);
               // IF(newItem.Product_Conditions__c !=  oldItem.Product_Conditions__c){ there might be a situation where user has put wrong serial number and want to revalidate it
                if(((newItem.Product_Conditions__c != oldItem.Product_Conditions__c) || (newItem.HSFE_Serial_Number__c != oldItem.HSFE_Serial_Number__c)) &&  newItem.HSFE_Account_SAP_Id__c != null && newItem.HSFE_Serial_Number__c!='Not Applicable'){
                    if(newItem.Product_Conditions__c =='Trade-In - Olympus'){
                        if(newItem.HSFE_Serial_Check__c!=FALSE){
                            extensionObj.HSFE_Is_Serial_Valid__c= FALSE;
                            addToList = true; 
                        }
                        if(!String.isEmpty(newItem.HSFE_Serial_Number__c)){
                            lstLineItems.add(newItem);
                        }
                    }
                }
                system.debug('%%%%%%%%%%%%%%%%%%%5'+lstLineItems.size());
                /****************************************[DIVYA 05/08/2015] Code Ends*********************************************/
                //End Sourav 08032015 Added code 
                if(addToList){
                    extensionList.add(extensionObj);
                }
            }
            if (!extensionList.isEmpty()){
                update extensionList;
            }
            //START Integration call
             if (LineItemIdAndConditionMap.size() > 0){   // lineItemToCallIdSet.size()
                // Gathering data for each Line Item updated with Product Condition.
                List<Apttus_Config2__LineItem__c> lineItems = new List<Apttus_Config2__LineItem__c>();
                lineItems = [Select 
                                Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c,
                                Product_Conditions__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id,
                                Apttus_Config2__BasePrice__c, HSFE_Product_Part_Number__c, HSFE_Line_Item_Extension__c
                            from Apttus_Config2__LineItem__c
                            where 
                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c != null and 
                                Apttus_Config2__BasePrice__c != null and HSFE_Product_Part_Number__c != null and 
                                Id IN :LineItemIdAndConditionMap.keySet()];

                if (lineItems  != null && !lineItems.isEmpty()){
                    String JSONRequestData = HSFE_Utility_Class.serializeListToJSON(lineItems, HSFE_Constant.CONTRACT_PRICING); // JSON Request Data
                    HSFE_IntegrateMuleSoftWebservice_Class.GetContractPriceForLineItem(JSONRequestData);    // WebService Call : @Future Call
                }
            }
            //END Integration call
/*****************************************[DIVYA 05 Aug]***********************BEGIN SERIAL NUM INtegration Call******************************/
            if(lstLineItems!= NULL && lstLineItems .size()>0){
                List<Apttus_Config2__LineItem__c> lineItemsSerialList = new List<Apttus_Config2__LineItem__c>();
                lineItemsSerialList = [Select 
                            Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c,
                            Product_Conditions__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id,
                            Apttus_Config2__BasePrice__c, HSFE_Product_Part_Number__c, HSFE_Line_Item_Extension__c ,HSFE_Serial_Number__c
                        from Apttus_Config2__LineItem__c
                        where 
                            Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c != null and 
                            Apttus_Config2__BasePrice__c != null and HSFE_Product_Part_Number__c != null and 
                            Id IN :lstLineItems];
                String JSONRequestData = HSFE_Utility_Class.serializeListToJSONSerNumCheck(lineItemsSerialList , HSFE_Constant.SERIAL_NUM_CHECK); 
                HSFE_IntegrateMuleSoftWebservice_Class.SerialNumberCheckForLineItem(JSONRequestData); 
            }
/***************************************Divya: Code Ends*************************************************************************************/
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception.
        }
    }



     /************************************************************************************************************
     * Method Name: updateIntegrationStatus_AfterInsert
     * Description: Update the Integration Status on Quote/Proposal on the basis of Line Item Integration Status
     *              changed by MuleSoft for Contract Pricing.
     * Return Type: None.
     ************************************************************************************************************/
    public static void updateIntegrationStatus_AfterInsert(List<Apttus_Config2__LineItem__c> itemList){
        try {
            Map<Id,String> LineItemIdAndConditionMap = new Map<Id,String>();
            Set<Id> prodConfigIdSet = new Set<Id>();
            Apttus_Config2__LineItem__c oldItem;
            List<HSFE_Line_Item_Extension__c> extensionList = new List<HSFE_Line_Item_Extension__c>();
            HSFE_Line_Item_Extension__c extensionObj;
            for(Apttus_Config2__LineItem__c newItem : itemList){

                extensionObj = new HSFE_Line_Item_Extension__c(Id = newItem.HSFE_Line_Item_Extension__c);
                if (newItem.HSFE_Contract_Price_Request_Flag__c){
                    if(newItem.HSFE_Product_Part_Number__c != null && newItem.Apttus_Config2__BasePrice__c > 0 &&
                          newItem.Product_Conditions__c != null && newItem.HSFE_Account_SAP_Id__c != null){
                        LineItemIdAndConditionMap.put(newItem.Id, newItem.Product_Conditions__c);
                        extensionObj.HSFE_Contract_Integration_Status__c = HSFE_Constant.SENT_TO_SAP;
                        extensionObj.HSFE_Contract_Price_Request_Flag__c = false;
                        extensionList.add(extensionObj);
                    }else{
                        extensionObj.HSFE_Contract_Integration_Status__c = HSFE_Constant.NOT_IN_SAP;
                        extensionList.add(extensionObj);
                    }
                }
            }
            if (!extensionList.isEmpty()){
                update extensionList;
            }
            //START Integration call
             if (LineItemIdAndConditionMap.size() > 0){   // lineItemToCallIdSet.size()
                // Gathering data for each Line Item updated with Product Condition.
                List<Apttus_Config2__LineItem__c> lineItems = new List<Apttus_Config2__LineItem__c>();
                lineItems = [Select 
                                Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c,
                                Product_Conditions__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id,
                                Apttus_Config2__BasePrice__c, HSFE_Product_Part_Number__c, HSFE_Line_Item_Extension__c   
                            from Apttus_Config2__LineItem__c
                            where 
                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c != null and 
                                Apttus_Config2__BasePrice__c != null and HSFE_Product_Part_Number__c != null and 
                                Id IN :LineItemIdAndConditionMap.keySet()];
                if (null != lineItems && !lineItems.isEmpty()){
                    String JSONRequestData = HSFE_Utility_Class.serializeListToJSON(lineItems, HSFE_Constant.CONTRACT_PRICING); // JSON Request Data
                    HSFE_IntegrateMuleSoftWebservice_Class.GetContractPriceForLineItem(JSONRequestData);    // WebService Call : @Future Call
                    HSFE_Utility_Class.alreadyExecutedCPTrigger = true;
                }
            }
            //END Integration call
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception.
        }
    }




    /*******************************************************************************************************************************************
     * Method Name: updateFreightChargesAndIntegrationStatus_AfterUpdate
     * Description: Update the Freight Charges and Freight Integration Status on Quote/Proposal on the basis of Line Item Integration Status
     *              updated by MuleSoft for Freight Charges.
     * Return Type: None.
     ****************************************************************************************************************************************/
    public static void lineItemBeforeUpdateAllTime(List<Apttus_Config2__LineItem__c> itemList, Map<Id,Apttus_Config2__LineItem__c> oldItemMap){
        try {
            for(Apttus_Config2__LineItem__c newItem:itemList){               

                    Apttus_Config2__LineItem__c oldItem  = oldItemMap.get(newItem.Id);
                    newItem.HSFE_Approver_Level__c = '';
                    if(newItem.HSFE_Child_Product_Stocking_or_Promo_Kit__c == FALSE){
                        if(newItem.HSFE_Target_Price__c  == 0  ||  newItem.HSFE_List_Price_Below_Floor_Price__c == TRUE || newItem.HSFE_Total_Unit_Price_Below_Floor_Price__c == TRUE){
                            newItem.HSFE_Approver_Level__c = HSFE_Constant.GVP;
                        }
                        else if(newItem.HSFE_Discount_from_Threshold_Condition__c == TRUE ){
                            if(newItem.HSFE_Discount_from_Threshold__c > 26){
                                newItem.HSFE_Approver_Level__c = HSFE_Constant.GVP;
                            }else if(newItem.HSFE_Discount_from_Threshold__c > 16){
                                newItem.HSFE_Approver_Level__c = HSFE_Constant.DVP;
                            }else if(newItem.HSFE_Discount_from_Threshold__c > 8){
                                newItem.HSFE_Approver_Level__c = HSFE_Constant.AVP;
                            }else if(newItem.HSFE_Discount_from_Threshold__c > 0){
                                newItem.HSFE_Approver_Level__c = HSFE_Constant.RVP;
                            }
                        }else if(newItem.HSFE_Contract_Price_Deviation__c == TRUE){
                            newItem.HSFE_Approver_Level__c = HSFE_Constant.RVP;
                        }
                    }

                
            }
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception.
        }
    }




     /*******************************************************************************************************************************************
     * Method Name: insertLineItemExtenstionBeforeUpdate
     * Description: 
     * Return Type: None.
     ****************************************************************************************************************************************/
    public static void insertLineItemExtenstionBeforeUpdate(List<Apttus_Config2__LineItem__c> newLineItemList){
        try {
            list<HSFE_Line_Item_Extension__c> extenstionList= new list<HSFE_Line_Item_Extension__c>();
            HSFE_Line_Item_Extension__c extensionObj;
            map<Id, Id> lineItemExtensionIdMap = new map<Id, Id>();
            for(Apttus_Config2__LineItem__c linItem: newLineItemList){
                if(linItem.HSFE_Line_Item_Extension__c == null){
                    extensionObj = new HSFE_Line_Item_Extension__c(HSFE_Line_Item__c = linItem.Id,HSFE_Product_Configuration__c =linItem.Apttus_Config2__ConfigurationId__c);
                    extenstionList.add(extensionObj);
                }
            }
            if(extenstionList.size() > 0){
                Insert extenstionList;
                for(HSFE_Line_Item_Extension__c ext: extenstionList){
                    lineItemExtensionIdMap.put(ext.HSFE_Line_Item__c, ext.Id);
                }
                for(Apttus_Config2__LineItem__c linItem: newLineItemList){
                    if (lineItemExtensionIdMap.containsKey(linItem.Id)){
                        linItem.HSFE_Line_Item_Extension__c = lineItemExtensionIdMap.get(linItem.Id);
                    }
                }
            }
        }catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);// Create a log file for an exception.
        }
    } 
}