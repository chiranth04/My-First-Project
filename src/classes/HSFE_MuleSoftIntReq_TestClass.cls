/* 
*Class Name  :HSFE_MuleSoftIntegrationRequest_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_MuleSoftIntegrationRequest_Class class.
*Created By  :Prateek Saxena
*Created On  :06/11/2015
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena            06/11/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*/
@isTest
private class HSFE_MuleSoftIntReq_TestClass{
  static testMethod void assignAttributesTest(){
  Test.startTest();
    HSFE_MuleSoftIntegrationRequest_Class reqObj = new HSFE_MuleSoftIntegrationRequest_Class();
    reqObj.quoteID= 'a1r83838383838494984';
    reqObj.interfaceName= HSFE_Constant.QUOTE_TO_ORDER;
    reqObj.ObjectAPIName= HSFE_Constant.QUOTE_PROPOSAL_OBJECT_API_NAME;
    reqObj.SAPId = 'AS23423';
    reqObj.lineItemList = new List<HSFE_MuleSoftIntegrationRequest_Class.LineItem>();
    
    HSFE_MuleSoftIntegrationRequest_Class.LineItem innerObj = new HSFE_MuleSoftIntegrationRequest_Class.LineItem();
    
    innerObj.lineItemId = 'a1r232323232323232';
    innerObj.productNumber = 'N304234'; 
    innerObj.productCondition = 'New'; 
    innerObj.quoteID = 'a1r83838383838494984';
    innerObj.SAPId = 'AS23423';
    innerObj.accountZipCode = '23423';
    innerObj.contractCode = 'PRT1';
    innerObj.contractNumber = '342342';
    innerObj.freightTerms = 'dfasdfasdfasdfasdfasdfad';
    innerObj.quantity = '2';

    reqObj.lineItemList.add(innerObj);
    String JSONStr = JSON.serialize(reqObj);
    HSFE_MuleSoftIntegrationRequest_Class getObj = HSFE_MuleSoftIntegrationRequest_Class.deserializeJSONString(JSONStr);
    System.assertEquals(reqObj.quoteID, getObj.quoteID);
    System.assertEquals(reqObj.SAPId, getObj.SAPId);
    Test.stopTest();
  }
}