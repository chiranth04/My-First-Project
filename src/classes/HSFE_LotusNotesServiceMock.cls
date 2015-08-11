/************************************************************************************** 
 Apex Class  Name    : HSFE_LotusNotesServiceMock
 Version             : 1.0 
 Created Date        : 12 April 2015
 Function            : This class will generate mock response for mule service 
 Modification Log    :
 * Developer                      Date                                    Description
 * ----------------------------------------------------------------------------                 
 * Kumar Gaurav                04/12/2014                              Original Version
 *************************************************************************************/
@isTest
global class HSFE_LotusNotesServiceMock implements HttpCalloutMock{
	
	//Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        //Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
            
        //Optionally, only send a mock response for a specific endpoint and method.
        if (req.getEndPoint() == (HSFE_Constant.LOTUS_NOTES_ENDPOINT)){
        	res.setBody(getValidResponseMessage());
        }else if (req.getEndPoint() == ('http://12.189.73.247:8888/esb/sfdc/updateSFDCEventInNotes?Id=')){
        	res.setBody(getInValidResponseMessage());
        }
        return res;
    }
    
    String getValidResponseMessage() {
        return '{"Success": "Y"}';
    }
    
    String getInValidResponseMessage() {
        return '{"Success": "N"}';
    }
}