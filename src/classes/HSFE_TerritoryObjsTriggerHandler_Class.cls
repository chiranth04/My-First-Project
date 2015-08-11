/* Class Name :HSFE_AccountTriggerHandler_Class
*Description :Trigger Handler class for the Account SObject, which implements all the logic of Account trigger.
            1. Update the primary text field on contact based on Is primary checkbox, Primary text field is used in duplicate rules.
*Created By :Sourav Datta
*Created On :04/08/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
 Sunil                      7/10/2015                                                            Check the combination key should be combination of
 																								 Zip,Specialty and Sub Specialty.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public with sharing class HSFE_TerritoryObjsTriggerHandler_Class {
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Zip To Territory Start*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
   /*********************************************************************************
     * Method Name:handleZipToTerrBeforeInsert
     * Description:Check the combination key should be combination of Zip,Specialty and Sub Specialty.
     * Return Type: None.
     ********************************************************************************/
    public static void handleZipToTerrBeforeInsert(List<HSFE_Zip_To_Territory__c> newZipList) {
    	try{
    		String combinationKey;
    		for(HSFE_Zip_To_Territory__c zip : newZipList){
    			combinationKey ='';
    			combinationKey = zip.Name+zip.HSFE_Specialty__c+zip.HSFE_Sub_Specialty__c;
    			if(combinationKey != zip.HSFE_Combination_Key__c){ 
    				zip.addError('Combination Key is not correct.It should be a combination of Zip Code,Specialty and Sub Specialty');
    			}
    		}
    	}catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    	
    }
   /*********************************************************************************
     * Method Name:handleZipToTerrAfterUpdate
     * Description:Handle After Update keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleZipToTerrAfterUpdate(map<Id, HSFE_Zip_To_Territory__c> newObjMap, map<Id, HSFE_Zip_To_Territory__c> oldObjMap) {
        try{
            set<String> zipCodeUpdatedSet = new set<String>();
            for(Id idVal:newObjMap.keySet()){
                HSFE_Zip_To_Territory__c newObj = newObjMap.get(idVal);
                HSFE_Zip_To_Territory__c oldObj = oldObjMap.get(idVal);
                if(newObj.HSFE_Combination_Key__c ==  oldObj.HSFE_Combination_Key__c && newObj.HSFE_Territory__c != oldObj.HSFE_Territory__c){
                    zipCodeUpdatedSet.add(newObj.Name);
                }
            }
            insertZipCodeSet(zipCodeUpdatedSet);
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    /*********************************************************************************
     * Method Name:handleZipToTerrBeforeUpdate
     * Description:Handle After Update keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleZipToTerrBeforeUpdate(map<Id, HSFE_Zip_To_Territory__c> newObjMap, map<Id, HSFE_Zip_To_Territory__c> oldObjMap) {
        try{
            set<String> zipCodeUpdatedSet = new set<String>();
            for(Id idVal:newObjMap.keySet()){
                HSFE_Zip_To_Territory__c newObj = newObjMap.get(idVal);
                HSFE_Zip_To_Territory__c oldObj = oldObjMap.get(idVal);
                if(newObj.HSFE_Combination_Key__c !=  oldObj.HSFE_Combination_Key__c || newObj.HSFE_Specialty__c!=newObj.HSFE_Specialty__c ||
                   newObj.HSFE_Sub_Specialty__c!= oldObj.HSFE_Sub_Specialty__c){
                    newObj.addError('Zip Code, Specialty or Sub Specialty cannnot be changed for an existing record');  
                }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
    /*********************************************************************************
     * Method Name:handleZipToTerrAfterUpdate
     * Description:Handle After Update keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleZipToTerrAfterInsertDelete(list<HSFE_Zip_To_Territory__c> objList) {
        try{
            set<String> zipCodeUpdatedSet = new set<String>();
            for(HSFE_Zip_To_Territory__c obj : objList){
                if(obj.Name != null && obj.Name != ''){
                    zipCodeUpdatedSet.add(obj.Name);
                }
            }
            insertZipCodeSet(zipCodeUpdatedSet);
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Zip To Terriotry End*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Territory Start*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /*********************************************************************************
     * Method Name:handleTerrBeforeInsert
     * Description:Territory ID and Territory External ID should be same.
     * Return Type: None.
     ********************************************************************************/
    public static void handleTerrBeforeInsert(list<HSEF_Territory__c> objList) {
        try{
            for(HSEF_Territory__c terr : objList){
            	if(terr.Name != terr.HSFE_Territory_External_ID__c){
            		terr.addError('Territory ID and Territory External ID should be same');
            	}
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    /*********************************************************************************
     * Method Name:handleTerrAfterDelete
     * Description:Handle After delete to keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleTerrAfterDelete(list<HSEF_Territory__c> objList) {
        try{
            List<HSFE_Zip_To_Territory__c> zipToTerrList= new List<HSFE_Zip_To_Territory__c>();
            Set<Id> zipcodeSet = new set<Id>();
            set<String> zipCodeUpdatedSet = new set<String>();
           
            for(HSEF_Territory__c terr:objList){
                zipcodeSet.add(terr.Id);
            }
            zipToTerrList = [Select Id,Name,HSFE_Territory__c from HSFE_Zip_To_Territory__c where HSFE_Territory__c IN:zipcodeSet];
            if(zipToTerrList.size()>0){
                for(HSFE_Zip_To_Territory__c obj : zipToTerrList){
                    if(obj.Name != null && obj.Name != ''){
                        zipCodeUpdatedSet.add(obj.Name);
                    }
                }
                insertZipCodeSet(zipCodeUpdatedSet);
                
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Territory End*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/




/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Territory to User Start*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /*********************************************************************************
     * Method Name:handleUserToTerrAfterInsert
     * Description:Check Combination Key is valid
     * Return Type: None.
     ********************************************************************************/
    public static void handleUserToTerrBeforeInsert(list<HSFE_Territory_To_User__c> objList) {
        try{
           String combinationKey;
           Set<String> userId = new Set<String>();
           Set<String> terrId = new Set<String>();
           for(HSFE_Territory_To_User__c tUser : objList){
           	 	userId.add(tUser.HSFE_User__c);
           	 	terrId.add(tUser.HSFE_Territory__c);
           }
           Map<ID,User> userMap = new Map<ID,User>([select id,EmployeeNumber from user where id=:userId and EmployeeNumber != null]);
           Map<ID,HSEF_Territory__c> territoryMap = new Map<ID,HSEF_Territory__c>([select id,name from HSEF_Territory__c where id=:terrId]);
           for(HSFE_Territory_To_User__c tUser : objList){
           	combinationKey = '';
           	if(userMap.containsKey(tUser.HSFE_User__c) && territoryMap.containsKey(tUser.HSFE_Territory__c)){
           		combinationKey = userMap.get(tUser.HSFE_User__c).EmployeeNumber+territoryMap.get(tUser.HSFE_Territory__c).Name;
           		if(tUser.HSFE_Combination_Key__c != combinationKey){
           			tUser.addError('Combination Key is not correct.It should be a combination of Empolyee Number and Territory ID');
           		}
           	}          	
           	   
           }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    /*********************************************************************************
     * Method Name:handleUserToTerrAfterInsert
     * Description:Handle After insert to keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleUserToTerrAfterInsert(list<HSFE_Territory_To_User__c> objList) {
        try{
            List<HSFE_Zip_To_Territory__c> zipToTerrList= new List<HSFE_Zip_To_Territory__c>();
            Set<Id> terrIdSet = new set<Id>();
            set<String> zipCodeUpdatedSet = new set<String>();
           
            for(HSFE_Territory_To_User__c terr:objList){
                terrIdSet.add(terr.HSFE_Territory__c);
            }
            zipToTerrList = [Select Id,Name,HSFE_Territory__c from HSFE_Zip_To_Territory__c where HSFE_Territory__c IN:terrIdSet];
            if(zipToTerrList.size()>0){
                for(HSFE_Zip_To_Territory__c obj : zipToTerrList){
                    if(obj.Name != null && obj.Name != ''){
                        zipCodeUpdatedSet.add(obj.Name);
                    }
                }
                insertZipCodeSet(zipCodeUpdatedSet);
                
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }

    /*********************************************************************************
     * Method Name:handleUserToTerrAfterUpdate
     * Description:Handle After Update to keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleUserToTerrAfterUpdate(map<Id, HSFE_Territory_To_User__c> newObjMap, map<Id, HSFE_Territory_To_User__c> oldObjMap) {
        try{
            List<HSFE_Zip_To_Territory__c> zipToTerrList= new List<HSFE_Zip_To_Territory__c>();
            Set<Id> terrIdSet = new set<Id>();
            set<String> zipCodeUpdatedSet = new set<String>();
            
            for(Id idVal:newObjMap.keySet()){
                HSFE_Territory_To_User__c newObj = newObjMap.get(idVal);
                HSFE_Territory_To_User__c oldObj = oldObjMap.get(idVal);
                if(newObj.HSFE_User__c!=  oldObj.HSFE_User__c || newObj.HSFE_Territory__c != oldObj.HSFE_Territory__c){
                     terrIdSet.add(newObj.HSFE_Territory__c);
                }
            }
            zipToTerrList = [Select Id,Name,HSFE_Territory__c from HSFE_Zip_To_Territory__c where HSFE_Territory__c IN:terrIdSet];
            if(zipToTerrList.size()>0){
                for(HSFE_Zip_To_Territory__c obj : zipToTerrList){
                    if(obj.Name != null && obj.Name != ''){
                        zipCodeUpdatedSet.add(obj.Name);
                    }
                }
                insertZipCodeSet(zipCodeUpdatedSet);
                
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
    /*********************************************************************************
     * Method Name:handleUserToTerrAfterDelete
     * Description:Handle After Delete to keep track of ZipCodes Updated
     * Return Type: None.
    ********************************************************************************/
    public static void handleUserToTerrAfterDelete(list<HSFE_Territory_To_User__c> objList) {
        try{
            List<HSFE_Zip_To_Territory__c> zipToTerrList= new List<HSFE_Zip_To_Territory__c>();
            Set<Id> terrIdSet = new set<Id>();
            set<String> zipCodeUpdatedSet = new set<String>();
           
            for(HSFE_Territory_To_User__c terr:objList){
                terrIdSet.add(terr.HSFE_Territory__c);
            }
            zipToTerrList = [Select Id,Name,HSFE_Territory__c from HSFE_Zip_To_Territory__c where HSFE_Territory__c IN:terrIdSet];
            if(zipToTerrList.size()>0){
                for(HSFE_Zip_To_Territory__c obj : zipToTerrList){
                    if(obj.Name != null && obj.Name != ''){
                        zipCodeUpdatedSet.add(obj.Name);
                    }
                }
                insertZipCodeSet(zipCodeUpdatedSet);
                
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Territory to User END*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    
    
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Territory  Exception Start*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**********************************************************************************************************
     * Method Name:handleTerrExcepBeforeInsert
     * Description:Combination Key check.It should be combination of SAP ID,Specialty,Sub Specialty and Zip Code
     * Return Type: None.
     ********************************************************************************************************/
    public static void handleTerrExcepBeforeInsert(list<HSFE_Territory_Exception__c> objList) {
        try{
        	String combinationKey;
            for(HSFE_Territory_Exception__c obj : objList){
            	combinationKey = '';
            	combinationKey = obj.Name+obj.HSFE_Zip_Code__c+obj.HSFE_Specialty__c+obj.HSFE_Sub_Specialty__c;
                if(obj.HSFE_Combination_Key__c != combinationKey){
                    obj.addError('Combination Key is not correct.It should be a combination of SAP ID,Zip Code,Specialty and Sub Specialty ');
                }
            }          
            
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    /*********************************************************************************
     * Method Name:handleTerrExcepAfterInsertDelete
     * Description:Handle After Insert/Delete to keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleTerrExcepAfterInsertDelete(list<HSFE_Territory_Exception__c> objList) {
        try{
            set<String> zipCodeUpdatedSet = new set<String>();
            for(HSFE_Territory_Exception__c obj : objList){
                if(obj.HSFE_Zip_Code__c != null && obj.HSFE_Zip_Code__c != ''){
                    zipCodeUpdatedSet.add(obj.HSFE_Zip_Code__c);
                }
            }
            insertZipCodeSet(zipCodeUpdatedSet);
            
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
    
    /*********************************************************************************
     * Method Name:handleTerrExcepAfterUpdate
     * Description:Handle After Update to keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleTerrExcepAfterUpdate(map<Id, HSFE_Territory_Exception__c> newObjMap, map<Id, HSFE_Territory_Exception__c> oldObjMap) {
        try{
            set<String> zipCodeUpdatedSet = new set<String>();
            for(Id idVal:newObjMap.keySet()){
                HSFE_Territory_Exception__c newObj = newObjMap.get(idVal);
                HSFE_Territory_Exception__c oldObj = oldObjMap.get(idVal);
                if(newObj.HSFE_Combination_Key__c ==  oldObj.HSFE_Combination_Key__c && newObj.HSFE_Territory__c != oldObj.HSFE_Territory__c){
                    zipCodeUpdatedSet.add(newObj.HSFE_Zip_Code__c);
                }
                system.debug('*****************newObj.HSFE_Territory__c*******************8'+newObj.HSFE_Territory__c);
                system.debug('*****************oldObj.HSFE_Territory__c*******************8'+oldObj.HSFE_Territory__c);
            }
            system.debug('***************zipCodeUpdatedSet***********************8'+zipCodeUpdatedSet);
            insertZipCodeSet(zipCodeUpdatedSet);
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
    /*********************************************************************************
     * Method Name:handleTerrExcepBeforeUpdate
     * Description:Handle Before Update to keep track of ZipCodes Updated
     * Return Type: None.
     ********************************************************************************/
    public static void handleTerrExcepBeforeUpdate(map<Id, HSFE_Territory_Exception__c> newObjMap, map<Id, HSFE_Territory_Exception__c> oldObjMap) {
        try{
            set<String> zipCodeUpdatedSet = new set<String>();
            for(Id idVal:newObjMap.keySet()){
                HSFE_Territory_Exception__c newObj = newObjMap.get(idVal);
                HSFE_Territory_Exception__c oldObj = oldObjMap.get(idVal);
                if(newObj.HSFE_Combination_Key__c !=  oldObj.HSFE_Combination_Key__c || newObj.HSFE_Specialty__c !=  oldObj.HSFE_Specialty__c || newObj.HSFE_Sub_Specialty__c    !=  oldObj.HSFE_Sub_Specialty__c    || newObj.HSFE_Zip_Code__c !=  oldObj.HSFE_Zip_Code__c){
                    newObj.addError('Zip Code, Specialty,Sub Specialty or Zip Code cannnot be changed for an existing record');  
                }
            }
            
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
   


/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Territory  Exception END*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Zip Code Temporary Start*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /*********************************************************************************
     * Method Name:insertZipCodeSet
     * Description: Insert unique zip code sets to the temporary table
     * Return Type: None.
     ********************************************************************************/
    public static void insertZipCodeSet(set<String> zipCodeSet) {
        try{
            if(Label.HSFE_Deactivate_Territory_Trigger == 'False'){
                Map< String, Id > duplicateZipcodeTempMap = new Map< String, Id >();
                List<HSFE_Updated_Zip_Code_Temporary__c> insertZipToTempList = new List<HSFE_Updated_Zip_Code_Temporary__c>();
                
                for( HSFE_Updated_Zip_Code_Temporary__c zipTemprec : [select Id, Name from HSFE_Updated_Zip_Code_Temporary__c where Name = :zipCodeSet] ){
                    duplicateZipcodeTempMap.put( zipTemprec.Name, zipTemprec.Id );
                }
                system.debug('**************duplicateZipcodeTempMap*******************'+duplicateZipcodeTempMap);
                for(String tempZipName:zipCodeSet){
                     Id duplicateZipcodeTempId = duplicateZipcodeTempMap.get(tempZipName);
                     if(duplicateZipcodeTempId == null){
                         HSFE_Updated_Zip_Code_Temporary__c Zterr = new HSFE_Updated_Zip_Code_Temporary__c();
                         Zterr.Name = tempZipName; 
                         insertZipToTempList.add(Zterr);
                     }
                }
                system.debug('**************insertZipToTempList*******************'+insertZipToTempList);
                if(insertZipToTempList.size()>0){
                    insert insertZipToTempList;
                }
             }
         }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
/** --------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************Zip Code Temporary End*************************************************************************
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    
     
}