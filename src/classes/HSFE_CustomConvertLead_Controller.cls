/* Class Name :HSFE_CustomConvertLead_Controller
*Description: This is custom lead converion class, which converts leads to account, contact and opportunity, If the account exist, then it will not create a new account.
*Created By :Chiranth Aradhya
*Created On :02/12/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
global class HSFE_CustomConvertLead_Controller{

    webservice static string HSFEConvertLeadMethod(Id leadID, Id accId){
        String strId;
        String descrip;
       try{

            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadID);
            //Set the existing account 
            lc.setAccountId(accId);
            lc.setOwnerId(UserInfo.getUserId());
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            strId = Id.valueOf(accId);
            return strId;
       }
        catch (Exception e){          
            
            
            descrip = e.getMessage();
            
            if( descrip != null && descrip.contains('DUPLICATES_DETECTED')){
                strId = System.Label.HSFE_Lead_Convert_Duplicate_Error_MSG;
            }
            //Added one more condition to throw error when user is not a part of Account Team - July 31
            else if(descrip != null && descrip.Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Validation error on Opportunity: You must be a part of Account team to create opportunities for this Account')){
                strId = System.Label.HSFE_Lead_Convert_Error_MSG;
            }
            else{
                HSFE_ExceptionLogger.createExceptionLog(e);
                strId = System.Label.HSFE_Lead_Convert_Validation_Error;
            }
             
            return strId;// Create a log file for an exception and return accountId
       }
        finally{
            return strId;
        }
        
    }
}