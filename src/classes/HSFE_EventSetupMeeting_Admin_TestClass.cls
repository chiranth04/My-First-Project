/* 
*Class Name :HSFE_EventSetupMeeting_Admin_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_EventSetupMeeting_Admin_Overr_Class.
*Created By  :Chiranth Aradhya
*Created On  :05/26/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest   
private class HSFE_EventSetupMeeting_Admin_TestClass{
  static  testmethod void testmethod1() {

    //Insert Role
    UserRole r = HSFE_TestUtility_Class.createRole();
    insert r;
    
    //Insert User record
    User Usr =  HSFE_TestUtility_Class.createUser(r);
    insert Usr;
   
    System.runAs(usr){  
        
     //Insert Territory
    HSEF_Territory__c terr = HSFE_TestUtility_Class.createTerritory();
    insert terr;
    
    //Insert Zip to Territory
    HSFE_Zip_To_Territory__c zipTerr =  HSFE_TestUtility_Class.createHSFEZipterr(terr);
    insert zipTerr;
    
    //Insert territory to User
    HSFE_Territory_To_User__c terrToUser = HSFE_TestUtility_Class.createTerritoryUser(usr,terr);
    insert terrToUser;
    
    //Insert the account record       
    Account acc = HSFE_TestUtility_Class.createAccountRecord();
    insert acc;
    
    
    //Insert AccountTerritory
    HSFE_Account_Territory__c accter = HSFE_TestUtility_Class.createAccountTerritory(acc,terr);
    insert accter;
    
    
    //Insert the lead record 
    Lead l = HSFE_TestUtility_Class.createLeadRecord(acc);
    insert l;
    System.Assert(l.Id != null, 'The Lead record is not inserted properly, Please check the Validation rules or other mechanism');
    
    //Insert  contact record      
    Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
    con.HSFE_Primary__c = True;
    insert con;
    System.Assert(con.Id != null, 'The Contact record is not inserted properly, Please check the Validation rules or other mechanism');
    
    
    //Insert Opporuntiy record
    Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
    insert opp; 
    System.Assert(opp.Id != null, 'The Opportuniry record is not inserted properly, Please check the Validation rules or other mechanism');
     
    Event evd = new Event( WhatId =opp.ID,WhoId=con.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = 'inservice', DurationInMinutes = 30, ActivityDateTime = System.today());
    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
    System.currentPageReference().getParameters().put('What_Id', opp.Id);
    HSFE_EventSetupMeeting_Admin_Overr_Class  eventoverr = new HSFE_EventSetupMeeting_Admin_Overr_Class(sc);
    eventoverr.onLoadSetupMeeting();
    insert evd; 
    
    
    //check whether Eventis inserted properly
    System.Assert(evd.Id != null, 'The Event record is not inserted properly, Please check the Validation rules or other mechanism');
    System.Assert(evd.WhatId == opp.Id, 'The Event record is not inserted properly, Please check the Validation rules or other mechanism');
    
   }
    }
}