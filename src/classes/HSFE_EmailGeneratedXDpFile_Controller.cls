/* Class Name : HSFE_EmailGeneratedXDpFile_Controller
*Description :  This class is used to generate a XDP file and send it as an attachment.
*Created By :   Prateek
*Created On :   4/14/2015
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                           Modification Id                       Description
* Deloitte/Prateek            4/14/2015                     Created 
* Deloitte/Sunil              4/23/2015                     Modified v2       
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
global class HSFE_EmailGeneratedXDpFile_Controller {
    global static String returnMsg;
    global static PageReference curPage; 
    public static String Status{get;set;}
    public static Account acc;   
    public HSFE_EmailGeneratedXDpFile_Controller(ApexPages.StandardController controller){
         controller.addFields(new List<String>{'HSFE_SAP_Account_Status__c'});
         acc = (Account)controller.getRecord(); 
              
    }
     public Pagereference startLoad(){
         
         Status = loadPage(acc.id,acc.HSFE_SAP_Account_Status__c);         
         return null;
     }
     /************************************************************************
    Method Name : loadPage
    Return Type: String
    Parameter: String
    Description: This is used to call the Prospect functionality in SF1.
    ************************************************************************/
     webservice static string loadPage(String accountId,String sapAccStatus){
        curPage = new PageReference('/apex/ProspectSapForm2?Id='+accountId);
        system.debug('sapAccStatus******'+sapAccStatus);
        curPage.setRedirect(false);
        returnMsg= attachAtachmentToAccount(accountId); 
        if(returnMsg == HSFE_Constant.SUCCESS){
            returnMsg = sendEmailwithAttachment();
            if(returnMsg == HSFE_Constant.SUCCESS && sapAccStatus != HSFE_Constant.IN_PROGRESS){
                returnMsg = updateSAPAccountStatus(accountId);
            }
        } 
        return  returnMsg;  
    }
     /************************************************************************
    Method Name : updateSAPAccountStatus
    Return Type: String
    Parameter: String
    Description: Send a mail to a sales team.
    ************************************************************************/
    webservice static string updateSAPAccountStatus(String accountId){
        try{        
            Account a = new Account(id = accountId);            
            a.HSFE_SAP_Account_Status__c = HSFE_Constant.IN_PROGRESS;
            update a;
            returnMsg = HSFE_Constant.SUCCESS;
            return returnMsg;
        }catch (Exception e){
           HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
           returnMsg = HSFE_Constant.ERRORUPDATE;
           return returnMsg;
        }    
    }
    /************************************************************************
    Method Name : sendEmailwithAttachment
    Return Type: String
    Parameter: None
    Description: Send a mail to a sales team.
    ************************************************************************/
    
    webservice static string sendEmailwithAttachment(){        
       try {
            List<String> recipientList = new List<String>();
            for(HSFE_Prospect_Promotion_Email__c prospect : HSFE_Prospect_Promotion_Email__c.getall().values()){
                recipientList.add(prospect.name);   
            }                    
            Blob emailBody = !Test.isRunningTest() ?curPage.getContent(): Blob.ValueOf('dummy text');
            System.debug('String Body is : ' + emailBody.toString());
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('CreateSoldToPayerForm.xdp');
            efa.setContentType('txt/xml');
            efa.setInline(true);
            efa.setBody(emailBody);            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(recipientList);
            email.setSubject('Account XDP File Attachment');
            email.setHtmlBody('Hi,<br/>Please find attached the pre-filled prospect promotion form to convert to a Sold To account in SAP.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            returnMsg = HSFE_Constant.SUCCESS;
            return returnMsg; 

        }
        catch (Exception e){
           HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
           returnMsg = HSFE_Constant.ERRORMAIL;
           return returnMsg;
        }        
    }
    /************************************************************************
    Method Name : attachAtachmentToAccount
    Return Type: String
    Parameter: String
    Description: Insert an attachment to a prospect account.
    ************************************************************************/
     webservice static string  attachAtachmentToAccount(String accountId){
       try {
            system.debug('AttachmentaccountID****'+accountId);
            Attachment attch = new Attachment();
            attch.Body = !Test.isRunningTest() ?curPage.getContent(): Blob.ValueOf('dummy text');
            attch.ParentId = accountId;
            attch.Name = 'CreateSoldToPayerForm.xdp';
            attch.ContentType = 'txt/xml';
            insert attch;
            returnMsg = HSFE_Constant.SUCCESS;
            return returnMsg; 
       }
       catch (Exception e) {
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
            returnMsg = HSFE_Constant.ERRORATTACH;
            return returnMsg;
       }      
    }
    
}