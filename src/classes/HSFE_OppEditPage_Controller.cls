/*Class Name : HSFE_NewOpportunityOverriddenExt  
*Description : On click of a custom button Sales Stage should be updated to Closed Lost
*Created By :  Chiranth Aradhya
*Created On :   3/31/2015
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                          Modification Id                       Description

*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



public with sharing class HSFE_OppEditPage_Controller{

    public HSFE_OppEditPage_Controller(ApexPages.StandardController controller) {
    
        Opportunity opp = (Opportunity)controller.getRecord();
        opp.HSFE_Sales_Stage__c='Closed Lost';

    }

}