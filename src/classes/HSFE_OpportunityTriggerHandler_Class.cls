/* Class Name :HSFE_OpportunityTriggerHandler_Class 
*Description :Trigger Handler for the Opportunity SObject, which implements all the logic of Opportunity trigger.
              1. Update the standard pricebook on opportunity before insert
              2. Update the Opportunity record type based on opportunity type picklist on creation of opportunity
*Created By :Chiranth Aradhya
*Created On :02/24/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public class HSFE_OpportunityTriggerHandler_Class {
    
        /*********************************************************************************
     * Method Name:handleBeforeInsert
     * Description:Update the standard pricebook Id on opportunity and record type based on Opportunity type.
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeInsert(List<Opportunity> oppList) {
        try{
            //Code for Territory Management
            list<Opportunity> opptyToUpdateList = new list<Opportunity>();
            list<Opportunity> opptyToDeleteList = new list<Opportunity>();
            Map<String,Id>opportuntiyCombinationMap = new Map<String,Id>();
            Set<String>opportuntiyCombinationSet = new Set<String>();
            set<Id> oppAccId = new set<Id>();
            set<String> accountQuerySet = new set<String>();
            //End Code for Territory Management
            set<Id> acntId = new set<Id>();//getting account ids
            Set<Id> secOwnerIds = new Set<id>();
            Map<Id,User> userMap = new Map<Id,User>();
            Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = sObjectMap.get('Opportunity') ; // getting Sobject Type
            Schema.DescribeSObjectResult resSchema = s.getDescribe() ;
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName(); //getting all Recordtype for the Sobject
            List<Contact> conList = new List<Contact>();
            Map<Id,Contact>specialtyMap = new Map<Id,Contact>();
            List<Pricebook2> stdPBL = new List<Pricebook2> ();
            //get the standard pricebook        
            stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];

            for(Opportunity opp:oppList){
                opportuntiyCombinationSet.add(opp.HSFE_Combination_Key__c);
               //update the pricebook on opportunity before insert
               if(!stdPBL.isEmpty()){
                   opp.PriceBook2Id = stdPBL[0].id;
               }
               if(opp.HSFE_Secondary_Owner__c != null){
                    secOwnerIds.add(opp.HSFE_Secondary_Owner__c);
               }
               oppAccId.add(opp.AccountId);
                 //Code for Territory Management
               if(HSFE_Utility_Class.stopUpdateOpptyTerritory == false){ // Stop the logic to excute when a batch class run.
                    if(opp.HSFE_Specialty__c != null && opp.HSFE_Sub_Specialty__c!= null && opp.AccountId !=null && opp.HSFE_Combination_Key__c!= null){
                        opptyToUpdateList.add(opp);
                        system.debug('opp.HSFE_Combination_Key__c**********'+opp.HSFE_Combination_Key__c);
                        accountQuerySet.add(String.valueOf(opp.HSFE_Combination_Key__c));
                    }
                    
                }
                
                //End Code for Territory Management               
                 //Code for Opportunity Creation Ability
                if(opp.AccountId != null){
                    acntId.add(opp.AccountId);                
                }
                //End Code for Opportunity Creation Ability
                              
            }
            //Query the primary  contact records which are related to opporutnities account
            for(Contact cont:[Select Id,Name,HSFE_Primary__c,HSFE_Specialty__c,HSFE_Sub_Specialty__c,AccountId from Contact where HSFE_AccCon_SpecialtySubSpecialty__c IN:opportuntiyCombinationSet and HSFE_Primary_Text__c= 'Yes' AND AccountId =:oppAccId]){
                opportuntiyCombinationMap.put(cont.AccountId+cont.HSFE_Specialty__c+cont.HSFE_Sub_Specialty__c,cont.Id);
            }

            //Code for Territory Management
            if(opptyToUpdateList.size() > 0 && HSFE_Utility_Class.stopFutureExceution == false){
                assignTerritory(opptyToUpdateList, opptyToDeleteList, accountQuerySet, false);  
            }
            //End Code for Territory Management
            
            //query user based on secOwnerIds
            if(secOwnerIds.size()> 0){
                for(User usr:[Select id,HSFE_Specialty__c,HSFE_Sub_Specialty__c from User where Id IN:secOwnerIds]){
                    userMap.put(usr.Id,usr);
                }
            }
            
            for(Opportunity opp:oppList){
                //Restrict owner update
                if(HSFE_Utility_Class.stopUpdateOpptyTerritory == false && (opp.HSFE_Territory__c!= null) && opp.HSFE_Admin_Update__c == true){
                     opp.HSFE_Admin_Update__c = false;                      
                }
                //Update Secondary specialty 
                if(opp.HSFE_Secondary_Owner__c != null){
                    opp.HSFE_Secondary_Specialty__c=userMap.get(opp.HSFE_Secondary_Owner__c).HSFE_Specialty__c;
                }
                //Update secondary sub specialty
                if(opp.HSFE_Secondary_Owner__c != null){
                    opp.HSFE_Secondary_Sub_Specialty__c=userMap.get(opp.HSFE_Secondary_Owner__c).HSFE_Sub_Specialty__c;
                }
                //Update contact on Opportunity
                if(opp.HSFE_Contact__c == null){
                    if( opportuntiyCombinationMap.ContainsKey(opp.AccountId+opp.HSFE_Specialty__c+opp.HSFE_Sub_Specialty__c) && opportuntiyCombinationMap != null ){
                        opp.HSFE_Contact__c = opportuntiyCombinationMap.get(opp.AccountId+opp.HSFE_Specialty__c+opp.HSFE_Sub_Specialty__c);
                    }
                }                
                //End Code for Opportunity Creation Ability
            }
            //Code for Opportunity Creation Ability
            if(acntId.size()>0){
                restrictOpty(acntId,oppList);
            }
            
        }// Create a log file for an exception.  
        catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);}
    }
    
    /*********************************************************************************
     * Method Name:handleBeforeUpdate
     * Description:Update the standard pricebook Id on opportunity and record type based on Opportunity type.
     * Return Type: None.
     ********************************************************************************/
    public static void handleBeforeUpdate(List<Opportunity> oppList, Map<Id,Opportunity> oldOpportunityMap) {
        try{
            //Code for Territory Management
            list<Opportunity> opptyToUpdateList = new list<Opportunity>();
            list<Opportunity> opptyToDeleteList = new list<Opportunity>();
            list<Opportunity> opptyOwnerList = new list<Opportunity>();
            set<String> accountQuerySet = new set<String>();
            Set<Id> secOwnerIds = new Set<id>();  
            Map<Id,User> userMap = new Map<Id,User>();
            
            //End Code for Territory Management
            Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = sObjectMap.get('Opportunity') ; // getting Sobject Type
            Schema.DescribeSObjectResult resSchema = s.getDescribe() ;
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName(); //getting all Recordtype for the Sobject
            set<Id> acntId = new set<Id>();//getting account ids
            List<Pricebook2> stdPBL = new List<Pricebook2> ();
            //get the standard pricebook        
            stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
            String errorMessage = 'You cannot change the Opportunity owner manually';
            for(Opportunity opp:oppList){
                Opportunity oldOppty  = oldOpportunityMap.get(opp.Id);
                //update the pricebook on opportunity before insert
                if(!stdPBL.isEmpty()){
                    opp.PriceBook2Id = stdPBL[0].id;
                }
                if(opp.HSFE_Secondary_Owner__c != null && opp.HSFE_Secondary_Owner__c != oldOppty.HSFE_Secondary_Owner__c ){
                    secOwnerIds.add(opp.HSFE_Secondary_Owner__c);
                }
                //Code for Territory Management
                if(HSFE_Utility_Class.stopUpdateOpptyTerritory == false){ // Stop the logic to excute when a batch class run.
                    if((opp.HSFE_Specialty__c != oldOppty.HSFE_Specialty__c) || (opp.HSFE_Sub_Specialty__c != oldOppty.HSFE_Sub_Specialty__c) || (opp.AccountId != oldOppty.AccountId)
                        || (opp.HSFE_Secondary_Owner__c != oldOppty.HSFE_Secondary_Owner__c )){
                        opptyToDeleteList.add(opp);
                        opp.HSFE_Territory__c = null;
                        if(opp.HSFE_Specialty__c != null && opp.HSFE_Sub_Specialty__c!= null && opp.AccountId !=null){
                            opptyToUpdateList.add(opp);
                            accountQuerySet.add(opp.HSFE_Combination_Key__c);
                        }
                    }
                }
                //Code for Opportunity Creation Ability
                if(opp.AccountId != oldOppty.AccountId && opp.AccountId != null){
                    acntId.add(opp.AccountId);                
                }
                //End Code for Opportunity Creation Ability
            }
            //End Code for Territory Management
               
            //query user based on secOwnerIds
            if(secOwnerIds.size()> 0){
                for(User usr:[Select id,HSFE_Specialty__c,HSFE_Sub_Specialty__c from User where Id IN:secOwnerIds]){
                    userMap.put(usr.Id,usr);
                }
            }       
            //Code for Territory Management
            if(opptyToUpdateList.size() > 0 || opptyToDeleteList.size() > 0 && HSFE_Utility_Class.stopFutureExceution == false){
                assignTerritory(opptyToUpdateList, opptyToDeleteList, accountQuerySet, false);  
            }
            //End Code for Territory Management
            
            //Code for Opportunity Creation Ability
            if(acntId.size()>0){
                restrictOpty(acntId,oppList);
            }
            //End Code for Opportunity Creation Ability
            for(Opportunity opp:oppList){
                //Owner change restrication
                Opportunity oldOppty  = oldOpportunityMap.get(opp.Id);
                if(HSFE_Utility_Class.stopUpdateOpptyTerritory == false && (opp.ownerid != oldOppty.ownerid)){
                    if(opp.HSFE_Admin_Update__c == true){
                        
                    }else{
                        opp.addError(errorMessage);
                    }
                }
                if(opp.HSFE_Admin_Update__c == true){
                    opp.HSFE_Admin_Update__c = false;
                }
                //Update Secondary specialty 
                if( userMap.ContainsKey(opp.HSFE_Secondary_Owner__c) && opp.HSFE_Secondary_Owner__c != null){
                    //if(userMap.get(opp.HSFE_Secondary_Owner__c).HSFE_Specialty__c != null )
                    opp.HSFE_Secondary_Specialty__c=userMap.get(opp.HSFE_Secondary_Owner__c).HSFE_Specialty__c;
                    
                }
                //Update secondary sub specialty
                if(opp.HSFE_Secondary_Owner__c != null && userMap.ContainsKey(opp.HSFE_Secondary_Owner__c)){
                    //if(userMap.get(opp.HSFE_Secondary_Owner__c).HSFE_Sub_Specialty__c!= null )
                    opp.HSFE_Secondary_Sub_Specialty__c=userMap.get(opp.HSFE_Secondary_Owner__c).HSFE_Sub_Specialty__c;
                }
            }
        }
        // Create a log file for an exception.  
        catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);}
    }
    
    
    /*********************************************************************************
     * Method Name:handleAfterUpdate
     * Description:Update Territory on Opportunity
     * Return Type: None.
     ********************************************************************************/
    public static void handleAfterUpdate(Map<Id, Opportunity> oldOpptyMap,Map<Id, Opportunity> newOpptyMap) {
        try{
            string timeSinceOpptyClosed;
            list<Opportunity> opptyToUpdateList = new list<Opportunity>();
            list<Opportunity> opptyToDeleteList = new list<Opportunity>();
            list<Event> eventList = new list<Event>();
            list<Event> updateEventList = new list<Event>();
            Set<String> accountQuerySet = new Set<String>();
            Map<Id,Opportunity>OppMap = new Map<Id,Opportunity>();
            for(Id idVal:newOpptyMap.keySet()){
                Opportunity newOppty = newOpptyMap.get(idVal);
                Opportunity oldOppty = oldOpptyMap.get(idVal);
                if(HSFE_Utility_Class.stopUpdateOpptyTerritory == false){ // Stop the logic to excute when a batch class run.
                    if((newOppty.HSFE_Specialty__c != oldOppty.HSFE_Specialty__c) || (newOppty.HSFE_Sub_Specialty__c != oldOppty.HSFE_Sub_Specialty__c) || (newOppty.AccountId != oldOppty.AccountId)
                        || (newOppty.HSFE_Secondary_Owner__c != oldOppty.HSFE_Secondary_Owner__c )){
                        opptyToDeleteList.add(newOppty);
                        if(newOppty.HSFE_Specialty__c != null && newOppty.HSFE_Sub_Specialty__c!= null && newOppty.AccountId !=null){
                            opptyToUpdateList.add(newOppty);
                            accountQuerySet.add(newOppty.HSFE_Combination_Key__c);
                        }
                    }
                    if((newOppty.HSFE_Opportunity_Won_Date__c != oldOppty.HSFE_Opportunity_Won_Date__c) && newOppty.HSFE_Opportunity_Won_Date__c !=null){
                        OppMap.put(newOppty.id,newOppty);
                    }
                }
            }
            
            eventList =[Select Id, CreatedDate,WhatId,HSFE_Time_since_Opportunity_Closed__c from event where WhatId =:OppMap.Keyset()];
            
            if(eventList.size()>0){
                for(Event evet:eventList){
                    if(OppMap.get(evet.WhatId).HSFE_Opportunity_Won_Date__c >= evet.CreatedDate.Date()){
                        timeSinceOpptyClosed= String.ValueOf(evet.CreatedDate.Date().daysBetween(OppMap.get(evet.WhatId).HSFE_Opportunity_Won_Date__c));
                    }else{
                        timeSinceOpptyClosed= String.ValueOf(OppMap.get(evet.WhatId).HSFE_Opportunity_Won_Date__c.daysBetween(evet.CreatedDate.Date()));
                    }
                    evet.HSFE_Time_since_Opportunity_Closed__c = (timeSinceOpptyClosed== '1' ? timeSinceOpptyClosed+' day': timeSinceOpptyClosed +' days'); 
                    updateEventList.add(evet);
                }
                //update time since opportunity closed field on event 
                if(updateEventList.size()>0){
                    update updateEventList;
                }
            }
            //Code for Territory Management
            if(opptyToUpdateList.size() > 0 || opptyToDeleteList.size() > 0 && HSFE_Utility_Class.stopFutureExceution == false){
                assignTerritory(opptyToUpdateList, opptyToDeleteList, accountQuerySet, true);   
            }
            //End Code for Territory Management
        }
        // Create a log file for an exception.  
        catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);}
    }
    /*********************************************************************************
     * Method Name:handleAfterUpdate
     * Description:Update Territory on Opportunity
     * Return Type: None.
     ********************************************************************************/
    public static void handleAfterInsert(Map<Id, Opportunity> newOpptyMap) {
        try{
            list<Opportunity> opptyToUpdateList = new list<Opportunity>();
            list<Opportunity> opptyToDeleteList = new list<Opportunity>();
            Set<String> accountQuerySet = new Set<String>();
            for(Id idVal:newOpptyMap.keySet()){
                Opportunity newOppty = newOpptyMap.get(idVal);
                if(HSFE_Utility_Class.stopUpdateOpptyTerritory == false){ // Stop the logic to excute when a batch class run.
                    if(newOppty.HSFE_Specialty__c != null && newOppty.HSFE_Sub_Specialty__c!= null && newOppty.AccountId !=null){
                        opptyToUpdateList.add(newOppty);
                        accountQuerySet.add(newOppty.HSFE_Combination_Key__c);
                    }
                }
            }
            //Code for Territory Management
            if(opptyToUpdateList.size() > 0 && HSFE_Utility_Class.stopFutureExceution == false){
                assignTerritory(opptyToUpdateList, opptyToDeleteList, accountQuerySet, true);   
            }
            //End Code for Territory Management
        }
        // Create a log file for an exception.  
        catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);}
    }
    /*********************************************************************************
     * Method Name:assignTerritory
     * Description:Update Territory on Opportunity
     * Return Type: None.
     ********************************************************************************/
    public static void assignTerritory(list<Opportunity> opptyToUpdateList,list<Opportunity> opptyToDeleteList, Set<String> accountQuerySet, boolean updateTeam) {
        try{
            Map<String, Id> combKeytoTerrMap = new Map<String, Id>();
            Set<Id> terrIdSet = new Set<Id>();
            Id userId;
            List<User> userList = new List<User>();
            List<UserRole> roleList = new List<UserRole>();
            Id gVPSurgical;
            Id gVPMedical;        
            Set<String> specialtySet = new Set<String>();
            Boolean creatorPresent;
            List<OpportunityTeamMember> teamToCreateList = new List<OpportunityTeamMember>();       
            OpportunityTeamMember tempTeam;
            if(opptyToUpdateList.size() > 0){           
                specialtySet.add(HSFE_Constant.SURGICAL);
                specialtySet.add(HSFE_Constant.MEDICAL); 
                roleList = [select id from userrole where name =:HSFE_Constant.GVP];
                userList = [select id,username,HSFE_Specialty__c,userroleid from user where userroleid =:roleList and HSFE_Specialty__c IN :specialtySet];          
                for(User u : userList ){
                        if(u.HSFE_Specialty__c == HSFE_Constant.SURGICAL){
                             gVPSurgical = u.id;
                        }
                        if(u.HSFE_Specialty__c == HSFE_Constant.MEDICAL){
                            gVPMedical = u.id;
                        }
                }
                List<HSFE_Account_Territory__c> accTerrList = new List<HSFE_Account_Territory__c>([SELECT Id, Account__c, Territory__c, HSFE_Combination_Key__c FROM HSFE_Account_Territory__c WHERE HSFE_Combination_Key__c IN :accountQuerySet]);
                for(HSFE_Account_Territory__c accTerr: accTerrList){
                    combKeytoTerrMap.put(accTerr.HSFE_Combination_Key__c, accTerr.Territory__c);
                    terrIdSet.add(accTerr.Territory__c);
                }
                Map<String,HSFE_Territory_To_User__c> tempMap;
                Map<String,List<HSFE_Territory_To_User__c>> territroyUserMap  = new Map<String,List<HSFE_Territory_To_User__c>>();
                List<HSFE_Territory_To_User__c> territoryUserList;           
                Map<Id, Map<String,HSFE_Territory_To_User__c >> territoryToRoleToUserMapMap = new Map<Id, Map<String,HSFE_Territory_To_User__c >>();
                List<HSFE_Territory_To_User__c> terrToUserList= new List<HSFE_Territory_To_User__c>([Select Id, HSFE_User_Role__c,HSFE_Territory__c, HSFE_User__c,HSFE_User_Active__c from HSFE_Territory_To_User__c where HSFE_Territory__c IN :terrIdSet and HSFE_User_Active__c= true]);
                for(HSFE_Territory_To_User__c terrUser: terrToUserList){                  
                    if(territoryToRoleToUserMapMap.containsKey(terrUser.HSFE_Territory__c)){                        
                        territoryUserList = territroyUserMap.get(terrUser.HSFE_Territory__c);
                        if(terrUser.HSFE_User_Role__c != null){
                        	tempMap = territoryToRoleToUserMapMap.get(terrUser.HSFE_Territory__c);
                        	tempMap.put(terrUser.HSFE_User_Role__c,terrUser);
                        }
                        territoryUserList.add(terrUser);
                        territroyUserMap.put(terrUser.HSFE_Territory__c,territoryUserList);
                    }else{                        
                        territoryUserList = new List<HSFE_Territory_To_User__c>();
                        tempMap = new Map<String,HSFE_Territory_To_User__c>(); 
                        if(terrUser.HSFE_User_Role__c != null){	                                              
	                        tempMap.put(terrUser.HSFE_User_Role__c,terrUser);
                        }
                        territoryUserList.add(terrUser);
                        territroyUserMap.put(terrUser.HSFE_Territory__c,territoryUserList);
                    }
                    territoryToRoleToUserMapMap.put(terrUser.HSFE_Territory__c,tempMap);                    
                }
                for(Opportunity tempOppty : opptyToUpdateList){
                    creatorPresent = false;
                    userId = tempOppty.CreatedById;
                    if(!updateTeam){
                        if(userList.size()>0){
                            tempOppty.HSFE_Approval_GVP_User__c = tempOppty.HSFE_Specialty__c == HSFE_Constant.MEDICAL?gVPMedical:gVPSurgical;
                        }               
                        tempOppty.HSFE_Approval_DVP_User__c = null;
                        tempOppty.HSFE_Approval_AVP_User__c = null;
                        tempOppty.HSFE_Approval_RSD_RVP_User__c = null;
                    }
                    if(combKeytoTerrMap.containsKey(tempOppty.HSFE_Combination_Key__c)){
                        Id terrId = combKeytoTerrMap.get(tempOppty.HSFE_Combination_Key__c);
                        if(!updateTeam){
                            tempOppty.HSFE_Territory__c = terrId;                        
                        }
                        if(territoryToRoleToUserMapMap.containsKey(terrId)){
                            tempMap = territoryToRoleToUserMapMap.get(terrId);
                            if(territroyUserMap.containsKey(terrId)) {
                                territoryUserList = territroyUserMap.get(terrId);
                            }                    
                            if(tempMap.containsKey(HSFE_Constant.TM)){
                                if(!updateTeam){
                                    tempOppty.OwnerId = tempMap.get(HSFE_Constant.TM).HSFE_User__c;
                                    tempOppty.HSFE_Admin_Update__c = true;
                                }
                            }                        
                            if(tempMap.containsKey(HSFE_Constant.DVP) && !updateTeam){
                                tempOppty.HSFE_Approval_DVP_User__c = tempMap.get(HSFE_Constant.DVP).HSFE_User__c;
                            }
                            else if(!tempMap.containsKey(HSFE_Constant.DVP) && !updateTeam){
                                tempOppty.HSFE_Approval_DVP_User__c = tempOppty.HSFE_Approval_GVP_User__c;
                            }
                            if(tempMap.containsKey(HSFE_Constant.AVP) && !updateTeam){
                                tempOppty.HSFE_Approval_AVP_User__c = tempMap.get(HSFE_Constant.AVP).HSFE_User__c;
                            }
                            else if(!tempMap.containsKey(HSFE_Constant.AVP) && !updateTeam){
                                tempOppty.HSFE_Approval_AVP_User__c = tempOppty.HSFE_Approval_DVP_User__c;
                            }                        
                            if(tempMap.containsKey(HSFE_Constant.RVP) && !updateTeam){
                                tempOppty.HSFE_Approval_RSD_RVP_User__c =tempMap.get(HSFE_Constant.RVP).HSFE_User__c;
                            }
                            else if(!tempMap.containsKey(HSFE_Constant.RVP) && !updateTeam){
                                tempOppty.HSFE_Approval_RSD_RVP_User__c = tempOppty.HSFE_Approval_AVP_User__c;
                            }
                            
                        }
                        if(updateTeam) {                        
                            for(HSFE_Territory_To_User__c role : territoryUserList){
                                if(userId == role.HSFE_User__c){
                                    creatorPresent = true;
                                }
                                tempTeam = new OpportunityTeamMember(OpportunityId = tempOppty.Id, UserId = role.HSFE_User__c, TeamMemberRole = role.HSFE_User_Role__c);
                                teamToCreateList.add(tempTeam); 
                            }
                            if(!creatorPresent){
                                tempTeam = new OpportunityTeamMember(OpportunityId = tempOppty.Id, UserId = userId, TeamMemberRole = 'Creator');
                                teamToCreateList.add(tempTeam);
                            }
                            //For adding a secondary owner - 6/4/2015
                            if(tempOppty.HSFE_Secondary_Owner__c != null){
                                tempTeam = new OpportunityTeamMember(OpportunityId = tempOppty.Id, UserId = tempOppty.HSFE_Secondary_Owner__c, TeamMemberRole = 'Secondary Owner');
                                teamToCreateList.add(tempTeam);
                            }
                        }
                    }
                }
            }
            if(updateTeam){
                if(opptyToDeleteList.size() > 0){
                    List<OpportunityTeamMember> teamToDeleteList = new List<OpportunityTeamMember>([SELECT Id from OpportunityTeamMember WHERE OpportunityId IN :opptyToDeleteList AND OpportunityAccessLevel != 'All']);
                    if(teamToDeleteList.size() > 0){
                        system.debug('teamToDeleteList****>'+teamToDeleteList);
                        Delete teamToDeleteList;
                    }
                }
                if(teamToCreateList.size() > 0){
                    Insert teamToCreateList;
                    List<OpportunityShare > updateOpptyShareList = new List<OpportunityShare>();
                    List<OpportunityShare > shares = [select Id, OpportunityAccessLevel, OpportunityId from OpportunityShare where OpportunityId IN :opptyToUpdateList 
                                                and OpportunityAccessLevel != 'All' and OpportunityAccessLevel !='Edit' and RowCause= 'Team'];
                    if(shares.size()>0){
                        for(OpportunityShare oppShare:shares ){
                            oppShare.OpportunityAccessLevel='Edit';
                            updateOpptyShareList.add(oppShare);
                        }
                    }
                    if(updateOpptyShareList.size()>0){
                        update updateOpptyShareList;
                    }
                }
            }
        }
        // Create a log file for an exception.  
        catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);}
    }
 
   //Code for Opportunity Creation Ability
     public static void restrictOpty(Set<Id> accountId, List<Opportunity> Opty){
        String errorMessage = System.Label.HSFE_Opty_Creation_Access;
        map<id,Set<Id>> accountIdToAccountTeamUserIdSetMap = new map<id,Set<Id>>();//mapfor account and account team member
        Set<String> profileSet = new Set<String>();
        list<Profile> nameList = new list<Profile> ();
        List<AccountTeamMember> accountTeam = new List<AccountTeamMember> ();
        for(HSFE_Opportunity_Profiles__c profile : HSFE_Opportunity_Profiles__c.getall().values()){
            profileSet.add(profile.name); 
        } 
         nameList = [Select Id,Name from Profile where Id =: UserInfo.getProfileId() limit 1];
        Set<Id> UserIdSet;
        if(nameList.size()>0){
            accountTeam = [SELECT Id,AccountId,UserId from AccountTeamMember WHERE AccountId IN :accountId];
            if(accountTeam.size()>0){
                for(AccountTeamMember accTm: accountTeam){
                    if(!accountIdToAccountTeamUserIdSetMap.containsKey(accTm.AccountId)){
                        UserIdSet = new Set<Id>();
                        UserIdSet.add(accTm.UserId);
                        accountIdToAccountTeamUserIdSetMap.put(accTm.AccountId,UserIdSet);
                    }
                    else{
                        UserIdSet = accountIdToAccountTeamUserIdSetMap.get(accTm.AccountId);
                        UserIdSet.add(accTm.UserId);
                    }
                    
                }
            }
            for(Opportunity opt : Opty){
                if(accountTeam.size()>0){
                    if(accountIdToAccountTeamUserIdSetMap.containsKey(opt.AccountId)){
                        Set<Id> accountTeamIdSet = accountIdToAccountTeamUserIdSetMap.get(opt.AccountId);
                        if(accountTeamIdSet.size()>0){
                            if(accountTeamIdSet.contains(UserInfo.getUserId()) == false && profileSet.contains(nameList[0].name)== false){
                            opt.addError(errorMessage);
                            }                           
                      }
                    }
                }
                else if(!profileSet.contains(nameList[0].name)){
                    opt.addError(errorMessage);
                }   
            }
         }                              
      }
    //End Code for Opportunity Creation Ability             
}