/* Class Name : HSFE_OppTerritoryAssignment_BatchClass
*Description :  This class used to assign territory based on zipcode and SAP ID.
*Created By :   Sunil Kumar
*Created On :   04/13/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Sunil              4/13/2015                      Created                               
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public with sharing class HSFE_OppTerritoryAssignment_BatchClass implements Database.Batchable<sObject>, Database.Stateful{
   /***********************************************************************************************
   Method Name:Start
   Parameter:Database.BatchableContext
   Return Type:Database.QueryLocator
   Description: Fetched all the opportunity records where Specialty and Sub Specialty are not null. 
   *************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, OwnerId, HSFE_Territory__c, HSFE_Combination_Key__c, HSFE_Sub_Specialty__c, HSFE_Specialty__c,
        								HSFE_Secondary_Owner__c,HSFE_Approval_DVP_User__c,HSFE_Approval_GVP_User__c,HSFE_Approval_AVP_User__c,HSFE_Approval_RSD_RVP_User__c,
        							    AccountId,HSFE_Account_Postal_Code__c,CreatedById FROM Opportunity WHERE HSFE_Specialty__c != null and HSFE_Sub_Specialty__c!= null]);// return  opportunity.
    }
    /*********************************************************************************************************
    Method Name:Execute
    Parameter:Database.BatchableContext, Sobject
    Return Type:None
    Description: Assign the territory,owner and opportunity team member based on a Specialty and Sub Specialty 
    **********************************************************************************************************/
    public void execute(Database.BatchableContext BC,List<sObject> scope){
        try{
            HSFE_Utility_Class.stopUpdateOpptyTerritory = true; //Stop trigger logic for TM.
            Map<String, Id> combKeytoTerrMap = new Map<String, Id>();
            Set<Id> terrIdSet = new Set<Id>();
            Boolean creatorPresent;
            Id userId;
            Set<ID> opptyID = new Set<ID>();
            Set<String> postalCodeSet = new Set<String>();
            List<OpportunityTeamMember> teamToCreateList = new List<OpportunityTeamMember>();
            List<Opportunity> updateOpp = new List<Opportunity>();
            Set<String> combinationKeySet = new Set<String>();
            Map<String,String> tempZipMap = new Map<String,String>();
            OpportunityTeamMember tempTeam;
            List<Opportunity> opptyList = new List<Opportunity>();
             for(Sobject s : scope){
                  Opportunity op = (Opportunity)s;
                  if(op.HSFE_Account_Postal_Code__c != null){
                    postalCodeSet.add(op.HSFE_Account_Postal_Code__c);
                  }        
            }
            for(HSFE_Updated_Zip_Code_Temporary__c tempZip : [select name from HSFE_Updated_Zip_Code_Temporary__c where name=:postalCodeSet]){
                tempZipMap.put(tempZip.name,tempZip.name);
            }
             for(Sobject s : scope){
                Opportunity o = (Opportunity)s;
                if(tempZipMap.containsKey(o.HSFE_Account_Postal_Code__c)){
                    opptyList.add(o);                   
                } 
            } 
            for(Opportunity opp : opptyList){                
                combinationKeySet.add(opp.HSFE_Combination_Key__c);
            }
            List<HSFE_Account_Territory__c> accTerrList = new List<HSFE_Account_Territory__c>([SELECT Id, Account__c, Territory__c, HSFE_Combination_Key__c FROM HSFE_Account_Territory__c WHERE HSFE_Combination_Key__c IN :combinationKeySet]);
            for(HSFE_Account_Territory__c accTerr: accTerrList){
                combKeytoTerrMap.put(accTerr.HSFE_Combination_Key__c, accTerr.Territory__c);
                terrIdSet.add(accTerr.Territory__c);
            }
            System.debug('*********************combKeytoTerrMap' + combKeytoTerrMap);
            Map<String,HSFE_Territory_To_User__c> tempMap;
            Map<String,List<HSFE_Territory_To_User__c>> territroyUserMap  = new Map<String,List<HSFE_Territory_To_User__c>>();
            List<HSFE_Territory_To_User__c> territoryUserList; 
            Map<Id, Map<String,HSFE_Territory_To_User__c >> territoryToRoleToUserMapMap = new Map<Id, Map<String,HSFE_Territory_To_User__c >>();
            List<HSFE_Territory_To_User__c> terrToUserList= new List<HSFE_Territory_To_User__c>([Select Id, HSFE_User_Role__c,HSFE_Territory__c, HSFE_User__c,HSFE_User_Active__c from HSFE_Territory_To_User__c where HSFE_Territory__c IN :terrIdSet and HSFE_User_Active__c = true]);
            for(HSFE_Territory_To_User__c terrUser: terrToUserList){               
                    if(territoryToRoleToUserMapMap.containsKey(terrUser.HSFE_Territory__c)){                  	
                    	                   
                        territoryUserList = territroyUserMap.get(terrUser.HSFE_Territory__c);
                        territoryUserList.add(terrUser);
                        if(terrUser.HSFE_User_Role__c != null){
	                        tempMap = territoryToRoleToUserMapMap.get(terrUser.HSFE_Territory__c);                        
	                        tempMap.put(terrUser.HSFE_User_Role__c,terrUser);
                        }
                        territroyUserMap.put(terrUser.HSFE_Territory__c,territoryUserList);
                    }else{
                        tempMap = new Map<String,HSFE_Territory_To_User__c>();
                        territoryUserList = new List<HSFE_Territory_To_User__c>();
                        if(terrUser.HSFE_User_Role__c != null){	                                              
	                        tempMap.put(terrUser.HSFE_User_Role__c,terrUser);
                        }
                        territoryUserList.add(terrUser);
                        territroyUserMap.put(terrUser.HSFE_Territory__c,territoryUserList);
                    }
                    territoryToRoleToUserMapMap.put(terrUser.HSFE_Territory__c,tempMap);                
            }
            List<User> userList = new List<User>();
            List<UserRole> roleList = new List<UserRole>();
            Id gVPSurgical;
            Id gVPMedical;        
            Set<String> specialtySet = new Set<String>();
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
            for(Opportunity opp : opptyList){                
                creatorPresent = false;
                userId = opp.CreatedById;
                opptyID.add(opp.id);               
                opp.HSFE_Territory__c = null;                
                if(userList.size()>0){
                   opp.HSFE_Approval_GVP_User__c = opp.HSFE_Specialty__c == HSFE_Constant.MEDICAL?gVPMedical:gVPSurgical;
                }               
                opp.HSFE_Approval_DVP_User__c = null;
                opp.HSFE_Approval_AVP_User__c = null;
                opp.HSFE_Approval_RSD_RVP_User__c = null;
                
                if(combKeytoTerrMap.containsKey(opp.HSFE_Combination_Key__c)){
                    Id terrId = combKeytoTerrMap.get(opp.HSFE_Combination_Key__c);
                    opp.HSFE_Territory__c = terrId;
                    if(territoryToRoleToUserMapMap.containsKey(terrId)){
                        tempMap = territoryToRoleToUserMapMap.get(terrId);                       
                        if(tempMap.containsKey(HSFE_Constant.TM)){
                            opp.OwnerId = tempMap.get(HSFE_Constant.TM).HSFE_User__c;
                        }
                        if(territroyUserMap.containsKey(terrId)) {
                                territoryUserList = territroyUserMap.get(terrId);
                        }
                        if(tempMap.containsKey(HSFE_Constant.DVP)){
							opp.HSFE_Approval_DVP_User__c = tempMap.get(HSFE_Constant.DVP).HSFE_User__c;
						}
						else if(!tempMap.containsKey(HSFE_Constant.DVP)){
							opp.HSFE_Approval_DVP_User__c = opp.HSFE_Approval_GVP_User__c;
						}
						if(tempMap.containsKey(HSFE_Constant.AVP)){
							opp.HSFE_Approval_AVP_User__c = tempMap.get(HSFE_Constant.AVP).HSFE_User__c;
						}
						else if(!tempMap.containsKey(HSFE_Constant.AVP)){
							opp.HSFE_Approval_AVP_User__c = opp.HSFE_Approval_DVP_User__c;
						}                        
						if(tempMap.containsKey(HSFE_Constant.RVP)){
							opp.HSFE_Approval_RSD_RVP_User__c =tempMap.get(HSFE_Constant.RVP).HSFE_User__c;
						}
						else if(!tempMap.containsKey(HSFE_Constant.RVP)){
							opp.HSFE_Approval_RSD_RVP_User__c = opp.HSFE_Approval_AVP_User__c;
						}
                    }
                    for(HSFE_Territory_To_User__c role : territoryUserList){
                            if(userId == role.HSFE_User__c){
                                creatorPresent = true;
                            }
                            tempTeam = new OpportunityTeamMember(OpportunityId = opp.Id, UserId = role.HSFE_User__c, TeamMemberRole = role.HSFE_User_Role__c);
                            teamToCreateList.add(tempTeam); 
                    }
                    if(!creatorPresent){
                        tempTeam = new OpportunityTeamMember(OpportunityId = opp.id, UserId = userId, TeamMemberRole = 'Creator');
                        teamToCreateList.add(tempTeam);
                    }
                    //For adding a secondary owner - 6/4/2015
                    if(opp.HSFE_Secondary_Owner__c != null){
                        tempTeam = new OpportunityTeamMember(OpportunityId = opp.Id, UserId = opp.HSFE_Secondary_Owner__c, TeamMemberRole = 'Secondary Owner');
                        teamToCreateList.add(tempTeam);
                    }
                }
                updateOpp.add(opp);
                
            }
            List<Database.Saveresult> updateOptyResult = Database.update(updateOpp,false);
            List<OpportunityTeamMember> teamToDeleteList = new List<OpportunityTeamMember>([SELECT Id from OpportunityTeamMember WHERE OpportunityId IN :opptyID AND OpportunityAccessLevel != 'All']);
            List<Database.DeleteResult> deleteResult = Database.delete(teamToDeleteList, false); // Delete Opportunity Team members
            List<Database.Saveresult> insertResult = Database.insert(teamToCreateList, false); //Insert Opoortunity Team members
            List<OpportunityShare > updateOpptyShareList = new List<OpportunityShare>();
            List<OpportunityShare > shares = [select Id, OpportunityAccessLevel, OpportunityId from OpportunityShare where OpportunityId IN :opptyID 
                                             and OpportunityAccessLevel != 'All' and OpportunityAccessLevel !='Edit' and RowCause= 'Team'];
            if(shares.size()>0){
                for(OpportunityShare oppShare:shares ){
                    oppShare.OpportunityAccessLevel='Edit';
                    updateOpptyShareList.add(oppShare);
                }
            }
            if(updateOpptyShareList.size()>0){
                List<Database.Saveresult> updateResult = Database.update(updateOpptyShareList, false); //Update opportunity share table.
            }
        }catch(Exception e){
          HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception. 
        }
        
    }
    /*********************************************************************************************************
    Method Name:finish
    Parameter:Database.BatchableContext
    Return Type:None
    Description: Exceute clear zip temp data batch class.
    **********************************************************************************************************/
    public void finish(Database.BatchableContext ctx){
        HSFE_ClearZipTempData_BatchClass clearZipObj = new HSFE_ClearZipTempData_BatchClass(); //This is used to delete records from temporary object.
        database.executebatch(clearZipObj,200);//Excute a batch class.
    }
}