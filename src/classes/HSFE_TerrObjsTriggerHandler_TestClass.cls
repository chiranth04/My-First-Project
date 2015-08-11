/* 
*Class Name :HSFE_TerritoryObjsTriggerHandler_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_TerritoryObjsTriggerHandler_Class.
*Created By  :Chiranth Aradhya
*Created On  :04/16/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest(seeAllData = false)                    
private class HSFE_TerrObjsTriggerHandler_TestClass{
    static testmethod void testmethod1() {
    
         ///Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        System.runAs(usr){       
        //Insert Territory
        HSEF_Territory__c terr = HSFE_TestUtility_Class.createTerritory();
        insert terr;
        
        //Insert Territory
        HSEF_Territory__c terr1 = HSFE_TestUtility_Class.createTerritory();
        terr1.name = 'ABCD';
        terr1.HSFE_Territory_External_ID__c = 'ABCD';
        insert terr1;
        
        //Insert Zip to Territory
        HSFE_Zip_To_Territory__c zipTerr =  HSFE_TestUtility_Class.createHSFEZipterr(terr1);
        insert zipTerr;
        
        //insert Zipt to Terr multiple records
        List<HSFE_Zip_To_Territory__c> zipTerrList = HSFE_TestUtility_Class.createMultipleZiptoTerr(terr);
        insert zipTerrList;
       
        
         //Insert Zip to Territory
        HSFE_Zip_To_Territory__c zipTerr2= HSFE_TestUtility_Class.createHSFEZipterr2(terr);
        insert zipTerr2;
        
        //Insert territory to User
        HSFE_Territory_To_User__c terrToUser = HSFE_TestUtility_Class.createTerritoryUser(usr,terr);
        insert terrToUser;
        
        //Insert territory Exception
        HSFE_Territory_Exception__c  terrExcep=HSFE_TestUtility_Class.createTerritoryException(terr);
        //terrExcep.HSFE_Zip_Code__c ='TestZip';
        insert terrExcep;
        
        //Update the Territory to User Record to change the territory from Terr to Terr1.
         HSFE_Territory_To_User__c  oTerrToUser= [SELECT Id,HSFE_Territory__c FROM HSFE_Territory_To_User__c  WHERE Id=:terrToUser.Id];
         oTerrToUser.HSFE_Territory__c=terr1.Id;
         Update oTerrToUser;
         List<HSFE_Updated_Zip_Code_Temporary__c> lstZipTemp = [SELECT Id,Name FROM HSFE_Updated_Zip_Code_Temporary__c Limit 1];
         System.assert(lstZipTemp.size()>0);
         delete lstZipTemp;
         
        //Delete the Territory to User Record
        HSFE_Territory_To_User__c  oTerrtoUserDel= [SELECT Id,HSFE_Territory__c FROM HSFE_Territory_To_User__c  WHERE Id=:terrToUser.Id];
        delete oTerrtoUserDel;
        List<HSFE_Updated_Zip_Code_Temporary__c> lstZipTempTerrToUser = [SELECT Id,Name FROM HSFE_Updated_Zip_Code_Temporary__c Limit 1];
        System.assert(lstZipTempTerrToUser.size()>0);
        
        //Update Zip To Territory by changing the combination key to test before update logic.
        HSFE_Zip_To_Territory__c oZipToTerritoryBeforeUpdate= [SELECT Id,HSFE_Territory__c,Name FROM HSFE_Zip_To_Territory__c  WHERE Id=:zipTerr.Id];
        update oZipToTerritoryBeforeUpdate;
       
        //Update the Zip To Territory Record
        HSFE_Zip_To_Territory__c oZipToTerritory= [SELECT Id,HSFE_Territory__c,Name FROM HSFE_Zip_To_Territory__c  WHERE Id=:zipTerr.Id];
        oZipToTerritory.HSFE_Territory__c =terr.Id;
        update oZipToTerritory;
        
        //Update Territory Exception Record to test the exception
        HSFE_Territory_Exception__c oTerrException= [SELECT Id,Name,HSFE_Territory__c ,HSFE_Specialty__c,HSFE_Combination_Key__c  FROM HSFE_Territory_Exception__c WHERE Id=:terrExcep.Id];
        update oTerrException;
        
        //Update Territory Exception Record
        HSFE_Territory_Exception__c oTerrExceptionAfterUpdate= [SELECT Id,Name,HSFE_Territory__c ,HSFE_Specialty__c  FROM HSFE_Territory_Exception__c WHERE Id=:terrExcep.Id];
        oTerrExceptionAfterUpdate.HSFE_Territory__c = terr1.Id;
        update oTerrExceptionAfterUpdate;
       
        //Delete the Territory
        HSEF_Territory__c oTerr = [SELECT Id, Name From HSEF_Territory__c  where iD=:terr.Id];
        delete oTerr;
        List<HSFE_Updated_Zip_Code_Temporary__c> lstZipTempFinal = [SELECT Id,Name FROM HSFE_Updated_Zip_Code_Temporary__c Limit 1];
       System.assert(lstZipTempFinal.size()>0);
    }
}
    
}