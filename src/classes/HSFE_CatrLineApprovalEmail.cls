public without sharing class HSFE_CatrLineApprovalEmail {
    public string productConfigId {get;set;}
    public string approverComments{get;set;}
    public string submitterComments1{get;set;}
    public string approvalRecordId{get;set;}
    public string sBaseURL{get;set;}
    public string quoteName{get;set;}
    public string oQuoteName{get;set;}
    public string replySubjectString{get;set;}
    public String sAssignedTo{get;set;}
    public boolean bApprovalRejected{get;set;}
    public boolean bApprovalCancelled{get;set;}
    public String sConcatenatedCriteria{get;set;}
    public List<string> lstFieldList{get;set;}
    
    
    public List<Apttus_Config2__ProductConfiguration__c> prodConfig{
        get{
            prodConfig  = [SELECT Id,HSFE_Concatenated_Steps__c,Total_Contract_Price__c,HSFE_Discount_From_Threshold__c,HSFE_Margin_from_Threshold__c,HSFE_Total_Threshold_Price__c,HSFE_List_Price__c,HSFE_Total_Unit_Price__c,HSFE_Net_Price_Sum__c,HSFE_Margin__c,HSFE_Discount_from_List__c, Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id=:productConfigId];           
            lstFieldList = new List<String>();
            lstFieldList = prodConfig [0].HSFE_Concatenated_Steps__c.split(';');
            return prodConfig;
        }set;
    }
    
    public List<Apttus_Approval__Approval_Request__c> lstApttusApprovalRequest{
        get{
            lstApttusApprovalRequest= [SELECT Id,Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__Approver_Comments__c,Apttus_Approval__ActualApproverName__c,Apttus_Approval__Approval_Status__c FROM Apttus_Approval__Approval_Request__c WHERE Apttus_Approval__Object_Id__c=:productConfigId AND Apttus_Approval__Approval_Status__c= 'Approved'];
           
            return lstApttusApprovalRequest;
        }set;
    }
    Public Map<Id,Apttus_Approval__Approval_Request__c> mapUserAndComments{
        get{
        mapUserAndComments = new Map<Id, Apttus_Approval__Approval_Request__c>();
            if(lstApttusApprovalRequest != NULL && lstApttusApprovalRequest.Size()>0){
             for(Apttus_Approval__Approval_Request__c oApttusRequest :lstApttusApprovalRequest){
                    List<String> lstFullString = oApttusRequest.Apttus_Approval__Approver_Comments__c.split('\n\n');
                    oApttusRequest.Apttus_Approval__Approver_Comments__c= lstFullString [0];
                    mapUserAndComments.put(oApttusRequest.Apttus_Approval__Assigned_To_Id__c,oApttusRequest);
                }
            } 
       return mapUserAndComments;
       }set;
    }
    public Boolean bApproverCommentsPresent{
        get{
            bApproverCommentsPresent = lstApttusApprovalRequest.size()>0 ? TRUE: FALSE;
            return bApproverCommentsPresent ;
        }set;
    }
    
    public String sOrgURL{
        get{
            //sOrgURL= Label.HSFE_BaseURLforApprovals;
            sOrgURL= URL.getSalesforceBaseUrl().toExternalForm();
            sOrgURL= sOrgURL+'/apex/Apttus_Approval__ApprovalSummaryLaunch?id=';
            return sOrgURL;
        }set;
    }
    
     public String sApproveURL{
        get{
            sApproveURL= '&actionName=cart_approval_summary&pageMode=approveReject';
            return sApproveURL;
        }set;
    }
    public String sAddCommentURL{
        get{
            sAddCommentURL= '&actionName=cart_approval_summary&pageMode=addComment';
            return sAddCommentURL;
        }set;
    }
    
    public List<Apttus_Proposal__Proposal__c> oQuote{
        get{
            if(prodConfig!= NULL && prodConfig.size()>0 )
            oQuote= [SELECT Id,Owner.Id,Owner.Name,Apttus_Proposal__Account__c,HSFE_Primary_Con__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Account__r.HSFE_SAP_ID__c,Apttus_Proposal__Account__r.Name,Apttus_Proposal__Proposal_Name__c,Name,HSFE_Related_Billing_Address__c,HSFE_Rel_Shipping_Address__c,HSFE_Account_Number__c,HSFE_Primary_Con__r.Name,Apttus_Proposal__Opportunity__r.Name,Apttus_Proposal__Proposal_Expiration_Date__c,HSFE_Net_Proposal_List_Price__c,HSFE_Additional_Discount__c,Apttus_Proposal__Discount_Percent__c,HSFE_FIS_Contract_Number__c FROM Apttus_Proposal__Proposal__c WHERE Id= :prodConfig[0].Apttus_QPConfig__Proposald__c];          
            if(oQuote.size()>0){
            quoteName = oQuote[0].Apttus_Proposal__Proposal_Name__c;
            replySubjectString= 'RE: Sandbox: Approval Request for Quote '+quoteName+ 'has been submitted for your approval';
            }
            return oQuote;
        }set;
    } 
    
    public List<Apttus_Config2__LineItem__c> pLineItem{
        get{
            pLineItem = [select id,Apttus_Config2__AdjustmentAmount__c,HSFE_Concatenated_Steps__c,HSFE_Serial_Number__c,HSFE_Batch_Number__c,HSFE_Room_Number__c,HSFE_UOM__c,HSFE_Freight_Charges__c,HSFE_UOM_Denominator__c,HSFE_Actions__c,HSFE_Approver_Level__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__LineType__c,HSFE_Contract_Disc__c,HSFE_Total_Price__c,Apttus_Config2__AdjustmentType__c,HSFE_Adjustment_Amount__c,HSFE_Line_Type__c,HSFE_Floor_Price__c,HSFE_Approval_Criteria__c,HSFE_Option_Price__c,HSFE_Margin_at_Threshold__c,HSFE_Discount_from_Threshold__c,Apttus_CQApprov__Approval_Status__c,HSFE_Net_Adjustment__c,Product_Conditions__c,Apttus_Config2__ConfigurationId__c,HSFE_Target_Price__c,HSFE_Total_Unit_Price__c,HSFE_Net_Price__c,Apttus_Config2__LineNumber__c,Apttus_Config2__Description__c,Apttus_Config2__BasePrice__c,HSFE_Contract_Code__c,HSFE_Contract_Price__c,Apttus_Config2__Quantity__c,HSFE_Margin__c,Apttus_Config2__ProductId__r.Name,HSFE_Email_Template_Product_Name__c,HSFE_Discount_from_List__c  from Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=: prodConfig[0].Id];
            return pLineItem;
        }set;
    }
     public String oUserName{
        get{
            User oUser= [SELECT FirstName, LastName FROM User WHERE Id=: UserInfo.getUserId()];
            oUserName= oUser.FirstName + ' ' + oUser.LastName;
            return oUserName;
        }set;
    }
     public List<Apttus_Approval__Approval_Request__c> lstApttusRejectedApprovals{
        get{
            lstApttusRejectedApprovals= [SELECT Id,Apttus_Approval__Actual_Approver__r.Name,Apttus_Approval__Actual_Approver__r.Title,Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__Approver_Comments__c,Apttus_Approval__ActualApproverName__c,Apttus_Approval__Approval_Status__c FROM Apttus_Approval__Approval_Request__c WHERE Apttus_Approval__Object_Id__c=:productConfigId AND Apttus_Approval__Approval_Status__c= 'Rejected' AND Apttus_Approval__Actual_Approver__C !=NULL];
            system.debug('lstApttusRejectedApprovals' + lstApttusRejectedApprovals);
            if(lstApttusRejectedApprovals!=NULL && lstApttusRejectedApprovals.size()>0 )
                bApprovalRejected = true;
            return lstApttusRejectedApprovals;
        }set;
    }
    
    public List<Apttus_Approval__Approval_Request__c> lstApttusCancelledApprovals{
        get{
            lstApttusCancelledApprovals= [SELECT Id,LastModifiedBy.Name,LastModifiedBy.Title,Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__Approver_Comments__c,Apttus_Approval__ActualApproverName__c,Apttus_Approval__Approval_Status__c FROM Apttus_Approval__Approval_Request__c WHERE Apttus_Approval__Object_Id__c=:productConfigId AND Apttus_Approval__Approval_Status__c= 'Cancelled'];
            system.debug(lstApttusCancelledApprovals + '***********');
            if(lstApttusCancelledApprovals!=NULL && lstApttusCancelledApprovals.size()>0 ){
                bApprovalCancelled = true;
            system.debug(bApprovalCancelled + 'Heyyyyyyyyyyyyyyyyyyyyy');}
            return lstApttusCancelledApprovals;
        }set;
    }
    
    public List<Apttus_Approval__Approval_Request__c> lstApttusApprovalReject{
        get{
            lstApttusApprovalReject= [SELECT Id,Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__Approver_Comments__c,Apttus_Approval__ActualApproverName__c,Apttus_Approval__Approval_Status__c FROM Apttus_Approval__Approval_Request__c WHERE Apttus_Approval__Object_Id__c=:productConfigId AND (Apttus_Approval__Approval_Status__c= 'Approved' OR Apttus_Approval__Approval_Status__c='Rejected')];
           
            return lstApttusApprovalReject;
        }set;
    }
    public Boolean bCommentsPresent{
        get{
            bCommentsPresent= lstApttusApprovalReject.size()>0 ? TRUE: FALSE;
            return bCommentsPresent;
        }set;
    }
    
    
    Public Map<Id,Apttus_Approval__Approval_Request__c> mapUserAndRejectedComments{
        get{
        mapUserAndRejectedComments= new Map<Id, Apttus_Approval__Approval_Request__c>();
            if(lstApttusApprovalReject!= NULL && lstApttusApprovalReject.Size()>0){
             for(Apttus_Approval__Approval_Request__c oApttusRequest :lstApttusApprovalReject){
                    List<String> lstFullString = oApttusRequest.Apttus_Approval__Approver_Comments__c.split('\n\n');
                    oApttusRequest.Apttus_Approval__Approver_Comments__c= lstFullString [0];
                    mapUserAndRejectedComments.put(oApttusRequest.Apttus_Approval__Assigned_To_Id__c,oApttusRequest);
                }
            } 
       return mapUserAndRejectedComments;
       }set;
    }
    
    
    public HSFE_CatrLineApprovalEmail () {
           sBaseURL= URL.getSalesforceBaseUrl().toExternalForm();
    }
    
}