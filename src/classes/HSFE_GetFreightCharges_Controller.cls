/*Class Name : HSFE_GetFreightCharges_Controller 
*Description : This class will act as a controller for HSFE_GetFreightCharges_Page adn will govern the functionality 
*               to request the Mulesoft for fetching the Freight Charges details.
*Created By : Prateek Saxena
*Created On :05/05/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena             05/05/2015                                                              Created
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*/
public with sharing class HSFE_GetFreightCharges_Controller {
    
    public String productConfigId;
    public String quoteId;
    public String configRequestId;
    
    public HSFE_GetFreightCharges_Controller(){
        productConfigId = Apexpages.currentPage().getParameters().get('id');
        quoteId = Apexpages.currentPage().getParameters().get('retId');
        configRequestId = Apexpages.currentPage().getParameters().get('configRequestId');
    }
    
    public void GetFreightCharges(){
        System.debug('********************** In GetFreightCharges method : Product Config Ids ' + productConfigId);
        List<Apttus_Config2__LineItem__c> cartLineItems = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__LineItem__c> cartLineItemToBeSent = new List<Apttus_Config2__LineItem__c>();
        List<HSFE_Line_Item_Extension__c> cartLineItemExtList = new List<HSFE_Line_Item_Extension__c>();
        Map<Id, String> lineItemExtMap = new Map<Id, String>();
        try {
            if (!String.isEmpty(productConfigId)){
                cartLineItems = [Select 
                                    Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c,
                                    Apttus_Config2__BasePrice__c, HSFE_Product_Part_Number__c, Product_Conditions__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id,
                                    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__ShipToAccountId__r.HSFE_Physical_Zip__c, HSFE_Line_Item_Extension__c, 
                                    HSFE_Freight_Charges__c,  HSFE_Contract_Number__c, HSFE_Contract_Code__c, HSFE_Freight_Terms__c, Apttus_Config2__Quantity__c,HSFE_Freight_Integration_Status__c
                                from Apttus_Config2__LineItem__c
                                where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c != null and 
                                        Apttus_Config2__ConfigurationId__c = :productConfigId];
                System.debug('*************************** Cart Line Item Details :  ' + cartLineItems);
                if (!cartLineItems.isEmpty()){
                    for (Apttus_Config2__LineItem__c objVar : cartLineItems){
                        lineItemExtMap.put(objVar.HSFE_Line_Item_Extension__c, HSFE_Constant.NOT_IN_SAP);
                        if(null != objVar.HSFE_Product_Part_Number__c){    // Removed Base Price Check
                            lineItemExtMap.put(objVar.HSFE_Line_Item_Extension__c, HSFE_Constant.SENT_TO_SAP);
                            cartLineItemToBeSent.add(objVar);
                        }
                    }
                    System.debug('************************ lineItemExtMap :  ' + lineItemExtMap);
                    cartLineItemExtList = [Select Id, HSFE_Freight_Integration_Status__c from HSFE_Line_Item_Extension__c
                                            where Id in : lineItemExtMap.keySet()];
                    System.debug('************************ cartLineItemExtList :  ' + cartLineItemExtList);
                    if (!cartLineItemExtList.isEmpty()){
                        for (HSFE_Line_Item_Extension__c extObj : cartLineItemExtList){
                            extObj.HSFE_Freight_Integration_Status__c = lineItemExtMap.get(extObj.Id);
                        }
                        System.debug('**************** Updating cartLineItemExtList :' + cartLineItemExtList);
                        Update cartLineItemExtList; // Updating Status IN Line Item Ext Obj
                    }                                           
                    if (!cartLineItemToBeSent.isEmpty()){
                        System.debug('**************** cartLineItemToBeSent :' + cartLineItemToBeSent);
                        String JSONRequestData = HSFE_Utility_Class.serializeListToJSON(cartLineItemToBeSent, HSFE_Constant.FREIGHT_CHARGES);  //Converting the List of data to JSON
                        System.debug('Freight Charges Request JSON Data : ' + JSONRequestData);
                        HSFE_IntegrateMuleSoftWebservice_Class.GetFreightChargesForLineItem(JSONRequestData);           //WebService Call : @Future Call
                    }
                }
            }
        }
        catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);
        }
    } 
    
    public Pagereference redirectToCart(){
        PageReference cartDetailPage = System.Page.Apttus_Config2__CartDetailView;
        cartDetailPage.getParameters().put('Id', productConfigId);
        cartDetailPage.getParameters().put('configRequestId', configRequestId);
        return cartDetailPage;
    }
}