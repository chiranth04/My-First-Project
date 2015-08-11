global class batchEquipmentToProductsLink implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,SAP_Material_Number__c FROM ELTON__Equipment__c where SAP_Material_Number__c != null and OLY_Related_Product__c =null';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<ELTON__Equipment__c> epuipList)
    {
        if(epuipList != null && epuipList.size() > 0){
            List<Product2> prodList = new List<Product2>();
            Set<String> SAPMaterialNumberList  = new Set<String>();
            Map<String, Product2> partNumberProductMap = new Map<String, Product2>();
            
             for(ELTON__Equipment__c el : epuipList){
                  SAPMaterialNumberList.add(el.SAP_Material_Number__c);           
             }
             
             prodList = [select Id, HSFE_Part_Number__c from Product2 where HSFE_Part_Number__c in : SAPMaterialNumberList and isActive =: TRUE];
             
             for(Product2 prod: prodList){
                 partNumberProductMap.put(prod.HSFE_Part_Number__c,prod);
             }
             
             
             for(ELTON__Equipment__c elVar : epuipList){
                 Product2 prodVar = partNumberProductMap.get(elVar.SAP_Material_Number__c);
                 if(prodVar != null){
                     elVar.OLY_Related_Product__c = prodVar.Id;
                 }
             }
             
             update epuipList;
         }
    }   
    global void finish(Database.BatchableContext BC)
    {
    }

}