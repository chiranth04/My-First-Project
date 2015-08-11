/* Class Name :HSFE_Insert_Renewal_Lead_BatchClass 
*Description :This class is used to insert renewals lead 90 days before an existing contract on an FIS quote expires. 
*The Lead owner is the same person as on the original owner of the contract/ quote.
*Created By :Chiranth Aradhya
*Created On :06/1/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
global class HSFE_Insert_Renewal_Lead_BatchClass implements database.Batchable<sObject> {
    global Database.Querylocator start(Database.BatchableContext bc){
        date dte = system.today().addDays(-90);
        String query='select Name,OwnerId,Apttus_Proposal__Account__r.Name,HSFE_Is_FIS__c,HSFE_FIS_Contract_Number__c,HSFE_Total_FIS_Price__c,HSFE_Contract_End_Date__c,HSFE_Primary_Contact_Name__c,HSFE_Contract_Duration_Months__c,Apttus_Proposal__Opportunity__r.HSFE_Specialty__c,Apttus_Proposal__Opportunity__r.HSFE_Sub_Specialty__c,HSFE_Primary_Con__r.Title,HSFE_Primary_Con__r.Email,HSFE_Primary_Con__r.MobilePhone,HSFE_Primary_Con__r.Fax,HSFE_Primary_Con__r.Phone,HSFE_Primary_Con__r.FirstName,HSFE_Primary_Con__r.MiddleName,HSFE_Primary_Con__r.LastName,Apttus_Proposal__Account__r.BillingCity,Apttus_Proposal__Account__r.BillingCountry,Apttus_Proposal__Account__r.BillingState,Apttus_Proposal__Account__r.BillingStreet,Apttus_Proposal__Account__r.BillingPostalCode,Apttus_Proposal__Account__r.HSFE_SAP_ID__c from Apttus_Proposal__Proposal__c where HSFE_Contract_End_Date__c >: dte AND HSFE_Renewal_Lead_Created__c=False AND HSFE_Is_FIS__c = TRUE AND HSFE_Primary_Con__r.LastName != null';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc , List<Apttus_Proposal__Proposal__c> scope) {
        List<Lead> leadToInsert= new List<Lead>{};
        List<HSFE_Exception_Log__c > ExceptionRecord = new List<HSFE_Exception_Log__c >{};
        List<Apttus_Proposal__Proposal__c > proposalUpdateList = new List<Apttus_Proposal__Proposal__c >{};
        for(Apttus_Proposal__Proposal__c prop :scope)
        {
            Lead newlead = new Lead();
                //Lead newlead = new Lead();
                newlead.OwnerId=prop.OwnerId;
                newlead.Company =prop.Apttus_Proposal__Account__r.Name; 
                newlead.HSFE_Origin__c='FIS Contracts';
                newlead.Is_FIS__c=prop.HSFE_Is_FIS__c;
                newlead.HSFE_Contract_Number__c=prop.HSFE_FIS_Contract_Number__c;
                newlead.HSFE_Contract_Value__c=prop.HSFE_Total_FIS_Price__c;
                newlead.HSFE_Contract_Expiration__c=prop.HSFE_Contract_End_Date__c;
                newlead.FirstName=prop.HSFE_Primary_Con__r.FirstName;
                newlead.MiddleName=prop.HSFE_Primary_Con__r.MiddleName;
                newlead.LastName=prop.HSFE_Primary_Con__r.LastName;
                newlead.HSFE_Contract_Duration__c=prop.HSFE_Contract_Duration_Months__c;
                newLead.HSFE_SAP_ID__c=prop.Apttus_Proposal__Account__r.HSFE_SAP_ID__c;
                newlead.HSFE_Opportunity_Type__c='Upgrade';
                newlead.HSFE_Specialty__c=prop.Apttus_Proposal__Opportunity__r.HSFE_Specialty__c;
                newlead.HSFE_Sub_Speciality__c=prop.Apttus_Proposal__Opportunity__r.HSFE_Sub_Specialty__c;
                newlead.Country=prop.Apttus_Proposal__Account__r.BillingCountry;
                newlead.State=prop.Apttus_Proposal__Account__r.BillingState;
                newlead.Street=prop.Apttus_Proposal__Account__r.BillingStreet;
                newlead.PostalCode=prop.Apttus_Proposal__Account__r.BillingPostalCode;
                newlead.City=prop.Apttus_Proposal__Account__r.BillingCity;
                newlead.Title=prop.HSFE_Primary_Con__r.Title;
                newlead.Email=prop.HSFE_Primary_Con__r.Email;
                newlead.Phone=prop.HSFE_Primary_Con__r.phone;
                newlead.MobilePhone=prop.HSFE_Primary_Con__r.MobilePhone;
                newlead.Fax=prop.HSFE_Primary_Con__r.Fax;
                newLead.Status ='Open';
                //used in the duplicate rule 
                newlead.HSFE_Renewal_Lead__c=True;
                leadToInsert.add(newlead);
                //Renewal lead created will be set to true on proposal, so that this proposal will not be queried when the next batch runs
                prop.HSFE_Renewal_Lead_Created__c=True;
                proposalUpdateList.add(prop);
            }
            
        try{
            if(leadToInsert.size()>0){
                insert leadToInsert;   
            }
            if(proposalUpdateList.size()>0){
                update proposalUpdateList;
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }
   }
   global void finish(Database.BatchableContext bc) {    
   }
}