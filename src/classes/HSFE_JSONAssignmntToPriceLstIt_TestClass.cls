/* Class Name   : HSFE_JSONAssignmntToPriceLstIt_TestClass 
 * Description  : Testclass for below Codes
                    HSFE_JSONAssignmentToPriceListItem
                    HSFE_UpdatePricelistItem_JSON
 * Created By   : Ajay Agnihotri
 * Created On   : 9/July/2015 
 * Modification Log:  
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                        Description
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * 
 */
@isTest(SeeAllData= false)
public class HSFE_JSONAssignmntToPriceLstIt_TestClass {

    // Used the below test Method to Cover Batch Execution of "HSFE_UpdatePricelistItem_JSON" from "HSFE_JSONAssignmentToPriceListItem" Class
    static testMethod void JSONAssignmentToPriceListItem_TestScenarios() {
    
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
            }    
            insert NewProductLst;
            HSFE_TestUtility_Class.createPriceBookEntry(NewProductLst[0].id);
            Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                                
            HSFE_Contant_Helper__c Rec1 = [select id, HSFE_Value__c,name from HSFE_Contant_Helper__c where name = 'HSFE_Price_List_Item_TriggerHandler'];
            Rec1.HSFE_Value__c = 'False';
            update  Rec1;                    
            
            if(NewProductLst.size()>0){
                
                //Insert the PriceListItem record
                Apttus_Config2__PriceListItem__c NewPriceListItem=new Apttus_Config2__PriceListItem__c();
                NewPriceListItem=HSFE_TestUtility_Class.createSinglePriceListItem(NewPriceList, NewProductLst[0], 'New', 'One Time', 'Per Unit', 100);
                insert NewPriceListItem;
                System.AssertNotEquals(NewPriceListItem.id,null);
                                
                //Insert the PriceDimension record
                Apttus_Config2__PriceDimension__c NewPriceDimension=new Apttus_Config2__PriceDimension__c();
                NewPriceDimension=HSFE_TestUtility_Class.createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
                insert NewPriceDimension;
                System.AssertNotEquals(NewPriceDimension.id,null);
                
                //Insert the PriceMatrix record
                Apttus_Config2__PriceMatrix__c NewPriceMatrix=new Apttus_Config2__PriceMatrix__c();
                NewPriceMatrix=HSFE_TestUtility_Class.createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension,NewPriceListItem);
                insert NewPriceMatrix;                        
                
                //Insert the PriceMatrixEntry record
                Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry = new Apttus_Config2__PriceMatrixEntry__c();
                NewPriceMatrixEntry=HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',43431,'New',NewPriceMatrix,43431);
                insert NewPriceMatrixEntry;
                System.AssertNotEquals(NewPriceMatrixEntry.id,null);
                
                //Insert the PriceMatrixEntry record
                Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry2 = new Apttus_Config2__PriceMatrixEntry__c();
                NewPriceMatrixEntry2 = HSFE_TestUtility_Class.createSinglePriceMatrixEntry('List Price Override',4331,'Trade-In - Competitor',NewPriceMatrix,4331);
                insert NewPriceMatrixEntry2;
                System.AssertNotEquals(NewPriceMatrixEntry2.id,null);                
                
    
                // Call HSFE_JSONAssignmentToPriceListItem to update JSON Strings on Price List item when JSON Update flag is false.
                HSFE_JSONAssignmentToPriceListItem JsonAssignIns=new HSFE_JSONAssignmentToPriceListItem();
                JsonAssignIns.runLeadBatchJob();
            
            }
            Test.StopTest();
        }

     
    }
}