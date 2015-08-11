/**
 *  Apttus Config & Pricing
 *  DisplayActionCallbackAdapter
 *   
 *  @2013-2014 Apttus Inc. All rights reserved.
 */
global with sharing class HSFE_ActionCallBackCustom implements Apttus_Config2.CustomClass.IDisplayActionCallback {
    private transient Apttus_Config2.ProductConfiguration cart;
    private transient List<Apttus_Config2.DisplayActionInfo> displayActions;
  /**
    * Callback at the beginning.
    * Use the start method to initialize state, before internal rule is applied
    * @param cart the cart object
    * @param displayActions the list of actions (or tasks) displayed in the current page
  */
  global void start(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.DisplayActionInfo> displayActions) {
        this.cart = cart;
        this.displayActions = displayActions;
    }
    /**
     * Callback to set properties to page commands
     * @param params information about current state of the cart
     *        request id can be retrieved from the params
    */
     global void setActionProperties(Apttus_Config2.CustomClass.ActionParams params){
       for(Apttus_Config2.DisplayActionInfo actionInfo : displayActions){
         if(actionInfo.ActionSO.Apttus_Config2__DisplayType__c == 'Cart Line Item'){ 
           //cart page, pick list value
              if(actionInfo.ActionSO.Apttus_Config2__ActionName__c == Label.HSFE_ActionCallBack){
                Apttus_Config2__ProductConfiguration__c prodConfiguration = cart.getConfigSO();
                //Sourav 08032015 added condition to check freight Integration status before making Submit for Approval Active.
                //&& prodConfiguration.HSFE_Serial_Number_Valid__c ==FALSE - removed from below as its breaking existing func
                if(prodConfiguration.HSFE_Contract_Code_Integration_Status__c == HSFE_Constant.SYNCED && prodConfiguration.HSFE_Freight_Integration_Status__c == HSFE_Constant.SYNCED && prodConfiguration.HSFE_Serial_Number_Valid__c == TRUE){
                    actionInfo.IsEnabled = true;
                }else{
                    actionInfo.IsEnabled = false;
                }
            } 
         }
       }      
     }
}