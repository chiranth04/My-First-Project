/**
 Version             : 1.0 
 Created Date        : 05 May 2015
 Function            : This class will invoke the service to mule
 Modification Log    :
 * Developer                      Date                                    Description
 * ----------------------------------------------------------------------------                 
 * Kumar Gaurav                05/11/2014                              Original Version
 *************************************************************************************
 */
@isTest
private class HSFE_EventTriggerHandler_Test {
    
    static  testmethod void testmethod1() {

        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
   
        System.runAs(usr){  
            
            //Insert Territory
            HSEF_Territory__c terr = HSFE_TestUtility_Class.createTerritory();
            insert terr;
            
            //Insert Zip to Territory
            HSFE_Zip_To_Territory__c zipTerr =  HSFE_TestUtility_Class.createHSFEZipterr(terr);
            insert zipTerr;
            
            //Insert territory to User
            HSFE_Territory_To_User__c terrToUser = HSFE_TestUtility_Class.createTerritoryUser(usr,terr);
            insert terrToUser;
            
            //Insert the account record       
            Account acc = HSFE_TestUtility_Class.createAccountRecord();
            insert acc;
            
            //Insert the lead record 
            Lead l = HSFE_TestUtility_Class.createLeadRecord(acc);
            insert l;
        
            //Insert the lead record 
            Lead l2 = HSFE_TestUtility_Class.createLeadRecord2(acc);
            insert l2;
        
        
            //Insert Opportunity record
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            oppList.add(opp);
            
            Opportunity opp1 = HSFE_TestUtility_Class.createOpportunityRecord(acc);
            oppList.add(opp1);
            insert oppList;
            
            
            //Insert  contact record 
            List<Contact> conList = new List<Contact>();
            Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
            con.HSFE_Primary__c = True;
            conList.add(con);
              
            Contact con2 = HSFE_TestUtility_Class.createContactRecord2(acc);
            con.HSFE_Primary__c = True;
            conList.add(con2);
            insert conList;
            
            List<Event> insertEventList = new List<Event>();  
            List<Event> updateEventList = new List<Event>();  
            
            //Insert Event with lead with and  meeting Type Inservice
            Event evd1 = new Event(WhoId=l.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.InService, DurationInMinutes = 30, ActivityDateTime = System.today());
            insertEventList.add(evd1);
            
            //Insert event with lead and Meeting Type On Patient Evaluation
            Event evd2 = new Event(WhoId=l.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ON_PATIENT_EVALUATION, DurationInMinutes = 30, ActivityDateTime = System.today());
            insertEventList.add(evd2); 
            
            
            //Insert event with lead and Meeting Type Demonstration
            Event evd3 = new Event(WhoId=l.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.Demonstration, DurationInMinutes = 30, ActivityDateTime = System.today());
            insertEventList.add(evd3);
            
            
            //Insert event with lead and Meeting Type Administrative
            Event evd4 = new Event(WhoId=l.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ADMIN, DurationInMinutes = 30, ActivityDateTime = System.today());
            insertEventList.add(evd4);
            
            if(insertEventList.size()> 0){
                insert insertEventList;           
                
                for(Event evdrec:insertEventList){
                    evdrec.WhoId = l2.Id;
                    updateEventList.add(evdrec);
                }
            
            }
            
            if(updateEventList.size()>0){
                update updateEventList;
            }
            
            Event event1 = new Event();
            event1 =[select Id,WhoId,Meeting_Type__c from event where Id =: evd1.id];
            
            if(event1.Id != null){
                //check whether who Id is updated
                System.assertEquals(event1.WhoId,l2.Id );
                
                //check whether Meeting Type is updated
                System.assertEquals(event1.Meeting_Type__c,HSFE_Constant.InService);
            }
            
        }
    }
     static  testmethod void testmethod2() {

        //Insert Role
        UserRole r = HSFE_TestUtility_Class.createRole();
        insert r;
        
        //Insert User record
        User Usr =  HSFE_TestUtility_Class.createUser(r);
        insert Usr;
   
        System.runAs(usr){            
            
                //Insert Territory
                HSEF_Territory__c terr = HSFE_TestUtility_Class.createTerritory();
                insert terr;
                
                //Insert Zip to Territory
                HSFE_Zip_To_Territory__c zipTerr =  HSFE_TestUtility_Class.createHSFEZipterr(terr);
                insert zipTerr;
                
                //Insert territory to User
                HSFE_Territory_To_User__c terrToUser = HSFE_TestUtility_Class.createTerritoryUser(usr,terr);
                insert terrToUser;
                
                //Insert the account record       
                Account acc = HSFE_TestUtility_Class.createAccountRecord();
                insert acc;
                
                //Insert Opportunity record
                List<Opportunity> oppList = new List<Opportunity>();
                Opportunity opp = HSFE_TestUtility_Class.createOpportunityRecord(acc);
                oppList.add(opp);                               
                
                Opportunity opp1 = HSFE_TestUtility_Class.createOpportunityRecord(acc);
                oppList.add(opp1);  
                insert oppList;                
              
                //Insert  contact record 
                List<Contact> conList = new List<Contact>();
                Contact con = HSFE_TestUtility_Class.createContactRecord(acc);
                con.HSFE_Primary__c = True;
                conList.add(con);
                     
                Contact con2 = HSFE_TestUtility_Class.createContactRecord2(acc);
                con.HSFE_Primary__c = True;
                conList.add(con2);
                insert conList;
                
                
                 //Insert the Opportunity record
                Opportunity NewOpportunity=new Opportunity();
                NewOpportunity = HSFE_TestUtility_Class.createOpportunityRecord(acc);
                NewOpportunity.HSFE_Specialty__c='Medical';
                NewOpportunity.HSFE_Sub_Specialty__c='Medical IT';
                NewOpportunity.TotalOpportunityQuantity=1;
                //NewOpportunity.HSFE_Opportunity_Won_Date__c =system.Today();
                insert NewOpportunity;
                
                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal=HSFE_TestUtility_Class.CreateSingleProposal(NewOpportunity ,acc, usr,'TestProposal' );
                NewProposal.Apttus_Proposal__Primary__c=true;
                NewProposal.Apttus_Proposal__Approval_Stage__c='Draft';            
                NewProposal.HSFE_Is_FIS__c=true;
                NewProposal.HSFE_Carrier_Name__c='FedEx';
                NewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
                NewProposal.HSFE_Primary_Con__c=conList[0].id;
                insert NewProposal;
            
            
                NewProposal.HSFE_Order_Status__c =HSFE_Constant.CUSTOM_QUOTE_ORDER_STATUS_CREATED ;
                update NewProposal;
                
                //check whether NewProposal is updated  properly
                System.assertEquals(NewProposal.HSFE_Order_Status__c, HSFE_Constant.CUSTOM_QUOTE_ORDER_STATUS_CREATED);
           
                Opportunity Opprec =  new Opportunity();
                Opprec=[select Id,HSFE_Sales_Stage__c from Opportunity where Id =:NewOpportunity.Id];
                
                if(Opprec.Id != null){
                    System.assertEquals(Opprec.HSFE_Sales_Stage__c, 'Closed Won');
                }
            
                List<Event> insertEventList = new List<Event>();  
                List<Event> updateEventList = new List<Event>(); 
                
                //Insert event with Opportunity and Contact Id
                Event evd = new Event(WhatId = acc.Id, WhoId=con.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.InService, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd);
             
                //Insert event with opportunity and Meeting Type On Patient Evaluation
                Event evd2 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ON_PATIENT_EVALUATION, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd2); 
                
                
                //Insert event with opportunity and Meeting Type Demonstration
                Event evd3 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.Demonstration, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd3);
                
               
                //Insert event with opportunity and Meeting Type Administrative
                Event evd4 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ADMIN, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd4);
                
                //Insert event with Opportunity and Contact Id
                Event evd5 = new Event(WhatId = NewOpportunity.Id, WhoId=con.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.InService, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd5);                
                
                //Insert event with opportunity and Meeting Type On Patient Evaluation
                Event evd6 = new Event(WhoId=con.Id,WhatId=opp1.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ON_PATIENT_EVALUATION, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd6);                
                
                //Insert event with opportunity and Meeting Type Demonstration
                Event evd7 = new Event(WhoId=con.Id,WhatId=opp1.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.Demonstration, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd7);              
               
                                
                //Insert event with opportunity and Meeting Type Administrative
                Event evd8 = new Event(WhoId=con.Id,WhatId=opp1.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ADMIN, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd8);                
                
                //Insert event with Opportunity and Contact Id
                Event evd11 = new Event(WhatId = acc.Id, WhoId=con.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.InService, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd11);                
                
                //Insert event with opportunity and Meeting Type On Patient Evaluation
                Event evd12 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ON_PATIENT_EVALUATION, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd12);                
                
                //Insert event with opportunity and Meeting Type Demonstration
                Event evd14 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.Demonstration, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd14);                
            
                //Insert event with opportunity and Meeting Type Administrative
                Event evd15 = new Event(WhoId=con.Id,WhatId=acc.Id,Type = HSFE_Constant.MEETING, Meeting_Type__c = HSFE_Constant.ADMIN, DurationInMinutes = 30, ActivityDateTime = System.today());
                insertEventList.add(evd15);                
               
            test.starttest();
            
                if(insertEventList.size()>0){
                    insert insertEventList;
                }
                for(Event e : insertEventList){
                    if(e.Meeting_Type__c != HSFE_Constant.Demonstration){
                        e.WhoId = con2.Id;
                    }
                    else if (e.Meeting_Type__c == HSFE_Constant.Demonstration){
                        e.HSFE_Specialty__c ='';
                        e.HSFE_Sub_Specialty__c='';
                        e.WhoId = con2.Id;
                    }
                    
                    updateEventList.add(e);                 
                }               
                update updateEventList;
                
                
                Event event1 = new Event();
                event1 =[select Id,WhoId,Meeting_Type__c from event where Id =: evd7.id];
                
                if(event1.Id != null){
                    //check whether who Id is updated
                    System.assertEquals(event1.WhoId,con2.Id );
                    
                    //check whether Meeting Type is updated
                    System.assertEquals(event1.Meeting_Type__c,HSFE_Constant.Demonstration);
                }
            
            test.StopTest();
           
       }
    }
   
    
}