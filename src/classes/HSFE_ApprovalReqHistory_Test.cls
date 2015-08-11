/* 
*Class Name : HSFE_ApprovalReqHistory_Test
*Description :This test class test the Approval Request History Trigger
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
private class HSFE_ApprovalReqHistory_Test{
    
    static testMethod void testApprovalRequestHistory(){
          //Insert the User Role record
            UserRole oUserRole=  HSFE_TestUtility_Class.createRole();
            insert oUserRole;
            
            //Insert the User record
            User ocreateUser = HSFE_TestUtility_Class.createUser(oUserRole);
            insert ocreateUser;
            
            // Run Test Logic as Test User
            system.runAs(ocreateUser){                
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
                oOpportunity.HSFE_Service_Amount__c=200.00;              
                insert oOpportunity ;

                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(oOpportunity ,oAccount, ocreateUser,'TestProposal' );
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Ground';
                insert NewProposal;
                
                //Insert the LineItem record
                Apttus_Config2__LineItem__c NewLineItem=new Apttus_Config2__LineItem__c();
                //NewLineItem=HSFE_TestUtility_Class.createSingleLineItemWithCompleteData(NewProductConf,NewProposal);
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
                
                //Insert Approval Request History
                Apttus_Approval__Approval_Request_History__c NewApprovalRequestHistory= new Apttus_Approval__Approval_Request_History__c();
                NewApprovalRequestHistory.Apttus_CQApprov__CartId__c=NewProductConf.Id;                
                NewApprovalRequestHistory.Apttus_Approval__Related_Opportunity__c=oOpportunity.Id;
                NewApprovalRequestHistory.Apttus_Approval__ParentRequestId__c=NewApprovalRequest.Id;
                insert NewApprovalRequestHistory;
                List<Apttus_Approval__Approval_Request_History__c> appHeqList = new List<Apttus_Approval__Approval_Request_History__c>();
                appHeqList.add(NewApprovalRequestHistory);
                Test.StartTest();
                HSFE_ApprovalReqHistory_Class.handleBeforeInsert(appHeqList);
                // To Validate the proposal id is getting mapped to Approval Request History record.
                Apttus_Approval__Approval_Request_History__c  appReq = new Apttus_Approval__Approval_Request_History__c();
                appReq = [select Apttus_QPApprov__ProposalId__c from Apttus_Approval__Approval_Request_History__c where id=:NewApprovalRequestHistory.id];
                //System.assertEquals(appReq.Apttus_QPApprov__ProposalId__c,NewProposal.Id);
                Test.StopTest();
        }
    }
}