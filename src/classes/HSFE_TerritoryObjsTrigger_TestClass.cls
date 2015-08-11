/* 
*Class Name :HSFE_TerritoryObjsTrigger_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_OppTerritoryAssignment_BatchClass batch class.
*Created By  :Sunil Kumar
*Created On  :04/17/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Sunil Kumar                 04/17/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_TerritoryObjsTrigger_TestClass {
    static testmethod void testmethod1(){
        
        //Insert Territory record
        HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
        insert terry;
        //Insert Territory record
        HSEF_Territory__c terrSecond = HSFE_TestUtility_Class.createSecondTerritory();
        insert terrSecond;
        //Insert Zip to Territory
        HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
        insert zipToTerr; 
        
        
        
        //To validate a temporary record is created 
        List<HSFE_Updated_Zip_Code_Temporary__c> tempObj = [Select name from HSFE_Updated_Zip_Code_Temporary__c where name=:zipToTerr.Name];        
        System.assertEquals(tempObj.size(),1);
        
        //Update Zip To Territory
        HSFE_Zip_To_Territory__c zipToTerrObj = new HSFE_Zip_To_Territory__c(id =zipToTerr.id);
        zipToTerrObj.HSFE_Territory__c =  terrSecond.id;
        update zipToTerrObj;
        
        //To validate duplicate record will not create when zip is updated.
        List<HSFE_Updated_Zip_Code_Temporary__c> tempUpdateObj = [Select name from HSFE_Updated_Zip_Code_Temporary__c where name=:zipToTerr.Name];
        System.assertEquals(tempObj.size(),1);
        
        //Delete Zip To Territory
        HSFE_Zip_To_Territory__c zipToTerrDel = new HSFE_Zip_To_Territory__c(id =zipToTerrObj.id);
        delete zipToTerrDel;
        
        //To validate duplicate record will not create when zip is deleted.
        List<HSFE_Updated_Zip_Code_Temporary__c> tempDelObj = [Select name from HSFE_Updated_Zip_Code_Temporary__c where name=:zipToTerr.Name];
        System.assertEquals(tempObj.size(),1);
    }
    
    static testmethod void testmethod2(){
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
         System.runAs(usr){ 
            //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;
            
            List<HSFE_Zip_To_Territory__c> zipterrList = new List<HSFE_Zip_To_Territory__c >();
            zipterrList =[Select HSFE_Territory__c from HSFE_Zip_To_Territory__c where HSFE_Territory__c =:terry.Id];
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr; 
            
                
            //Delete Territory
            delete terry;   
            
            System.assertEquals(zipterrList.size(),1);
                 
            //To validate a temporary record is created.
            List<HSFE_Updated_Zip_Code_Temporary__c> tempObj = [Select name from HSFE_Updated_Zip_Code_Temporary__c where name=:zipToTerr.Name];
            System.assertEquals(tempObj.size(),1);
            
            
            HSFE_Zip_To_Territory__c zipToTerr1=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            try{
                insert zipToTerr1;
            }catch(Exception e){
            }
            
          }
    }
    static testmethod void testmethod3(){
         //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
         System.runAs(usr){ 
            //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
             //Insert Territory record
            HSEF_Territory__c terrSecond = HSFE_TestUtility_Class.createSecondTerritory();
            insert terrSecond;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerrSec=  HSFE_TestUtility_Class.createHSFEMedicalZipterr(terrSecond);
            insert zipToTerrSec;
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr; 
            
            //To validate a temporary record is created.
            List<HSFE_Updated_Zip_Code_Temporary__c> tempObj = [Select name from HSFE_Updated_Zip_Code_Temporary__c where name=:zipToTerr.Name];
            System.assertEquals(tempObj.size(),1);
            
             //Update Territory to User
            HSFE_Territory_To_User__c trrUpdateObj =  new HSFE_Territory_To_User__c(id= trrToUsr.id);
            trrUpdateObj.HSFE_Territory__c = terrSecond.id;
            update trrUpdateObj;
            
            //To validate duplicate record will not create when zip is updated.
            List<HSFE_Updated_Zip_Code_Temporary__c> tempUpdateObj = [Select name from HSFE_Updated_Zip_Code_Temporary__c where name=:zipToTerr.Name];
            System.assertEquals(tempObj.size(),1);          
            HSFE_Territory_To_User__c trrDelObj =  new HSFE_Territory_To_User__c(id= trrUpdateObj.id);
            delete trrUpdateObj;
             //To validate duplicate record will not create when zip is deleted.
            List<HSFE_Updated_Zip_Code_Temporary__c> tempDelObj = [Select name from HSFE_Updated_Zip_Code_Temporary__c where name=:zipToTerr.Name];
            System.assertEquals(tempObj.size(),1);   
            
         }
    }
    static testmethod void testmethod4(){
         //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
         System.runAs(usr){ 
            //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
             //Insert Territory record
            HSEF_Territory__c terrSecond = HSFE_TestUtility_Class.createSecondTerritory();
            insert terrSecond;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;
            
           
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c exceptionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry); 
            insert exceptionObj;
           
            exceptionobj.HSFE_Territory__c=terrSecond.Id;
            update exceptionobj;
            
             
            
            
            try{
                zipToTerr.HSFE_Combination_Key__c ='1234SurgicalEnergy';
                update zipToTerr;
                
               exceptionobj.HSFE_Sub_Specialty__c='EndoCapsule';
             update exceptionobj;
               
            
            }catch(Exception e){
            }
            
            delete exceptionobj;

            delete terry;
            
            
         }
    }
    
}