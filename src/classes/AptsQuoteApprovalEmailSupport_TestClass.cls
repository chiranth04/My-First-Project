/* 
    Name            : Test_AptsQuoteApprovalEmailSupport
    Author          : Sourav Datta
    Created Date    : June 11, 2015 
    Usage           : Test class for Apttus Approval visualforce email template controller. 
    
*/ 
@isTest 
private class AptsQuoteApprovalEmailSupport_TestClass{

    static testMethod void unitTest_AptsQuoteApprovalEmailSupport() {
        
        User usr = HSFE_TestUtility_Class.createUser2();
        Account acc = HSFE_TestUtility_Class.createAccountRecord(); //create an account
        Contact con = HSFE_TestUtility_Class.createContactRecord(acc); // create a contact
        Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc); // create an Opportunity
        Apttus_Proposal__Proposal__c  proposal = HSFE_TestUtility_Class.CreateSingleProposal(opp,acc,usr,'Test');  // create a proposal
        
        test.startTest();
        List<Apttus_Approval__Approval_Request__c> appprovalRequestList2  = new List<Apttus_Approval__Approval_Request__c> ();
        Apttus_Approval__Approval_Request__c approvalRequestObj = new Apttus_Approval__Approval_Request__c();
        approvalRequestObj.Apttus_Approval__Step_Name__c = 'Approval Step - (Group 1)';
        approvalRequestObj.Apttus_Approval__Approval_Status__c = 'Notify'; 
        approvalRequestObj.Apttus_Approval__DateAssigned__c = Date.Today(); 
        approvalRequestObj.Apttus_Approval__Initial_Submitter__c = UserInfo.getUserId();
        
        approvalRequestObj.Apttus_QPApprov__ProposalId__c = proposal.Id;
        approvalRequestObj.Apttus_Approval__Backup_From_User__c = UserInfo.getUserId();
        approvalRequestObj.Apttus_Approval__Assigned_To__c = UserInfo.getUserId();
        appprovalRequestList2.add(approvalRequestObj);
        insert appprovalRequestList2;
         
        appprovalRequestList2[0].Apttus_Approval__Approval_Status__c = 'Assigned';
        appprovalRequestList2[0].Apttus_Approval__Backup_From_User__c = UserInfo.getUserId();
        appprovalRequestList2[0].Apttus_Approval__Assigned_To__c = UserInfo.getUserId();
        update appprovalRequestList2;
        
        Apttus_Approval.ApprovalsWebService.getReassignPageUrl(appprovalRequestList2[0]);             
        AptsQuoteApprovalEmailSupport  emailsupport=new AptsQuoteApprovalEmailSupport ();
        Apttus_Approval.ApprovalsWebService.getReassignPageUrl(appprovalRequestList2[0]);
        Apttus_Approval.ApprovalsWebService.getApproveRejectPageUrl(appprovalRequestList2[0]);
        Apttus_Approval.ApprovalsWebService.getAddCommentPageUrl(appprovalRequestList2[0]);
        Apttus_Approval.ApprovalsWebService.isEmailApprovalResponseEnabled();
        Apttus_Approval.ApprovalsWebService.getApprovalHistory(appprovalRequestList2[0]);
        Apttus_Approval.ApprovalsWebService.isStatusCancelled(appprovalRequestList2[0]);
        
        AptsQuoteApprovalEmailSupport approvalEmailSuppObj = new AptsQuoteApprovalEmailSupport();
        approvalEmailSuppObj.relatedTo = appprovalRequestList2[0];
        approvalEmailSuppObj.getProposalPageUrl();
        approvalEmailSuppObj.getReassignPageUrl();
        approvalEmailSuppObj.getApproveRejectPageUrl();
        approvalEmailSuppObj.getAddCommentPageUrl();
        
        approvalEmailSuppObj.getIsEmailApprovalResponseEnabled();
        approvalEmailSuppObj.getApprovalHistory();
        approvalEmailSuppObj.getIsStatusCancelled();
        
        test.stopTest();
    }
}