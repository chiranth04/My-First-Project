/* 
*Class Name  :HSFE_QuoteToOrderRequest_TestClass
*Description :This test class test the functionlity and covers the code for HSFE_QuoteToOrderRequest_Class class.
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
private class HSFE_QuoteToOrderRequest_TestClass{
	static testMethod void deserializeRequestTest(){
		HSFE_QuoteToOrderRequest_Class reqObj = new HSFE_QuoteToOrderRequest_Class();
		reqObj.quoteID = 'a1r83838383838494984';
		reqObj.interfaceName = HSFE_Constant.QUOTE_TO_ORDER;
		reqObj.objectAPIName = HSFE_Constant.QUOTE_PROPOSAL_OBJECT_API_NAME;

		String jsonStr = JSON.serialize(reqObj);
		HSFE_QuoteToOrderRequest_Class obj = HSFE_QuoteToOrderRequest_Class.deserializeRequest(jsonStr);

		System.assertEquals(reqObj.quoteID, obj.quoteID);
		System.assertEquals(reqObj.interfaceName, obj.interfaceName);
		System.assertEquals(reqObj.objectAPIName, obj.objectAPIName);

	}
}