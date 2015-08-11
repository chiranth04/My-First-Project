/* Class Name   : HSFE_Insert_Renewal_Lead_Batch_TestClass 
 * Description  : Testclass for HSFE_Insert_Renewal_Lead_Batch class
 * Created By   :Chiranth Aradhya
 * Created On   : 06/11/2015 
 * Modification Log:  
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                        Description
 *------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 *
 */
@isTest(SeeAllData= false)
public class HSFE_Insert_Renewal_Lead_Batch_TestClass {
    static testMethod void ProposalTrigger_TestScenarios() {
        Test.startTest();
         //Insert the User Role record
        UserRole NewUserRole=new UserRole();
        NewUserRole=  HSFE_TestUtility_Class.createRole();
        insert NewUserRole;
        
        //Insert the User record
        User NewcreateUser=new User();
        NewcreateUser = HSFE_TestUtility_Class.createUser(NewUserRole);
        insert NewcreateUser;
        
         // Run Test Logic as Test User
        system.runAs(NewcreateUser){
       
            //Insert the Account record
            Account NewAccount=new Account();
            NewAccount = HSFE_TestUtility_Class.createAccountRecord();
            insert NewAccount;
            
            //Insert the AccountTeamMember record
            AccountTeamMember ATM=new AccountTeamMember();
            ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(NewAccount.id,NewcreateUser.id,'Test');
            insert ATM;
            
            //Insert the Contact record
            Contact NewContact =new Contact();
            NewContact=HSFE_TestUtility_Class.createContactRecord(NewAccount);
            NewContact.HSFE_Primary__c=true;
            NewContact.HSFE_Specialty__c='Medical';
            NewContact.HSFE_Sub_Specialty__c='Medical IT';
            insert NewContact;
            
            //Insert the Related Account record
            List<HSFE_Related_Account__c> RelatedAccLst=new List<HSFE_Related_Account__c>();
            RelatedAccLst=HSFE_TestUtility_Class.createMultipleRelatedAccount(NewAccount,4);
            insert RelatedAccLst;
            
            //Insert the Opportunity record
            Opportunity NewOpportunity=new Opportunity();
            NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(NewAccount);
            NewOpportunity.HSFE_Specialty__c='Medical';
            NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
            insert NewOpportunity ;
            
            //Insert the PriceList record
            Apttus_Config2__PriceList__c NewPriceList=new Apttus_Config2__PriceList__c();
            NewPriceList=HSFE_TestUtility_Class.createSinglePriceList(HSFE_Constant.CUSTOM_DEFAULT_PRICELIST);
            insert NewPriceList;
            
               
            //Insert the Proposal record
            Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
            NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,NewAccount, NewcreateUser,'TestProposal' );
            NewProposal.Apttus_Proposal__Primary__c=true;
            NewProposal.HSFE_Is_FIS__c=True;
            NewProposal.HSFE_Contract_Effective_Date__c=system.today();
            NewProposal.HSFE_FIS_Contract_Number__c='1223455';
            NewProposal.HSFE_Renewal_Lead_Created__c=False; 
            NewProposal.HSFE_Carrier_Name__c='UPS';  
            NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
            insert NewProposal;
            
            NewProposal.HSFE_Order_Status__c =HSFE_Constant.CUSTOM_QUOTE_ORDER_STATUS_CREATED ;
            update NewProposal;
            
            //check whether NewProposal is updated  properly
            System.assertEquals(NewProposal.HSFE_Order_Status__c, HSFE_Constant.CUSTOM_QUOTE_ORDER_STATUS_CREATED);
           
            Opportunity Opprec =  new Opportunity();
            Opprec=[select Id,HSFE_Sales_Stage__c from Opportunity where Id =:NewOpportunity.Id];
                
            if(Opprec.Id != null){
                  System.assertEquals(Opprec.HSFE_Sales_Stage__c, 'Closed Won');
            }
            
            HSFE_Insert_Renewal_Lead_BatchClass  RenewalBatchObj = new HSFE_Insert_Renewal_Lead_BatchClass();
            Database.executeBatch(RenewalBatchObj);
            
                  
            Test.stopTest();
            }
        }
    }