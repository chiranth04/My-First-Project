/* 
*Class Name  :HSFE_MockHttpResponseGenerator_Test
*Description :This test class test and covers the test coverage for HSFE_IntegrateMuleSoftWebservice_Class class.
*Created By  :Prateek Saxena
*Created On  :06/12/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena         12 June,2015                                                            Initial Version
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
global class HSFE_MockHttpResponseGenerator_Test implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        System.assertEquals('POST', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"SAPId":"1232312","quoteID":"a0i11000004hNXsAAM","ObjectAPIName":"HSFE_Line_Item_Extension__c","lineItemList":[{"SAPId":"1232312","quoteID":"a0i11000004hNXsAAM","quantity":null,"productNumber":"N3043000","productCondition":"New","lineItemId":"a3u11000000CYykAAG","freightTerms":null,"contractNumber":null,"contractCode":null,"accountZipCode":null}],"interfaceName":"Contract_Pricing"}]');
        res.setStatusCode(500);
        return res;
    }
}