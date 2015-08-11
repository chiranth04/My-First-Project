/**
    Name            : AptsQuoteApprovalEmailSupport
    Author          : Sourav Datta
    Created Date    : Jul 20, 2015 
    Usage           : Controller used for the visualforce components inside the vf email templates.
 */
public  class AptsQuoteApprovalEmailSupport {
    // context approval request
    public Apttus_Approval__Approval_Request__c relatedTo {get;set;}
    
    // receipient user
    public User recipientSO {get; set;}
    public boolean bNotifyFlag {get; set;}
    /**
    * Gets proposal/quote page url
    */ 
    public String getProposalPageUrl() {
        
        Map<String, Apttus_Approval__ApprovalsSystemProperties__c> apttusSettings = Apttus_Approval__ApprovalsSystemProperties__c.getAll();
        List<Apttus_Approval__ApprovalsSystemProperties__c> propsList = apttusSettings.values();
        String pageURL = '';
        if(!propsList.isEmpty()){
            pageURL = propsList[0].Apttus_Approval__InstanceUrl__c + '/' + relatedTo.Apttus_QPApprov__ProposalId__c;
        }
        //pageURL = pageURL + relatedTo.Apttus_QPApprov__ProposalId__c;         
        PageReference pageRef = new PageReference(pageURL);
        return pageRef.getUrl();
    }
    /**
    * Gets reassign page url
    */ 
    public String getReassignPageUrl() {
        // get the page url
        return Apttus_Approval.ApprovalsWebService.getReassignPageUrl(relatedTo);
    }
    
    /**
    * Gets approve/reject page url
    */ 
    public String getApproveRejectPageUrl() {
        // get the page url
        return Apttus_Approval.ApprovalsWebService.getApproveRejectPageUrl(relatedTo);
    }
        
    /**
    * Gets comment entry page url
    */ 
    public String getAddCommentPageUrl() {
        // get the page url
        return Apttus_Approval.ApprovalsWebService.getAddCommentPageUrl(relatedTo);
    }
    
    /**
    * Is approval via email response enabled?
    */
    public Boolean getIsEmailApprovalResponseEnabled() {
        return Apttus_Approval.ApprovalsWebService.isEmailApprovalResponseEnabled();
    }
    
    /**
    * Get completed and outstanding approval requests
    */
    public List<Apttus_Approval__Approval_Request__c> getApprovalHistory() {
        return Apttus_Approval.ApprovalsWebService.getApprovalHistory(relatedTo);
    }
    
    /**
    * Is approval request in cancelled status?
    */
    public Boolean getIsStatusCancelled() {
        return Apttus_Approval.ApprovalsWebService.isStatusCancelled(relatedTo);
    }
    
    
}