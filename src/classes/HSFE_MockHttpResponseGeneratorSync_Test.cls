/* 
*Class Name  :HSFE_MockHttpResponseGeneratorSync_Test
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
global class HSFE_MockHttpResponseGeneratorSync_Test implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        System.assertEquals('POST', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[ { "Id": "a3u110000048BhIAAU", "HSFE_Contract_Integration_Status__c": "Synched", "HSFE_Contract_Price__c": "0.00", "HSFE_Inco_Terms__c": " ", "HSFE_GSA_Price__c": "0.00", "HSFE_Freight_Terms__c": " ", "HSFE_Contract_Number__c": " ", "HSFE_Admin_Update_Flag__c": true, "HSFE_Contract_Code__c": " ", "HSFE_Contract_Description__c": "Test " }, { "Id": "a3u110000048BhNAAU", "HSFE_Contract_Integration_Status__c": "Synched", "HSFE_Contract_Price__c": "0.00", "HSFE_Inco_Terms__c": " ", "HSFE_GSA_Price__c": "0.00", "HSFE_Freight_Terms__c": " ", "HSFE_Contract_Number__c": " ", "HSFE_Admin_Update_Flag__c": true, "HSFE_Contract_Code__c": " ", "HSFE_Contract_Description__c": "Test123 " } ],"interfaceName":"Contract_Pricing_Sync"}]');
        res.setStatusCode(200);
        //res.setStatusCode(HSFE_Constant.STATUS_CODE_SUCCESS);
        return res;
    }
}