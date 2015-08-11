/* 
*Class Name :HSFE_Reject_Lead_Controller_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_Reject_Lead_Controller class.
*Created By  :Chiranth Aradhya
*Created On  :06/11/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Chiranth            6/11/2015                      Created                          
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest 
private class HSFE_Reject_Lead_Controller_TestClass{
    static testmethod void testmethod1() {
    
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
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;     
                    
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
            
            //Insert the Lead record
            Lead lead = HSFE_TestUtility_Class.createLeadRecord(acc);
            lead.LastName='TBD';
            lead.HSFE_Assign_Primary_Contact__c=true;
            insert lead;    
            
            ApexPages.StandardController sc = new ApexPages.StandardController(lead);
           HSFE_Reject_Lead_Controller newlead = new HSFE_Reject_Lead_Controller(sc);
            lead.HSFE_Reject_Reason__c='Already Closed Lost';
            update lead;
            
            lead[] lead1= [select id, Status from Lead where Id =:lead.Id];
            System.assertEquals('Rejected', lead1[0].Status);   
            
           
        }   
    }   
}