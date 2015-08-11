/*Class Name :HSFE_MuleSoftIntegrationRequest_Class 
*Description :This class is used to store the request parameter for all Integration requests. For serializing and deserializing the JSON request.
*Created By :Prateek Saxena
*Created On :04/30/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena             04/30/2015                                                              Created
Sunil Kumar                 07/31/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class HSFE_MuleSoftIntegrationRequest_Class {

    public String interfaceName;
    public String ObjectAPIName;
    public String quoteID;
    public String SAPId;
    public List<LineItem> lineItemList;

    public Class LineItem {
        public String lineItemId;
        public String productNumber;
        public String productCondition;
        public String quoteID;
        public String SAPId;
        public String accountZipCode;
        public String contractCode;
        public String contractNumber;
        public String freightTerms;
        public String quantity;
        //[Sunil] For real time response.
        public Double contractPrice;
        public String contractDiscreption;
        public Double gsaPrice;
        public String incoTerms;
        public boolean adminFlag;
        //End of change.
    }

    public static HSFE_MuleSoftIntegrationRequest_Class deserializeJSONString(String JSONStr){
        HSFE_MuleSoftIntegrationRequest_Class reqObj = null;
        if (!String.isEmpty(JSONStr)){
            reqObj = (HSFE_MuleSoftIntegrationRequest_Class) JSON.deserialize(JSONStr, HSFE_MuleSoftIntegrationRequest_Class.class);
        }
        return reqObj;
    }
}