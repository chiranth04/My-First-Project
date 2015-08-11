/**
 Version             : 1.0 
 Created Date        : 06 May 2016
 Function            : This class covers the code and test the functionaliy of Utility Class
 Modification Log    :
 * Developer                      Date                                    Description
 * ----------------------------------------------------------------------------                 
 * Chiranth Aradhya                06/26/2015                              Original Version
 *************************************************************************************
 */
@isTest
private class HSFE_Utility_TestClass {
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
            
            //Insert the lead record 
            Lead l = HSFE_TestUtility_Class.createLeadRecord(acc);
            insert l;
        
            //Insert the lead record 
            Lead l2 = HSFE_TestUtility_Class.createLeadRecord2(acc);
            insert l2;
        
            //Insert Opportunity record
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            insert opp;
            
            //Insert  contact record 
            Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
            con.HSFE_Primary__c = True;
            insert con;
            
            //Insert Event with lead with and  meeting Type Inservice
            Event evd1 = new Event(WhoId=l.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ON_PATIENT_EVALUATION, DurationInMinutes = 30, ActivityDateTime = System.today());
            insert evd1;
            
            //Insert Event with lead with and  meeting Type Inservice
            Event evd2 = new Event(WhoId=l.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.DEMONSTRATION, DurationInMinutes = 30, ActivityDateTime = System.today());
            insert evd2;
            
            //Insert Event with lead with and  meeting Type Inservice
            Event evd3 = new Event(WhoId=con.Id,WhatId=opp.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ON_PATIENT_EVALUATION, DurationInMinutes = 30, ActivityDateTime = System.today());
            insert evd3;
            
            //Insert Event with lead with and  meeting Type Inservice
            Event evd5 = new Event(WhoId=con.Id,WhatId=opp.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.DEMONSTRATION, DurationInMinutes = 30, ActivityDateTime = System.today());
            insert evd5;
            
            //Insert Event with lead with and  meeting Type Inservice
            Event evd4 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ON_PATIENT_EVALUATION, DurationInMinutes = 30, ActivityDateTime = System.today());
            insert evd4;
            
            
            //Insert Event with lead with and  meeting Type Inservice
            Event evd6 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.DEMONSTRATION, DurationInMinutes = 30, ActivityDateTime = System.today());
            insert evd6;
            
           // HSFE_Utility_Class utilClass = new HSFE_Utility_Class();
              /***********************[divya 04/08]: Commented out for deployment without ELTON*****************/
           /* HSFE_Utility_Class.newOrderURL(evd1.id);
            HSFE_Utility_Class.newOrderURL(evd2.id);
            HSFE_Utility_Class.newOrderURL(evd3.id);
            HSFE_Utility_Class.newOrderURL(evd4.id);
            HSFE_Utility_Class.newOrderURL(evd5.id);
            HSFE_Utility_Class.newOrderURL(evd6.id);*/
            /***********************[divya 04/08]:Commenting out ends****************************************/
            }
        }
        static  testmethod void testmethod2() {
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
                
                HSFE_Utility_Class.newOpportunityURL(acc.Name,acc.id);
                
            }
    }
    Static testmethod void serializeListToJSONTest(){
        
        List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
        //Insert the User Role record
        UserRole NewUserRole=new UserRole();
        NewUserRole=  HSFE_TestUtility_Class.createRole();
        NewUserRole.Name=HSFE_Constant.GVP;
        insert NewUserRole;
        
        //Insert the User record
        User NewcreateUser=new User();
        NewcreateUser = HSFE_TestUtility_Class.createUser(NewUserRole);
        NewcreateUser.HSFE_Specialty__c=HSFE_Constant.MEDICAL;
        insert NewcreateUser;
        System.runAs(NewcreateUser){
            //create Account
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            Insert acc;
            
            //Insert the AccountTeamMember record
            AccountTeamMember ATM=new AccountTeamMember();
            ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(acc.id,NewcreateUser.id,'Test');
            insert ATM;

            //create Opportunity
            Opportunity oppt = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            Insert oppt;
            
            // Create Proposal Record
            Apttus_Proposal__Proposal__c newProposal = new Apttus_Proposal__Proposal__c();
            newProposal = HSFE_TestUtility_Class.CreateSingleProposal(oppt, acc, NewcreateUser, 'Q1234567');
            Insert newProposal;

            //create Product
            List<Product2> prodRecList = HSFE_TestUtility_Class.createProductRecords(1,'test');
            Product2 prodRec = prodRecList[0];
            //create Line Item
            Apttus_Config2__LineItem__c lineItem = HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(newProposal);
            lineItem.Apttus_Config2__BasePrice__c = 5608.00;        
            Insert lineItem;

            lineItemList = [Select 
                                Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c,
                                Product_Conditions__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Id,HSFE_Serial_Number__c,
                                Apttus_Config2__BasePrice__c, HSFE_Product_Part_Number__c, HSFE_Line_Item_Extension__c   
                            from Apttus_Config2__LineItem__c
                            where 
                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.HSFE_SAP_ID__c != null and 
                                Apttus_Config2__BasePrice__c != null and HSFE_Product_Part_Number__c != null];

            if (lineItemList.size() > 0){
                Test.startTest();
                String JSONRequest = HSFE_Utility_Class.serializeListToJSON(lineItemList, HSFE_Constant.CONTRACT_PRICING);
                String JSONRequestSerNumCheck = HSFE_Utility_Class.serializeListToJSONSerNumCheck(lineItemList, HSFE_Constant.SERIAL_NUM_CHECK);
                System.assertNotEquals(JSONRequest, null);
                Set<Id> lineItemSet = HSFE_Utility_Class.deserializeJSONtoList(JSONRequest);
                String LineItemExtID = lineItemList[0].HSFE_Line_Item_Extension__c;
                System.assertNotEquals(lineItemSet, null);
                HSFE_Utility_Class.insertIntegrationRetryObject(JSONRequest, HSFE_Constant.CONTRACT_PRICING, HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME);
                List<HSFE_Integration_Retry_Object__c> retryList = [Select Id, HSFE_Record_Id__c from HSFE_Integration_Retry_Object__c where HSFE_Record_Id__c =:LineItemExtID];
                System.assertEquals(retryList.size(), 1);
                Test.stopTest();
            }
        }
    }
}