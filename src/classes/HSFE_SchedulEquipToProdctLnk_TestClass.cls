/* Class Name   : HSFE_SchedulEquipToProdctLnk_TestClass 
 * Description  : Testclass for below Codes
                    SchedulableEquipmentToProductLinkClass
                    batchEquipmentToProductsLink
 * Created By   : Ajay Agnihotri
 * Created On   : 9/July/2015 
 * Modification Log:  
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                        Description
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * 
 */
@isTest(SeeAllData= false)
public class HSFE_SchedulEquipToProdctLnk_TestClass {
/*
    // Used the below test Method to Cover Batch Execution of "batchEquipmentToProductsLink" from "SchedulableEquipmentToProductLinkClass" Class
    static testMethod void SchedulableEquipmentToProductLink_TestScenarios() {
        try{
                //Insert the User record
                User NewcreateUser = HSFE_TestUtility_Class.createUserNoRole();
                insert NewcreateUser;
                System.AssertNotEquals(NewcreateUser , null);

                // Run Test Logic as Test User
                system.runAs(NewcreateUser){
                    
                    Test.StartTest();
                    
                    //Insert the PriceList record
                    Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
                    NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
                    insert NewPriceList;
                    System.AssertNotEquals(NewPriceList.id,null);
                    

                    // Insert PriceListId and ProfileId In Custom Setting   
                    List<HSFE_Contant_Helper__c> NewContant_Helper_Lst = new List<HSFE_Contant_Helper__c>();
                    NewContant_Helper_Lst=HSFE_TestUtility_Class.Create_HSFE_Contant_Helper_Data(UserInfo.getProfileId(),NewPriceList.id);
                    insert NewContant_Helper_Lst;
                
                    // Insert Product record
                    List<Product2> NewProductLst=new List<Product2>();
                    NewProductLst=HSFE_TestUtility_Class.createProductRecords(1,'HSFE');
                    if(NewProductLst.size()>0){
                        NewProductLst[0].Is_Stocking_Kit__c=true;
                        NewProductLst[0].HSFE_Part_Number__c ='1234';
                    }   
                    insert NewProductLst;
                    HSFE_TestUtility_Class.createPriceBookEntry(NewProductLst[0].id);
                    Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                    if(NewProductLst.size()>0){
                        
                        ELTON__Equipment__c NewETON_Equipment = new ELTON__Equipment__c();
                        NewETON_Equipment=HSFE_TestUtility_Class.Create_SingleELTON_Equipment_Data();
                        insert NewETON_Equipment;
                        System.AssertNotEquals(NewETON_Equipment.id,null);
                        

                        // Call SchedulableEquipmentToProductLinkClass to call Batch used to assign product to Equipment Object.
                        SchedulableEquipmentToProductLinkClass SchedulableEquipmentToProductLinkClassIns=new SchedulableEquipmentToProductLinkClass();
                        String scd = '0 0 23 * * ?'; 
                        system.schedule('Test TXN Check', scd, SchedulableEquipmentToProductLinkClassIns);
                    
                    }
                    Test.StopTest();
                }
        }
        catch(exception e){
        }       
    }
   */
}