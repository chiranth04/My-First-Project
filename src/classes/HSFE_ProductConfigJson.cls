/* 
* Class Name  : HSFE_ProductConfigJson 
* Description : JSON Class for Product Configuration Attribute
* Created By  : Yunus H Navalur
* Created On  : 06/25/2015
*
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

public class HSFE_ProductConfigJson {

    public String ID;
    public Boolean FITQuote;
    public String QuoteOrderType;
    public String ProposalID;
    public String AVP;
    public String DVP;
    public String GVP;
    public String RSDRVP;
    public Boolean DeepClone;
    public Boolean QUOTEFITQuote;
    public String ProposalOrderType;

    public HSFE_ProductConfigJson (){

    }
    
    public HSFE_ProductConfigJson (Apttus_Config2__ProductConfiguration__c ProductConfig){
        this.ID = ProductConfig.Id;
        this.FITQuote = ProductConfig.HSFE_FIT_Quote__c;
        this.QuoteOrderType = ProductConfig.HSFE_Quote_Order_Type__c;
        this.ProposalID =  ProductConfig.Apttus_QPConfig__Proposald__c;
        this.AVP = ProductConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_AVP_User__c;
        this.DVP = ProductConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_DVP_User__c;
        this.GVP = ProductConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_GVP_User__c;
        this.RSDRVP = ProductConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.HSFE_Approval_RSD_RVP_User__c;
        this.DeepClone = ProductConfig.Apttus_QPConfig__Proposald__r.HSFE_Deep_Clone__c;
        this.QUOTEFITQuote = ProductConfig.Apttus_QPConfig__Proposald__r.HSFE_FIT_Quote__c;
        this.ProposalOrderType = ProductConfig.Apttus_QPConfig__Proposald__r.HSFE_Proposal_Order_Type__c;    
    }
    
     public static HSFE_ProductConfigJson GetProductJsonRecord(String JSONString){
        return (HSFE_ProductConfigJson) JSON.deserialize(JSONString, HSFE_ProductConfigJson.class);
     }          
}