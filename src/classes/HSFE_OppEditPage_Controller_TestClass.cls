/* 
*Class Name :HSFE_OppEditPage_Controller_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_OppEditPage_Controller class.
*Created By  :Chiranth Aradhya
*Created On  :04/27/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest                    
private class HSFE_OppEditPage_Controller_TestClass {
   
    static  testmethod void testmethod1() {
        
        ///Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
        System.runAs(usr){  
            Test.StartTest();
             //Insert  account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert Account Team
            AccountTeamMember accteam= HSFE_TestUtility_Class.createAccountTeamMember(acc, Usr);
            insert accteam;
       
            //Insert Opporuntiy record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            insert opp;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            HSFE_OppEditPage_Controller oppnew = new HSFE_OppEditPage_Controller(sc);
            opp.HSFE_Lost_Reason__c='Price not competitive';
            update opp;
            
            Opportunity[] Opps= [select id, HSFE_Sales_Stage__c from Opportunity where Id =:opp.Id];
            System.assertEquals('Closed Lost', Opps[0].HSFE_Sales_Stage__c);
            Test.StopTest();
        } 
    }
}