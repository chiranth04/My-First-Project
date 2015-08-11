/* 
* Class Name  : HSFE_CustomPricingCallBack_Util_Class
* Description : 
* Created By  : Yunus H Navalur
* Created On  : 05/06/2015
*
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                             Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Yunus                      05/06/2015                       Migrated code from Call back class to util class
*
*
*
*/



global with sharing class HSFE_CustomPricingCallBack_Util_Class{


    //Declaration Section Start
    private static map<String,Integer> ProductConditionCapitalCountMap = new map<String,Integer>{'Trade-in'=>0,'Used'=>0,'Others'=>0};
    private static map<String,Integer> ProductConditionAccessoryCountMap = new map<String,Integer>{'Trade-in'=>0,'Used'=>0,'Others'=>0};
    private static map<String,Integer> ProductConditionDisposableCountMap = new map<String,Integer>{'Trade-in'=>0,'Used'=>0,'Others'=>0};
    private static map<String,Decimal> ProductConditionCapitalQuanMap = new map<String,Decimal>{'Trade-in'=>0,'Used'=>0,'Others'=>0};
    private static map<String,Decimal> ProductConditionAccessoryQuanMap = new map<String,Decimal>{'Trade-in'=>0,'Used'=>0,'Others'=>0};
    private static map<String,Decimal> ProductConditionDisposableQuanMap = new map<String,Decimal>{'Trade-in'=>0,'Used'=>0,'Others'=>0};    
    private static map<String,Decimal> OptionPriceCount = new map<String,Decimal>();
    private static map<String,Decimal> OptionPriceCountRPrice = new map<String,Decimal>();
    private static map<String,Decimal> OptionPriceBaseQtyPrice = new map<String,Decimal>();
    private static map<String,Decimal> OptionPriceBaseQtyRPrice = new map<String,Decimal>();
    private static map<id,Decimal> NetAdjustPerc_Map = new map<id,Decimal>();

    private static Boolean check;

    private static Decimal AmountToSum = 0.0;
    private static Decimal AmountToSumRP = 0.0;
    private static Decimal AmountToOptionBaseQtyPrice = 0.0;
    private static Decimal AmountToOptionBaseQtyRPrice = 0.0;

    //JSON Variables
    public static JSONGenerator generator;
    public static string Temp_Var ;       
    public static String MatrixRecSTR;        
    public static HSFE_ProductJson ProductRec;
    public static HSFE_ProductJson ParentProductRec;      
    public static HSFE_ProductConfigJson ProdConfigRec;
    public static HSFE_PriceMatxEntryJson PriceMatricRec;

    //Declaration Section End   
    

    /*********************************************************************************
     * Method Name: beforePricing_Method
     * Description: Below are the details of the functionality
     *              1. 
     *              2. 
     *              3.
     * Return Type: List<Apttus_Config2__LineItem__c>
    *********************************************************************************/
    public static list<Apttus_Config2__LineItem__c> beforePricing_Method(List<Apttus_Config2__LineItem__c> liSOList){

        system.debug('--------beforePricing_Method------Start---');

        //Declaration - Section
        
        map<Decimal,string> ParentRoomNumber_Map = new map<Decimal,String>();       
        map<string,Integer> SerialCounter_Map = new map<string,Integer>();
        map<string,boolean> SerialNumberCheck_Map = new map<string,boolean>();
        map<id,boolean> ProductStockingFlagMap = new map<id,boolean>();
        map<String,Decimal> ParentProductQuantity = new map<String,Decimal>();
        map<Decimal,string> LineConditionMap = new map<Decimal,String>();

        Set<Id> attributeValueIds = new Set<Id>();
        Set<Id> ProductIds = new Set<Id>();        
        Set<string> CombinationKey = new set<String>();
        

        boolean Is_Stocking_Kit = false;
        boolean Is_Kit_In_A_Kit = false;

        String pcondition = null;                    
        string codesToCheck = Label.HSFE_Contract_Codes_Tocheck;  
        string[] contractCodes = codesToCheck.split(';');
        Set <String> stringContractCodes = new Set<String>(contractCodes);
        id logged_in = UserInfo.getUserId();
        
        //Logic Section
        //Getting the list of line items form the cart                      
        
        for(Apttus_Config2__LineItem__c litem : liSOList){
        
            if(litem.Apttus_Config2__ParentBundleNumber__c==null)
                    ParentProductQuantity.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__PrimaryLineNumber__c,litem.Apttus_Config2__Quantity__c);
            if(litem.Apttus_Config2__ParentBundleNumber__c!=null) {
                if(ParentProductQuantity.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__ParentBundleNumber__c)){
                    litem.HSFE_Parent_Quantity__c = ParentProductQuantity.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__ParentBundleNumber__c);
                    if(litem.HSFE_Option_Group_Label__c!='Recommended Products') {
                        ParentProductQuantity.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__PrimaryLineNumber__c, litem.Apttus_Config2__Quantity__c *litem.HSFE_Parent_Quantity__c);
                    }
                    else {
                        ParentProductQuantity.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__PrimaryLineNumber__c, litem.HSFE_Parent_Quantity__c);  
                    }               
                }
             }
        
            //Parent Product/ Standalone Product            
            if(String.isEmpty(litem.Apttus_Config2__OptionId__c)){

                if(litem.HSFE_Condition_Modified__c == true){

                    if(!String.isEmpty(litem.HSFE_Price_Matrix_Details_JSON_String__c)){
                        PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(litem.HSFE_Price_Matrix_Details_JSON_String__c,litem.Product_Conditions__c);
                        litem.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                        litem.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                        litem.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;
                    }else{
                        PriceMatricRec = new HSFE_PriceMatxEntryJson();
                    }                  
                
                }

                if(litem.HSFE_Order_Type__c == 'Integration' && (litem.HSFE_Room_Number__c != null || litem.HSFE_Room_Number__c != ''))
                    ParentRoomNumber_Map.put(litem.Apttus_Config2__PrimaryLineNumber__c,litem.HSFE_Room_Number__c);
                
                LineConditionMap.put(litem.Apttus_Config2__PrimaryLineNumber__c, litem.Product_Conditions__c);                        

            }else if(!String.isEmpty(litem.Apttus_Config2__OptionId__c)){
                
                if(litem.HSFE_Condition_Modified__c == true){

                    if(!String.isEmpty(litem.HSFE_Price_Matrix_Details_JSON_String__c)){
                        PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(litem.HSFE_Price_Matrix_Details_JSON_String__c,litem.Product_Conditions__c);
                    }else{
                        PriceMatricRec = new HSFE_PriceMatxEntryJson();
                    }
                    if(!String.isEmpty(litem.HSFE_Parent_Product_Details_JSON_String__c)){
                        ParentProductRec = HSFE_ProductJson.GetProductJsonRecord(litem.HSFE_Parent_Product_Details_JSON_String__c);
                    }else{
                        ParentProductRec = new HSFE_ProductJson();
                    }

                    if(ParentProductRec.IsStocking == True){

                        if(litem.Apttus_Config2__OptionGroupLabel__c != null)
                            litem.HSFE_Option_Group_Label__c = litem.Apttus_Config2__OptionGroupLabel__c; 

                        if(litem.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_RECOMMENDED || litem.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_OPTIONAL || litem.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_MANDATORY ||litem.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_FREE_GOODS){
                                                                            
                            litem.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                            litem.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                            litem.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;
                            
                        }else{
                            litem.HSFE_Target_Price__c = 0.0;
                        }        
                    }else{
                        litem.HSFE_Target_Price__c = PriceMatricRec.TargetPrice;
                        litem.Apttus_Config2__ListPrice__c = PriceMatricRec.AdjustAmount;
                        litem.Apttus_Config2__BasePrice__c = PriceMatricRec.AdjustAmount;                     
                    }
                }    
            }
            
            

            if(litem.HSFE_FIT_Quote_Flag__c == 'True'){

                if(litem.HSFE_Condition_Modified__c == true){
                    if(!String.isEmpty(litem.HSFE_Price_Matrix_Details_JSON_String__c)){
                        PriceMatricRec = HSFE_Utility_Class.GetPriceMatricRecord(litem.HSFE_Price_Matrix_Details_JSON_String__c,litem.HSFE_UOM__c);                                      
                        litem.HSFE_UOM_Denominator__c = PriceMatricRec.AdjustAmount;
                    }else{
                        PriceMatricRec = new HSFE_PriceMatxEntryJson();
                        litem.HSFE_UOM_Denominator__c = PriceMatricRec.AdjustAmount;
                    }
                }

                if(litem.HSFE_UOM__c == 'PC' && (litem.HSFE_UOM_Denominator__c == 0 || litem.HSFE_UOM_Denominator__c == null)){                    
                    litem.HSFE_UOM_Denominator__c = 1;
                }                               

                litem.HSFE_No_Value_in_Serial_Number__c = false;                
                litem.HSFE_In_Correct_Quantity_for_Serial_Prod__c = false;
                                    
                if((litem.HSFE_Serial_Number__c == null || litem.HSFE_Serial_Number__c == '') && (litem.Is_Product_Serialized__c == True || litem.Is_Product_Batched__c == True)){
                    litem.HSFE_No_Value_in_Serial_Number__c = true;
                }
                                    
                if(litem.Apttus_Config2__Quantity__c > 1 && litem.Is_Product_Serialized__c == True && litem.Is_Product_Batched__c == False){
                    litem.HSFE_In_Correct_Quantity_for_Serial_Prod__c  = true;
                }
                
                if(litem.HSFE_No_Value_in_Serial_Number__c == false){
                    
                    if((litem.HSFE_Serial_Number__c != null || litem.HSFE_Serial_Number__c != '') && litem.HSFE_Serial_Number__c != HSFE_Constant.COUSTOM_NOT_APPLICABLE && (litem.Is_Product_Serialized__c == True || litem.Is_Product_Batched__c == True)){
                        
                        if(SerialCounter_Map.ContainsKey(litem.HSFE_Serial_Number__c))
                            SerialCounter_Map.put(litem.HSFE_Serial_Number__c,SerialCounter_Map.get(litem.HSFE_Serial_Number__c)+1);
                        else    
                            SerialCounter_Map.put(litem.HSFE_Serial_Number__c,1);
                            
                        if(String.isEmpty(litem.Apttus_Config2__OptionId__c)){
                            SerialNumberCheck_Map.put(litem.Apttus_Config2__ProductId__c+''+litem.HSFE_Serial_Number__c+''+logged_in,false);
                        }else if(!String.isEmpty(litem.Apttus_Config2__OptionId__c)){
                            SerialNumberCheck_Map.put(litem.Apttus_Config2__OptionId__c+''+litem.HSFE_Serial_Number__c+''+logged_in,false);
                        }                   
                    }
                }               
            }                       
        }

        if(!SerialNumberCheck_Map.isEmpty()){
        /******************************************[Divya 31-07-2015]: Commenting out the code for deployment without ELTON Objects**********************************/
           /* for(ELTON__Equipment__c EqmtRec : [select id, HSFE_Combination_Key_Uniq__c from ELTON__Equipment__c where HSFE_Combination_Key_Uniq__c in: SerialNumberCheck_Map.KeySet()]){
                if(SerialNumberCheck_Map.ContainsKey(EqmtRec.HSFE_Combination_Key_Uniq__c))
                    SerialNumberCheck_Map.put(EqmtRec.HSFE_Combination_Key_Uniq__c,True);                
            }*/
         /*******************************************[Divya 31-07-2015]: Commenting out ends***************************************************************************/
        }           
        
        //Calculate Option Prices - Recommended product and Non Recommended Products        
        calculateOptionPrice(liSOList);           
        
        //Populating List price and Target based on conditions
        //Populate Parent prouct quantity on option line items.
        for(Apttus_Config2__LineItem__c litem : liSOList){

            if(!String.isEmpty(litem.Apttus_Config2__OptionId__c)){
                if(litem.HSFE_Order_Type__c == 'Integration' && ParentRoomNumber_Map.ContainsKey(litem.Apttus_Config2__LineNumber__c) && litem.HSFE_Option_Group_Label__c != HSFE_Constant.COUSTOM_RECOMMENDED)
                    litem.HSFE_Room_Number__c = ParentRoomNumber_Map.get(litem.Apttus_Config2__LineNumber__c); 
                if(litem.Product_Conditions__c == HSFE_Constant.NA_STOCKING_KIT)
                    litem.HSFE_Actual_Condition__c = LineConditionMap.get(litem.Apttus_Config2__ParentBundleNumber__c);
            }
        
            if(litem.HSFE_FIT_Quote_Flag__c == 'True'){
                                                             
                if(litem.HSFE_No_Value_in_Serial_Number__c == false){
                                
                    //reset the flags
                    litem.HSFE_Invalid_Serial_Number__c = false;
                
                    if((litem.HSFE_Serial_Number__c != null || litem.HSFE_Serial_Number__c != '') && litem.HSFE_Serial_Number__c != HSFE_Constant.COUSTOM_NOT_APPLICABLE && (litem.Is_Product_Serialized__c == True || litem.Is_Product_Batched__c == True)){
                        if(SerialCounter_Map.get(litem.HSFE_Serial_Number__c) > 1)
                            litem.HSFE_Invalid_Serial_Number__c = true;
                        else
                            litem.HSFE_Invalid_Serial_Number__c = false;
                    }
                    
                    if(litem.HSFE_Invalid_Serial_Number__c == false){
                        
                        //reset the flags
                        litem.HSFE_In_Correct_Serial_Number__c = false;                        
                        
                        if((litem.HSFE_Serial_Number__c != null || litem.HSFE_Serial_Number__c != '') && litem.HSFE_Serial_Number__c != HSFE_Constant.COUSTOM_NOT_APPLICABLE && (litem.Is_Product_Serialized__c == True || litem.Is_Product_Batched__c == True)){
                            if(String.isEmpty(litem.Apttus_Config2__OptionId__c) && SerialNumberCheck_Map.get(litem.Apttus_Config2__ProductId__c+''+litem.HSFE_Serial_Number__c+''+logged_in) == false){
                                litem.HSFE_In_Correct_Serial_Number__c = true;
                            }else if(!String.isEmpty(litem.Apttus_Config2__OptionId__c)&& SerialNumberCheck_Map.get(litem.Apttus_Config2__ProductId__c+''+litem.HSFE_Serial_Number__c+''+logged_in) == false){
                                litem.HSFE_In_Correct_Serial_Number__c = true;
                            }else   
                                litem.HSFE_In_Correct_Serial_Number__c = false;               
                        }else if(litem.Is_Product_Serialized__c == False){
                            litem.HSFE_In_Correct_Serial_Number__c = false;                 
                        }
                    }
                }
            }else{

                //if non FIT quote All the features are nullified
                if(litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS)
                    litem.HSFE_Serial_Number__c = 'Not Applicable';
                else{
                    system.debug('-----HSFE_Serial_Number__c---------->'+litem.HSFE_Serial_Number__c);
                    if(litem.HSFE_Serial_Number__c == null || litem.HSFE_Serial_Number__c == 'Not Applicable'){
                        litem.HSFE_Serial_Number__c = ' ';
                        system.debug('-----HSFE_Serial_Number__c---------->'+litem.HSFE_Serial_Number__c);
                    }
                }
                litem.HSFE_In_Correct_Serial_Number__c = false;
                litem.HSFE_Invalid_Serial_Number__c = false;
                litem.HSFE_No_Value_in_Serial_Number__c = false;
                litem.HSFE_In_Correct_Quantity_for_Serial_Prod__c = false;
            }                                            
        }
        system.debug('--------beforePricing_Method------End---');

        Return liSOList;
    }
    

    
    /*********************************************************************************
     * Method Name:finish_Method
     * Description: Below are the details of the functionality
     *              1. 
     *              2. 
     *              3.
     * Return Type: list<Apttus_Config2__LineItem__c>
    *********************************************************************************/    
    public static list<Apttus_Config2__LineItem__c> finish_Method(List<Apttus_Config2__LineItem__c> liSOList) {

        system.debug('--------finish_Method------Start---');
        //Logic Section ---- Trade-in Logic Start---
        //Logic to trigger error in cart in case there are more no of trade in products
        //(Not Service and Chemical Category products) than new,CPO and demo
        //Getting the list of line items form the cart      
        map<id,decimal> TotalCostPrice_Map = new map<id,decimal>();
        map<id,decimal> TotalThresholdPrice_Map = new map<id,decimal>();
        map<id,decimal> TotalUnitPrice_Map = new map<id,decimal>();
        Set<id> cartIdSet = new Set <id>();               
        list<Apttus_Config2__ProductConfiguration__c> UpdateProductConfig = new list<Apttus_Config2__ProductConfiguration__c>(); 
        
        map<String,Integer> Trade_IN_Count = new map<String,Integer>{'Trade-In'=>0};
        map<String,Decimal> SummaryAmount_Count = new map<String,Decimal>{'SummaryAmount'=>0.0};

        integer CartListSize = 0;     

        //Pre-Calculate Option Price for bundles
        calculateOptionPrice(liSOList);       
                   
        String codesToCheck = Label.HSFE_Contract_Codes_Tocheck;  
        String[] contractCodes = codesToCheck.split(';');
        Set <String> stringContractCodes = new Set<String>(contractCodes);
        
        for(Apttus_Config2__LineItem__c litem : liSOList){
        
            //Get cart Size
            if(litem.Product_Conditions__c != HSFE_Constant.NA_STOCKING_KIT)
                CartListSize = CartListSize + 1;

            litem.HSFE_Option_Price__c = null;
            litem.HSFE_RP_Price__c = null;
            litem.HSFE_Total_Option_List_Price__c = null;
            litem.HSFE_Total_Option_List_R_Price__c = null;  

            //Calculate Option Price for bundles
            if(String.isEmpty(litem.Apttus_Config2__OptionId__c) && litem.Apttus_Config2__HasOptions__c == true){
                if(OptionPriceCount.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){                
                        litem.HSFE_Option_Price__c = OptionPriceCount.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c);            
                }
            }

            //Calculate Option Price for Recommended Products
            if(OptionPriceCountRPrice.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){
                if(String.isEmpty(litem.Apttus_Config2__OptionId__c) && litem.Apttus_Config2__HasOptions__c == true)
                    litem.HSFE_RP_Price__c = OptionPriceCountRPrice.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c);            
            }

            //Calculate Option List Price without Recommended Products
            if(OptionPriceBaseQtyPrice.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){
                if(String.isEmpty(litem.Apttus_Config2__OptionId__c) && litem.Apttus_Config2__HasOptions__c == true)
                    litem.HSFE_Total_Option_List_Price__c = OptionPriceBaseQtyPrice.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c);            
            }

            //Calculate Option list Price with Recommended Products
            if(OptionPriceBaseQtyRPrice.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){
                if(String.isEmpty(litem.Apttus_Config2__OptionId__c) && litem.Apttus_Config2__HasOptions__c == true)
                    litem.HSFE_Total_Option_List_R_Price__c = OptionPriceBaseQtyRPrice.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c);            
            } 
                        
            //Count no of Trade-in Products in cart                                   
            if(litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS || litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR){
                Trade_IN_Count.put('Trade-In',Trade_IN_Count.get('Trade-In')+1);
            }
            
            //Sum of Net Price on Cart
            if (!Test.isRunningTest())
            if(litem.Apttus_Config2__LineType__c != 'Option' && litem.Apttus_Config2__LineType__c != 'Misc')
                SummaryAmount_Count.put('SummaryAmount',SummaryAmount_Count.get('SummaryAmount')+litem.HSFE_Net_Price__c);
            
            //Count no of Trade-in, Used ad Other condition products
            If(litem.Product_Conditions__c != HSFE_Constant.NA_STOCKING_KIT){
                If(litem.HSFE_Product_Classification_Label__c == 'Capital'){
                    if(litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS || litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR){
                        ProductConditionCapitalQuanMap.put('Trade-in',ProductConditionCapitalQuanMap.get('Trade-in')+litem.Apttus_Config2__Quantity__c);
                    }else if(litem.Product_Conditions__c == HSFE_Constant.COUSTOM_USED){
                        ProductConditionCapitalQuanMap.put('Used',ProductConditionCapitalQuanMap.get('Used')+litem.Apttus_Config2__Quantity__c);
                    }else if(litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS && litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && litem.Product_Conditions__c != HSFE_Constant.COUSTOM_USED){
                        ProductConditionCapitalQuanMap.put('Others',ProductConditionCapitalQuanMap.get('Others')+litem.Apttus_Config2__Quantity__c);
                    }
                }
                If(litem.HSFE_Product_Classification_Label__c == 'Disposable'){
                    if(litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS || litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR){                    
                        ProductConditionDisposableQuanMap.put('Trade-in',ProductConditionDisposableQuanMap.get('Trade-in')+litem.Apttus_Config2__Quantity__c);
                    }else if(litem.Product_Conditions__c == HSFE_Constant.COUSTOM_USED){
                        ProductConditionDisposableQuanMap.put('Used',ProductConditionDisposableQuanMap.get('Used')+litem.Apttus_Config2__Quantity__c);
                    }else if(litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS && litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && litem.Product_Conditions__c != HSFE_Constant.COUSTOM_USED){
                        ProductConditionDisposableQuanMap.put('Others',ProductConditionDisposableQuanMap.get('Others')+litem.Apttus_Config2__Quantity__c);
                    }
                }
                If(litem.HSFE_Product_Classification_Label__c == 'Accessory'){
                    if(litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_OLYMPUS || litem.Product_Conditions__c == HSFE_Constant.COUSTOM_TRADE_COMPETITOR){                    
                        ProductConditionAccessoryQuanMap.put('Trade-in',ProductConditionAccessoryQuanMap.get('Trade-in')+litem.Apttus_Config2__Quantity__c);
                    }else if(litem.Product_Conditions__c == HSFE_Constant.COUSTOM_USED){
                        ProductConditionAccessoryQuanMap.put('Used',ProductConditionAccessoryQuanMap.get('Used')+litem.Apttus_Config2__Quantity__c);
                    }else if(litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_OLYMPUS && litem.Product_Conditions__c != HSFE_Constant.COUSTOM_TRADE_COMPETITOR && litem.Product_Conditions__c != HSFE_Constant.COUSTOM_USED){
                        ProductConditionAccessoryQuanMap.put('Others',ProductConditionAccessoryQuanMap.get('Others')+litem.Apttus_Config2__Quantity__c);
                    }
                }
            }
            
        }

        for(Apttus_Config2__LineItem__c litem2 : liSOList){
        
            //Check if the line items have only trade-in condition excluding Chemical and Service ---Start---
            If(String.isEmpty(litem2.Apttus_Config2__OptionId__c)){
                If(litem2.HSFE_Product_Classification_Label__c != HSFE_Constant.COUSTOM_CHEMICAL && litem2.HSFE_Product_Classification_Label__c != HSFE_Constant.COUSTOM_SERVICE){        
                    litem2.HSFE_In_Correct_Product_Addition_on_Cart__c = false;
                    if(ProductConditionCapitalQuanMap.get('Trade-in') > ProductConditionCapitalQuanMap.get('Others')){
                        litem2.HSFE_In_Correct_Product_Addition_on_Cart__c = true;
                    }
                    if(ProductConditionDisposableQuanMap.get('Trade-in') > ProductConditionDisposableQuanMap.get('Others')){
                        litem2.HSFE_In_Correct_Product_Addition_on_Cart__c = true;
                    }
                    if(ProductConditionAccessoryQuanMap.get('Trade-in') > ProductConditionAccessoryQuanMap.get('Others')){
                        litem2.HSFE_In_Correct_Product_Addition_on_Cart__c = true;
                    }                                      
                }
            }               
            //Check if the line items have only trade-in condition excluding Chemical and Service ---End---
            
            //Check if the line items have only trade-in and Total net price is 0 ---Start---
            litem2.HSFE_Only_Trade_In_Products_On_Cart__c = false;
            
            if(Trade_IN_Count.get('Trade-In') == CartListSize){
                litem2.HSFE_Only_Trade_In_Products_On_Cart__c = true;                
            }
            
            litem2.HSFE_Zero_Value_Cart__c = false;
            decimal OptionPriceNR = 0.0;
            decimal OptionPriceR = 0.0;

            if( OptionPriceBaseQtyPrice.ContainsKey(litem2.Apttus_Config2__ProductId__c+''+litem2.Apttus_Config2__LineNumber__c))
                OptionPriceNR = OptionPriceBaseQtyPrice.get(litem2.Apttus_Config2__ProductId__c+''+litem2.Apttus_Config2__LineNumber__c);
            if( OptionPriceBaseQtyRPrice.ContainsKey(litem2.Apttus_Config2__ProductId__c+''+litem2.Apttus_Config2__LineNumber__c))
                OptionPriceR = OptionPriceBaseQtyRPrice.get(litem2.Apttus_Config2__ProductId__c+''+litem2.Apttus_Config2__LineNumber__c);
            if(SummaryAmount_Count.get('SummaryAmount') == 0.0 && OptionPriceNR == 0.0 && OptionPriceR == 0.0){
                litem2.HSFE_Zero_Value_Cart__c = true;
            }
            //Check if the line items have only trade-in and Total net price is 0 ---End---
            if(!String.isEmpty(litem2.HSFE_Product_Details_JSON_String__c))                             
                ProductRec = HSFE_ProductJson.GetProductJsonRecord(litem2.HSFE_Product_Details_JSON_String__c);
            else{ litem2.addError('Error code 019: The product you selected has configuration issues and cannot be added to the cart. Please contact your Support Administrator.'); Continue; }

            if(HSFE_Constant.CUSTOM_SKIP_ADJUSTMENT.contains(litem2.Product_Conditions__c) || ProductRec.ProductType == HSFE_Constant.COUSTOM_PKP){
                litem2.Apttus_Config2__AllowManualAdjustment__c = false;
                litem2.Apttus_Config2__AllocateGroupAdjustment__c = false;  
                litem2.Apttus_Config2__AdjustmentType__c = null;
                litem2.Apttus_Config2__AdjustmentAmount__c = null;  
            }else if(HSFE_Constant.NA_STOCKING_KIT != litem2.Product_Conditions__c && !HSFE_Constant.CUSTOM_SKIP_ADJUSTMENT.contains(litem2.Product_Conditions__c) &&  ProductRec.ProductType != HSFE_Constant.COUSTOM_PKP){
                litem2.Apttus_Config2__AllowManualAdjustment__c = true;
                litem2.Apttus_Config2__AllocateGroupAdjustment__c = true;
            }                
        }
        system.debug('--------finish_Method------End---');   
        Return liSOList;
    }



    /*********************************************************************************
     * Method Name:calculateOptionPrice
     * Description: Below are the details of the functionality
     *              1. 
     *              2. 
     *              3.
     * Return Type: none
    *********************************************************************************/  
    public static void calculateOptionPrice(list<Apttus_Config2__LineItem__c> liSOList) {         

        OptionPriceCount = new map<String,Decimal>();
        OptionPriceCountRPrice = new map<String,Decimal>();
        OptionPriceBaseQtyPrice = new map<String,Decimal>();
        OptionPriceBaseQtyRPrice = new map<String,Decimal>();


        double baseprice = 0.0;
        double quantity = 0.0;
        double parentQuantity = 0.0;
        double qprice = 0.0;
        double AdjusAmt = 0.0;

        for(Apttus_Config2__LineItem__c litem : liSOList){

            AmountToSum = 0.0;
            AmountToSumRP = 0.0;
            AmountToOptionBaseQtyPrice = 0.0;
            AmountToOptionBaseQtyRPrice = 0.0;

            quantity  = litem.Apttus_Config2__Quantity__c != null ? litem.Apttus_Config2__Quantity__c : 1;
            parentQuantity = litem.HSFE_Parent_Quantity__c != null ? litem.HSFE_Parent_Quantity__c : 1;
            qprice    = litem.HSFE_Contract_Price__c != null ? litem.HSFE_Contract_Price__c : 0.0;            
            baseprice = litem.Apttus_Config2__BasePrice__c != null ? litem.Apttus_Config2__BasePrice__c : 0.0;
            AdjusAmt  = litem.Apttus_Config2__AdjustmentAmount__c != null ? litem.Apttus_Config2__AdjustmentAmount__c : 0.0;
                        
            if(!String.isEmpty(litem.Apttus_Config2__OptionId__c) && litem.Apttus_Config2__OptionGroupLabel__c != HSFE_Constant.COUSTOM_RECOMMENDED){

                if(litem.Apttus_Config2__AdjustmentType__c == 'Percntg Dis'){
                
                    if (qprice > 0){
                        AmountToSum = ((qprice * quantity * parentQuantity ) - ((qprice * quantity * parentQuantity ) * AdjusAmt )/100);
                    }else{
                        AmountToSum = ((baseprice * quantity * parentQuantity ) - ((baseprice * quantity * parentQuantity ) * AdjusAmt )/100);
                    }
                    
                }else if(litem.Apttus_Config2__AdjustmentType__c == 'Discount Amount'){
                
                    if (qprice > 0){
                        AmountToSum = ((qprice * quantity * parentQuantity) - AdjusAmt );
                    }else{
                        AmountToSum = ((baseprice * quantity * parentQuantity) - AdjusAmt );
                    }
                    
                }else if(litem.Apttus_Config2__AdjustmentType__c == 'Price Override'){
                
                    AmountToSum = AdjusAmt;
                    
                }else{                    
                    if (qprice > 0){
                        AmountToSum = (qprice * quantity * parentQuantity);
                    }else{                       
                        AmountToSum = (baseprice * quantity * parentQuantity);
                    }
                }

                if(OptionPriceCount.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){
                    OptionPriceCount.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,OptionPriceCount.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)+AmountToSum);
                }else{
                    OptionPriceCount.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,AmountToSum);
                }

                AmountToOptionBaseQtyPrice = AmountToOptionBaseQtyPrice + (baseprice * quantity);

                if(OptionPriceBaseQtyPrice.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){
                    OptionPriceBaseQtyPrice.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,OptionPriceBaseQtyPrice.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)+AmountToOptionBaseQtyPrice);
                }else{
                    OptionPriceBaseQtyPrice.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,AmountToOptionBaseQtyPrice);
                }

            }else if(!String.isEmpty(litem.Apttus_Config2__OptionId__c) && litem.HSFE_Option_Group_Label__c == HSFE_Constant.COUSTOM_RECOMMENDED && litem.Product_Conditions__c != HSFE_Constant.NA_STOCKING_KIT){
                
                if(litem.Apttus_Config2__AdjustmentType__c == 'Percntg Dis'){
                
                    if (qprice > 0 && (quantity != null) && (litem.Apttus_Config2__AdjustmentAmount__c != null)){
                        AmountToSumRP = ((qprice * quantity) - ((qprice* quantity) * AdjusAmt )/100);
                    }else{
                        AmountToSumRP = ((baseprice * quantity) - ((baseprice * quantity) * AdjusAmt )/100);
                    }
                    
                }else if(litem.Apttus_Config2__AdjustmentType__c == 'Discount Amount'){
                
                    if (qprice > 0){
                        AmountToSumRP = ((qprice * quantity) - AdjusAmt );
                    }else{
                        AmountToSumRP = ((baseprice * quantity) - AdjusAmt );
                    }
                    
                }else if(litem.Apttus_Config2__AdjustmentType__c == 'Price Override'){
                
                    AmountToSumRP = AdjusAmt;
                    
                }else{
                
                    if (qprice > 0){
                        AmountToSumRP = (qprice * quantity);
                    }else{
                        AmountToSumRP = (baseprice * quantity);
                    }
                    
                }

                if(OptionPriceCountRPrice.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){
                    OptionPriceCountRPrice.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,OptionPriceCountRPrice.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)+AmountToSumRP);
                }else{
                    OptionPriceCountRPrice.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,AmountToSumRP);
                }

                AmountToOptionBaseQtyRPrice = AmountToOptionBaseQtyRPrice + (baseprice * quantity); 

                if(OptionPriceBaseQtyRPrice.ContainsKey(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)){
                    OptionPriceBaseQtyRPrice.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,OptionPriceBaseQtyRPrice.get(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c)+AmountToOptionBaseQtyRPrice);
                }else{
                    OptionPriceBaseQtyRPrice.put(litem.Apttus_Config2__ProductId__c+''+litem.Apttus_Config2__LineNumber__c,AmountToOptionBaseQtyRPrice);
                }
            }    
        }               
    }    
}