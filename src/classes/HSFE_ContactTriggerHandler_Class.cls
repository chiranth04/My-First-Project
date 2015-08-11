/* Class Name :HSFE_ContactTriggerHandler_Class
*Description :Trigger Handler class for the Contact SObject, which implements all the logic of contact trigger.
            1. Update the primary text field on contact based on Is primary checkbox, Primary text field is used in duplicate rules.
*Created By :Chiranth Aradhya
*Created On :02/17/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public with sharing class HSFE_ContactTriggerHandler_Class {
    
     /*********************************************************************************
     * Method Name:handleBeforeInsert
     * Description:Update the primary text field based o Primary checkbox.
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeInsert(List<Contact> conList) {
        try{
            for(Contact con:conList){
        
                if(con.HSFE_Primary__c == True){
                    //If true update Primary text field to Yes
                    con.HSFE_Primary_Text__c = 'Yes';
                
                }else{
                     //If False update Primary text field to No
                    con.HSFE_Primary_Text__c = 'No';
                }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
   /*********************************************************************************
     * Method Name:handleBeforeUpdate
     * Description:Update the primary text field based o Primary checkbox.
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeUpdate(List<Contact> conList) {
        try{
            for(Contact con:conList){
                if(con.HSFE_Primary__c == True){
                    //If False update Primary text field to Yes
                    con.HSFE_Primary_Text__c = HSFE_Constant.YES;
                }else{
                    //If False update Primary text field to No
                    con.HSFE_Primary_Text__c = HSFE_Constant.NO;
                }
            }
        }catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);} // Create a log file for an exception.
    }
   /*********************************************************************************
     * Method Name:activateDeactivateBeforeUpdate
     * Description:Activate/Deactivate Contact based on Active CheckBox
     * Return Type: None.
     ********************************************************************************/
    public static void activateDeactivateBeforeUpdate(Map<Id, Contact> newConMap, Map<Id, Contact> oldConMap) {
        try{
            Map<Id, Id> oldAccountMap = new Map<Id, Id>();
            List<Id> oldAccountList = new List<Id>();
            Account a = new Account();
            List<Account> accList = new List<Account>([Select id,name from account where name =: HSFE_Constant.ACCOUNTNAME limit 1]); //Find existing account.
            if(accList.size() == 0){                
                a.name = HSFE_Constant.ACCOUNTNAME; // Insert an account.
                insert a;
            }
            
            for(Id idVal:newConMap.keySet()){
                Contact newCon = newConMap.get(idVal);
                Contact oldCon = oldConMap.get(idVal);
                if(newCon.HSFE_Active__c != oldCon.HSFE_Active__c){ 
                    if(newCon.HSFE_Active__c){  //check for an active contact.          
                        oldAccountMap.put(idVal, Id.valueOf(newCon.HSFE_Account_Id_Back_Up__c));
                        oldAccountList.add(Id.valueOf(newCon.HSFE_Account_Id_Back_Up__c));
                    }               
                    else if(!newCon.HSFE_Active__c){ //check for an Inactive contact.
                        newCon.HSFE_Account_Id_Back_Up__c = oldCon.AccountID;                       
                        newCon.AccountId = accList.size() >0 ? accList[0].id : a.id;                                
                    }
                }
             }
             if(oldAccountList.size()>0){
                Map<Id, Account> mapOfAccount = new Map<Id, Account>([SELECT Id,Name from Account WHERE Id IN :oldAccountList]);// Find the existing accounts.
                for(Id idVal:oldAccountMap.keySet()){
                    if(mapOfAccount.containsKey(oldAccountMap.get(idVal)) && accList.size()>0 && newConMap.get(idVal).AccountId == accList[0].id){
                        newConMap.get(idVal).AccountId = mapOfAccount.get(oldAccountMap.get(idVal)).Id;//Map account
                        newConMap.get(idVal).HSFE_Account_Id_Back_Up__c = null;
                    }
                    else if(mapOfAccount.containsKey(oldAccountMap.get(idVal)) && accList.size()>0 && newConMap.get(idVal).AccountId != accList[0].id){
                        newConMap.get(idVal).HSFE_Account_Id_Back_Up__c = null;                     
                    }
                }
            }            
           
        }catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);}
    }
    /*********************************************************************************
     * Method Name:deactivateBeforeInsert
     * Description:Deactivate Contact based on Active CheckBox
     * Return Type: None.
     ********************************************************************************/
    public static void deactivateBeforeInsert(List<Contact> contactList) {
        try{
            Account a = new Account();
            //Sourav 0508 Added to fix regression testing defect
            List<Account> accList = new List<Account>([Select id,name from account where name =: HSFE_Constant.ACCOUNTNAME limit 1]); //Find existing account.
            if(accList.size() == 0){                
                a.name = HSFE_Constant.ACCOUNTNAME; // Insert an account.
                insert a;
            }
            //End Sourav 0508 Added 
            for(Contact newCon:contactList){
                if(!newCon.HSFE_Active__c){     //Check for an Inactive.            
                    newCon.HSFE_Account_Id_Back_Up__c = newCon.AccountId;//Assign the account.
                    //Sourav 0508 Added to fix regression testing defect
                    newCon.AccountId = accList.size() >0 ? accList[0].id : a.id;
                    //End Sourav 0508 Added
                }
            }
        }catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);}
    }
    
}