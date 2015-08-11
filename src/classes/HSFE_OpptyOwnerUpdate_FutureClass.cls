/* Class Name :HSFE_OpptyOwnerUpdate_FutureClass 
*Description :This is a future method used to update the opportunity owner
*Created By :Sunil Kumar
*Created On :04/20/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public class HSFE_OpptyOwnerUpdate_FutureClass {
    @future
    /************************************************************************************************
    Method Name: updateOpportunityOwner
    Return Type : None
    Parameter: Set
    Description: Update opportunity owner and crate opportunity team member.
    ************************************************************************************************/
    public static void updateOpportunityOwner(Set<Id> opportunityId){
        try{
            HSFE_Utility_Class.stopFutureExceution = true;
            Map<String, Id> combKeytoTerrMap = new Map<String, Id>();
            Set<Id> terrIdSet = new Set<Id>(); 
            Set<String> accountQuerySet = new Set<String>();      
            List<OpportunityTeamMember> teamToCreateList = new List<OpportunityTeamMember>();
            List<Opportunity> opptyToUpdateList = new List<Opportunity>();
            List<Opportunity> opptyToUpdate = new List<Opportunity>();
            Id userId;
            Boolean creatorPresent;
            opptyToUpdateList = [select id,ownerid,accountid,HSFE_Combination_Key__c,HSFE_Territory__c,CreatedById,
                                HSFE_Approval_DVP_User__c,HSFE_Approval_GVP_User__c,HSFE_Specialty__c,HSFE_Approval_AVP_User__c,HSFE_Approval_RSD_RVP_User__c from Opportunity where id=:opportunityId];
            for(Opportunity opp : opptyToUpdateList){
                accountQuerySet.add(opp.HSFE_Combination_Key__c);
            }
            OpportunityTeamMember tempTeam;
            if(opptyToUpdateList.size() > 0){
                List<HSFE_Account_Territory__c> accTerrList = new List<HSFE_Account_Territory__c>([SELECT Id, Account__c, Territory__c, HSFE_Combination_Key__c FROM HSFE_Account_Territory__c WHERE HSFE_Combination_Key__c IN :accountQuerySet]);
                for(HSFE_Account_Territory__c accTerr: accTerrList){
                    combKeytoTerrMap.put(accTerr.HSFE_Combination_Key__c, accTerr.Territory__c);
                    terrIdSet.add(accTerr.Territory__c);
                }
                Map<String,HSFE_Territory_To_User__c> tempMap;
                Map<String,List<HSFE_Territory_To_User__c>> territroyUserMap  = new Map<String,List<HSFE_Territory_To_User__c>>();
                List<HSFE_Territory_To_User__c> territoryUserList;
                List<User> userList = new List<User>();
                List<UserRole> roleList = new List<UserRole>();
                Id gVPSurgical;
                Id gVPMedical;        
                Set<String> specialtySet = new Set<String>(); 
                Map<Id, Map<String,HSFE_Territory_To_User__c >> territoryToRoleToUserMapMap = new Map<Id, Map<String,HSFE_Territory_To_User__c >>();
                List<HSFE_Territory_To_User__c> terrToUserList= new List<HSFE_Territory_To_User__c>([Select Id, HSFE_User_Role__c,HSFE_User_Active__c,HSFE_Territory__c, HSFE_User__c from HSFE_Territory_To_User__c where HSFE_Territory__c IN :terrIdSet  and HSFE_User_Active__c = true]);
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
                for(HSFE_Territory_To_User__c terrUser: terrToUserList){                    
                    if(territoryToRoleToUserMapMap.containsKey(terrUser.HSFE_Territory__c)){                        
                        territoryUserList = territroyUserMap.get(terrUser.HSFE_Territory__c);
                        if(terrUser.HSFE_User_Role__c != null){
                            tempMap.put(terrUser.HSFE_User_Role__c,terrUser);
                            tempMap = territoryToRoleToUserMapMap.get(terrUser.HSFE_Territory__c);
                        }
                        territoryUserList.add(terrUser);
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
                
                for(Opportunity tempOppty : opptyToUpdateList){
                    creatorPresent = false;
                    userId = tempOppty.CreatedById;
                    if(userList.size()>0){
                        tempOppty.HSFE_Approval_GVP_User__c = tempOppty.HSFE_Specialty__c == HSFE_Constant.MEDICAL?gVPMedical:gVPSurgical;
                    }               
                    tempOppty.HSFE_Approval_DVP_User__c = null;
                    tempOppty.HSFE_Approval_AVP_User__c = null;
                    tempOppty.HSFE_Approval_RSD_RVP_User__c = null;                   
                    if(combKeytoTerrMap.containsKey(tempOppty.HSFE_Combination_Key__c)){
                        Id terrId = combKeytoTerrMap.get(tempOppty.HSFE_Combination_Key__c);
                        if(territoryToRoleToUserMapMap.containsKey(terrId)){
                            tempMap = territoryToRoleToUserMapMap.get(terrId);
                            System.debug('*********************tempMap' + tempMap);
                            if(territroyUserMap.containsKey(terrId)) {
                                territoryUserList = territroyUserMap.get(terrId);
                            }
                            if(tempMap.containsKey(HSFE_Constant.TM)){
                                tempOppty.OwnerId = tempMap.get(HSFE_Constant.TM).HSFE_User__c;
                                tempOppty.HSFE_Admin_Update__c = true;
                                opptyToUpdate.add(tempOppty);
                                
                            }
                            if(tempMap.containsKey(HSFE_Constant.DVP)){
                                tempOppty.HSFE_Approval_DVP_User__c = tempMap.get(HSFE_Constant.DVP).HSFE_User__c;
                            }
                            else if(!tempMap.containsKey(HSFE_Constant.DVP)){
                                tempOppty.HSFE_Approval_DVP_User__c = tempOppty.HSFE_Approval_GVP_User__c;
                            }
                            if(tempMap.containsKey(HSFE_Constant.AVP)){
                                tempOppty.HSFE_Approval_AVP_User__c = tempMap.get(HSFE_Constant.AVP).HSFE_User__c;
                            }
                            else if(!tempMap.containsKey(HSFE_Constant.AVP)){
                                tempOppty.HSFE_Approval_AVP_User__c = tempOppty.HSFE_Approval_DVP_User__c;
                            }                        
                            if(tempMap.containsKey(HSFE_Constant.RVP)){
                                tempOppty.HSFE_Approval_RSD_RVP_User__c =tempMap.get(HSFE_Constant.RVP).HSFE_User__c;
                            }
                            else if(!tempMap.containsKey(HSFE_Constant.RVP)){
                                tempOppty.HSFE_Approval_RSD_RVP_User__c = tempOppty.HSFE_Approval_AVP_User__c;
                            }
                        }
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
                       
                    }
                }
                if(opptyToUpdate.size()>0){
                    Update opptyToUpdate;                     
                }
                if(teamToCreateList.size() > 0){
                insert teamToCreateList;
                List<OpportunityShare > updateOpptyShareList = new List<OpportunityShare>();
                List<OpportunityShare > shares = new List<OpportunityShare >(); 
                shares  = [select Id, OpportunityAccessLevel, OpportunityId from OpportunityShare where OpportunityId IN :opptyToUpdateList 
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
        }catch(Exception e){
            system.debug('Exception********************************************* '+e);
            HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.  
        }
       
    }

}