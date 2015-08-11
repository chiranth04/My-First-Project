/* 
* Class Name  : HSFE_CustomPricingCallBack
* Description : Trigger Handler for the Product SObject, which implements all the logic.
* Created By  : Yunus H Navalur
* Created On  : 03/17/2015
*
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                             Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Yunus                    3/17/2015
* Gaurav Kumar             3/19/2015
* Yunus                    3/23/2015
*/



global with sharing class HSFE_CustomPricingCallBack_WorkSpace implements Apttus_Config2.CustomClass.IPricingCallback2{ 
    
    private Apttus_Config2.ProductConfiguration cart = null;
    private Apttus_Config2.CustomClass.PricingMode mode = null;
    private Apttus_Config2__ProductConfiguration__c prodConfigSO = null;
    
    
    //Constructor
    public HSFE_CustomPricingCallBack_WorkSpace(){
    }

    
    /**
    * Callback to indicate the pricing mode
    * @param mode the pricing mode
    */
    global void setMode(Apttus_Config2.CustomClass.PricingMode mode) {
        system.debug('-CallBack-SetMode--Start--');
        this.mode = mode;
        system.debug('-CallBack-SetMode--End--');
    }
    
    
    /**
    * Callback at the beginning of the pricing call.
    * Use the start method to initialize state
    * @param cart the cart object
    */
    global void start(Apttus_Config2.ProductConfiguration cart) {
        system.debug('-CallBack-Start Method--Start--');
        this.cart = cart;
        prodConfigSO  = cart.getConfigSO();
        system.debug('-CallBack-Start Method--End--');
    }
    
    
    /**
    * Callback before pricing the line item collection
    * Use this method to do all required pre-processing to prepare the line items for pricing.
    * @param itemColl the line item collection to pre-process
    */
    global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        
        system.debug('-CallBack-beforePricing--Start--'+HSFE_Utility_Class.alreadyExecutedCallBackBefore);
        try{
            if (!HSFE_Utility_Class.alreadyExecutedCallBackBefore) {

                List <Apttus_Config2.LineItem> allLines = cart.getLineItems();          
                List<Apttus_Config2__LineItem__c> liSOList = new List<Apttus_Config2__LineItem__c>();

                //Logic Section
                //Getting the list of line items form the cart
                for(Apttus_Config2.LineItem line: allLines) {
                    liSOList.add(line.getLineItemSO());
                }                
                                           
                liSOList = HSFE_CustomPricingCallBack_Util_Class.beforePricing_Method(liSOList);
                //system.debug('-------liSOList---'+liSOList);
                HSFE_Utility_Class.alreadyExecutedCallBackBefore = true;           
            }
        }catch(exception e){
             HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }

        system.debug('-CallBack-beforePricing--End--');
    }
    
    
    /**
    * Callback before pricing the given line item in the line item collection
    * Use this method to do all required pre-processing to prepare the line item for pricing.
    * @param itemColl the line item collection holding the line item
    * @param lineItemMO the line item to pre-process
    */
    global void beforePricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
        system.debug('-CallBack-beforePricingLineItem--Method-*-No Code');
        if (Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT == mode && !HSFE_Utility_Class.alreadyExecutedCallBackBefore) {
            calculateTerm(cart.getLineItems());
        }
    }
    
    
    /**
    * Callback after pricing the given line item in the line item collection
    * Use this method to do all required post-processing after the line item is priced
    * @param itemColl the line item collection holding the line item
    * @param lineItemMO the line item to post-process
    */
    global void afterPricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
        system.debug('-CallBack-afterPricingLineItem--Method-*-No Code');   
    }
      
      
    /**
    * Callback after pricing the line item collection
    * Use this method to do all required post-processing after line items are priced.
    * @param itemColl the line item collection to post-process
    * This method will validate pricing business rules for renewals and calculate Customer Price, Discount on line item 
    */
    global void afterPricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        system.debug('-CallBack-afterPricing--Start--');                 
        system.debug('-CallBack-afterPricing--End--');     
    }
   

    /**
    * Callback after all batches of line items are processed
    * Use the finish method to release state
    */
    global void finish() {
   
        system.debug('-CallBack-finish--Method-*-');
        try{
            if(!HSFE_Utility_Class.alreadyExecutedCallBackFinish){

                List<Apttus_Config2__LineItem__c> liSOList = new List<Apttus_Config2__LineItem__c>();
                List <Apttus_Config2.LineItem> allLines = cart.getLineItems();

                for(Apttus_Config2.LineItem line: allLines) {
                    liSOList.add(line.getLineItemSO());
                }

                liSOList = HSFE_CustomPricingCallBack_Util_Class.finish_Method(liSOList);
                //system.debug('-------liSOList---'+liSOList);
                HSFE_Utility_Class.alreadyExecutedCallBackFinish = true;
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
        system.debug('-CallBack----finish-----Method-*-');          
    }
        
    
    /**
    *calculateTerm: Calculates term on cart.
    **/
    private void calculateTerm(List<Apttus_Config2.LineItem> allLines) {
        system.debug('-CallBack-calculateTerm--Method-*-');
    }        
}