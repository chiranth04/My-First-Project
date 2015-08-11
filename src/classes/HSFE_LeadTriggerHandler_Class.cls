/* Class Name : HSFE_LeadTriggerHandler_Class
*Description :  Trigger Handler class for the Lead SObject, which implements all the logic of lead trigger.
*Created By :   Sunil Kumar
*Created On :   02/26/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Sunil              2/26/2015                      Created                               
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public with sharing class HSFE_LeadTriggerHandler_Class {
    /************VARIABLES**************************************/
    public static Set<Id> convertedAccountIds = new Set<Id>();
    public static Map<String,Account> accMap = new Map<String,Account>(); 
    public static List<AccountTeamMember > insertaccTeamMembersList ; 
    public static List<AccountTeamMember > accTeamMembersList; 
    public static List<HSFE_Account_Territory__c> accTerritoryList;
    public static List<HSFE_Account_Territory__c> insertAccTerritoryList;
    public static Map<String, AccountTeamMember > accTeamMap = new Map<String, AccountTeamMember >();
    public static Map<id, Set<Id>> terrUserId = new Map<id, Set<Id>>();
    public static Map<id, Set<Id>> accterrId = new Map<id, Set<Id>>();
    public static List<Lead> leadUpdateList;   
    public static Set<Id> terrIds = new Set<Id>();
    public static List<AccountShare> updateAccountShareList;
    /************VARIABLES**************************************/
    
    /*********************************************************************************
     * Method Name:handleBeforeInsert
     * Description:Assign account based on SAP ID.
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeInsert(List<Lead> leadList) {
        try{
            Set<Lead> leadToUpdateSet = new Set<Lead>();
            list<Lead> leadToAssignList = new list<Lead>();
            Set<String> terrCombKeySet = new Set<String>();
            Set<String> exepCombKeySet = new Set<String>();
            Set<String> SAPIDSet = new Set<String>();
            list<Lead> leadToChangeNameList = new list<Lead>();
            String combinationKey;
            String postalCode;
            String exceptionCombKey;
            String exceptionPosatlCode;
            String trimPostalCode;
            for(Lead newLead : leadList){
                if(newLead.HSFE_SAP_ID__c != '' && newLead.HSFE_SAP_ID__c != null){  //Check SAP ID value
                    leadToUpdateSet.add(newLead);
                    SAPIDSet.add(newLead.HSFE_SAP_ID__c); // Add SAP ID in set
                }
            }
            if(leadToUpdateSet.size() > 0){
                assignAccount(leadToUpdateSet,SAPIDSet);
            }
            for(Lead newLead : leadList){
                combinationKey = '';
                postalCode = '';
                exceptionCombKey = '';
                exceptionPosatlCode='';
                trimPostalCode = '';
                if(newLead.HSFE_SAP_ID__c != '' && newLead.HSFE_SAP_ID__c != null){      
                    if(newLead.HSFE_Assign_Primary_Contact__c == true && newLead.LastName == HSFE_Constant.LEAD_TBD_NAME && newLead.HSFE_Specialty__c != null && newLead.HSFE_Sub_Speciality__c!= null){
                        leadToChangeNameList.add(newLead);
                    }
                }
                if(HSFE_Utility_Class.stopUpdateLeadTerritory == false){ // Stop the logic to excute when a batch class run.
                    if(newLead.PostalCode != null && newLead.HSFE_Specialty__c != null && newLead.HSFE_Sub_Speciality__c!= null && newLead.HSFE_Ex_Territory_Assignment_Rule__c == false){
                        leadToAssignList.add(newLead);
                        postalCode = newLead.PostalCode;
                        trimPostalCode = postalCode.length()>5?postalCode.left(5):postalCode;
                        combinationKey =trimPostalCode+newLead.HSFE_Specialty__c+newLead.HSFE_Sub_Speciality__c;
                        terrCombKeySet.add(combinationKey);
                        system.debug('terrCombKeySet********>'+terrCombKeySet);
                        if(newLead.HSFE_SAP_ID__c != null && newLead.HSFE_SAP_ID__c != ''){
                            exceptionPosatlCode = postalCode.length()>5?postalCode.left(5):postalCode;
                            exceptionCombKey = newLead.HSFE_SAP_ID__c+exceptionPosatlCode+newLead.HSFE_Specialty__c+newLead.HSFE_Sub_Speciality__c;
                            exepCombKeySet.add(exceptionCombKey);
                        }
                    }
                }
            }            
            if(leadToChangeNameList.size()> 0){
                changeName(leadToChangeNameList);
            }
            if(leadToAssignList.size()> 0){
                assignTerritory(leadToAssignList, terrCombKeySet, exepCombKeySet);
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }

    /*********************************************************************************
     * Method Name:handleBeforeUpdate
     * Description:Assign account based on SAP ID.
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeUpdate(Map<Id,Lead> oldLeadMap,Map<Id,Lead> newLeadMap) {
        try{
            Set<Lead> leadToUpdateSet = new Set<Lead>();
            list<Lead> leadToAssignList = new list<Lead>();
            Set<String> terrCombKeySet = new Set<String>();
            Set<String> exepCombKeySet = new Set<String>();
            Set<String> SAPIDSet = new Set<String>();
            String combinationKey;
            String postalCode;
            String exceptionCombKey;
            String exceptionPosatlCode;
            String trimPostalCode;
            for(Id idVal:newLeadMap.keySet()){
                Lead newLead = newLeadMap.get(idVal);
                Lead oldLead = oldLeadMap.get(idVal);
                system.debug('SAP ID'+newLead.HSFE_SAP_ID__c);
                if(newLead.HSFE_SAP_ID__c != oldLead.HSFE_SAP_ID__c && newLead.HSFE_SAP_ID__c != null){  //Check SAP ID value
                    leadToUpdateSet.add(newLead);
                    SAPIDSet.add(newLead.HSFE_SAP_ID__c); // Add SAP ID in set
                }
            }
            if(leadToUpdateSet.size() > 0){
                assignAccount(leadToUpdateSet,SAPIDSet);
            }
            for(Id idVal:newLeadMap.keySet()){
                Lead newLead = newLeadMap.get(idVal);
                Lead oldLead = oldLeadMap.get(idVal);
                if(newLead.HSFE_SAP_ID__c != oldLead.HSFE_SAP_ID__c && (newLead.HSFE_SAP_ID__c == null || newLead.HSFE_SAP_ID__c == '')){                    
                    newLead.HSFE_Account__c = null;                   
                }
                if(HSFE_Utility_Class.stopUpdateLeadTerritory == false){ // Stop the logic to excute when a batch class run.
                    if((newLead.PostalCode != oldLead.PostalCode) || (newLead.HSFE_Specialty__c != oldLead.HSFE_Specialty__c) || (newLead.HSFE_Sub_Speciality__c != oldLead.HSFE_Sub_Speciality__c) || (newLead.HSFE_SAP_ID__c != oldLead.HSFE_SAP_ID__c)){
                        if(newLead.PostalCode != null && newLead.HSFE_Specialty__c != null && newLead.HSFE_Sub_Speciality__c!= null && newLead.HSFE_Ex_Territory_Assignment_Rule__c == false){
                            leadToAssignList.add(newLead);
                            postalCode = newLead.PostalCode;
                            trimPostalCode = postalCode.length()>5?postalCode.left(5):postalCode;
                            combinationKey = trimPostalCode+newLead.HSFE_Specialty__c+newLead.HSFE_Sub_Speciality__c;
                            terrCombKeySet.add(combinationKey);
                            if(newLead.HSFE_SAP_ID__c != null && newLead.HSFE_SAP_ID__c != ''){
                                exceptionPosatlCode = postalCode.length()>5?postalCode.left(5):postalCode;
                                exceptionCombKey = newLead.HSFE_SAP_ID__c+exceptionPosatlCode+newLead.HSFE_Specialty__c+newLead.HSFE_Sub_Speciality__c;
                                exepCombKeySet.add(exceptionCombKey);
                            }
                        }else if(newLead.HSFE_Ex_Territory_Assignment_Rule__c == false){
                            newLead.HSFE_Territory__c = null;
                        }
                    }
                }
            }            
            if(leadToAssignList.size()> 0){
                assignTerritory(leadToAssignList, terrCombKeySet, exepCombKeySet);
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
    
    /*********************************************************************************
     * Method Name:handleBeforeUpdate
     * Description:Assign account based on SAP ID.
     * Return Type: None.
     ********************************************************************************/
    public static void assignAccount(Set<Lead> leadToUpdateSet, Set<String> SAPIDSet) {
        try{
            List<Account> accList = new List<Account>();
            if(SAPIDSet.size()>0){ // Check the size of SAPID set.
                accList = [select id,HSFE_SAP_ID__c,name,billingcity,billingcountry,billingpostalcode,billingstate,billingstreet from account where HSFE_SAP_ID__c IN :SAPIDSet]; // Query on account based on the SAP ID.
                for(Account acc : accList){
                    accMap.put(acc.HSFE_SAP_ID__c , acc);        
                }
                
                for(Lead lead : leadToUpdateSet){
                    if(accMap.containsKey(lead.HSFE_SAP_ID__c )){
                        lead.HSFE_Account__c = accMap.get(lead.HSFE_SAP_ID__c).id;  //Assign the account id based on SAPID.
                        lead.Company = accMap.get(lead.HSFE_SAP_ID__c).name;                       
                        if(lead.City== null && lead.State== null && lead.PostalCode == null && lead.Country == null && lead.Street ==null && 
                           lead.CountryCode == null && lead.StateCode== null){
	                        lead.City = accMap.get(lead.HSFE_SAP_ID__c).billingcity;
	                        lead.State = accMap.get(lead.HSFE_SAP_ID__c).billingstate;
	                        lead.PostalCode = accMap.get(lead.HSFE_SAP_ID__c).billingpostalcode;
	                        lead.Country = accMap.get(lead.HSFE_SAP_ID__c).billingcountry;
	                        lead.Street = accMap.get(lead.HSFE_SAP_ID__c).billingstreet;
                        }
                        
                    }
                }
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }  

    /*********************************************************************************
     * Method Name:assignTerritory
     * Description: Assign territory based on the combination of zip code,Specialty and Sub Specialty
     * Return Type:None
     ********************************************************************************/
     public static void assignTerritory(list<Lead> leadToAssignList, Set<String> terrCombKeySet, Set<String> exepCombKeySet){
        try{
            List<Group> groupList = new List<Group>();
            Map<String, Id> exepCombKeyToTerrIdMap = new Map<String, Id>();
            Map<String, Id> terrCombKeyToTerrIdMap = new Map<String, Id>();
            Map<Id, Id> leadIdToTerrIdMap = new Map<Id, Id>();
            Set<Id> terrIdSet = new Set<Id>();
            String combinationKey;
            String postalCode;
            String exceptionCombKey;
            String exceptionPosatlCode;
            String trimPostalCode;
            groupList = [select Id from Group where Name = :HSFE_Constant.QUEUENAME and Type = 'Queue' Limit 1];
            List<HSFE_Territory_Exception__c> TerrExceptionList = new List<HSFE_Territory_Exception__c>([SELECT Id,Name, HSFE_Specialty__c, HSFE_Sub_Specialty__c, HSFE_Territory__c, HSFE_Combination_Key__c FROM HSFE_Territory_Exception__c WHERE HSFE_Combination_Key__c IN :exepCombKeySet]);
            for(HSFE_Territory_Exception__c terrExep:TerrExceptionList){
                exepCombKeyToTerrIdMap.put(terrExep.HSFE_Combination_Key__c, terrExep.HSFE_Territory__c);
                terrIdSet.add(terrExep.HSFE_Territory__c);
            }
            List<HSFE_Zip_To_Territory__c> ZipToTerrList = new List<HSFE_Zip_To_Territory__c>([Select Id,HSFE_Territory__c,HSFE_Combination_Key__c from HSFE_Zip_To_Territory__c where HSFE_Combination_Key__c IN :terrCombKeySet]);
            for(HSFE_Zip_To_Territory__c zipte:ZipToTerrList){
                terrCombKeyToTerrIdMap.put(zipte.HSFE_Combination_Key__c, zipte.HSFE_Territory__c);
                terrIdSet.add(zipte.HSFE_Territory__c);
            }
            Map<String,HSFE_Territory_To_User__c> tempMap;
            Map<Id, Map<String,HSFE_Territory_To_User__c >> territoryToRoleToUserMapMap = new Map<Id, Map<String,HSFE_Territory_To_User__c >>();
            List<HSFE_Territory_To_User__c> terrToUserList= new List<HSFE_Territory_To_User__c>([Select Id, HSFE_User_Role__c,HSFE_Territory__c, HSFE_User__c,HSFE_User_Active__c from HSFE_Territory_To_User__c where HSFE_Territory__c IN :terrIdSet and HSFE_User_Active__c = true]);
            for(HSFE_Territory_To_User__c terrUser: terrToUserList){
                if(terrUser.HSFE_User_Role__c != null){
                    if(territoryToRoleToUserMapMap.containsKey(terrUser.HSFE_Territory__c)){
                        tempMap = territoryToRoleToUserMapMap.get(terrUser.HSFE_Territory__c);
                        tempMap.put(terrUser.HSFE_User_Role__c,terrUser);
                    }else{
                        tempMap = new Map<String,HSFE_Territory_To_User__c>();
                        tempMap.put(terrUser.HSFE_User_Role__c,terrUser);
                    }
                    territoryToRoleToUserMapMap.put(terrUser.HSFE_Territory__c,tempMap);
                }
            }
            Id terrId;
            Map<String,HSFE_Territory_To_User__c> territoryUserMap;
            Boolean checkRole;
            for(Lead l : leadToAssignList){
                terrId = null;
                combinationKey = '';
                postalCode = '';
                exceptionCombKey = '';
                exceptionPosatlCode='';
                trimPostalCode = '';
                postalCode = l.PostalCode;
                trimPostalCode = postalCode.length()>5?postalCode.left(5):postalCode;
                combinationKey = trimPostalCode+l.HSFE_Specialty__c+l.HSFE_Sub_Speciality__c;
                exceptionPosatlCode = postalCode.length()>5?postalCode.left(5):postalCode;
                exceptionCombKey = l.HSFE_SAP_ID__c+exceptionPosatlCode+l.HSFE_Specialty__c+l.HSFE_Sub_Speciality__c;
                if(exepCombKeyToTerrIdMap.containsKey(exceptionCombKey)){
                    terrId = exepCombKeyToTerrIdMap.get(exceptionCombKey);
                }else if(terrCombKeyToTerrIdMap.containsKey(combinationKey)){
                    terrId = terrCombKeyToTerrIdMap.get(combinationKey);
                }
                l.HSFE_Territory__c = terrId;
                if(groupList.size()>0){
                    l.ownerid = groupList[0].id;
                }
                if(terrId != null && territoryToRoleToUserMapMap.containsKey(terrId)){            
                    territoryUserMap = territoryToRoleToUserMapMap.get(terrId);  // Get the territory and its related user based on the combination key.    
                    if(territoryUserMap.size()>0 && territoryUserMap!= null){                
                        terrToUserList = new List<HSFE_Territory_To_User__c>(); 
                        l.HSFE_Territory_User__c = ''; //Clear a value before assigning a user.                                                 
                        terrToUserList = territoryUserMap.values();                   
                        system.debug('Map Values'+ terrToUserList); 
                        for(HSFE_Territory_To_User__c userTerr : terrToUserList){
                            l.HSFE_Territory__c = userTerr.HSFE_Territory__c; // Assign territory
                            l.HSFE_Territory_User__c =  l.HSFE_Territory_User__c != ''?l.HSFE_Territory_User__c+';'+userTerr.HSFE_User__c:userTerr.HSFE_User__c;// For My territory.
                        }                  
                        checkRole = false;
                        if(territoryUserMap.containsKey(HSFE_Constant.TM) && l.HSFE_Specialty__c == HSFE_Constant.SURGICAL && checkRole == false){                            
                            l.ownerid = territoryUserMap.get(HSFE_Constant.TM).HSFE_User__c; //Assign the lead owner                       
                            checkRole = true;
                        }
                        else if(territoryUserMap.containsKey(HSFE_Constant.RVP) && l.HSFE_Specialty__c == HSFE_Constant.SURGICAL && checkRole == false){
                             l.ownerid = territoryUserMap.get(HSFE_Constant.RVP).HSFE_User__c;  //Assign the lead owner
                             checkRole = true;
                        }
                        else if(territoryUserMap.containsKey(HSFE_Constant.INSIDESALES) && l.HSFE_Specialty__c == HSFE_Constant.SURGICAL && checkRole == false){
                             l.ownerid = territoryUserMap.get(HSFE_Constant.INSIDESALES).HSFE_User__c;  //Assign the lead owner
                             checkRole = true;
                        }
                        if(territoryUserMap.containsKey(HSFE_Constant.TM) && l.HSFE_Specialty__c == HSFE_Constant.MEDICAL && l.HSFE_Renewal_Lead__c ==false &&
                           l.HSFE_IsImported__c == false && checkRole == false){                            
                            l.ownerid = territoryUserMap.get(HSFE_Constant.TM).HSFE_User__c; //Assign the lead owner                       
                            checkRole = true;
                        }
                        else if(territoryUserMap.containsKey(HSFE_Constant.RVP) && l.HSFE_Specialty__c == HSFE_Constant.MEDICAL && 
                                l.HSFE_Renewal_Lead__c ==false && l.HSFE_IsImported__c == false && checkRole == false){
                             l.ownerid = territoryUserMap.get(HSFE_Constant.RVP).HSFE_User__c;  //Assign the lead owner
                             checkRole = true;
                        }
                        else if(territoryUserMap.containsKey( HSFE_Constant.INSIDESALES) && l.HSFE_Specialty__c == HSFE_Constant.MEDICAL && 
                                l.HSFE_Renewal_Lead__c ==false && l.HSFE_IsImported__c == false && checkRole == false){
                             l.ownerid = territoryUserMap.get(HSFE_Constant.INSIDESALES).HSFE_User__c;  //Assign the lead owner
                             checkRole = true;
                        }    
                    }                               
                }
           }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }
    }
    /*********************************************************************************
     * Method Name:handleAfterUpdate
     * Description:Update Opportunity field with lead fields on conversion
     * Return Type: None.
    ********************************************************************************/
    public static void handleAfterUpdate(List<Lead> leadList, Map<Id,Lead> oldLeadMap){
        try{
            Set<Id> opportunityIds = new Set<Id>();
            Set<ID> accountids = new Set<Id>();
            Map<Id,Opportunity> convertedOppMap = new Map<Id,Opportunity>();
            List<Opportunity> oppRecList = new List<Opportunity>();
            List<Opportunity> updateoppRecList = new List<Opportunity>();
            for(Lead leadRec:leadList){
                Lead oldLeadRec = oldLeadMap.get(leadRec.Id);
                    if (leadRec.isConverted == true  && oldLeadRec.isConverted == false && leadRec.convertedOpportunityId != null && leadRec.convertedaccountid!= null) {
                    opportunityIds.add(leadRec.convertedOpportunityId); 
                    accountids.add(leadRec.convertedaccountid);                
                }
            }
             
            if(opportunityIds.size()>0){
                oppRecList =[Select Id, Description,HSFE_Lead_Origin__c,HSFE_Lead_Sub_Origin__c,CloseDate,HSFE_Admin_Update__c,Amount,HSFE_Specialty__c,HSFE_Sub_Specialty__c,HSFE_Capital_Amount__c,HSFE_Disposable_Amount__c,HSFE_Service_Amount__c from Opportunity where ID IN:opportunityIds];
                if(oppRecList .size()>0){
                    for(Opportunity opp:oppRecList){
                        convertedOppMap.put(opp.Id,opp);
                    }
                }
                for(Lead leadRec:leadList){
                    Opportunity oppRec = convertedOppMap.get(leadRec.convertedOpportunityId);
                    oppRec.Description=leadRec.Description;
                    oppRec.HSFE_Lead_Origin__c=leadRec.HSFE_Origin__c;
                    oppRec.HSFE_Lead_Sub_Origin__c=leadRec.HSFE_Sub_Origin__c;
                    oppRec.Amount=leadRec.HSFE_Opportunity_Amount__c;
                    oppRec.HSFE_Specialty__c=leadRec.HSFE_Specialty__c;
                    oppRec.HSFE_Sub_Specialty__c=leadRec.HSFE_Sub_Speciality__c;
                    oppRec.HSFE_Product_Interest__c=leadRec.HSFE_Product_Interest__c;
                    oppRec.StageName='Pipeline';
                    oppRec.HSFE_Contact__c=leadRec.convertedContactId;
                    //oppRec.HSFE_Admin_Update__c = true;
                    if(leadRec.HSFE_Expected_Close_Date__c!=Null){
                        oppRec.CloseDate=leadRec.HSFE_Expected_Close_Date__c;
                    }
                    updateoppRecList.add(oppRec);
                }
            }
            if(updateoppRecList.size()>0){
                update updateoppRecList;                        
                HSFE_OpptyOwnerUpdate_FutureClass.updateOpportunityOwner(opportunityIds);
            }
        }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
     /*********************************************************************************
     * Method Name:changeName
     * Description: Change Name of Lead
     * Return Type:None
     ********************************************************************************/
    public static void changeName(list<Lead> leadToChangeNameList){
        try{
            set<Id> accountIdSet = new set<Id>();
            set<String> specialtySet = new set<String>();
            set<String> subSpecialtySet = new set<String>();
            map<String, list<Lead>> leadUpdateMap = new map<String, list<Lead>>();
            list<Lead> tempLeadList;
            String key;
            for(Lead newLead : leadToChangeNameList){
                if(newLead.HSFE_Account__c != null && newLead.HSFE_Specialty__c != null && newLead.HSFE_Sub_Speciality__c != null){
                    accountIdSet.add(newLead.HSFE_Account__c);
                    system.debug('accountIdSet****'+accountIdSet);
                    specialtySet.add(newLead.HSFE_Specialty__c);
                    subSpecialtySet.add(newLead.HSFE_Sub_Speciality__c);
                    key = String.valueOf(newLead.HSFE_Account__c).Left(15) + newLead.HSFE_Specialty__c + newLead.HSFE_Sub_Speciality__c;
                    if(leadUpdateMap.containsKey(key)){
                        tempLeadList = leadUpdateMap.get(key);
                        tempLeadList.add(newLead);
                        leadUpdateMap.put(key, tempLeadList);
                    }else{
                        tempLeadList = new list<Lead>();
                        tempLeadList.add(newLead);
                        leadUpdateMap.put(key, tempLeadList);
                    }
                }
            }
            List<Contact> primContactList = new List<Contact>([SELECT FirstName,LastName,MiddleName,Salutation,Suffix, HSFE_Specialty__c, HSFE_Sub_Specialty__c, AccountId FROM Contact WHERE HSFE_Specialty__c IN :specialtySet AND HSFE_Sub_Specialty__c IN :subSpecialtySet AND AccountId IN :accountIdSet AND HSFE_Primary__c = true]);
            for(Contact con: primContactList){
                key = String.valueOf(con.AccountId).Left(15) + con.HSFE_Specialty__c + con.HSFE_Sub_Specialty__c; 
                system.debug('Contact Key'+key);
                if(leadUpdateMap.containsKey(key)){
                    tempLeadList = leadUpdateMap.get(key);
                    for(Lead ld : tempLeadList){
                        ld.FirstName = con.FirstName;
                        ld.LastName = con.LastName;
                        ld.Salutation = con.Salutation;
                        ld.MiddleName = con.MiddleName;
                        ld.Suffix = con.Suffix;
                    }
                }
            }
          }catch(Exception e){
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
}