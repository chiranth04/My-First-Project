/* 
*Class Name :HSFE_AccTerritoryAssignTest_BatchClass 
*Description :This test class test the functionlity and covers the code for HSFE_AccTerritoryAssignment_BatchClass batch class.
*Created By  :Sunil Kumar
*Created On  :04/17/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Sunil Kumar					04/17/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_AccTerritoryAssignTest_BatchClass {
	static testmethod void testmethod1(){
		 //Insert Role
	    UserRole r = HSFE_TestUtility_Class.createRole();
	    insert r;
	   //Insert User record
	    User Usr =  HSFE_TestUtility_Class.createUser(r);
	    insert Usr;	    
	     System.runAs(usr){  
	     	HSFE_Utility_Class.stopUpdateAccountTerritory = true;
	     	HSFE_Utility_Class.stopUpdateLeadTerritory = true;  
			//Insert  account record       
	        List<Account> acc = HSFE_TestUtility_Class.createmultipleAccount();
	        insert acc;
	        //Insert Territroy
	        HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
	        insert terry;
	        
	        //Insert Territory to User
	        HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
	        insert trrToUsr;
	        
	        //Insert Zip to Territory
	        HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
	        insert zipToTerr;        
	        system.debug('**********createHSFEZipterrcombination*********'+zipToTerr.HSFE_Combination_Key__c);
	        
	        //Insert Territory Exception
	        HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
	        insert expectionObj;        
	        
	        HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
	        insert temZipObj;
	                
	        Test.startTest();
	        	HSFE_AccTerritoryAssignment_BatchClass accBatchObj = new HSFE_AccTerritoryAssignment_BatchClass();
				Database.executeBatch(accBatchObj);	        	
	        Test.stopTest();
	     }
	}
}