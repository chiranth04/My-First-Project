/* 
*Class Name :HSFE_LeadTriggerHandler_TestClass 
*Description :This test class test the functionlity and covers the code for HSFE_Lead_TriggerHandler trigger.
*Created By  :Sunil Kumar
*Created On  :02/26/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Sunil              2/26/2015                      Created                          
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest 
private class HSFE_LeadTriggerHandler_TestClass {
    
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
            
            Contact con= HSFE_TestUtility_Class.createContactRecord(acc);
            con.HSFE_Primary__c=True;
            insert con;
            
            //Insert the Lead record
            Lead lead = HSFE_TestUtility_Class.createLeadRecord(acc);
            lead.LastName='TBD';
            lead.HSFE_Assign_Primary_Contact__c=true;
            insert lead;       
            
            lead.HSFE_SAP_ID__c='23232123';
            update lead;
            
            Lead.HSFE_SAP_ID__c='';
            update lead;
            
            //call the custom lead convert controller by passing lead and account Id
            HSFE_CustomConvertLead_Controller.HSFEConvertLeadMethod(lead.Id,acc.Id);            
           
            //Check account name populated is based on the SAP ID
            System.Assert(lead.HSFE_Account__c != null, 'Validate Account is populated based on the SAP ID');
           
            Lead l = [select HSFE_Territory__c,ownerID from lead where id =: lead.id];
            
            //insert multiple lead records
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleLeadRecord(acc);
           insert leadList;
            
        }   
    }  
    
    public static testMethod void testmethod2(){
        
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        System.runAs(usr){ 
            //Insert the account record       
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
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c trrException = HSFE_TestUtility_class.createHSFETerritoryException(terry);
            insert trrException;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr3(terry);
            insert zipToTerr;        
            
            
            //Insert the Lead record
            Lead lead1 = HSFE_TestUtility_Class.createLeadRecord2(acc);
            insert lead1; 
            
            
            //Check account name populated is based on the SAP ID
            System.Assert(lead1.HSFE_Account__c != null, 'Validate Account is populated based on the SAP ID');
            Lead l = [select ownerID,HSFE_Territory__c from lead where id =: lead1.id];
            System.Assert(l.HSFE_Territory__c == terry.id); //Validate territory.
            System.Assert(l.ownerid == Usr.id); // Validate Lead Owner 
            
            lead1.HSFE_Specialty__c='Medical';
            update lead1;
            
        }
            
    }
        public static testMethod void testAsRVP(){
        
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRoleRVP();
        insert r;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        System.runAs(usr){ 
            //Insert the account record       
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
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c trrException = HSFE_TestUtility_class.createHSFETerritoryException(terry);
            insert trrException;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr3(terry);
            insert zipToTerr;        
            
            
            //Insert the Lead record
            Lead lead1 = HSFE_TestUtility_Class.createLeadRecord2(acc);
            insert lead1; 
            
            //Check account name populated is based on the SAP ID
            System.Assert(lead1.HSFE_Account__c != null, 'Validate Account is populated based on the SAP ID');
            Lead l = [select ownerID,HSFE_Territory__c from lead where id =: lead1.id];
            System.Assert(l.HSFE_Territory__c == terry.id); //Validate territory.
            System.Assert(l.ownerid == Usr.id); // Validate Lead Owner 
            
            lead1.HSFE_Specialty__c='Surgical';
            update lead1;
            
        }
            
    }
    public static testMethod void testAsInsideSales(){
        
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRoleInsideSales();
        insert r;
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
        System.runAs(usr){ 
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert Contact Record
            Contact oCon= HSFE_TestUtility_Class.createContactRecord(acc);
            oCon.HSFE_Primary__c = true;
            insert oCon;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
            
             //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            insert trrToUsr;
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c trrException = HSFE_TestUtility_class.createHSFETerritoryException(terry);
            insert trrException;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr3(terry);
            insert zipToTerr;        
           
            //Insert the Lead record
            Lead lead1 = HSFE_TestUtility_Class.createLeadRecord2(acc);
            insert lead1; 
            
            
            //Check account name populated is based on the SAP ID
            System.Assert(lead1.HSFE_Account__c != null, 'Validate Account is populated based on the SAP ID');
            Lead l = [select ownerID,HSFE_Territory__c from lead where id =: lead1.id];
            System.Assert(l.HSFE_Territory__c == terry.id); //Validate territory.
            System.Assert(l.ownerid == Usr.id); // Validate Lead Owner 
            
            lead1.HSFE_Specialty__c='Surgical';
            update lead1;
            
            Lead oLead = [select ownerID,HSFE_Territory__c from lead where id =: lead1.id];
            oLead.HSFE_Specialty__c='Medical';
            update oLead ;
            
            //insert multiple lead records
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleLeadRecord(acc);
            insert leadList;
            
            
        }
            
    }
    
    
    public static testMethod void testAsInsideSales2(){
        
        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRoleInsideSales();
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
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c trrException = HSFE_TestUtility_class.createHSFETerritoryException(terry);
            insert trrException;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr3(terry);
            insert zipToTerr;        
          
            //Insert the account record  
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert Contact Record
            Contact oCon= HSFE_TestUtility_Class.createContactRecord(acc);
            oCon.HSFE_Primary__c = true;
            insert oCon;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
            
            //Insert the Lead record
            Lead lead1 = HSFE_TestUtility_Class.createLeadRecord2(acc);
            lead1.HSFE_Specialty__c =HSFE_Constant.MEDICAL;
            insert lead1; 
            
            //insert multiple lead records
            List<Lead> leadList = HSFE_TestUtility_Class.createmultipleMedicalLeadRecord(acc);
            insert leadList;
        
        
        }
    }
    public static testMethod void testAsUserWithNoRole(){
        
    
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUserNoRole();
        insert Usr;
        System.runAs(usr){ 
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert Contact Record
            Contact oCon= HSFE_TestUtility_Class.createContactRecord(acc);
            oCon.HSFE_Primary__c = true;
            insert oCon;
            
            //check whether account is inserted properly
            System.Assert(acc.Id != null, 'The Test Account did not insert properly, please check validation rules and other mechanisms');
            
             //Insert Territory record
            HSEF_Territory__c terry = HSFE_TestUtility_Class.createTerritory();
            insert terry;
            
            //Insert Territory to User
            HSFE_Territory_To_User__c trrToUsr= HSFE_TestUtility_Class.createTerritoryUser(Usr,terry);
            //trrToUsr.HSFE_User_Active__c = true;
            insert trrToUsr;
            
            //Insert Territory Exception
            HSFE_Territory_Exception__c trrException = HSFE_TestUtility_class.createHSFETerritoryException(terry);
            insert trrException;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipToTerr=  HSFE_TestUtility_Class.createHSFEZipterr3(terry);
            insert zipToTerr;        
            
            
            //Insert the Lead record
            Lead lead1 = HSFE_TestUtility_Class.createLeadRecord2(acc);
            insert lead1; 
            
            
            
            //Check account name populated is based on the SAP ID
            System.Assert(lead1.HSFE_Account__c != null, 'Validate Account is populated based on the SAP ID');
            Lead l = [select ownerID,HSFE_Territory__c from lead where id =: lead1.id];
            System.Assert(l.HSFE_Territory__c == terry.id); //Validate territory.
            //System.Assert(l.ownerid == usr.id); // Validate Lead Owner 
            
            lead1.HSFE_Specialty__c='Surgical';
            update lead1;
            
            Lead oLead = [select ownerID,HSFE_Territory__c from lead where id =: lead1.id];
            oLead.HSFE_Specialty__c='Medical';
            update oLead ;
        }
            
    }
}