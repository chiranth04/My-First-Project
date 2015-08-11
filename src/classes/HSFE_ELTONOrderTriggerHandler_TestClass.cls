/* 
*Class Name :HSFE_ELTONOrderTriggerHandler_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_ELTONOrderTriggerHandler_Class.
*Created By  :Divya A N
*Created On  :06/24/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest                    
private class HSFE_ELTONOrderTriggerHandler_TestClass{
   
    static  testmethod void insertELTONOrder() {
      
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        UserRole r1 = HSFE_TestUtility_Class.createRoleRVP();
        insert r1;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
        //Insert User record
        User Usr2 =  HSFE_TestUtility_Class.create2User(r1);
        insert Usr2;
        
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
            
            test.startTest();
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');        
    
            //Insert AccountTerritory
            HSFE_Account_Territory__c accter = HSFE_TestUtility_Class.createAccountTerritory(acc,terr);
            insert accter;
            
            //Insert  contact record      
            Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
            con.HSFE_Primary__c = True;
            insert con;
            
            //check whether the contact is inserted properly
            System.Assert(con.Id != null, 'The Test Contact did not insert properly, please check validation rules and other mechanisms');
            
            Id pricebookId = Test.getStandardPricebookId();
            
            //Insert Opporuntiy record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            opp.HSFE_Secondary_Owner__c = Usr2.id;
            opp.HSFE_Service_Amount__c=200.00;
            insert opp;
            
            ELTONOlympus__Equipment_Configuration__c EqConfigs = new ELTONOlympus__Equipment_Configuration__c();
            EqConfigs.ELTONOlympus__Return_To_Warehouse_Account__c = acc.Id;
            insert EqConfigs;

            //Insert an ELTON Order record
            ELTON__Equipment_Order__c oEltonOrder= new ELTON__Equipment_Order__c();
            oEltonOrder.ELTON__Opportunity__c=opp.Id;
            oEltonOrder.ELTONOlympus__Primary_Salesperson__c=Usr.Id;
            insert oEltonOrder;
            
            //Update the ELTON Order Record
            ELTON__Equipment_Order__c oOrder=[SELECT Id,ELTONOlympus__Exception__c FROM ELTON__Equipment_Order__c  WHERE ID=:oEltonOrder.Id];
            oOrder.ELTONOlympus__Exception__c ='18 Month Eval';
            update oOrder;
            test.stopTest();
           
        }
        
     }
     
         static  testmethod void insertELTONOrderToTriggerApproval() {
      
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        UserRole r1 = HSFE_TestUtility_Class.createRoleRVP();
        insert r1;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
        //Insert User record
        User Usr2 =  HSFE_TestUtility_Class.create2User(r1);
        insert Usr2;
        
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
            
            //Insert the account record       
            Account acc1 = HSFE_TestUtility_Class.createAccountRecord2();
            insert acc1;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');        
    
            //Insert AccountTerritory
            HSFE_Account_Territory__c accter = HSFE_TestUtility_Class.createAccountTerritory(acc,terr);
            insert accter;
            
            //Insert  contact record      
            Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
            con.HSFE_Primary__c = True;
            insert con;
            
            //check whether the contact is inserted properly
            System.Assert(con.Id != null, 'The Test Contact did not insert properly, please check validation rules and other mechanisms');
            
            Id pricebookId = Test.getStandardPricebookId();
            
            //Insert Opporuntiy record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            opp.HSFE_Secondary_Owner__c = Usr2.id;
            opp.HSFE_Service_Amount__c=200.00;
            insert opp;
            
            ELTONOlympus__Equipment_Configuration__c EqConfigs = new ELTONOlympus__Equipment_Configuration__c();
            EqConfigs.ELTONOlympus__Return_To_Warehouse_Account__c = acc1.Id;
            insert EqConfigs;

            //Insert an ELTON Order record
            ELTON__Equipment_Order__c oEltonOrder= new ELTON__Equipment_Order__c();
            oEltonOrder.ELTON__Opportunity__c=opp.Id;
            oEltonOrder.ELTONOlympus__Exception__c ='18 Month Eval';
            oEltonOrder.ELTONOlympus__Primary_Salesperson__c=Usr.Id;
            insert oEltonOrder;
        }
        
     }
}