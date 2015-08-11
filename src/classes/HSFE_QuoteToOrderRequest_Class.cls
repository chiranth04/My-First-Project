/*Class Name :HSFE_QuoteToOrderRequest_Class 
*Description :This class is used to store the request parameters for all Quote to Order requests. For serializing and deserializing the JSON request.
*Created By :Prateek Saxena
*Created On :5/12/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Prateek Saxena				5/12/2015															Created
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public with sharing class HSFE_QuoteToOrderRequest_Class {

	public String quoteID;
	public String interfaceName;
	public String objectAPIName;

	public static HSFE_QuoteToOrderRequest_Class deserializeRequest (String JSONRequestData){
		return (HSFE_QuoteToOrderRequest_Class) JSON.deserialize(JSONRequestData, HSFE_QuoteToOrderRequest_Class.class);
	}
}