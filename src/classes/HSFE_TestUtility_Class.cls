/* 
*Class Name :HSFE_TestUtility_Class 
*Description :This is common test utility class that contain reusable code for test data creation.
*Created By  :Chiranth Aradhya
*Created On  :02/17/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Ajay Agnihotri             18/May/2015                                                         Added Code to CreateSingleProposal, createSingleAccountTeamMember etc
*Ajay Agnihotri             2/July/2015                                                         Created Method to create Multiple Records And ReturnLineItem
*Ajay Agnihotri             7/July/2015                                                         Created Method to Create_HSFE_Contant_Helper_Data
Ajay Agnihotri              9/July/2015                                                         Created Method to Create_SingleELTON__Equipment_Data
Sunil Kumar                 14/July/2015                                                        Updated for territory chnages.
*
*/
@isTest
public class HSFE_TestUtility_Class {

    
    public static void HSFE_InsertCustomSetting_Data(){                    
        HSFE_Contant_Helper__c Rec1 = new HSFE_Contant_Helper__c();
        Rec1.Name = 'HSFE_Price_List_Item_TriggerHandler';
        Rec1.HSFE_Value__c = 'True';
        insert Rec1;
        
        HSFE_Contant_Helper__c Rec2 = new HSFE_Contant_Helper__c();
        Rec2.Name = 'HSFE_Matrix_Entry_TriggerHandler';
        Rec2.HSFE_Value__c = 'True';       
        insert Rec2;
    }    
    
    public static UserRole createRole(){
        UserRole r = new UserRole(name =HSFE_Constant.TM);
        return r;
    }
    
    public static UserRole createRoleRVP(){
        UserRole r = new UserRole(name =HSFE_Constant.RVP);
        return r;
    }
     public static UserRole createRoleInsideSales(){
        UserRole r = new UserRole(name =HSFE_Constant.INSIDESALES);
        return r;
    }
     public static User createUserNoRole(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='stestUser@testorg.com', IsActive=TRUE
            ,EmployeeNumber='1234');
            return u;
     }
     
     public static User createIntegrationUserProfileUser(UserRole r){
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration User Profile']; 
        User u = new User(Alias = 'standt', Email='testUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId = r.id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stestUser@testorg.com');
            return u;
     }

     public static void CreateCustomSettingData(){
         HSFE_Contant_Helper__c Data = new HSFE_Contant_Helper__c();
         Data.name = 'HSFE_System_Administrator_Profile';
         Data.HSFE_Value__c = UserInfo.getProfileId();
         insert Data;
     
     }
     
  
    public static User createUser(UserRole r){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId = r.id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stestUser@testorg.com',EmployeeNumber='1234');
            return u;
     }
     
     public static User create2User(UserRole r){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testStdUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId = r.id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stestStdUser@testorg.com',EmployeeNumber='1234');
            return u;
     }
     
     public static User createUser2(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='testStdUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, HSFE_Specialty__c='Medical',HSFE_Sub_Specialty__c='Endoscopy',
            TimeZoneSidKey='America/Los_Angeles', UserName='stestStdUser@testorg.com',EmployeeNumber='1234');
            return u;
     }  
     
     public static List <Product2> createProductRecords(Integer noOfRecords, String prefix) {
         List<Product2> prodList = new List<Product2>();
         HSFE_InsertCustomSetting_Data();
         for (Integer i=0; i<noOfRecords;i++) {
             Product2 prod = new Product2();
             prod.HSFE_Part_Number__c = 'testProd'+prefix+i;
             prod.Name = 'testProd'+prefix+i;
             prod.HSFE_Product_Conditions_Multi__c = 'CPO;Demo;New;Trade-In - Olympus';
             prod.IsActive=true;
             prodList.add(prod);
         }

        HSFE_Product_Attribute_Charge_Types__c Reco = new HSFE_Product_Attribute_Charge_Types__c();
        Reco.Name = 'Charge Type 10';
        Reco.HSFE_Description__c = '{CPO,Demo,New,Trade-In - Olympus}';
        Reco.HSFE_Name_LongSKP__c = 'CPO;Demo;New';
        Reco.HSFE_Name_Long__c = 'CPO;Demo;New;Trade-In - Olympus';
        Reco.HSFE_SKP_Charge_Type__c = 'Charge Type 33';
        insert Reco;
        
        return prodList;   
    }
     
     
     public static List<Account> createmultipleAccount(){
         List<Account> accs = new List<Account>();
         for (Integer i = 0; i < 10; i++) {
            Account acct = new Account();
            acct.Name='Test Account'+i;
            acct.HSFE_SAP_ID__c = '12345' + i;
            acct.BillingPostalCode='12345';
            accs.add(acct);
         }
         return accs;
     }     
     
    public static Account createAccountRecord() {       
        Account acct= new Account();             
        acct.Name='Test Account';
        acct.HSFE_SAP_ID__c = '12345';
        acct.BillingPostalCode='12345';     
        return acct;
    }
    
     public static Account createAccountRecord1() {       
        Account acct= new Account();             
        acct.Name='Test Account';
        acct.HSFE_SAP_ID__c = '1as2ad345abcd123x';
        acct.BillingPostalCode='12345';     
        return acct;
    }
    
    
    public static Account createAccountRecord2() {       
        Account acct= new Account();             
        acct.Name='Test Account';
        acct.HSFE_SAP_ID__c = 'Ac12345';
        acct.BillingPostalCode='17682345';     
        return acct;
    }
    
    public static Account createInactiveContacts() {       
        Account acct= new Account();             
        acct.Name='Inactive Contacts';
        acct.HSFE_SAP_ID__c = 'ACC12345';
        acct.BillingPostalCode='123456';     
        return acct;
    }
    
    public static Lead createLeadRecord(Account acc){
        Lead l = new Lead();
        l.LastName='test';
        l.Company='test';
        l.Email='test@test.com';
        l.HSFE_Account__c =acc.Id;
        l.Status='Qualified';
        l.HSFE_SAP_ID__c = '12345';
        l.PostalCode='1234';
        l.HSFE_Specialty__c ='Medical';
        l.HSFE_Sub_Speciality__c='Endoscopy';
        l.HSFE_Ex_Territory_Assignment_Rule__c = false;
        l.HSFE_Expected_Close_Date__c = system.today();
        l.HSFE_Disposables_Total__c=1000;
        l.HSFE_Service_Total__c=100;
        return l;
    }
    
    public static Lead createLeadRecord2(Account acc){
        Lead l = new Lead();
        l.LastName='test';
        l.Company='test';
        l.Email='test22@test.com';
        l.HSFE_Account__c =acc.Id;
        l.Status='Qualified';
        l.HSFE_SAP_ID__c = '12345';
        l.PostalCode='123456';
        l.HSFE_Specialty__c ='Surgical';
        l.HSFE_Sub_Speciality__c='Energy';
        l.HSFE_Ex_Territory_Assignment_Rule__c = false;
        l.HSFE_Disposables_Total__c=1000;
        l.HSFE_Service_Total__c=100;
        return l;
    }
    public static Lead createLeadwithTerr(Account acc, HSEF_Territory__c  tr){
        Lead l = new Lead();
        l.LastName='test1';
        l.Company='test';
        l.Email='test1@test.com';
        l.HSFE_Account__c =acc.Id;
        l.Status='Qualified';
        l.HSFE_SAP_ID__c = '12345';
        l.HSFE_Territory__c =tr.id;
        l.HSFE_Disposables_Total__c=1000;
        l.HSFE_Service_Total__c=100;        
        return l;
    }
    public static Contact createContactRecord( Account acc) {       

        Contact con= new Contact();
        con.LastName='Test contact';
        con.Email='test@test.com';     
        con.AccountId = acc.Id;
        con.HSFE_Specialty__c='Surgical';
        con.HSFE_Sub_Specialty__c='Energy';
        return con;
            
    }
    public static Contact createContactRecord2( Account acc) {       

        Contact con= new Contact();
        con.LastName='Test2 contact';
        con.Email='test2@test.com';     
        con.AccountId = acc.Id;
        con.HSFE_Specialty__c='Surgical';
        con.HSFE_Sub_Specialty__c='Energy';
        return con;
            
    }
    public static List<Contact> createmultipleContactRecord( Account acc) {
         List<Contact > conss = new List<Contact >();
         for (Integer i = 0; i < 200; i++) {
            Contact con= new Contact();
            con.LastName='Test5 contact';
            con.Email='test5@test.com';     
            con.AccountId = acc.Id;
            conss.add(con);
         }
         return conss;
    }
    public static List<Lead> createmultipleLeadRecord(Account acc){
        List<Lead> leadList = new List<Lead>();
        for(Integer i=0;i<200;i++){
            Lead l = new Lead();
            l.LastName='TBD';
            l.HSFE_Assign_Primary_Contact__c=true;
            l.Company='test';
            l.Email='test@test.com';
            l.HSFE_Account__c =acc.Id;
            l.Status='Qualified';
            l.HSFE_SAP_ID__c = '12345';
            l.PostalCode='123456';
            l.HSFE_Specialty__c ='Surgical';
            l.HSFE_Sub_Speciality__c='Energy';
            l.HSFE_Ex_Territory_Assignment_Rule__c = false;
            l.HSFE_Expected_Close_Date__c = system.today();
            l.HSFE_Disposables_Total__c=1000;
            l.HSFE_Service_Total__c=100;
            leadList.add(l);            
        }
        return leadList;
    }
    
    public static List<Lead> createmultipleMedicalLeadRecord(Account acc){
        List<Lead> leadList = new List<Lead>();
        for(Integer i=0;i<200;i++){
            Lead l = new Lead();
            l.LastName='test';
            l.Company='test';
            l.Email='test@test.com';
            l.HSFE_Account__c =acc.Id;
            l.Status='Qualified';
            l.HSFE_SAP_ID__c = '12345';
            l.PostalCode='1234';
            l.HSFE_Specialty__c ='Medical';
            l.HSFE_Sub_Speciality__c='Endoscopy';
            l.HSFE_Expected_Close_Date__c=system.today();
            l.HSFE_Ex_Territory_Assignment_Rule__c = false;
            l.HSFE_Expected_Close_Date__c = system.today();
            l.HSFE_Disposables_Total__c=1000;
            l.HSFE_Service_Total__c=100;
            leadList.add(l);            
        }
        return leadList;
    }
    public static List<Opportunity> createmultipleOpportunityRecord(String accID){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<200;i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Test';
            opp.AccountId = accID;
            opp.CloseDate = system.today();
            opp.HSFE_Specialty__c = 'Surgical';
            opp.HSFE_Sub_Specialty__c = 'Energy';
            opp.HSFE_Opportunity_Type__c='New Business';
            opp.stageName = 'Pipeline';
            opp.HSFE_Disposable_Amount__c=1000;
            opp.HSFE_Service_Amount__c=100;
            oppList.add(opp);       
        }
        return oppList;
    }
    
    public static void createPriceBook(){
        Product2 prod = new Product2(Name = 'Laptop X200', 
            Family = 'Hardware');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
    }
    
     public static void createPriceBookEntry(String id){
         
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
    }
       
    
    public static Opportunity createOpportunityRecord( Account acc ) {       
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = OpportunityRecordTypeInfo.get('Customer').getRecordTypeId();
        Date TodayDate = Date.today();
        Date fiveDayDate = TodayDate.addDays(HSFE_Constant.NUMBER_OF_DAYS);
        Opportunity opp= new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name='Test';
        opp.HSFE_Opportunity_Type__c='New Business';
        opp.CloseDate= fiveDayDate;
        opp.StageName='Omitted';
        opp.HSFE_Specialty__c='Surgical';
        opp.HSFE_Sub_Specialty__c='Energy';
        opp.HSFE_Sales_Stage__c= 'Universe';
        opp.HSFE_Funding_Probability__c= 'No Budget';
        opp.HSFE_Product_Category__c = 'Capital';
        opp.HSFE_Competitive_Probability__c= 'Prefer Competition, No discussion';
        opp.RecordTypeId=rtId;
        opp.HSFE_Disposable_Amount__c=1000;
        opp.HSFE_Service_Amount__c=100;
        return opp;
            
    }
     
    public static Opportunity createOpporutnitywithCustomerRecordType(Account acc){
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = OpportunityRecordTypeInfo.get('Customer').getRecordTypeId();
        Opportunity opp= new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name='Test';
        opp.HSFE_Opportunity_Type__c='Customer';
        opp.CloseDate=System.Today();
        opp.StageName='Pipeline';
        opp.HSFE_Specialty__c='Surgical';
        opp.HSFE_Sub_Specialty__c='Energy';
        opp.RecordTypeId=rtId;
        opp.HSFE_Disposable_Amount__c=1000;
        opp.HSFE_Service_Amount__c=100;
        return opp;
        
    }
      public static Opportunity createOpportunityRecord2( Account acc) {       
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = OpportunityRecordTypeInfo.get('Customer').getRecordTypeId();
        Opportunity opp= new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name='Test';
        opp.CloseDate=System.Today();
        opp.StageName='Pipeline';
        opp.HSFE_Specialty__c='Surgical';
        opp.HSFE_Opportunity_Type__c='Customer';
        opp.HSFE_Sub_Specialty__c='Energy';
        opp.RecordTypeId=rtId;
        opp.HSFE_Disposable_Amount__c=1000;
        opp.HSFE_Service_Amount__c=100;
        return opp;
            
    }
     
    public static HSEF_Territory__c createTerritory(){
        HSEF_Territory__c terty= new HSEF_Territory__c();
        terty.Name='test';
        terty.HSFE_Territory_Name__c ='t1';
        terty.HSFE_Territory_External_ID__c='test';
        return terty;
    }
    public static HSEF_Territory__c createSecondTerritory(){
        HSEF_Territory__c terty= new HSEF_Territory__c();
        terty.Name='test1';
        terty.HSFE_Territory_Name__c ='t2';
        terty.HSFE_Territory_External_ID__c='test1';
        return terty;
    }
    
    public static HSFE_Territory_To_User__c createTerritoryUser(User usr,HSEF_Territory__c terty ){
        HSFE_Territory_To_User__c tusr = new HSFE_Territory_To_User__c ();
        HSEF_Territory__c terObj = new HSEF_Territory__c();
        User u = new user();
        u = [select id,EmployeeNumber from user where id=:usr.Id and EmployeeNumber != null];
        terObj = [select id,Name from HSEF_Territory__c where id=:terty.id];
        tusr.HSFE_Territory__c =terty.Id;
        tusr.HSFE_Combination_Key__c =u.EmployeeNumber+terObj.name; 
        tusr.HSFE_User__c=usr.Id;       
        return tusr;
    }
    
    public static List<HSFE_Territory_To_User__c>  createMultipleTerritoryUser(User usr,HSEF_Territory__c terty){
        List<HSFE_Territory_To_User__c  > terrToUserList = new List<HSFE_Territory_To_User__c  >();     
        HSEF_Territory__c terObj = new HSEF_Territory__c();
        User u =  new user();
        u = [select id,EmployeeNumber from user where id=:usr.Id and EmployeeNumber != null];
        terObj = [select id,Name from HSEF_Territory__c where id=:terty.id];
        for(Integer i=0;i<200;i++){
            HSFE_Territory_To_User__c tusr = new HSFE_Territory_To_User__c ();
            tusr.HSFE_Territory__c =terty.Id;
            tusr.HSFE_User__c=usr.Id;
            tusr.HSFE_Combination_Key__c =u.EmployeeNumber+terObj.name; 
            terrToUserList.add(tusr);
        }
        return terrToUserList;
    }
    
    public static HSFE_Zip_To_Territory__c createHSFEZipterr(HSEF_Territory__c terty){
        HSFE_Zip_To_Territory__c zipTr = new HSFE_Zip_To_Territory__c();
        zipTr.HSFE_Specialty__c = 'Surgical';
        ziptr.HSFE_Sub_Specialty__c='Energy';
        ziptr.HSFE_Territory__c=terty.Id;
        ziptr.Name='12345';
        ziptr.HSFE_Combination_Key__c='12345SurgicalEnergy';
        return ziptr;
        
    }
    public static HSFE_Zip_To_Territory__c createHSFEMedicalZipterr(HSEF_Territory__c terty){
        HSFE_Zip_To_Territory__c zipTr = new HSFE_Zip_To_Territory__c();
        zipTr.HSFE_Specialty__c = 'Medical';
        ziptr.HSFE_Sub_Specialty__c='Endoscopy';
        ziptr.HSFE_Territory__c=terty.Id;
        ziptr.Name='1234';
        ziptr.HSFE_Combination_Key__c='1234MedicalEndoscopy';
        return ziptr;
        
    }
    
    public static HSFE_Zip_To_Territory__c createHSFEZipterr3(HSEF_Territory__c terty){
        HSFE_Zip_To_Territory__c zipTr = new HSFE_Zip_To_Territory__c();
        zipTr.HSFE_Specialty__c = 'Surgical';
        ziptr.HSFE_Sub_Specialty__c='Energy';
        ziptr.HSFE_Territory__c=terty.Id;
        ziptr.HSFE_Combination_Key__c='12345SurgicalEnergy';
        ziptr.Name='12345';
        return ziptr;
    }
    
    public static HSFE_Zip_To_Territory__c createHSFEZipterr4(HSEF_Territory__c terty){
        HSFE_Zip_To_Territory__c zipTr = new HSFE_Zip_To_Territory__c();
        zipTr.HSFE_Specialty__c = 'Surgical';
        ziptr.HSFE_Sub_Specialty__c='Energy';
        ziptr.HSFE_Territory__c=terty.Id;
        ziptr.HSFE_Combination_Key__c='12345tdtSurgicalEnergy';
        ziptr.Name='12345tdt';
        return ziptr;
    }
    
    public static HSFE_Territory_Exception__c createHSFETerritoryException(HSEF_Territory__c territory){
        HSFE_Territory_Exception__c terrException = new HSFE_Territory_Exception__c();
        terrException.HSFE_Combination_Key__c = '1234512345SurgicalEnergy';
        terrException.HSFE_Specialty__c = 'Surgical';
        terrException.HSFE_Sub_Specialty__c = 'Energy';
        terrException.HSFE_Territory__c = territory.Id;
        terrException.Rep_Type__c = 'abc';
        terrException.HSFE_Zip_Code__c = '12345';
        terrException.Name = '12345';
        return terrException;
    }
    
    public static List<HSFE_Zip_To_Territory__c> createMultipleZiptoTerr(HSEF_Territory__c terty){
        List<HSFE_Zip_To_Territory__c> zipterrList = new List<HSFE_Zip_To_Territory__c>();
        for (Integer i = 0; i < 200; i++) {
            HSFE_Zip_To_Territory__c zipTr = new HSFE_Zip_To_Territory__c();
            String zip = String.valueOf(1000 + i);
            ziptr.Name=zip;
            zipTr.HSFE_Specialty__c = 'Medical';
            ziptr.HSFE_Sub_Specialty__c='Endoscopy';
            ziptr.HSFE_Territory__c=terty.Id;
            ziptr.HSFE_Combination_Key__c=zip+'MedicalEndoscopy';
            zipterrList.add(ziptr);
        }
    return zipterrList;
    }
    public static HSFE_Updated_Zip_Code_Temporary__c createUpdateTemp(){
        HSFE_Updated_Zip_Code_Temporary__c ztptemp = new HSFE_Updated_Zip_Code_Temporary__c();
        ztptemp.Name = '123456' ;
        return ztptemp;
    }
    public static HSFE_Zip_To_Territory__c createHSFEZipterr2(HSEF_Territory__c terty){
        HSFE_Zip_To_Territory__c zipTr = new HSFE_Zip_To_Territory__c();
        zipTr.HSFE_Specialty__c = 'Surgical';
        ziptr.HSFE_Sub_Specialty__c='Energy';
        ziptr.HSFE_Territory__c=terty.Id;
        ziptr.HSFE_Combination_Key__c='123SurgicalEnergy';
        ziptr.Name='123';
        return ziptr;
        
    }
    
    public static AccountTeamMember  createAccountTeamMember(Account acc, User Usr){
        AccountTeamMember   accTeam = new AccountTeamMember();
        accTeam.AccountId = acc.Id;
        accTeam.TeamMemberRole = 'Sales Rep';
        accTeam.UserId = Usr.Id;
        return accTeam;
    }
    public static HSFE_Account_Territory__c createAccountTerritory(String accid,HSEF_Territory__c ter){
        HSFE_Account_Territory__c accTerr = new HSFE_Account_Territory__c();
        accTerr.Account__c = accid;
        accTerr.Territory__c = ter.id;
        accTerr.HSFE_Specialty__c ='Surgical';
        accTerr.HSFE_Sub_Specialty__c = 'Energy';
        accTerr.HSFE_Combination_Key__c = accid+'SurgicalEnergy';
        return accTerr;     
    }
    
    public static Group createGroup(){
        Group testGroup = new Group();
        testGroup.Name = 'testGroup';
        testGroup.DeveloperName = 'ABC';
        return testGroup;
    }
    
    public static HSFE_Account_Territory__c createAccountTerritory(Account acc,HSEF_Territory__c terty){
        HSFE_Account_Territory__c accTerr = new HSFE_Account_Territory__c();
        accTerr.Account__c=acc.Id;
        accTerr.Territory__c=terty.Id;
        accTerr.HSFE_Specialty__c='Surgical';
        accTerr.HSFE_Sub_Specialty__c='Energy';
        accTerr.HSFE_Combination_Key__c=acc.Id+'SurgicalEnergy';
        return accTerr;
    }
    
    public static HSFE_Territory_Exception__c createTerritoryException(HSEF_Territory__c terty){
        HSFE_Territory_Exception__c terrExcep = new HSFE_Territory_Exception__c ();
        terrExcep.HSFE_Specialty__c='Surgical';
        terrExcep.HSFE_Sub_Specialty__c='Energy';
        terrExcep.HSFE_Territory__c=terty.Id;
        terrExcep.Name='12345';
        terrExcep.HSFE_Zip_Code__c='12345';
        terrExcep.HSFE_Combination_Key__c='1234512345SurgicalEnergy';
        return terrExcep;
    }
    
    public static List<Apttus_Proposal__Proposal__c> CreateMultipleProposal(Opportunity opp, Account acc, User u) {
        list <Apttus_Proposal__Proposal__c> propList = new List<Apttus_Proposal__Proposal__c>(); 
        for (Integer i=0; i<10;i++) {
            Apttus_Proposal__Proposal__c newProp = new Apttus_Proposal__Proposal__c();
            newProp.Apttus_Proposal__Opportunity__c=opp.id;         
            newProp.Apttus_Proposal__Account__c=acc.id;
            newProp.HSFE_Is_FIS__c=True;
            newProp.HSFE_Contract_Effective_Date__c=system.today();
            newProp.HSFE_FIS_Contract_Number__c='1223455';
            newProp.HSFE_Renewal_Lead_Created__c=False;
            propList.add(newProp);
        }       
        return propList;   
    }
    
    
    
    
    
    public static Apttus_Proposal__Proposal__c CreateSingleProposal(Opportunity opp, Account acc, User u,String PropName) {
        CreateCustomSettingData();
        Apttus_Proposal__Proposal__c PropInstace = new Apttus_Proposal__Proposal__c(); 
        PropInstace.Apttus_Proposal__Proposal_Name__c=PropName;
        PropInstace.Apttus_Proposal__Opportunity__c=opp.id;         
        PropInstace.Apttus_Proposal__Account__c=acc.id;  
        return PropInstace;   
    }
    
    public static AccountTeamMember createSingleAccountTeamMember(Id AccId,Id UserId,String TeamMembRole) {
        AccountTeamMember ATM=new AccountTeamMember(AccountId=AccId,TeamMemberRole=TeamMembRole,UserId=UserId);       
        return ATM;   
    }
    
    public static Apttus_Config2__ProductConfiguration__c createSingleProductConfiguration(Apttus_Proposal__Proposal__c ProposalObj){
        Apttus_Config2__ProductConfiguration__c ProductConfigurationObj = new Apttus_Config2__ProductConfiguration__c(name='Product Config -'+ProposalObj.Apttus_Proposal__Proposal_Name__c,Apttus_QPConfig__Proposald__c=ProposalObj.id,Apttus_Config2__BusinessObjectId__c=ProposalObj.id,Apttus_Config2__BusinessObjectType__c='Proposal');
        return ProductConfigurationObj;        
    }

    public static Apttus_Config2__TempObject__c createSingleTempObject(Apttus_Config2__ProductConfiguration__c ConfigObj){
        Apttus_Config2__TempObject__c TempObj = new Apttus_Config2__TempObject__c(Apttus_Config2__ConfigurationId__c=ConfigObj.id,Apttus_Config2__Data__c='Test');
        return TempObj;        
    }
    
    public static Apttus_Config2__LineItem__c createSingleLineItem(Apttus_Config2__ProductConfiguration__c ConfigObj,Apttus_Proposal__Proposal__c ProposalObj){
        Apttus_Config2__LineItem__c LineItemObj = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c=ConfigObj.id,HSFE_Quote_Id__c=ProposalObj.id,Apttus_Config2__ItemSequence__c=1,Apttus_Config2__LineNumber__c=1,HSFE_Contract_Integration_Status__c='Test');
        return LineItemObj;        
    }
    
    public static Apttus_Config2__LineItem__c createSingleLineItemWithCompleteData(Apttus_Config2__ProductConfiguration__c ConfigObj,Apttus_Proposal__Proposal__c ProposalObj){
        Apttus_Config2__LineItem__c LineItemObj = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c=ConfigObj.id,
                                                                                    HSFE_Quote_Id__c=ProposalObj.id,
                                                                                    Apttus_Config2__ItemSequence__c=1,
                                                                                    Apttus_Config2__LineNumber__c=1,
                                                                                    HSFE_Contract_Integration_Status__c='Test',
                                                                                    HSFE_No_of_Used__c=0,
                                                                                    Apttus_Config2__ConfigStatus__c='NA', 
                                                                                    Apttus_Config2__LineType__c='Product/Service', 
                                                                                    Apttus_Config2__ChargeType__c='New', 
                                                                                    Apttus_Config2__AdjustedPrice__c=0.00000, 
                                                                                    HSFE_Admin_Update_Flag__c=false,  
                                                                                    Apttus_Config2__LineStatus__c='New', 
                                                                                    Apttus_Config2__PriceMethod__c='Per Unit', 
                                                                                    Apttus_Config2__IsQuantityModifiable__c=true, 
                                                                                    Apttus_Config2__IsPrimaryLine__c=true, 
                                                                                    Charge_Type__c='Charge Type 14', 
                                                                                    Apttus_Config2__PricingStatus__c='Complete', 
                                                                                    HSFE_Target_Price__c=615.000, 
                                                                                    Apttus_Config2__TaxInclusive__c=false, 
                                                                                    Apttus_Config2__AllocateGroupAdjustment__c=false, 
                                                                                    HSFE_No_of_Other_Condition__c=0, 
                                                                                    Apttus_Config2__PriceType__c='One Time', 
                                                                                    Product_Conditions__c='New', 
                                                                                    Apttus_Config2__GroupAdjustmentPercent__c=0.0000, 
                                                                                    Apttus_Config2__BasePriceMethod__c='Per Unit', 
                                                                                    Apttus_Config2__ExtendedPrice__c=0.00000, 
                                                                                    Apttus_Config2__Cost__c=501.00000, 
                                                                                    Apttus_Config2__IsPrimaryRampLine__c=false, 
                                                                                    HSFE_Invalid_Serial_Number__c=false, 
                                                                                    HSFE_No_of_Trade_In__c=0, 
                                                                                    Apttus_Config2__IsOptionRollupLine__c=false, 
                                                                                    Apttus_Config2__ConstraintCheckStatus__c='NA', 
                                                                                    Apttus_Config2__Quantity__c=1.00000, 
                                                                                    Apttus_Config2__IsAssetPricing__c=false, 
                                                                                    Apttus_Config2__AddedBy__c='User', 
                                                                                    Apttus_Config2__ExtendedCost__c=501.00000, 
                                                                                    Apttus_Config2__HasAttributes__c=false, 
                                                                                    Apttus_Config2__AllowRemoval__c=true, 
                                                                                    Apttus_Config2__AllowableAction__c='Unrestricted', 
                                                                                    Apttus_Config2__HasTieredPrice__c=false,    
                                                                                    Apttus_Config2__BaseCost__c=501.00000, 
                                                                                    Apttus_Config2__HasOptions__c=false, 
                                                                                    Apttus_Config2__HideInvoiceDisplay__c=false, 
                                                                                    HSFE_Invalid_Batch_Number__c=false, 
                                                                                    Apttus_Config2__SyncStatus__c='Synchronized', 
                                                                                    Apttus_Config2__SellingFrequency__c='One Time', 
                                                                                    Apttus_Config2__HideCopyAction__c=false, 
                                                                                    Apttus_Config2__NetAdjustmentPercent__c=0.0000, 
                                                                                    Apttus_Config2__Taxable__c=false, 
                                                                                    HSFE_In_Correct_Product_Addition_on_Cart__c=false,  
                                                                                    Apttus_Config2__PrimaryLineNumber__c=1, 
                                                                                    Apttus_Config2__BaseExtendedPrice__c=625.00000,  
                                                                                    HSFE_In_Correct_Batch_Number__c=false, 
                                                                                    Apttus_Config2__NetPrice__c=0.00000,
                                                                                    HSFE_In_Correct_Serial_Number__c=false,  
                                                                                    Apttus_Config2__ListPrice__c=0.00000, 
                                                                                    Apttus_Config2__IsSellingTermReadOnly__c=false, 
                                                                                    Apttus_Config2__Customizable__c=false,  
                                                                                    Apttus_Config2__AllowManualAdjustment__c=false, 
                                                                                    Is_Product_Serialized__c=false, 
                                                                                    HSFE_Contract_Price_Update_Flag__c=false,  
                                                                                    Apttus_Config2__BasePrice__c=0.00000,  
                                                                                    Apttus_Config2__SellingTerm__c=1.00000,  
                                                                                    Apttus_Config2__PriceUom__c='Each',  
                                                                                    Apttus_Config2__BaseExtendedCost__c=501.00000, 
                                                                                    Apttus_Config2__PriceIncludedInBundle__c=false, 
                                                                                    Apttus_Config2__Uom__c='Each', 
                                                                                    Apttus_Config2__HasBaseProduct__c=false,  
                                                                                    Apttus_Config2__AllowProration__c=false,  
                                                                                    Apttus_Config2__IsCustomPricing__c=false,  
                                                                                    Apttus_Config2__Term__c=1,  
                                                                                    Apttus_Config2__TotalQuantity__c=1.00000,  
                                                                                    Apttus_Config2__Frequency__c='One Time',
                                                                                    Apttus_Config2__HasDefaults__c=false, 
                                                                                    Apttus_Config2__IsUsageTierModifiable__c=false, 
                                                                                    Is_Product_Batched__c=false, 
                                                                                    Apttus_Config2__IsReadOnly__c=false, 
                                                                                    Apttus_Config2__RollupPriceToBundle__c=true);
        return LineItemObj;

    }
    
    public static Apttus_Config2__SummaryGroup__c createSingleSummaryGroup(Apttus_Config2__ProductConfiguration__c ConfigObj){
        Apttus_Config2__SummaryGroup__c SummaryGroupObj = new Apttus_Config2__SummaryGroup__c(Apttus_Config2__ConfigurationId__c=ConfigObj.id,Apttus_Config2__ItemSequence__c=1,Apttus_Config2__LineNumber__c=1);
        return SummaryGroupObj;        
    }
    
    public static Apttus_Proposal__Proposal_Line_Item__c createSingleProposalLineItem(Apttus_Config2__ProductConfiguration__c ConfigObj,Apttus_Proposal__Proposal__c ProposalObj,Apttus_Config2__LineItem__c LineItemIns){
        Apttus_Proposal__Proposal_Line_Item__c ProposalLineItemObj = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__ConfigurationId__c=ConfigObj.id,Apttus_QPConfig__DerivedFromId__c=LineItemIns.id,Apttus_Proposal__Proposal__c=ProposalObj.id);
        return ProposalLineItemObj;        
    }
    
    public static Apttus_Config2__PriceList__c createSinglePriceList(string PriceListName){
        Apttus_Config2__PriceList__c PriceListObj = new Apttus_Config2__PriceList__c(Name=PriceListName,Apttus_Config2__Active__c=true);
        return PriceListObj;        
    }
    

    public static Apttus_Config2__PriceListItem__c createSinglePriceListItem(Apttus_Config2__PriceList__c PriceListIns, Product2 ProdIns,String ChargeTypeStr,String PriceTypeStr,String PriceMethodStr, integer ListPrice){
        Apttus_Config2__PriceListItem__c PriceListItemObj = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c=PriceListIns.id, 
                                                                                                Apttus_Config2__ProductId__c=ProdIns.id, 
                                                                                                Apttus_Config2__ChargeType__c=ChargeTypeStr,
                                                                                                 Apttus_Config2__PriceType__c=PriceTypeStr,
                                                                                                 Apttus_Config2__PriceMethod__c= PriceMethodStr, 
                                                                                                 Apttus_Config2__ListPrice__c=ListPrice, 
                                                                                                 Apttus_Config2__Sequence__c=1,
                                                                                                 Apttus_Config2__Cost__c = 100,
                                                                                                 Apttus_Config2__Active__c=true);    
        return PriceListItemObj;
    }

    public static List<HSFE_Related_Account__c> createMultipleRelatedAccount(Account AccountInst,Integer Count){
        List<HSFE_Related_Account__c> RelatedAccountLst=new List<HSFE_Related_Account__c>();
        for(integer i=0;i<Count;i++){
            if(math.mod(i, 4)==1)
                RelatedAccountLst.add(new HSFE_Related_Account__c(Name='RelatedAcc'+i,
                                                                HSFE_Related_Account__c=AccountInst.id ,
                                                                HSFE_Sold_To_Account__c=AccountInst.id, 
                                                                HSFE_Relationship_Type_ID__c='BP'));
            else if(math.mod(i, 4)==2)
                RelatedAccountLst.add(new HSFE_Related_Account__c(Name='RelatedAcc'+i,
                                                                    HSFE_Related_Account__c=AccountInst.id, 
                                                                    HSFE_Sold_To_Account__c=AccountInst.id, 
                                                                    HSFE_Relationship_Type_ID__c='SP'));
            else if(math.mod(i, 4)==3)
                RelatedAccountLst.add(new HSFE_Related_Account__c(Name='RelatedAcc'+i,
                                                                    HSFE_Related_Account__c=AccountInst.id, 
                                                                    HSFE_Sold_To_Account__c=AccountInst.id, 
                                                                    HSFE_Relationship_Type_ID__c='PY'));
            else
                RelatedAccountLst.add(new HSFE_Related_Account__c(Name='RelatedAcc'+i,
                                                                    HSFE_Related_Account__c=AccountInst.id, 
                                                                    HSFE_Sold_To_Account__c=AccountInst.id, 
                                                                    HSFE_Relationship_Type_ID__c='SH'));
        }
        return RelatedAccountLst;
    }

    public static List<HSFE_PromotionCodeMapping__c> createMultiplePromotionCodeMapping(Integer Count){
        List<HSFE_PromotionCodeMapping__c> PCMappingLst=new List<HSFE_PromotionCodeMapping__c>();
        for(integer i=0;i<Count;i++){
            PCMappingLst.add(new HSFE_PromotionCodeMapping__c(Name='Test'+i,HSFE_Promotion_Code__c='PC'+i));
        }
        return PCMappingLst;        
    }
    
    public static Apttus_Config2__ClassificationName__c createSingleCategory(string CategName,string CategType){
       Apttus_Config2__ClassificationName__c CategoryObj=new Apttus_Config2__ClassificationName__c(Name=CategName,
                                                                                                    Apttus_Config2__HierarchyLabel__c=CategName,
                                                                                                    HSFE_Category_Id__c=CategName, 
                                                                                                    Apttus_Config2__Type__c=CategType,
                                                                                                    Apttus_Config2__Active__c=true);
        return CategoryObj;        
    }
    
    public static Apttus_Config2__ClassificationHierarchy__c createSingleCategoryHeirachy(Apttus_Config2__ClassificationName__c CategoryIns,string CategHierarchyName){
       Apttus_Config2__ClassificationHierarchy__c CategoryHierarchyObj=new Apttus_Config2__ClassificationHierarchy__c(Name=CategHierarchyName,
                                                                                                                    Apttus_Config2__Label__c=CategHierarchyName,
                                                                                                                    Apttus_Config2__HierarchyId__c=CategoryIns.id,
                                                                                                                    HSFE_Category_Hierarchy_Id__c=CategHierarchyName);
        return CategoryHierarchyObj;        
    }
    
    public static Apttus_Config2__ProductClassification__c createSingleProductClassification(Apttus_Config2__ClassificationHierarchy__c CategoryHierarchyIns,Product2 Prod){
       Apttus_Config2__ProductClassification__c ProductClassificationObj=new Apttus_Config2__ProductClassification__c(Apttus_Config2__ClassificationId__c=CategoryHierarchyIns.id,
                                                                                                                        HSFE_Product_Classification_Id__c=Prod.id);
       return ProductClassificationObj;        
    }
    
    public static Apttus_Config2__PriceDimension__c createSinglePriceDimension(String DimName,String BussObj, String Field,String ContextType){
        Apttus_Config2__PriceDimension__c PDimensionObj=new Apttus_Config2__PriceDimension__c(Name=DimName, 
                                                                                            Apttus_Config2__BusinessObject__c=BussObj, 
                                                                                            Apttus_Config2__Datasource__c=Field, 
                                                                                            Apttus_Config2__ContextType__c=ContextType);
        return PDimensionObj;
    }
    
    public static Apttus_Config2__PriceMatrix__c createSinglePriceMatrix(string MatrixType,string Dimension1ValueType,Apttus_Config2__PriceDimension__c PDimIns,Apttus_Config2__PriceListItem__c PListItem){
        Apttus_Config2__PriceMatrix__c PriceMatrixObj=new Apttus_Config2__PriceMatrix__c(Apttus_Config2__MatrixType__c=MatrixType, 
                                                                                        Apttus_Config2__Dimension1ValueType__c=Dimension1ValueType, 
                                                                                        Apttus_Config2__IsCumulativeRange__c=false, 
                                                                                        Apttus_Config2__EnableDateRange__c=false, 
                                                                                        Apttus_Config2__Dimension1Id__c=PDimIns.id, 
                                                                                        Apttus_Config2__PriceListItemId__c=PListItem.id, 
                                                                                        Apttus_Config2__InitialRows__c=5, 
                                                                                        Apttus_Config2__StopProcessingMoreMatrices__c=false,  
                                                                                        Apttus_Config2__Sequence__c=1);
        return PriceMatrixObj;
    }
    
    public static Apttus_Config2__PriceMatrixEntry__c createSinglePriceMatrixEntry(string AdjustmentType,Integer PriceOverride,string Dimension1Value,Apttus_Config2__PriceMatrix__c PriceMatrixIns,integer AdjustmentAmount){
        Apttus_Config2__PriceMatrixEntry__c PriceMatrixEntryObj=new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__AdjustmentType__c=AdjustmentType, 
                                                                                                        Apttus_Config2__PriceOverride__c=PriceOverride, 
                                                                                                        Apttus_Config2__Dimension1Value__c=Dimension1Value, 
                                                                                                        Apttus_Config2__PriceMatrixId__c=PriceMatrixIns.id,  
                                                                                                        Apttus_Config2__IsIncluded__c=false,  
                                                                                                        Apttus_Config2__AdjustmentAmount__c=AdjustmentAmount, 
                                                                                                        Apttus_Config2__Sequence__c=1);
        return PriceMatrixEntryObj;
    }
    
    public static HSFE_Line_Item_Extension__c createSingleLineItemExtension(Id LineItemId, Integer ContractPrice){
        HSFE_Line_Item_Extension__c LineItemExtensionObj = new HSFE_Line_Item_Extension__c(HSFE_Line_Item__c=LineItemId, HSFE_Contract_Price__c=ContractPrice);
        return LineItemExtensionObj;        
    }
    
    public static Apttus_Config2__ProductOptionGroup__c createSingleProductOptionGroup(Id CategaoryHerierchyId,Id RootCategaoryHerierchyId, Boolean IsLeaf, Id ProdId){
        Apttus_Config2__ProductOptionGroup__c ProductOptionGroupObj = new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c=CategaoryHerierchyId, 
                                                                                                                Apttus_Config2__IsLeaf__c=IsLeaf,
                                                                                                                Apttus_Config2__ModifiableType__c='Variable',
                                                                                                                Apttus_Config2__ProductId__c=ProdId, 
                                                                                                                Apttus_Config2__RootOptionGroupId__c=RootCategaoryHerierchyId, 
                                                                                                                Apttus_Config2__Left__c=1, 
                                                                                                                Apttus_Config2__Level__c=0, 
                                                                                                                Apttus_Config2__MaxOptions__c=2, 
                                                                                                                Apttus_Config2__MinOptions__c=2, 
                                                                                                                Apttus_Config2__RootSequence__c=1, 
                                                                                                                Apttus_Config2__Sequence__c=0);
        return ProductOptionGroupObj;        
    }
    
    public static Apttus_Config2__ProductOptionComponent__c createSingleProductOptionComponent(Id ProdId, Id ParentProdId, Id ProductOptionGroupId, string RelationType, integer MaxQuan, integer MinQuan, integer DefQuan, integer ConSeq){
        Apttus_Config2__ProductOptionComponent__c ProductOptionComponentObj = new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ComponentProductId__c=ProdId, 
                                                                                                                            Apttus_Config2__Modifiable__c=true, 
                                                                                                                            Apttus_Config2__ParentProductId__c=ParentProdId, 
                                                                                                                            Apttus_Config2__ProductOptionGroupId__c=ProductOptionGroupId, 
                                                                                                                            Apttus_Config2__RelationshipType__c=RelationType, 
                                                                                                                            Apttus_Config2__MaxQuantity__c=MaxQuan,
                                                                                                                            Apttus_Config2__MinQuantity__c=MinQuan, 
                                                                                                                            Apttus_Config2__DefaultQuantity__c=DefQuan,
                                                                                                                            Apttus_Config2__Sequence__c=ConSeq);
        return ProductOptionComponentObj;        
    }

    public static Apttus_Config2__LineItem__c createMultipleRecordsAndReturnLineItem(Apttus_Proposal__Proposal__c NewProposal){
        // Line Item Variable
        Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
        
        //Insert the PriceList record
        Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
        NewPriceList=createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
        insert NewPriceList;
        if(Test.isRunningTest())
            System.AssertNotEquals(NewPriceList.id,null);
        
        // Insert PriceListId In Custom Setting
        HSFE_Contant_Helper__c ContactHelperIns = new HSFE_Contant_Helper__c();
        ContactHelperIns.Name='HSFE_Olympus_MSG_NA';
        ContactHelperIns.HSFE_Value__c=NewPriceList.id;
        insert ContactHelperIns;
        
        //Insert the ProductConfiguration record
        Apttus_Config2__ProductConfiguration__c NewProductConf=new Apttus_Config2__ProductConfiguration__c();
        NewProductConf=HSFE_TestUtility_Class.createSingleProductConfiguration(NewProposal);
        insert NewProductConf;
        if(Test.isRunningTest())
            System.AssertNotEquals(NewProductConf.id,null);
        
        // Insert Category record
        Apttus_Config2__ClassificationName__c NewCategory=new Apttus_Config2__ClassificationName__c();
        NewCategory=createSingleCategory('HSFE_Category','Offering');
        insert NewCategory;
        if(Test.isRunningTest())
            System.AssertNotEquals(NewCategory.id,null);
        
        // Insert Category Hierarchy record
        Apttus_Config2__ClassificationHierarchy__c NewCategoryHierarchy=new Apttus_Config2__ClassificationHierarchy__c();
        string Category_Hierarchy_Label_Str='HSFE_CategoryHierarchy';
        for(string Category_Hierarchy_Label_Ins: HSFE_Constant.CUSTOM_CATEGORYLABEL){
            Category_Hierarchy_Label_Str=Category_Hierarchy_Label_Ins;
        }
        NewCategoryHierarchy=createSingleCategoryHeirachy(NewCategory,Category_Hierarchy_Label_Str);
        insert NewCategoryHierarchy;
        if(Test.isRunningTest())
            System.AssertNotEquals(NewCategoryHierarchy.id,null);
        
        //Insert the Product record
        List<Product2> NewProductLst=new List<Product2>();
        NewProductLst=createProductRecords(1,'HSFE');
        insert NewProductLst;
        if(Test.isRunningTest())
            System.AssertEquals(NewProductLst.size(),1);
        
        if(NewProductLst.size()>0){
                    
            //Insert the PriceListItem record
            Apttus_Config2__PriceListItem__c NewPriceListItem=new Apttus_Config2__PriceListItem__c();
            NewPriceListItem=createSinglePriceListItem(NewPriceList, NewProductLst[0], 'New', 'One Time', 'Per Unit', 100);
            insert NewPriceListItem;
            if(Test.isRunningTest())
                System.AssertNotEquals(NewPriceListItem.id,null);
            
            //Insert the PriceDimension record
            Apttus_Config2__PriceDimension__c NewPriceDimension=new Apttus_Config2__PriceDimension__c();
            NewPriceDimension=createSinglePriceDimension('Attribute','Apttus_Config2__LineItem__c','Product_Conditions__c','Line Item');
            insert NewPriceDimension;
            
            //Insert the PriceMatrix record
            Apttus_Config2__PriceMatrix__c NewPriceMatrix=new Apttus_Config2__PriceMatrix__c();
            NewPriceMatrix=createSinglePriceMatrix('Dimension','Discrete',NewPriceDimension,NewPriceListItem);
            insert NewPriceMatrix;
            
            //Insert the PriceMatrixEntry record
            Apttus_Config2__PriceMatrixEntry__c NewPriceMatrixEntry=new Apttus_Config2__PriceMatrixEntry__c();
            NewPriceMatrixEntry=createSinglePriceMatrixEntry('List Price Override',43431,'New',NewPriceMatrix,43431);
            insert NewPriceMatrixEntry;                                     

            // Insert ProductClassification record
            Apttus_Config2__ProductClassification__c NewProductClassification=new Apttus_Config2__ProductClassification__c();
            NewProductClassification=createSingleProductClassification(NewCategoryHierarchy,NewProductLst[0]);
            NewProductClassification.Apttus_Config2__ProductId__c=NewProductLst[0].id;
            insert NewProductClassification;

            //Insert the LineItem record
            NewLineItem=new Apttus_Config2__LineItem__c();
            NewLineItem=createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
            NewLineItem.Apttus_Config2__ListPrice__c=1000;
            NewLineItem.Apttus_Config2__ProductId__c=NewProductLst[0].id;
            NewLineItem.HSFE_Product_Classification__c=NewProductClassification.id;
            NewLineItem.Apttus_Config2__PriceListId__c=NewPriceList.id;
            NewLineItem.Apttus_Config2__PriceListItemId__c=NewPriceListItem.id;
            NewLineItem.Apttus_Config2__ClassificationId__c=NewCategoryHierarchy.id;
            
        }
        return NewLineItem;
    }
    
    // Insert PriceListId and ProfileId In Custom Setting   
    public static List<HSFE_Contant_Helper__c> Create_HSFE_Contant_Helper_Data(string ProfileId, string PriceListId){
        List<HSFE_Contant_Helper__c> Contant_Helper_Lst = new List<HSFE_Contant_Helper__c>();
        if(ProfileId!=null && ProfileId!='')
            Contant_Helper_Lst.add(new HSFE_Contant_Helper__c(Name='HSFE_System_Administrator_Profile',HSFE_Value__c=String.valueOf(ProfileId)));
        if(PriceListId!=null && PriceListId!='')
            Contant_Helper_Lst.add(new HSFE_Contant_Helper__c(Name='HSFE_Olympus_MSG_NA',HSFE_Value__c=String.valueOf(PriceListId)));
    
        return Contant_Helper_Lst;
     }  
     
     /****************************************[DIVYA 04-08-2015] Commenting out the code for migration without ELTON****************************************/
    // Create Single ELTON Equipment Data
    /*public static ELTON__Equipment__c Create_SingleELTON_Equipment_Data(){
        ELTON__Equipment_Type__c EqType=new ELTON__Equipment_Type__c(Name='TestType');
        insert EqType;
        
        
        ELTON__Equipment__c NewETON_Equipment = new ELTON__Equipment__c();
        NewETON_Equipment.OLY_Related_Product__c =null;
        NewETON_Equipment.ELTON__Equipment_Type__c=EqType.id;
        NewETON_Equipment.SAP_Material_Number__c='1234';
        NewETON_Equipment.ELTON__Assigned_Email__c='test.Corp@test.com';
        NewETON_Equipment.ELTON__Active__c=true;
    
        return NewETON_Equipment;
     }  */
     /****************************************[DIVYA 04-08-2015] Commenting out ENds****************************************/
}