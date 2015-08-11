/* 
*Class Name :HSFE_ProductTriggerHandler_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_ProductTriggerHandler_Class.
*Created By  :Teena Philip
*Created On  :04/17/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest                    
private class HSFE_ProductTriggerHandler_TestClass {
    
    @isTest(SeeAllData=false)    
    static void testmethod1() {    
        //Insert Custom Setting
        HSFE_Product_Attribute_Charge_Types__c chargeTypeRecord= new HSFE_Product_Attribute_Charge_Types__c();
        chargeTypeRecord.HSFE_Description__c = '{CPO,Demo}';
        chargeTypeRecord.HSFE_Name_Long__c = 'CPO;Demo';
        chargeTypeRecord.Name='Charge Type 41';
        insert chargeTypeRecord;    
             

        //Insert  product records       
        List <Product2> prodList1 = new List <Product2>();
        prodList1 = HSFE_TestUtility_Class.createProductRecords(3, 'ab');     
        prodList1[0].HSFE_Product_Conditions_Multi__c='';
        prodList1[1].HSFE_Product_Conditions_Multi__c='CPO;Demo';
        
        insert prodList1 ;        
  
        //Check whether charge type has been populated correctly
        List <Product2> prodList2 = new List <Product2>();
        if(prodList2.size() > 3){
            prodList2 = [Select id, HSFE_Charge_Type__c from Product2 where id =: prodList2[0].id OR id =: prodList2[1].id or id =: prodList2[2].id];      
            System.Assert(prodList2[0].HSFE_Charge_Type__c == null);
            System.Assert(prodList2[1].HSFE_Charge_Type__c == 'Charge Type 41');
            System.Assert(prodList2[2].HSFE_Charge_Type__c != null);
        }
    }
    
    @isTest(SeeAllData=false)
    static void testmethod2() {       
        //Insert Custom Setting 
        HSFE_Product_Attribute_Charge_Types__c chargeTypeRecord= new HSFE_Product_Attribute_Charge_Types__c();
        chargeTypeRecord.HSFE_Description__c = '{CPO,Demo,New;Trade-In - Olympus}';
        chargeTypeRecord.HSFE_Name_Long__c = 'CPO;Demo;New;Trade-In - Olympus';
        chargeTypeRecord.Name='Charge Type 44';
        insert chargeTypeRecord;  
    
        //Insert Product records
        List <Product2> prodList1 = new List <Product2>();
        prodList1 = HSFE_TestUtility_Class.createProductRecords(4, 'ab');
        prodList1[3].HSFE_Product_Type__c='SKP';   
        insert prodList1;   
        //Check whether product is inserted properly
        System.Assert(prodList1[0].Id != null, 'The Test Product did not insert properly, please check validation rules and other mechanisms');   
        
        //Update product conditions     
        prodList1[1].HSFE_Product_Conditions_Multi__c='CPO;Demo';   
        prodList1[0].HSFE_Product_Conditions_Multi__c='';            
        update prodList1;
        
        //Check if charge types have been populated correctly 
        if(prodList1.size() > 4){     
            List <Product2> prodList2 = [Select id, HSFE_Charge_Type__c from Product2 where id =: prodList1[0].id OR id =: prodList1[1].id or id =: prodList1[2].id OR id =: prodList1[3].id];
            System.Assert(prodList2[0].HSFE_Charge_Type__c == null);
            System.Assert(prodList2[1].HSFE_Charge_Type__c == null);
            System.Assert(prodList2[2].HSFE_Charge_Type__c != null);    
            System.Assert(prodList2[3].HSFE_Charge_Type__c == null); 
        }        
    }     
}