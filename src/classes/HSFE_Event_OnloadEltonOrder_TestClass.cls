/* 
*Class Name :HSFE_Event_OnloadEltonOrder_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_Event_OnloadEltonOrder_TestClass.
*Created By  :Chiranth Aradhya
*Created On  :06/11/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest   
private class HSFE_Event_OnloadEltonOrder_TestClass{
  public static  testmethod void testmethod1() {

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
    
    System.Assert(l.Id != null, 'The Lead record is not inserted , Please check the Validation rules or other mechanism');
    
    
    //Insert  contact record      
    Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
    con.HSFE_Primary__c = True;
    insert con;
    
    System.Assert(con.Id != null, 'The Contact record is not inserted , Please check the Validation rules or other mechanism');
    
           
    //Insert Opporuntiy record
    Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
    insert opp; 
    
    
    System.Assert(opp.Id != null, 'The Opportuntiy record is not inserted , Please check the Validation rules or other mechanism');
    
    
    Event evd1 = new Event(WhatId = opp.Id, Type = HSFE_Constant.MEETING, Meeting_Type__c = 'On Patient Evaluation', DurationInMinutes = 30, ActivityDateTime = System.today());
    insert evd1;
    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
    System.currentPageReference().getParameters().put('What_Id', opp.Id); 
    HSFE_Event_OnloadEltonOrder_Controller  eltonoreder = new HSFE_Event_OnloadEltonOrder_Controller(sc);
    eltonoreder.onLoad();
    
    System.Assert(evd1.Meeting_Type__c == 'On Patient Evaluation', 'The Event record is not inserted , Please check the Validation rules or other mechanism');
    
    }
    
    
    }
    
  public static  testmethod void testmethod2() {

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
    
    System.Assert(l.Id != null, 'The Lead record is not inserted , Please check the Validation rules or other mechanism');
    
    //Insert  contact record      
    Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
    con.HSFE_Primary__c = True;
    insert con;
     
    System.Assert(con.Id != null, 'The Contact record is not inserted , Please check the Validation rules or other mechanism');
           
    //Insert Opporuntiy record
    Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
    insert opp; 
    
    System.Assert(opp.Id != null, 'The Opportuntiy record is not inserted , Please check the Validation rules or other mechanism');
    
    Event evd2 = new Event(WhatId = opp.Id, Type = HSFE_Constant.MEETING, Meeting_Type__c = 'Inservice', DurationInMinutes = 30, ActivityDateTime = System.today());
    insert evd2; 
    System.currentPageReference().getParameters().put('What_Id', opp.Id);
    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
    HSFE_Event_OnloadEltonOrder_Controller  eltonoreder = new HSFE_Event_OnloadEltonOrder_Controller(sc);
    eltonoreder.onLoad();
    
    System.Assert(evd2.Meeting_Type__c == 'Inservice', 'The Event record is not inserted properly, Please check the Validation rules or other mechanism');
    }
   
   } 
   
   public static  testmethod void testmethod3() {

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
    
    System.Assert(acc.Id != null, 'The account record is not inserted , Please check the Validation rules or other mechanism');
    
    //Insert AccountTerritory
    HSFE_Account_Territory__c accter = HSFE_TestUtility_Class.createAccountTerritory(acc,terr);
    insert accter;
    
    
    //Insert the lead record 
    Lead l = HSFE_TestUtility_Class.createLeadRecord(acc);
    insert l;
    
    System.Assert(l.Id != null, 'The lead record is not inserted , Please check the Validation rules or other mechanism');
    
    //Insert  contact record      
    Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
    con.HSFE_Primary__c = True;
    insert con;
    
    System.Assert(con.Id != null, 'The contact record is not inserted , Please check the Validation rules or other mechanism');
           
    //Insert Opporuntiy record
    Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
    insert opp; 
    
    System.Assert(opp.Id != null, 'The opportunity record is not inserted , Please check the Validation rules or other mechanism');
    
    Event evd2 = new Event(WhatId = opp.Id, Type = HSFE_Constant.MEETING, Meeting_Type__c = 'Inservice', DurationInMinutes = 30, ActivityDateTime = System.today());
    insert evd2; 
    System.currentPageReference().getParameters().put('What_Id', l.Id);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    HSFE_Event_OnloadEltonOrder_Controller  eltonoreder = new HSFE_Event_OnloadEltonOrder_Controller(sc);
    eltonoreder.onLoad();
    
    System.Assert(evd2.Meeting_Type__c == 'Inservice', 'The Event record is not inserted properly, Please check the Validation rules or other mechanism');
    }
    }
    
    public static  testmethod void testmethod4() {

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
    
    System.Assert(acc.Id != null, 'The account record is not inserted , Please check the Validation rules or other mechanism');
    
    //Insert AccountTerritory
    HSFE_Account_Territory__c accter = HSFE_TestUtility_Class.createAccountTerritory(acc,terr);
    insert accter;
    
    
    //Insert the lead record 
    Lead l = HSFE_TestUtility_Class.createLeadRecord(acc);
    insert l;
    
    System.Assert(l.Id != null, 'The lead record is not inserted , Please check the Validation rules or other mechanism');
    
    //Insert  contact record      
    Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
    con.HSFE_Primary__c = True;
    insert con;
           
    System.Assert(con.Id != null, 'The contact record is not inserted , Please check the Validation rules or other mechanism');
    
    //Insert Opporuntiy record
    Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
    insert opp; 
    
    System.Assert(opp.Id != null, 'The opportuntiy record is not inserted , Please check the Validation rules or other mechanism');
    
    Event evd2 = new Event(WhatId = acc.Id,whoId=con.Id, Type = HSFE_Constant.MEETING, Meeting_Type__c = 'Inservice', DurationInMinutes = 30, ActivityDateTime = System.today());
    insert evd2; 
    System.currentPageReference().getParameters().put('What_Id', acc.Id);
    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
    HSFE_Event_OnloadEltonOrder_Controller  eltonoreder = new HSFE_Event_OnloadEltonOrder_Controller(sc);
    eltonoreder.onLoad();
    
    System.Assert(evd2.Meeting_Type__c == 'Inservice', 'The Event record is not inserted properly, Please check the Validation rules or other mechanism');
    
    }
    }
    }