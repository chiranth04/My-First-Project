/* 
*Class Name  : HSFE_IntMuleSoftWebservice_TestClass
*Description :This test class test and covers the test coverage for HSFE_IntegrateMuleSoftWebservice_Class class.
*Created By  :Prateek Saxena
*Created On  :06/12/2015
*Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena         12 June,2015                                                            Initial Version
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*/
@isTest
private class HSFE_IntMuleSoftWebservice_TestClass{

    static testMethod void GetContractPriceForLineItemTest(){

        HSFE_MuleSoftIntegrationRequest_Class reqObj = new HSFE_MuleSoftIntegrationRequest_Class();
        List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> lineItemList = new List<HSFE_MuleSoftIntegrationRequest_Class.LineItem>();
        List<HSFE_MuleSoftIntegrationRequest_Class> muleSoftIntegrationRequestObjList = new List<HSFE_MuleSoftIntegrationRequest_Class>();
        reqObj.interfaceName = HSFE_Constant.CONTRACT_PRICING;
        reqObj.ObjectAPIName = HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME;
        reqObj.SAPId = '29987034';
        reqObj.quoteID = 'a01sdfsdfjksdfhfkj';
        HSFE_MuleSoftIntegrationRequest_Class.LineItem innerObj = new HSFE_MuleSoftIntegrationRequest_Class.LineItem();
        innerObj.SAPId = '29987034';
        innerObj.lineItemId = 'a0i11000004iBIeAAM';
        innerObj.productCondition = 'New';
        innerObj.productNumber = 'N403203';
        innerObj.quoteID = 'a01sdfsdfjksdfhfkj';
        lineItemList.add(innerObj);
        reqObj.lineItemList = lineItemList;
        muleSoftIntegrationRequestObjList.add(reqObj);
        String JSONRequestData = JSON.serialize(muleSoftIntegrationRequestObjList);
        Test.startTest();
         // Insert Custom Setting for Endpoint Url
        HSFE_IntegrationEndPointURL__c custSettObj = new HSFE_IntegrationEndPointURL__c();
        custSettObj.Name = HSFE_Constant.CONTRACT_PRICING;
        custSettObj.HSFE_EndPointURL__c = 'https://integration.com/stubbingResponse';
        Insert custSettObj;
        // Setting Mock Response for Http Callout
        Test.setMock(HttpCalloutMock.class, new HSFE_MockHttpResponseGenerator_Test());
        // Calling HTTP Callout
        HSFE_IntegrateMuleSoftWebservice_Class.GetContractPriceForLineItem(JSONRequestData);
        Test.stopTest();
        HSFE_Integration_Retry_Object__c retryObj = [Select Id, HSFE_Record_Id__c from HSFE_Integration_Retry_Object__c where HSFE_Record_Id__c =:innerObj.lineItemId];
        System.assertNotEquals(retryObj, null);
    }

    static testMethod void GetFreightChargesForLineItemTest(){

        HSFE_MuleSoftIntegrationRequest_Class reqObj = new HSFE_MuleSoftIntegrationRequest_Class();
        List<HSFE_MuleSoftIntegrationRequest_Class.LineItem> lineItemList = new List<HSFE_MuleSoftIntegrationRequest_Class.LineItem>();
        List<HSFE_MuleSoftIntegrationRequest_Class> muleSoftIntegrationRequestObjList = new List<HSFE_MuleSoftIntegrationRequest_Class>();
        reqObj.interfaceName = HSFE_Constant.FREIGHT_CHARGES;
        reqObj.ObjectAPIName = HSFE_Constant.LINE_ITEM_EXTENSION_OBJECT_API_NAME;
        reqObj.SAPId = '29987034';
        reqObj.quoteID = 'a01sdfsdfjksdfhfkj';
        HSFE_MuleSoftIntegrationRequest_Class.LineItem innerObj = new HSFE_MuleSoftIntegrationRequest_Class.LineItem();
        innerObj.SAPId = '29987034';
        innerObj.lineItemId = 'a0i11000004iBIeAAM';
        innerObj.productCondition = 'New';
        innerObj.productNumber = 'N403203';
        innerObj.quoteID = 'a01sdfsdfjksdfhfkj';
        lineItemList.add(innerObj);
        reqObj.lineItemList = lineItemList;
        muleSoftIntegrationRequestObjList.add(reqObj);
        String JSONRequestData = JSON.serialize(muleSoftIntegrationRequestObjList);
        Test.startTest();
        // Insert Custom Setting for Endpoint Url
        HSFE_IntegrationEndPointURL__c custSettObj = new HSFE_IntegrationEndPointURL__c();
        custSettObj.Name = HSFE_Constant.FREIGHT_CHARGES;
        custSettObj.HSFE_EndPointURL__c = 'https://integration.com/stubbingResponse';
        Insert custSettObj;
        // Setting Mock Response for Http Callout
        Test.setMock(HttpCalloutMock.class, new HSFE_MockHttpResponseGenerator_Test());
        // Calling HTTP Callout
        HSFE_IntegrateMuleSoftWebservice_Class.GetFreightChargesForLineItem(JSONRequestData);
        Test.stopTest(); 
        HSFE_Integration_Retry_Object__c retryObj = [Select Id, HSFE_Record_Id__c from HSFE_Integration_Retry_Object__c where HSFE_Record_Id__c =:innerObj.lineItemId];
        System.assertNotEquals(retryObj, null);            
    }

    static testMethod void GetQuotetoOrderTest(){

        HSFE_QuoteToOrderRequest_Class reqobj = new HSFE_QuoteToOrderRequest_Class();
        reqObj.quoteID = 'a0i11000004iBIeAAM';
        reqObj.interfaceName = HSFE_Constant.QUOTE_TO_ORDER;
        reqObj.objectAPIName = HSFE_Constant.QUOTE_PROPOSAL_OBJECT_API_NAME;
        String JSONQuoteToOrderReqStr = JSON.serialize(reqObj);
        
        Test.startTest();
         // Insert Custom Setting for Endpoint Url
        HSFE_IntegrationEndPointURL__c custSettObj = new HSFE_IntegrationEndPointURL__c();
        custSettObj.Name = HSFE_Constant.QUOTE_TO_ORDER;
        custSettObj.HSFE_EndPointURL__c = 'https://integration.com/stubbingResponse';
        Insert custSettObj;
        // Setting Mock Response for Http Callout
        Test.setMock(HttpCalloutMock.class, new HSFE_MockHttpResponseGenerator_Test());
        testFutureCallout(JSONQuoteToOrderReqStr, reqObj.quoteID);
        Test.stopTest();
        HSFE_Integration_Retry_Object__c retryObj = [Select Id, HSFE_Record_Id__c from HSFE_Integration_Retry_Object__c where HSFE_Record_Id__c =:reqObj.quoteID];
        System.assertNotEquals(retryObj, null);            
    }

    @future(Callout=true)
    static void testFutureCallout(String JSONQuoteToOrderReqStr,String quoteId){
        // Calling HTTP Callout
        HSFE_IntegrateMuleSoftWebservice_Class.ConvertQuotetoOrder(JSONQuoteToOrderReqStr, quoteId);
    }
    static testMethod void SerialNumberCheckForLineItemTest(){

        HSFE_MuleIntegSerialNumCheck_Class reqObj = new HSFE_MuleIntegSerialNumCheck_Class();
        List<HSFE_MuleIntegSerialNumCheck_Class.LineItem> lineItemList = new List<HSFE_MuleIntegSerialNumCheck_Class.LineItem>();
        List<HSFE_MuleIntegSerialNumCheck_Class> muleSoftIntegrationRequestObjList = new List<HSFE_MuleIntegSerialNumCheck_Class>();
        reqObj.interfaceName =  HSFE_Constant.SERIAL_NUM_CHECK;
        reqObj.SAPId = '29987034';
        HSFE_MuleIntegSerialNumCheck_Class.LineItem innerObj = new HSFE_MuleIntegSerialNumCheck_Class.LineItem();
        
        innerObj.lineItemId = 'a0i11000004iBIeAAM';
        innerObj.productNumber = 'N403203';
        innerObj.serialNumber= '123456'; 
        lineItemList.add(innerObj);
        reqObj.lineItemList = lineItemList;
        muleSoftIntegrationRequestObjList.add(reqObj);
        String JSONRequestData = JSON.serialize(muleSoftIntegrationRequestObjList);
        Test.startTest();
        // Insert Custom Setting for Endpoint Url
        HSFE_IntegrationEndPointURL__c custSettObj = new HSFE_IntegrationEndPointURL__c();
        custSettObj.Name = HSFE_Constant.SERIAL_NUM_CHECK;
        custSettObj.HSFE_EndPointURL__c = 'https://integration.com/stubbingResponse';
        Insert custSettObj;
        // Setting Mock Response for Http Callout
        Test.setMock(HttpCalloutMock.class, new HSFE_MockHttpResponseGenerator_Test());
        // Calling HTTP Callout
        HSFE_IntegrateMuleSoftWebservice_Class.SerialNumberCheckForLineItem(JSONRequestData);
        Test.stopTest();            
    }
}