/* 
*Class Name : HSFE_CatrLineApprovalEmail_TestClass
*Description :This test class test the Approval Email Functionality.
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
private class HSFE_CatrLineApprovalEmail_TestClass{
    
    static testMethod void testApprovalEmail(){
          
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
                    
                    // Insert Approval Request Record
                    Apttus_Approval__Approval_Request__c NewApprovalRequest= new Apttus_Approval__Approval_Request__c();
                    NewApprovalRequest.Apttus_Approval__Assigned_To_Id__c = userInfo.getUserId();
                    NewApprovalRequest.Apttus_Approval__Approver_Comments__c = 'Test 1234';
                    NewApprovalRequest.Apttus_Approval__Approval_Status__c ='Approved';
                    NewApprovalRequest.Apttus_Approval__Object_Id__c=NewProductConf.Id;
                    NewApprovalRequest.Apttus_CQApprov__CartId__c=NewProductConf.Id;
                    NewApprovalRequest.Apttus_Approval__ChildObjectId__c=NewLineItem.Id;
                    insert NewApprovalRequest;
                    
                    // Insert Approval Request Record for Rejected
                    Apttus_Approval__Approval_Request__c NewrejectedApprovalRequest= new Apttus_Approval__Approval_Request__c();
                    NewrejectedApprovalRequest.Apttus_Approval__Assigned_To_Id__c = userInfo.getUserId();
                    NewrejectedApprovalRequest.Apttus_Approval__Approver_Comments__c = 'Test 12344';
                    NewrejectedApprovalRequest.Apttus_Approval__Actual_Approver__C =userInfo.getUserId();
                    NewrejectedApprovalRequest.Apttus_Approval__Approval_Status__c ='Rejected';
                    NewrejectedApprovalRequest.Apttus_Approval__Object_Id__c=NewProductConf.Id;
                    insert NewrejectedApprovalRequest;
                    
                    // Insert Approval Request Record for Cancelled Approvals
                    Apttus_Approval__Approval_Request__c NewCancelledApprovalRequest= new Apttus_Approval__Approval_Request__c();
                    NewCancelledApprovalRequest.Apttus_Approval__Assigned_To_Id__c = userInfo.getUserId();
                    NewCancelledApprovalRequest.Apttus_Approval__Approver_Comments__c = 'Test 12344';
                    NewCancelledApprovalRequest.Apttus_Approval__Approval_Status__c ='Cancelled';
                    NewCancelledApprovalRequest.Apttus_Approval__Object_Id__c=NewProductConf.Id;
                    insert NewCancelledApprovalRequest;
                    
                    //Invoke the Controller
                    HSFE_CatrLineApprovalEmail  cntrl = new HSFE_CatrLineApprovalEmail();
                    //cntrl.lstApttusApprovalRequest[0] =NewApprovalRequest;
                    //Product Config Id
                    cntrl.productConfigId = NewProductConf.Id;
                    String getproductConfigId = cntrl.productConfigId;
                    //Product Config List
                    cntrl.prodConfig = new List<Apttus_Config2__ProductConfiguration__c>();
                    cntrl.prodConfig[0]= NewProductConf;
                    List<Apttus_Config2__ProductConfiguration__c> getprodConfig=cntrl.prodConfig;  
                    //Submitter Comments
                    cntrl.submitterComments1= 'TrueTest';
                    String getsubmitterComments1= cntrl.submitterComments1;
                    //Approver Comments
                    cntrl.approverComments= 'Test1';
                    String getapproverComments= cntrl.approverComments;
                    //Approval Record
                    cntrl.lstApttusApprovalRequest = new List<Apttus_Approval__Approval_Request__c>();
                    cntrl.lstApttusApprovalRequest[0]= NewApprovalRequest;
                    List<Apttus_Approval__Approval_Request__c> getlstApttusApprovalRequest=cntrl.lstApttusApprovalRequest;  
                    //Approval Record Id
                    cntrl.approvalRecordId= NewApprovalRequest.Id;
                    String getapprovalRecordId= cntrl.approvalRecordId;
                    //Approver Comments Present
                     cntrl.bApproverCommentsPresent= True;
                    Boolean getbApproverCommentsPresent= cntrl.bApproverCommentsPresent;
                    //Map User with Comments
                    cntrl.mapUserAndComments= new Map<Id,Apttus_Approval__Approval_Request__c>();
                    cntrl.mapUserAndComments.put(ocreateUser.Id,NewApprovalRequest);
                    Map<Id,Apttus_Approval__Approval_Request__c> getmapUserAndComments=cntrl.mapUserAndComments;  
                    //Proposal Record
                    cntrl.oQuote= new List<Apttus_Proposal__Proposal__c>();
                    cntrl.oQuote[0]= NewProposal;
                    List<Apttus_Proposal__Proposal__c> getoQuote=cntrl.oQuote;
                    //oQuoteName
                     cntrl.quoteName= 'TestQuote1';
                    String getquoteName= cntrl.quoteName;
                    //oQuoteName
                     cntrl.oQuoteName= 'TestQuote2';
                    String getoQuoteName= cntrl.oQuoteName;
                    //Line Item
                    cntrl.pLineItem= new List<Apttus_Config2__LineItem__c>();
                    cntrl.pLineItem[0]= NewLineItem;
                    List<Apttus_Config2__LineItem__c> getpLineItem=cntrl.pLineItem;
                    //Rejected Approval Request
                    cntrl.lstApttusRejectedApprovals= new List<Apttus_Approval__Approval_Request__c>();
                    cntrl.lstApttusRejectedApprovals[0]= NewrejectedApprovalRequest;
                    List<Apttus_Approval__Approval_Request__c> getlstApttusRejectedApprovals=cntrl.lstApttusRejectedApprovals;  
                    //Cancelled Approval Requests
                    cntrl.lstApttusCancelledApprovals= new List<Apttus_Approval__Approval_Request__c>();
                    cntrl.lstApttusCancelledApprovals[0]= NewCancelledApprovalRequest;
                    List<Apttus_Approval__Approval_Request__c> getlstApttusCancelledApprovals=cntrl.lstApttusCancelledApprovals;
            }
         }
         static testMethod void testApprovalRejectEmail(){
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
                    
                    
                    // Insert Approval Request Record for Rejected
                    Apttus_Approval__Approval_Request__c NewrejectedApprovalRequest= new Apttus_Approval__Approval_Request__c();
                    NewrejectedApprovalRequest.Apttus_Approval__Assigned_To_Id__c = userInfo.getUserId();
                    NewrejectedApprovalRequest.Apttus_Approval__Approver_Comments__c = 'Test 12344';
                    NewrejectedApprovalRequest.Apttus_Approval__Actual_Approver__C =userInfo.getUserId();
                    NewrejectedApprovalRequest.Apttus_Approval__Approval_Status__c ='Rejected';
                    NewrejectedApprovalRequest.Apttus_Approval__Object_Id__c=NewProductConf.Id;
                    insert NewrejectedApprovalRequest;
                    
                    // Insert Approval Request Record for Cancelled Approvals
                    Apttus_Approval__Approval_Request__c NewCancelledApprovalRequest= new Apttus_Approval__Approval_Request__c();
                    NewCancelledApprovalRequest.Apttus_Approval__Assigned_To_Id__c = userInfo.getUserId();
                    NewCancelledApprovalRequest.Apttus_Approval__Approver_Comments__c = 'Test 12344';
                    NewCancelledApprovalRequest.Apttus_Approval__Approval_Status__c ='Cancelled';
                    NewCancelledApprovalRequest.Apttus_Approval__Object_Id__c=NewProductConf.Id;
                    insert NewCancelledApprovalRequest;
                    
                    Apttus_Approval__Approval_Request__c  NewUpdatedCancelledApprovalRequest= [SELECT Id,Apttus_Approval__Approver_Comments__c  FROM Apttus_Approval__Approval_Request__c   WHERE Id=: NewCancelledApprovalRequest.Id];
                    NewUpdatedCancelledApprovalRequest.Apttus_Approval__Approver_Comments__c ='Test Comment';
                    update NewUpdatedCancelledApprovalRequest;
                    
                    
                    //Invoke the Controller
                    HSFE_CatrLineApprovalEmail  cntrl = new HSFE_CatrLineApprovalEmail();
                    //cntrl.lstApttusApprovalRequest[0] =NewApprovalRequest;
                    //Product Config Id
                    cntrl.productConfigId = NewProductConf.Id;
                    String getproductConfigId = cntrl.productConfigId;
                    //Product Config List
                    cntrl.prodConfig = new List<Apttus_Config2__ProductConfiguration__c>();
                    cntrl.prodConfig[0]= NewProductConf;
                    List<Apttus_Config2__ProductConfiguration__c> getprodConfig=cntrl.prodConfig; 
                    cntrl.lstApttusApprovalReject= new List<Apttus_Approval__Approval_Request__c>();
                   //Approved or Rejected
                    cntrl.lstApttusApprovalReject= new List<Apttus_Approval__Approval_Request__c>();
                    cntrl.lstApttusApprovalReject[0]= NewrejectedApprovalRequest;
                    List<Apttus_Approval__Approval_Request__c> getlstApttusApprovalReject=cntrl.lstApttusApprovalReject; 
                    //Map User with Rejected Comments
                    cntrl.mapUserAndRejectedComments= new Map<Id,Apttus_Approval__Approval_Request__c>();
                    cntrl.mapUserAndRejectedComments.put(ocreateUser.Id,NewrejectedApprovalRequest);
                    Map<Id,Apttus_Approval__Approval_Request__c> getmapUserAndRejectedComments=cntrl.mapUserAndRejectedComments;  
                    //User Name
                    cntrl.oUserName= 'Test';
                    String getoUserName= cntrl.oUserName;
                    //Comments Present
                    cntrl.bCommentsPresent= True;
                    Boolean getbCommentsPresent= cntrl.bCommentsPresent;
                     //sOrg URL
                    cntrl.sOrgURL= '/apex/Apttus_Approval__ApprovalSummaryLaunch?id=';
                    String getsOrgURL= cntrl.sOrgURL;
                    //sApprove URL
                    cntrl.sApproveURL= '&actionName=cart_approval_summary&pageMode=approveReject';
                    String getsApproveURL= cntrl.sApproveURL;
                    //sComment URL
                    cntrl.sAddCommentURL= '&actionName=cart_approval_summary&pageMode=addComment';
                    String getsAddCommentURL= cntrl.sAddCommentURL;
                    //sAssignedTo
                    cntrl.sAssignedTo= ocreateUser.Id ;
                    String getsAssignedTo= cntrl.sAssignedTo;
                    //sConcatenatedCriteria
                    cntrl.sConcatenatedCriteria= 'Test:123';
                    String getsConcatenatedCriteria= cntrl.sConcatenatedCriteria;
            }
        }
    }