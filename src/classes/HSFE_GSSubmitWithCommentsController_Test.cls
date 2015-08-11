/* 
*Class Name : HSFE_GSSubmitWithCommentsController_Test
*Description :This test class to test the Submit with Comments functionality on Cart Page
*Created By  :Divya A N
*Created On  :06/11/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Divya                    11 June,2015                                                            Initial Version
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_GSSubmitWithCommentsController_Test{
    
    static testMethod void testGSSSubmitWithCommentsWithQuote(){
         //Insert the User Role record
            UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
            insert oUserRole;
            
            //Insert the User record
            User ocreateUser = HSFE_TestUtility_Class.createUser(oUserRole);
            insert ocreateUser;
            
            // Run Test Logic as Test User
            system.runAs(ocreateUser){
                Test.StartTest();
                //Insert the Account record
                Account oAccount = new Account();
                oAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert oAccount;
                
                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(oAccount.id,ocreateUser.id,'Test');
                insert ATM;
                
                //Insert the Opportunity record
                Opportunity oOpportunity = new Opportunity();
                oOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(oAccount);                
                insert oOpportunity ;

                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(oOpportunity ,oAccount, ocreateUser,'TestProposal' );
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
                insert NewProposal;
                
                //Insert the LineItem record
                Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                NewLineItem=HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(NewProposal);
                insert NewLineItem;
                
                Apttus_Config2__LineItem__c  oLineItem=[SELECT Id,Apttus_Config2__ConfigurationId__c FROM Apttus_Config2__LineItem__c  WHERE ID=:NewLineItem.Id];
                Apttus_Config2__ProductConfiguration__c NewProductConf=[SELECT Id,Name FROM Apttus_Config2__ProductConfiguration__c WHERE ID=:oLineItem.Apttus_Config2__ConfigurationId__c ];
                 
                //Invoke the Controller and the VF page
                PageReference pageRef = Page.HSFE_GSSubmitWithComments;
                Test.setCurrentPageReference(pageRef);
                System.currentPageReference().getParameters().put('Id',NewProductConf.Id);
                System.currentPageReference().getParameters().put( 'showHeader','True');
                System.currentPageReference().getParameters().put( 'showSidebar','True');
                System.currentPageReference().getParameters().put( 'arFieldSetName','Test');
                System.currentPageReference().getParameters().put( 'returnButtonLabel',NULL);
                System.currentPageReference().getParameters().put( 'quoteId',NewProposal.Id);
                System.currentPageReference().getParameters().put( 'returnId',NewProposal.Id);
                System.currentPageReference().getParameters().put( 'returnPage','home/home.jsp');
                System.currentPageReference().getParameters().put( 'configRequestId',NewProductConf.Id);
                System.currentPageReference().getParameters().put( 'lineItemIds',NewLineItem.Id);
                System.currentPageReference().getParameters().put( 'includeHeaderApprovals','True');
                System.currentPageReference().getParameters().put( 'isDialog','True');
                HSFE_GSSubmitWithCommentsController cntrl = new HSFE_GSSubmitWithCommentsController();
                //Set SF1 mode to false
                    cntrl.setInSf1Mode(False);
                //get the SF1 Mode
                    cntrl.getInSf1Mode();
                cntrl.getPageLoaded();
                cntrl.doLaunchSObjectApprovals();
                cntrl.getReturnLabel();
                cntrl.doReturnInternal();
                cntrl.getPageUrlForObjectId(NewProposal.Id);
                cntrl.getFieldSetName();
                cntrl.getShowHeader();
                cntrl.getShowSidebar();
                cntrl.getContextInfo();
                cntrl.doSubmit();
           }
    }
    static testMethod void testGSSSubmitWithCommentsWithConfig(){
         //Insert the User Role record
            UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
            insert oUserRole;
            
            //Insert the User record
            User ocreateUser = HSFE_TestUtility_Class.createUser(oUserRole);
            insert ocreateUser;
            
            // Run Test Logic as Test User
            system.runAs(ocreateUser){
                Test.StartTest();
                //Insert the Account record
                Account oAccount = new Account();
                oAccount = HSFE_TestUtility_Class.createAccountRecord();
                insert oAccount;
                
                //Insert the AccountTeamMember record
                AccountTeamMember ATM=new AccountTeamMember();
                ATM=HSFE_TestUtility_Class.createSingleAccountTeamMember(oAccount.id,ocreateUser.id,'Test');
                insert ATM;
                
                //Insert the Opportunity record
                Opportunity oOpportunity = new Opportunity();
                oOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(oAccount);                
                insert oOpportunity ;

                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(oOpportunity ,oAccount, ocreateUser,'TestProposal' );
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
                insert NewProposal;
                
                //Insert the LineItem record
                Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                NewLineItem=HSFE_TestUtility_Class.createMultipleRecordsAndReturnLineItem(NewProposal);
                insert NewLineItem;
                
                Apttus_Config2__LineItem__c  oLineItem=[SELECT Id,Apttus_Config2__ConfigurationId__c FROM Apttus_Config2__LineItem__c  WHERE ID=:NewLineItem.Id];
               Apttus_Config2__ProductConfiguration__c NewProductConf=[SELECT Id,Name FROM Apttus_Config2__ProductConfiguration__c WHERE ID=:oLineItem.Apttus_Config2__ConfigurationId__c ];
                
                //Invoke the Controller and the VF page
                PageReference pageRef = Page.HSFE_GSSubmitWithComments;
                Test.setCurrentPageReference(pageRef);
                System.currentPageReference().getParameters().put('Id',NewProductConf.Id);
                System.currentPageReference().getParameters().put( 'showHeader','True');
                System.currentPageReference().getParameters().put( 'showSidebar','True');
                System.currentPageReference().getParameters().put( 'arFieldSetName','Test');
                System.currentPageReference().getParameters().put( 'returnButtonLabel',NULL);
                //System.currentPageReference().getParameters().put( 'quoteId',NewProposal.Id);
                //System.currentPageReference().getParameters().put( 'returnId',NewProposal.Id);
                System.currentPageReference().getParameters().put( 'returnPage','home/home.jsp');
                System.currentPageReference().getParameters().put( 'configRequestId',NewProductConf.Id);
                System.currentPageReference().getParameters().put( 'lineItemIds',NewLineItem.Id);
                System.currentPageReference().getParameters().put( 'includeHeaderApprovals','True');
                System.currentPageReference().getParameters().put( 'isDialog','True');
                HSFE_GSSubmitWithCommentsController cntrl = new HSFE_GSSubmitWithCommentsController();
                //Set SF1 mode to True
                    cntrl.setInSf1Mode(True);
                //get the SF1 Mode
                    cntrl.getInSf1Mode();
                cntrl.getPageLoaded();
                cntrl.doReturnInternal();
                cntrl.doSubmit();
           }
    }
}