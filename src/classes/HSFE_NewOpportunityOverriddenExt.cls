/*Class Name : HSFE_NewOpportunityOverriddenExt  
*Description : To override standard New button to pre populate Sales stage, Speciality and Sub specility field on opportunity creation.
*Created By :  Chiranth Aradhya
*Created On : 4/6/2015 
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                          Modification Id                       Description

*------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public with sharing class HSFE_NewOpportunityOverriddenExt  {
    private ApexPages.StandardController controller = null;
    public String accId;
    public String accName;
    public String conId;
    public String conName;
    public Map<Id,Contact>specialtyMap;
    public List<Contact> conList;
   
    public HSFE_NewOpportunityOverriddenExt  (ApexPages.StandardController controller){
        this.controller = controller;
        conList = new List<Contact>();
        specialtyMap = new  Map<Id,Contact>();
        accId=ApexPages.CurrentPage().getparameters().get('accId');
        accName=ApexPages.CurrentPage().getparameters().get('accName');
        conId=ApexPages.CurrentPage().getparameters().get('conId');
        conName=ApexPages.CurrentPage().getparameters().get('conName');
    }

    //On load pre populate the speciality sub specilaity and sales stage field
    public PageReference onLoad(){
    User currentuser=[Select Id,Name,HSFE_Specialty__c,HSFE_Sub_Specialty__c from User where Id=:userinfo.getuserId()];
    String prefix = Opportunity.SObjectType.getDescribe().getKeyPrefix();
    String param = getParameters();
    //Query the primary  contact records which are related to opporutnities account
    conList = [Select Id,Name,HSFE_Primary__c,HSFE_Specialty__c,HSFE_Sub_Specialty__c,AccountId from Contact where AccountId =:accId and HSFE_Primary__c = True];
    //maps of specialty, sub specialty, Contact Name, ContactId 
    if(conList.size()>0){
        for(Contact cont:conList){
            if(cont.HSFE_Specialty__c == currentuser.HSFE_Specialty__c && cont.HSFE_Sub_Specialty__c==currentuser.HSFE_Sub_Specialty__c ){
                specialtyMap.put(cont.AccountId,cont);
            }
        }
    }
    
    Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    PageReference pg = new PageReference('/'+prefix+'/e?nooverride=1&'+param); 
    
    //The primary contact (from the Account) that matches the Speciality-Sub-Specialty on the Opportunity is populated in the "Contact" field.  
    if(specialtyMap != NULL && specialtyMap.containsKey(accId) && (specialtyMap.get(accId).HSFE_Specialty__c == currentuser.HSFE_Specialty__c && specialtyMap.get(accId).HSFE_Sub_Specialty__c  == currentuser.HSFE_Sub_Specialty__c) ){
        pg.getParameters().put(System.Label.HSFE_Opportunity_Primary_Contact_Id,specialtyMap.get(accId).Id);
        pg.getParameters().put(System.Label.HSFE_Opportunity_Primary_Contact_Name,specialtyMap.get(accId).Name);
    }
    
    pg.getParameters().put('opp4',accName);
    pg.getParameters().put('opp4_lkid',accId);
    pg.getParameters().put(System.Label.HSFE_Sub_Specialty,currentuser.HSFE_Sub_Specialty__c );
    pg.getParameters().put(System.Label.HSFE_Specialty,currentuser.HSFE_Specialty__c);
    pg.getParameters().put(System.Label.HSFE_Sub_Specialty,currentuser.HSFE_Sub_Specialty__c );
    pg.getParameters().put('opp11','Pipeline');
    pg.getParameters().put(System.Label.HSFE_Sales_Stage,'Universe');
    pg.setRedirect(true);
    return pg;
    
}

// Inherit previous parameters, more imporatntly, RecordType parameter!
private String getParameters(){
    string param = '';
    Map<String, String> strMap = ApexPages.currentPage().getParameters();
    String[] keys = new String[]{'RecordType', 'retURL', 'cancelURL','opp4_lkid'};
    for(String s : keys){
    if(strMap.containsKey(S)) param += s + '=' + strMap.get(s) + '&';
    }
    if(param.length() > 0) param = param.substring(0, param.length()-1);
    return param;
    }

}