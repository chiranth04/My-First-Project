/* 
*Class Name :HSFE_LeadTerritoryAssign_BatchTestClass 
*Description :This test class test the functionlity and covers the code for HSFE_LeadTerritoryAssignment_BatchClass batch class.
*Created By  :Sunil Kumar
*Created On  :04/15/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Sunil Kumar                 04/15/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_LeadTerritoryAssign_BatchTestClass {
    static testmethod void testmethod1() {
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
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
              //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;        
           
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
            insert expectionObj;
            
            HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
            insert temZipObj;
            //Insert Lead records        
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleLeadRecord(acc);
            insert leadList;
           Test.startTest();
                HSFE_LeadTerritoryAssignment_BatchClass b = new HSFE_LeadTerritoryAssignment_BatchClass();
                Database.executeBatch(b); 
                //TO Validate all 200 lead records are inserted.
                System.assert(leadList.size()==200,'Total Lead is not properly inserted' ) ;
                //To validate the owner id is properly assigned.
                List<Lead> newLeadList = new List<Lead>([select id,ownerid from lead where id in : leadList]);
                System.assertEquals(newLeadList[0].ownerID,Usr.id);             
            Test.stopTest();
         
         }
    }
    static testmethod void testmethod2() {
         //Insert Role
        UserRole r = new UserRole();
        r.name = HSFE_Constant.RVP;
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
         System.runAs(usr){  
            HSFE_Utility_Class.stopUpdateAccountTerritory = true;
            HSFE_Utility_Class.stopUpdateLeadTerritory = true;  
            //Insert  account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
              //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;        
           
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
            insert expectionObj;
            
            HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
            insert temZipObj;
            //Insert Lead records        
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleLeadRecord(acc);
            insert leadList;
           Test.startTest();
                HSFE_LeadTerritoryAssignment_BatchClass b = new HSFE_LeadTerritoryAssignment_BatchClass();
                Database.executeBatch(b); 
                //TO Validate all 200 lead records are inserted.
                System.assert(leadList.size()==200,'Total Lead is not properly inserted' ) ;
                //To validate the owner id is properly assigned.
                List<Lead> newLeadList = new List<Lead>([select id,ownerid from lead where id in : leadList]);
                System.assertEquals(newLeadList[0].ownerID,Usr.id);                    
            Test.stopTest();
         }
    }
    static testmethod void testmethod3() {
         //Insert Role
        UserRole r = new UserRole();
        r.name = HSFE_Constant.INSIDESALES;
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
         System.runAs(usr){  
            HSFE_Utility_Class.stopUpdateAccountTerritory = true;
            HSFE_Utility_Class.stopUpdateLeadTerritory = true;  
            //Insert  account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
              //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;        
           
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
            insert expectionObj;
            
            HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
            insert temZipObj;
            //Insert Lead records        
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleLeadRecord(acc);
            insert leadList;            
           Test.startTest();
                HSFE_LeadTerritoryAssignment_BatchClass b = new HSFE_LeadTerritoryAssignment_BatchClass();
                Database.executeBatch(b);
                 //TO Validate all 200 lead records are inserted.
                System.assert(leadList.size()==200,'Total Lead is not properly inserted' ) ;
                //To validate the owner id is properly assigned.
                List<Lead> newLeadList = new List<Lead>([select id,ownerid from lead where id in : leadList]);
                System.assertEquals(newLeadList[0].ownerID,Usr.id);                     
            Test.stopTest();
            
           
         }
    }
    static testmethod void testmethod4(){
        UserRole r = new UserRole();
        r.name = HSFE_Constant.INSIDESALES;
        insert r;
       //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        
         System.runAs(usr){  
            HSFE_Utility_Class.stopUpdateAccountTerritory = true;
            HSFE_Utility_Class.stopUpdateLeadTerritory = true;  
            //Insert  account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
              //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEMedicalZipterr(terry);
            insert zipToTerr;        
           
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
            insert expectionObj;
            
            HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
            insert temZipObj;
            //Insert Lead records        
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleMedicalLeadRecord(acc);
            insert leadList;
          Test.startTest();
             HSFE_LeadTerritoryAssignment_BatchClass b = new HSFE_LeadTerritoryAssignment_BatchClass();
             Database.executeBatch(b);
             //TO Validate all 200 lead records are inserted.
             System.assert(leadList.size()==200,'Total Lead is not properly inserted' ) ;
            //To validate the owner id is properly assigned.
            List<Lead> newLeadList = new List<Lead>([select id,ownerid from lead where id in : leadList]);
            System.assertEquals(newLeadList[0].ownerID,Usr.id);                    
          Test.stopTest();
            
           
         }
    
    }
    
    static testmethod void testmethod5(){
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
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
              //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;        
            
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
            insert expectionObj;
            
            HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
            insert temZipObj;
            //Insert Lead records        
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleLeadRecord(acc);
            for(Lead l : leadList){
                l.HSFE_SAP_ID__c = '';
            }
            insert leadList;
           Test.startTest();
                HSFE_LeadTerritoryAssignment_BatchClass b = new HSFE_LeadTerritoryAssignment_BatchClass();
                Database.executeBatch(b);
                 //TO Validate all 200 lead records are inserted.
                System.assert(leadList.size()==200,'Total Lead is not properly inserted' ) ;
                //To validate the owner id is properly assigned.
                List<Lead> newLeadList = new List<Lead>([select id,ownerid from lead where id in : leadList]);
                System.assertEquals(newLeadList[0].ownerID,Usr.id);                     
            Test.stopTest();
        } 
        
    }
    //To cover the catch block
    static testmethod void testmethod6(){
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
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
              //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr(terry);
            insert zipToTerr;        
            
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c expectionObj = HSFE_TestUtility_Class.createHSFETerritoryException(terry);
            insert expectionObj;
            
            HSFE_Updated_Zip_Code_Temporary__c temZipObj = HSFE_TestUtility_Class.createUpdateTemp();
            insert temZipObj;
            //Insert Lead records        
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleLeadRecord(acc);            
            insert leadList;
            
           Test.startTest();
                HSFE_LeadTerritoryAssignment_BatchClass b = new HSFE_LeadTerritoryAssignment_BatchClass();
                b.start(null);                               
            Test.stopTest();
        } 
        
    }
    
}