/* 
*Class Name :HSFE_AccountOwnerUpdate_TestFutureClass 
*Description :This test class test the functionlity and covers the code for HSFE_AccountOwnerUpdate_TestFutureClass class.
*Created By  :Sunil Kumar
*Created On  :05/7/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Sunil Kumar					05/7/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_AccountOwnerUpdate_TestFutureClass {
	static testMethod void testMethod1(){
		//Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        User accOwner = HSFE_TestUtility_Class.create2User(r);
        insert Usr;
        insert accOwner;
        System.runAs(usr){ 
        	//Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            Set<Id> accountList = new Set<Id>();
            accountList.add(acc.id);
            Test.startTest();
            	HSFE_AccountOwnerUpdate_FutureClass.updateAccountOwner(accountList, accOwner.id);
            Test.stopTest();
            List<Account> updatedAccList = new List<Account>([select id,ownerid from account where id=:acc.id]);
            //Validate account owner is properly updated.
            System.assertEquals(updatedAccList[0].ownerid,accOwner.id );
        }
		
	}
}