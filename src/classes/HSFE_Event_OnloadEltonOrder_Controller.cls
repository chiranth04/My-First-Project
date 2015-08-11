/*Class Name : HSFE_EventSetupMeeting_Admin_Overr_Class  
*Description : This class is used to redirect equipement order page on creation of OPE activity.
*Created By :  Chiranth Aradhya
*Created On : 5/21/2015 
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date           Modification Id        Description
Deloitte/Chiranth Aradhya   5/21/2015                             On creation of the OPE activity redirect to Equipment Order page
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class HSFE_Event_OnloadEltonOrder_Controller {
    
    //Variable declaration
    private ApexPages.StandardController controller = null;
    public String whatId='';
    public String relatedToObject='';
    public List<Event> lstevet;
    public List<Opportunity> lstOpp;
    public Event eve;
    public String currentUserId='';
    public String Obj;
    public HSFE_Event_OnloadEltonOrder_Controller (ApexPages.StandardController controller){
        this.controller = controller;
        lstevet= new List<Event>();
        lstOpp = new List<opportunity>();
        eve= new Event();
        currentUserId=UserInfo.getUserId();
        //Get the Current Record Id
        whatId=ApexPages.CurrentPage().getparameters().get('What_Id');
        relatedToObject=ApexPages.CurrentPage().getparameters().get('relatedToObj');
        
        if(whatId != null ){
            Obj =whatId.substring(0, 3);
        }
        
    }
    //Called on load of vf page
    public PageReference onLoad(){
       
        String prefix = ELTON__Equipment_Order__c.SObjectType.getDescribe().getKeyPrefix();
        String prefix_Account = Account.SObjectType.getDescribe().getKeyPrefix();
        String prefix_Lead = Lead.SObjectType.getDescribe().getKeyPrefix();
        String prefix_Opportunity = Opportunity.SObjectType.getDescribe().getKeyPrefix();
        if(Obj == prefix_Opportunity ){
            //query the event  based on related to Id
            lstevet= [Select Id,WhatId,StartDateTime,WhoId,Who.Name, Meeting_Type__c,createdbyId  from Event where WhatId =: whatId AND createdbyId =:currentUserId ORDER BY CreatedDate DESC LIMIT 1];
            lstOpp= [Select Id,Name, Opportunity.Account.Name from Opportunity where Id=: whatId ];
        }else if(Obj == prefix_Lead ){
            //query the event based on related to Id
            lstevet= [Select Id,WhatId,Meeting_Type__c,StartDateTime,createdbyId,WhoId,Who.Name  from Event where WhoId =: whatId AND createdbyId =:currentUserId ORDER BY CreatedDate DESC LIMIT 1];
        }else if(Obj == prefix_Account ){
            //query the event based on related to Id
            lstevet= [Select Id,WhatId,Meeting_Type__c,createdbyId,StartDateTime,WhoId,Who.Name from Event where WhatId =: whatId AND createdbyId =:currentUserId ORDER BY CreatedDate DESC LIMIT 1];
        }
        
        if(lstevet.size()>0 && lstevet!= NULL) {
            eve=lstevet[0];
            //Date dte=eve.StartDateTime.format();
            String formattedDt = eve.StartDateTime.date().format();
            if(eve.Meeting_Type__c == HSFE_Constant.ON_PATIENT_EVALUATION){
                PageReference redirect= new PageReference('/'+prefix+'/e?nooverride=1&');
                redirect.getParameters().put(System.Label.HSFE_Eq_Commit_Start_Date,formattedDt );
                redirect.getParameters().put(System.Label.HSFE_ELTON_ActivityId,eve.Id);
                redirect.getParameters().put(System.Label.HSFE_Eq_Order_Type,HSFE_Constant.Order_Type_Evaluation);
                redirect.getParameters().put('retURL',eve.Id);
                if(lstOpp.size()>0 && lstOpp!= NULL){
                    redirect.getParameters().put(System.Label.HSFE_Eq_Order_Opp_Name,lstOpp[0].Name);
                    redirect.getParameters().put(System.Label.HSFE_Eq_Order_Opp_Id,lstOpp[0].Id);
                }
                redirect.setRedirect(true); 
                return redirect;
            }
            else{
                 PageReference redirect= new PageReference('/'+whatId);
                 return redirect;
            }
        }
        return null;
    }
}