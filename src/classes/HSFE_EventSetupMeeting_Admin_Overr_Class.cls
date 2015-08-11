/*Class Name : HSFE_EventSetupMeeting_Admin_Overr_Class  
*Description : To override SetUpMeeting to pre populate Name field on Event creation.
*Created By :  Chiranth Aradhya
*Created On : 5/12/2015 
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date           Modification Id        Description
Deloitte/Chiranth Aradhya   5/12/2015                             Pre populates the Name and Meeting Type( Primary Contact for the Specialty-Sub Specialty data combination of related opportunities populates the "Name" field on the Activity)
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class HSFE_EventSetupMeeting_Admin_Overr_Class  {
    
    //Variable declaration
    private ApexPages.StandardController controller = null;
    public String currentRecordId;
    public List<Contact> conList;
    public Map<Id,Contact>specialtyMap;
    public List<Opportunity> lstOppty;
    public List<Account> lstAcct;
    public List<Lead> lstlead;
    public Opportunity oppty;
    public Lead leadrec;
    public Account acc;
    public String Obj;
    //constructor
    public HSFE_EventSetupMeeting_Admin_Overr_Class(ApexPages.StandardController controller){
        
        this.controller = controller;
        conList = new List<Contact>();
        lstOppty = new List<Opportunity>();
        lstAcct = new List<Account>();
        lstlead = new List<Lead>();
        specialtyMap = new Map<Id,Contact>();
        oppty = new Opportunity();
        acc = new Account();
        leadrec = new Lead();
        //Get the Opportunity Id
        currentRecordId=ApexPages.CurrentPage().getparameters().get('What_Id');
        Obj =currentRecordId.substring(0, 3);
    }

    //Called on click of SetUpmeeting button to pre populate values
    public PageReference onLoadSetupMeeting(){
            //query the opp based on the What_Id
            lstOppty= [Select Id,Name,HSFE_Sales_Stage__c,HSFE_Specialty__c,HSFE_Sub_Specialty__c,HSFE_Area_of_Interest__c,AccountId,Account.Name from Opportunity where Id =: currentRecordId];
            if(lstOppty.size()>0 && lstOppty!= NULL){
                oppty= lstOppty[0];
                //Query the primary  contact records which are related to opporutnities account
                conList = [Select Id,Name,HSFE_Primary__c,HSFE_Specialty__c,HSFE_Sub_Specialty__c,AccountId from Contact where AccountId =:oppty.AccountId and HSFE_Primary__c = True];
                //maps of specialty, sub specialty, Contact Name, ContactId 
                if(conList.size()>0){
                    for(Contact cont:conList){
                        if(cont.HSFE_Specialty__c == oppty.HSFE_Specialty__c && cont.HSFE_Sub_Specialty__c==oppty.HSFE_Sub_Specialty__c ){
                            specialtyMap.put(cont.AccountId,cont);
                        }
                    }
                }
                String param = getParameters();
                String prefix = Event.SObjectType.getDescribe().getKeyPrefix();
                PageReference pg = new PageReference('/'+prefix+'/e?nooverride=1&'+param);
                //populate the "Name" field based on the Primary Contact for the Specialty-Sub Specialty on the Activity and related Opportunity.
                if(specialtyMap != NULL && specialtyMap.containsKey(oppty.AccountId) && (specialtyMap.get(oppty.AccountId).HSFE_Specialty__c == oppty.HSFE_Specialty__c && specialtyMap.get(oppty.AccountId).HSFE_Sub_Specialty__c  == oppty.HSFE_Sub_Specialty__c) ){
                    pg.getParameters().put('evt2_lkid',specialtyMap.get(oppty.AccountId).Id);
                    pg.getParameters().put('evt2',specialtyMap.get(oppty.AccountId).Name);
                }
                //populate Related to,Subject,Specialty,subspecialty and Area of Interest
                pg.getParameters().put('evt5',oppty.Account.Name);
                pg.getParameters().put('evt3_lkid',oppty.Id);
                pg.getParameters().put('evt3',oppty.Name);
                pg.getParameters().put('RecordType',System.Label.HSFE_Event_Activity_for_Opportunity_Record_Type);
                pg.getParameters().put(System.Label.HSFE_Activity_Specialty,oppty.HSFE_Specialty__c);
                pg.getParameters().put(System.Label.HSFE_Activity_Sub_Specialty,oppty.HSFE_Sub_Specialty__c);
                pg.setRedirect(true);
                return pg;
                
            }
            
            return null;
          }
     
    // Inherit previous parameters, Save new URL, retUrl, CancelUrl!
    private String getParameters(){
        string param = '';
        Map<String, String> strMap = ApexPages.currentPage().getParameters();
        String[] keys = new String[]{'save_new_url', 'retURL', 'cancelURL','who_id'};
        for(String s : keys){
        if(strMap.containsKey(S)) param += s + '=' + strMap.get(s) + '&';
        }
        if(param.length() > 0) param = param.substring(0, param.length()-1);
        return param;
    }
}