/* 
*Class Name : HSFE_SchedulableEquipmentToProductLinkClass_TestClass 
*Description :This test class test the functionlity and covers the code for     SchedulableEquipmentToProductLinkClass class.
*Created By  :Teena Philip
*Created On  :06/111/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest(SeeAllData= false)
private class  HSFE_SchedEquipToProdLinkClass_TestClass {
   
   
    // Below Method is used to test the Batch apex class for linking equipment to products
    
    static testMethod void  SchedEquipToProdLinkClass_Test(){
        try{
            
            //Insert the User Role record
            //UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
            //insert oUserRole;
            
            //Insert the User record
            User ocreateUser = HSFE_TestUtility_Class.createUser2();
            insert ocreateUser;
            
            // Run Test Logic as Test User
            system.runAs(ocreateUser){
                Test.StartTest();
                //Insert the Account record
                List <Product2> prodList1 = new List <Product2>();
                prodList1 = HSFE_TestUtility_Class.createProductRecords(10, '');                   
                insert prodList1 ;   
                
                List <ELTON__Equipment__c> equip = new List<ELTON__Equipment__c>();
                
                for(Integer i=0;i<10;i++) {
                    ELTON__Equipment__c e = new ELTON__Equipment__c();
                    e.SAP_Material_Number__c='testProd'+i;
                    e.ELTON__Active__c=true;
                    e.OLY_Related_Product__c=null;
                    equip.add(e);
                }
                insert equip; 
                
                SchedulableEquipmentToProductLinkClass c = new SchedulableEquipmentToProductLinkClass();
                String schedule = '0 1 1 * * ?';
                System.schedule('Just Checking',schedule,c);
                Test.StopTest();
            }
        }
        catch(exception e){
        }    
    }
    
}