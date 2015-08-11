/* 
*Class Name :HSFE_EmailGeneratedXDpFile_TestCon 
*Description :This test class test the functionlity and covers the code for HSFE_EmailGeneratedXDpFile_TestCon class.
*Created By  :Sunil Kumar
*Created On  :05/7/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Sunil Kumar                 05/7/2015
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_EmailGeneratedXDpFile_TestCon {
    static testmethod void testMethod1(){
        //Insert the account record       
        Account acc = HSFE_TestUtility_Class.createAccountRecord();
        acc.HSFE_SAP_Account_Status__c = 'Not Sent';
        insert acc;
        HSFE_Prospect_Promotion_Email__c emailObj = new HSFE_Prospect_Promotion_Email__c();
        emailObj.Name = 'test@Olympus.com.test';
        insert emailObj;
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.ProspectSapForm2;
        
        Test.startTest();
            HSFE_EmailGeneratedXDpFile_Controller.loadPage(acc.id,'Not Sent');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', acc.id);
            ApexPages.StandardController sc = new ApexPages.standardController(acc);
            HSFE_EmailGeneratedXDpFile_Controller.attachAtachmentToAccount(acc.id);                    
            HSFE_EmailGeneratedXDpFile_Controller.sendEmailwithAttachment();
            HSFE_EmailGeneratedXDpFile_Controller.updateSAPAccountStatus(acc.id);
        Test.stopTest();
        List<Attachment> attachList = new List<Attachment>([select id,parentid from attachment where parentid =:acc.id]);
        //Validate an attachemnt is inserted with proper account 
        System.assert(attachList.size()>0,'Attachment is not inserted');
        //Validate account status is updated.
        List<Account> accList = new List<Account>([select id,HSFE_SAP_Account_Status__c from account where id = :acc.id]);
        System.assertEquals(accList[0].HSFE_SAP_Account_Status__c, 'In Progress');
    }
    
    static testmethod void testMethod2(){
        //TO cover catch block
        HSFE_Prospect_Promotion_Email__c emailObj = new HSFE_Prospect_Promotion_Email__c();
        emailObj.Name = 'test';
        insert emailObj;        
        HSFE_EmailGeneratedXDpFile_Controller.updateSAPAccountStatus('12345');
        HSFE_EmailGeneratedXDpFile_Controller.attachAtachmentToAccount('12345');
        HSFE_EmailGeneratedXDpFile_Controller.sendEmailwithAttachment();
    }  
}