/*Class Name : HSFE_Reject_Lead_Controller
*Description : On click of a custom button lead status should be updated to Rejected
*Created By :  Chiranth Aradhya
*Created On :   06/01/2015
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                          Modification Id                       Description

*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



public with sharing class HSFE_Reject_Lead_Controller{

    public HSFE_Reject_Lead_Controller(ApexPages.StandardController controller) {
    
        Lead leadrec = (Lead)controller.getRecord();
        leadrec.Status='Rejected';

    }

}