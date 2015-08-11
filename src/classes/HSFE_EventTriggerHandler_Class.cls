/* Class Name : HSFE_EventTriggerHandler_Class
*Description :  Trigger Handler class for the Event SObject, which implements all the logic of event trigger.
*Created By :   Chiranth Aradhya
*Created On :   05/11/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                    Date                      Modification Id                       Description
Deloitte/Chiranth           05/11/2015                    Created                             Added before insert method to Capture in a field the duration between when the related Opportunity was closed and when the InService activity is being created 
Deloitte/Divya              05/14/2015                    Modified                            Added logic to add 'day(s)' to the days since Opportunity was closed                             
Deloitte/Chiranth           05/19/2015                    Modified                            Added logic to updated the subject with Meeting type (ex: subject = SoldToAccount_MeetingType).      
Deloitte/Kumar Gaurav       05/24/2015                    Modified                            Added logic to lotus notes calendar
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/

public with sharing class HSFE_EventTriggerHandler_Class{
    public static void handleBeforeInsert(List<Event> eventList) {
        try{
            Set<Id>relatedToIds = new Set<Id>();
            Set<Id>relatedToNameIds = new Set<Id>();
            Map<Id,Opportunity>OppSalesStageMap = new Map<Id,Opportunity>();
            Map<Id,Contact>contactMap = new Map<Id,Contact>();
            Map<Id,Lead>leadMap = new Map<Id,Lead>();
            List<recordType> recordTypeList = new List<RecordType>();
            Map<Id,Account>accMap = new Map<Id,Account>();
            string timeSinceOpptyClosed;
            
            //get the record type id of event
            recordTypeList =[SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType WHERE SobjectType = 'Event' AND DeveloperName = 'HSFE_Event_Elton_Order' Limit 1];
            
            for(Event eve:eventList){
               relatedToIds.add(eve.WhatId);
               relatedToNameIds.add(eve.WhoId);
               //All Activitie are of "Type" = "Meeting"
               eve.Type=HSFE_Constant.EVENT_MEETING;
              
            }
            //If event is created from Account
            if(relatedToIds.size()>0){
                for(Account ac:[Select Id,Name from Account where Id IN:relatedToIds]){
                    accMap.put(ac.Id,ac);
                }
            }
            //If event is created from Contact
            if(relatedToNameIds.size()>0){
                for(Contact con:[select Id,Name from Contact where Id IN:relatedToNameIds]){
                    contactMap.put(con.Id,con);
                }
            }
            //If event is created from Lead
            if(relatedToNameIds.size()>0){
                for(Lead leadrec:[select Id,Name,Company from Lead where Id IN:relatedToNameIds]){
                    leadMap.put(leadrec.Id,leadrec);
                }
            }
            //If event is created from Opportunity
            if(relatedToIds.size() > 0){
                for(Opportunity opp:[Select Id, Name,HSFE_Sales_Stage__c,Account.Name,HSFE_Opportunity_Won_Date__c,HSFE_Specialty__c,HSFE_Sub_Specialty__c,HSFE_Area_of_Interest__c from Opportunity where Id IN:relatedToIds]){
                   OppSalesStageMap.put(opp.Id,opp);
                }
            }
            for(Event eve:eventList){
                String subject_Meeting_Type ='';
                if(leadMap.ContainsKey(eve.WhoId)){
                    if(leadMap.get(eve.WhoId).Company != null){
                        subject_Meeting_Type = subject_Meeting_Type+leadMap.get(eve.WhoId).Company + '_';
                    }
                    if(leadMap.get(eve.WhoId).Name != null){
                        subject_Meeting_Type = subject_Meeting_Type+leadMap.get(eve.WhoId).Name + '_';
                    }
                }
                if(accMap.ContainsKey(eve.WhatId)){
                    if(accMap.get(eve.WhatId).Name != null){
                        subject_Meeting_Type = subject_Meeting_Type+accMap.get(eve.WhatId).Name + '_';
                    }
                    if(contactMap.ContainsKey(eve.WhoId)){
                        if(contactMap.get(eve.WhoId).Name != null){
                            subject_Meeting_Type = subject_Meeting_Type+contactMap.get(eve.WhoId).Name + '_';
                        }
                    }
                }
                if(OppSalesStageMap.ContainsKey(eve.WhatId)){
                    if(OppSalesStageMap.get(eve.WhatId).Name != null){
                        subject_Meeting_Type = subject_Meeting_Type+OppSalesStageMap.get(eve.WhatId).Name + '_';
                    }
                    if(contactMap.ContainsKey(eve.WhoId)){
                        if(contactMap.get(eve.WhoId).Name != null){
                            subject_Meeting_Type = subject_Meeting_Type+contactMap.get(eve.WhoId).Name + '_';
                        }
                    }
                    //Calculate time since opportunity closed and In Service event created
                    if(OppSalesStageMap.get(eve.WhatId).HSFE_Opportunity_Won_Date__c != null && eve.Meeting_Type__c == HSFE_Constant.INSERVICE){
                        // DAN_14-05-2015: Added Logic to add 'day(s)' to the HSFE_Time_since_Opportunity_Closed__c field
                        timeSinceOpptyClosed= String.ValueOf(OppSalesStageMap.get(eve.WhatId).HSFE_Opportunity_Won_Date__c.daysBetween(System.Today()));
                        eve.HSFE_Time_since_Opportunity_Closed__c = (timeSinceOpptyClosed== '1' ? timeSinceOpptyClosed+' day': timeSinceOpptyClosed +' days'); 
                            
                    }
                    //Update the record type of the event to elto order if event is created from opportunity and meeting type is OPE/Demo
                    if(eve.Meeting_Type__c == HSFE_Constant.ON_PATIENT_EVALUATION || eve.Meeting_Type__c == HSFE_Constant.DEMONSTRATION){
                        if(recordTypeList.size()>0){
                            eve.RecordTypeId = recordTypeList[0].id;
                        }
                        
                    }
                }
                if(eve.Meeting_Type__c == HSFE_Constant.ON_PATIENT_EVALUATION){
                    eve.Subject = subject_Meeting_Type+HSFE_Constant.ON_PATIENT_EVALUATION;
                }else if(eve.Meeting_Type__c == HSFE_Constant.DEMONSTRATION){
                    eve.Subject = subject_Meeting_Type+HSFE_Constant.DEMONSTRATION;
                }else if (eve.Meeting_Type__c == HSFE_Constant.INSERVICE){
                    eve.Subject = subject_Meeting_Type+HSFE_Constant.INSERVICE;
                }else if (eve.Meeting_Type__c == HSFE_Constant.ADMIN){
                    eve.Subject = subject_Meeting_Type+HSFE_Constant.ADMIN;
                }
                
                //If specialty is null, then get the specialty from related Opportunity
                if(eve.HSFE_Specialty__c == null  && OppSalesStageMap.containsKey(eve.WhatId)){
                    eve.HSFE_Specialty__c=(OppSalesStageMap.get(eve.WhatId)).HSFE_Specialty__c;
                }
                //If Sub specialty is null, then get the Sub specialty from related Opportunity
                if(eve.HSFE_Sub_Specialty__c == null  && OppSalesStageMap.containsKey(eve.WhatId)){
                    eve.HSFE_Sub_Specialty__c=(OppSalesStageMap.get(eve.WhatId)).HSFE_Sub_Specialty__c;
                }
            }
        }
        catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
      
    /*
     * Method name  : handleBeforeUpdate
     * Description  : This method is called on event update, if related name is changed, subject will be updated with the new related name.
     * Return Type  : None
     * Parameter    : None
    */ 
    public static void handleBeforeUpdate(List<Event> eventList,Map<Id,Event> oldeventMAp) {
        try{
            
            Set<Id>relatedToIds = new Set<Id>();
            Set<Id>relatedToNameIds = new Set<Id>();
            Map<Id,Event>eventOldMap = new Map<Id,Event>();
            Map<Id,Contact>contactMap = new Map<Id,Contact>();
            List<Contact>conlist = new List<Contact>();
            Map<Id,Lead>leadMap=new Map<Id,Lead>();
            List<Lead>leadlist = new List<Lead>();
            List<Account> acList = new List<Account>(); 
            Map<Id,Account>accMap = new Map<Id,Account>();
            Map<Id,Opportunity>OppSalesStageMap =new Map<Id,Opportunity>();
            string timeSinceOpptyClosed;
            for(Event eve:eventList){
                Event oldEven = oldeventMAp.get(eve.Id);
                if(eve.WhoId != oldEven.WhoId){
                    relatedToIds.add(eve.WhatId);
                    relatedToNameIds.add(eve.WhoId);
                }
            }
            //Query Account if related to Account record
            if(relatedToIds.size()>0){
                for(Account ac:[Select Id,Name from Account where Id IN:relatedToIds]){
                    accMap.put(ac.Id,ac);
                }
            }
            
            //Query Contact if name is contact record
            if(relatedToNameIds.size()>0){
                for(Contact con:[select Id,Name from Contact where Id IN:relatedToNameIds]){
                    contactMap.put(con.Id,con);
                }
            }
            
            //Query lead if name has lead record
            if(relatedToNameIds.size()>0){
                for(Lead leadrec:[select Id,Name,Company from Lead where Id IN:relatedToNameIds]){
                    leadMap.put(leadrec.Id,leadrec);
                }
            }
            
            //If event is created from Opportunity
            if(relatedToIds.size() > 0){
                for(Opportunity opp:[Select Id, Name,HSFE_Sales_Stage__c,Account.Name,HSFE_Opportunity_Won_Date__c,HSFE_Specialty__c,HSFE_Sub_Specialty__c,HSFE_Area_of_Interest__c from Opportunity where Id IN:relatedToIds]){
                   OppSalesStageMap.put(opp.Id,opp);
              }
            }
            for(Event eve:eventList){
                Event oldEven = oldeventMAp.get(eve.Id);
                if(eve.WhoId != oldEven.WhoId){
                    String subject_Meeting_Type ='';
                    if(leadMap.ContainsKey(eve.WhoId)){
                        if(leadMap.get(eve.WhoId).Company != null){
                            subject_Meeting_Type = subject_Meeting_Type+leadMap.get(eve.WhoId).Company + '_';
                        }
                        if(leadMap.get(eve.WhoId).Name != null){
                            subject_Meeting_Type = subject_Meeting_Type+leadMap.get(eve.WhoId).Name + '_';
                        }
                    }
                    if(accMap.ContainsKey(eve.WhatId)){
                        if(accMap.get(eve.WhatId).Name != null){
                            subject_Meeting_Type = subject_Meeting_Type+accMap.get(eve.WhatId).Name + '_';
                        }
                        if(contactMap.ContainsKey(eve.WhoId)){
                            if(contactMap.get(eve.WhoId).Name != null){
                                subject_Meeting_Type = subject_Meeting_Type+contactMap.get(eve.WhoId).Name + '_';
                            }
                        }
                    }
                    if(OppSalesStageMap.ContainsKey(eve.WhatId)){
                        if(OppSalesStageMap.get(eve.WhatId).Name != null){
                            subject_Meeting_Type = subject_Meeting_Type+OppSalesStageMap.get(eve.WhatId).Name + '_';
                        }
                        if(contactMap.ContainsKey(eve.WhoId)){
                            if(contactMap.get(eve.WhoId).Name != null){
                                subject_Meeting_Type = subject_Meeting_Type+contactMap.get(eve.WhoId).Name + '_';
                            }
                        }
                        //Calculate time since opportunity closed and In Service event created
                        if(OppSalesStageMap.get(eve.WhatId).HSFE_Opportunity_Won_Date__c != null && eve.Meeting_Type__c == HSFE_Constant.INSERVICE){
                            // DAN_14-05-2015: Added Logic to add 'day(s)' to the HSFE_Time_since_Opportunity_Closed__c field
                            timeSinceOpptyClosed= String.ValueOf(OppSalesStageMap.get(eve.WhatId).HSFE_Opportunity_Won_Date__c.daysBetween(System.Today()));
                            eve.HSFE_Time_since_Opportunity_Closed__c = (timeSinceOpptyClosed== '1' ? timeSinceOpptyClosed+' day': timeSinceOpptyClosed +' days'); 
                                
                        }
                        
                    }
                    if(eve.Meeting_Type__c == HSFE_Constant.ON_PATIENT_EVALUATION){
                        eve.Subject = subject_Meeting_Type+HSFE_Constant.ON_PATIENT_EVALUATION;
                    }else if(eve.Meeting_Type__c == HSFE_Constant.DEMONSTRATION){
                        eve.Subject = subject_Meeting_Type+HSFE_Constant.DEMONSTRATION;
                    }else if (eve.Meeting_Type__c == HSFE_Constant.INSERVICE){
                        eve.Subject = subject_Meeting_Type+HSFE_Constant.INSERVICE;
                    }else if (eve.Meeting_Type__c == HSFE_Constant.ADMIN){
                        eve.Subject = subject_Meeting_Type+HSFE_Constant.ADMIN;
                    }
                    
                    //If specialty is null, then get the specialty from related Opportunity
                    if(eve.HSFE_Specialty__c == null  && OppSalesStageMap.containsKey(eve.WhatId)){
                        eve.HSFE_Specialty__c=(OppSalesStageMap.get(eve.WhatId)).HSFE_Specialty__c;
                    }
                    //If Sub specialty is null, then get the Sub specialty from related Opportunity
                    if(eve.HSFE_Sub_Specialty__c == null  && OppSalesStageMap.containsKey(eve.WhatId)){
                        eve.HSFE_Sub_Specialty__c=(OppSalesStageMap.get(eve.WhatId)).HSFE_Sub_Specialty__c;
                    }
                }
            }
        }
        catch(Exception e){ HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }
    }
     /*
     * Method name  : handleLotusNotesUpdate
     * Description  : This method is called when the salesrep creates an event in salesforce
     * Return Type  : None
     * Parameter    : None
     */ 
     public static void handleLotusNotesUpdate(List<Event> evdList){
        Set<Id> evdIds = new Set<Id>();
        Map<Id,String> oppIdAccNameMap = new Map<Id, String>();
        String mType = null;
        // Skip method for Integration profile AND validate if trigger needs to be executed
        if (HSFE_ProfileWithNoExecution__c.getValues(UserInfo.getProfileId()) != null) {
            return;
        } 
        for(Event evd : evdList){
            if(evd.WhatId != null && evd.Type == HSFE_Constant.MEETING  && evd.WhatId.getSObjectType().getDescribe().getName() == Opportunity.sObjectType.getDescribe().getLabel()){
                system.debug('WhatId -- > '+evd.WhatId + ' Type -> '+ evd.WhatId.getSObjectType().getDescribe().getName());
                if(evd.Id != null){
                    evdIds.add(evd.Id);
                }
                if(Trigger.isbefore){
                    evd.Modified_By_Mule__c = false;
                }
                if(String.isEmpty(evd.Lotus_Note_Id__c)){
                     oppIdAccNameMap.put(evd.WhatId,null);
                }
            }
        }
        //read all what Ids and change the subject if trigger is IsBefore and IsUpdate
        If(!oppIdAccNameMap.isEmpty() && Trigger.isbefore && Trigger.isInsert){
            for(Opportunity opp : [Select Id, Account.name from Opportunity where Id IN: oppIdAccNameMap.keyset()]){
                oppIdAccNameMap.put(opp.Id, opp.account.name);
            }
            for(Event evd : evdList){
                if(oppIdAccNameMap.containsKey(evd.WhatId)){
                    mType = evd.Meeting_Type__c == null ? '' : evd.Meeting_Type__c;
                    //Chiranth : Commented this line because now subject will be WhatID+Name_MeetingType, we have implemented this in before insert trigger
                    //evd.Subject = oppIdAccNameMap.get(evd.WhatId)+ '_'+ mType;
                }
            }
        }
        system.debug('evdIds -- > '+evdIds);
        if(!System.isFuture() && !evdIds.isEmpty()){
            // create the callout request
            List<Id> ls = new List<Id>(evdIds);
            system.debug('Service called evdIds -- > '+evdIds + ' --- ' +evdIds.size());
            HSFE_SendEventToLotusNotes.createOrUpdateCalendarInNotes(ls);
        }
     }
      
}