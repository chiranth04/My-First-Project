/* Class Name : HSFE_ConvertQuoteToOrder_Controller
*Description :  This class is used to convert Quote to Order and Forward the request to Mulesoft with required Parameters.
*Created By :   Prateek
*Created On :   5/12/2015
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                           Modification Id                       Description
* Deloitte/Prateek            5/12/2015                     Created    
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*/
global class HSFE_ConvertQuoteToOrder_Controller {
    
    global static String returnMsg;
    global static PageReference returnPage;
    
    webservice static String convertQuoteToOrder(String quoteId){
        try {
            if (!String.isEmpty(quoteId)){
                returnPage = new PageReference('/'+ quoteId);
                HSFE_QuoteToOrderRequest_Class quoteToOrdrReqObj;
                System.debug('**************************** Quote Id : ' + quoteId);
                quoteToOrdrReqObj = new HSFE_QuoteToOrderRequest_Class();
                quoteToOrdrReqObj.quoteID = quoteId;
                quoteToOrdrReqObj.interfaceName = HSFE_Constant.QUOTE_TO_ORDER;
                quoteToOrdrReqObj.objectAPIName = HSFE_Constant.QUOTE_PROPOSAL_OBJECT_API_NAME;
                
                String JSONQuoteToOrderReqStr = JSON.serialize(quoteToOrdrReqObj);
                System.debug('@@@ QuoteTO Order JSON Request : ' + JSONQuoteToOrderReqStr);
                HSFE_IntegrateMuleSoftWebservice_Class.ConvertQuotetoOrder(JSONQuoteToOrderReqStr, quoteId); // Webservice Call @ Future for Quote to Order request
            }
        }
        catch(JSONException jsex) {
            System.debug('****JSON Exception*****');
            HSFE_ExceptionLogger.createExceptionLog(jsex);
            return HSFE_Constant.ERROR;
        }
        catch(Exception ex){
            HSFE_ExceptionLogger.createExceptionLog(ex);
            return HSFE_Constant.ERROR;
        }
        return HSFE_Constant.SUCCESS;
    }
}