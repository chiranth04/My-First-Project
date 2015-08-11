/* NOT A "PRODUCTION QUALITY" class!

This is mainly used to try out writing the dynamic Apex to fetch addresses according to Olympus' data model.
Final versions will be developed in "ELTON extension" package.
*/
public with sharing class ELTON_OrderSetAddress{

    public List<Account> accounts {get; private set;}
    private ELTON__Equipment_Order__c o;
    
    public ELTON_OrderSetAddress(ApexPages.standardController sc){
        Id orderId = sc.getId();
        if(orderId == null || String.valueOf(orderId.getSobjectType()) != 'ELTON__Equipment_Order__c'){
            throw new ELTON_InvalidArgumentException('Please pass a valid ELTON Equipment Order Id in as "id" parameter in the URL.');
        }
        o = (ELTON__Equipment_Order__c ) sc.getRecord();
        
        try{
            getSoldToAccounts();
        } catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
    
    // Private method, with implementation details specific for Olympus' data model.
    // Throws exceptions.
    private void getSoldToAccounts(){
        accounts = new List<Account>();
        // Crude check to determine whether we're in Olympus's org.
        // For now - will do. Ideal code would check for existence (& permissions to read) of all fields we reference.
        // But well... time constraints and if anything goes wrong - the query will simply fail so it's not the end of the world.
        Set<String> objects = Schema.getGlobalDescribe().keyset();
        if(objects.contains('hsfe_related_account__c')){
            if(o.ELTON__Opportunity__c == null){
                throw new ELTON_InvalidArgumentException('This order is not related to Opportunity, cannot use the custom logic. Please use the standard ELTON "Set Address" button or contact your administrator for assistance.');
            }
            List<Opportunity> opps = [SELECT AccountId FROM Opportunity WHERE Id = :o.ELTON__Opportunity__c];
            if(opps.isEmpty()){
            	throw new ELTON_InvalidArgumentException('Looks like you do not have permission to see the Opportunity. No way to fetch Sold-To\'s data.');
            }
            if(opps[0].AccountId == null){
            	throw new ELTON_InvalidArgumentException('This seems to be a private Opportunity, not related to an Account. No way to fetch Sold-To\'s data.');
            }
            
            Id parentId = opps[0].AccountId;
            String query = String.join(new List<String>{
                'SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry',
                'FROM Account',
                'WHERE Id IN (SELECT HSFE_Related_Account__c FROM HSFE_Related_Account__c WHERE HSFE_Sold_To_Account__c = :parentId)',
                //'WHERE Id IN (SELECT HSFE_Related_Account__c FROM HSFE_Related_Account__c WHERE HSFE_Sold_To_Account__c = :parentId AND HSFE_Relationship_Type__c = \'Ship To\')',
                'ORDER BY Name, BillingCountry, BillingState, BillingCity',
                'LIMIT 1000'
            }, '\n');
			accounts = (List<Account>) Database.query(query);
        }
    }

    public class ELTON_InvalidArgumentException extends Exception{}
}