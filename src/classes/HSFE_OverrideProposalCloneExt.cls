/* 
* Class Name  : HSFE_OverrideProposalCloneExt
* Description : Extension for HSFE_OverrideProposalClone
              : Incase of exception the quote will role back to old quote  
* Created By  : Kritika Nagpal
* Created On  : 4/21/2015
*
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                             Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Yunus                      4/03/2015
* Kritika                    4/17/2015                        Update the Quote Version Number on Opportunity
* Yunus                      4/03/2015                        Added Exception blocks
* Ajay Agnihotri             12/05/2015                       Modified the Logic replace static query with dynamic query.
* Ajay Agnihotri             5/06/2015                        The new quote will have "versioned from" populated with the lookup to the quote it was versioned. 
* Ajay Agnihotri            10/06/2015                        Enhancement: HSFE_Line_Item_Extension__c column in Line Item is set to Null while cloning.
* Ajay Agnihotri            10/06/2015                        Enhancement: “HSFE_Contract_Integration_Status__c”,” HSFE_Freight_Integration_Status__c” column in Line Item is set to 'Not Synched' while cloning.
* Ajay Agnihotri            16/06/2015                        Enhancement: If ""Quote Status"" is “In Review”.Default below fields while cloning Quote.
                                                                Approval Preview Status (In Product Configuration)= Pending
                                                                Approval Status(In Product Configuration)= Approval Required
                                                                Quote Status (In Quote/Proposal)= Approval Required
                                                                Contract Integration Status (In Quote/Proposal)= BLANK
                                                                Freight Integration Status (In Quote/Proposal)= BLANK           
                                                                Order Integration Status (In Quote/Proposal)= BLANK
* Ajay Agnihotri            18/06/2015                        Enhancement:  None of the FIS fields  and operation details should be copied over in new cloned quote.
* Ajay Agnihotri            26/06/2015                        Don't Copy Order Created and Freight Fields     
* Ajay Agnihotri            29/06/2015                        While cloning, HSFE_Line_Con_Codes__c is inserted with null.                                                                                                              
*/ 
public with sharing class HSFE_OverrideProposalCloneExt{

    private final Apttus_Proposal__Proposal__c mysObject;
    public String sRecordId{get; private set;}
    public String sRetURL{get; private set;}
    Public String sRedirectURL{get; private set;}
    public boolean DisplayError {get;set;}
        
    public HSFE_OverrideProposalCloneExt(ApexPages.StandardController stdController) {
        this.mysObject = (Apttus_Proposal__Proposal__c )stdController.getRecord();
        sRecordId = System.currentPagereference().getParameters().get('id');
        sRetURL = System.currentPagereference().getParameters().get('retURL');
        DisplayError = false;   
    
    }
    
    public PageReference init() {
        
        list<Apttus__TempObject__c> lTempObject = new List<Apttus__TempObject__c>();
        list<NoteAndAttachment> lNoteAndAttachment = new List<NoteAndAttachment>();
        list<Apttus_Proposal__Proposal_Line_Item__c > lProposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        list<Apttus_Config2__ProductConfiguration__c> lProductConfiguration = new list <Apttus_Config2__ProductConfiguration__c>();
        list<Id> lOLDProductConfiguration = new list <Id>();        
        list<Apttus_Config2__LineItem__c> lLineItem = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__TempObject__c> lTempObjectCPQ = new list<Apttus_Config2__TempObject__c>();
        list<Apttus_Config2__SummaryGroup__c> lSummaryGroup = new list<Apttus_Config2__SummaryGroup__c>();
        string QuoteStatusBeforeCloning='';
        
        Map<Id, Id> mOldNewProductConfiguration = new Map <Id,Id>();
        
        Apttus_Proposal__Proposal__c oProposal=new Apttus_Proposal__Proposal__c();
        List<Apttus_Proposal__Proposal__c> QProposalList=new List<Apttus_Proposal__Proposal__c>();
        
        QProposalList=Database.query(CreateParentToChildDynamicQueryForQuoteProposal());
        if(QProposalList.size()>0){
             oProposal=QProposalList[0];
             /* 5/06/2015 : The new quote will have "versioned from" populated with the lookup to the quote it was versioned. (Ajay Agnihotri )*/
            if(sRecordId!=null && sRecordId!='')
                oProposal.HSFE_Versioned_From__c=sRecordId;
            else
                oProposal.HSFE_Versioned_From__c=null;  
        }    
        
       
        
        Apttus_Proposal__Proposal__c oNewProposal = oProposal.clone(false,true); // Clones to create a new Proposal Record    
        
        String sProposalName = oProposal.Apttus_Proposal__Proposal_Name__c ;
        String[] aSplitProposalName = sProposalName.split('-v',5);
        String sProposalType;
        String sVersionNumber;
        Integer iNewVersionNumber;
        try{
        
            if(aSplitProposalName.size() == 2){
                sProposalType = aSplitProposalName[0];
                system.debug('------------->'+aSplitProposalName);
                if(aSplitProposalName[aSplitProposalName.size()-1] != '')
                    iNewVersionNumber = Integer.valueOf(aSplitProposalName[aSplitProposalName.size()-1]) +1;
                else
                    iNewVersionNumber = 1;
            }else if(aSplitProposalName.size() >2){  
                for(integer i=0;i<=aSplitProposalName.size()-2;i=i+2){
                    sProposalType= aSplitProposalName[i]+'-v'+aSplitProposalName[i+1];
                }
                iNewVersionNumber= Integer.valueOf(aSplitProposalName[aSplitProposalName.size()-1]) +1;             
            }else{
                sProposalType = aSplitProposalName[aSplitProposalName.size()-1];
                iNewVersionNumber =1;
            }
            
            RecordType oRecordType = [SELECT id,Name from RecordType where SobjectType= 'Apttus_Proposal__Proposal__c' AND Name='Proposal'];
            
            //oNewProposal.Apttus_Proposal__Approval_Stage__c ='Draft';
            oNewProposal.Apttus_QPApprov__Approval_Status__c=null;
            oNewProposal.HSFE_Contract_Integration_Status__c=null;
            oNewProposal.Apttus_Proposal__Proposal_Expiration_Date__c=null;
            oNewProposal.Apttus_Proposal__Proposal_Approval_Date__c=null;
            oNewProposal.RecordTypeId = oRecordType.Id;
            oNewProposal.HSFE_Deep_Clone__c=true;
            oNewProposal.Apttus_Proposal__Proposal_Name__c = sProposalType+'-v'+iNewVersionNumber;
            
            oNewProposal.HSFE_Update_Record_Type__c=false;
            oNewProposal.HSFE_Contract_Integration_Status__c='';
            oNewProposal.HSFE_Freight_Integration_Status__c='';
            oNewProposal.HSFE_Order_Status__c='';
            
            // Don't copy FIS Fields in Clone
            oNewProposal.HSFE_Additional_Discount__c=null;
            oNewProposal.HSFE_Blind_Disc__c=null;
            oNewProposal.HSFE_FIS_Bill_To__c=null;
            oNewProposal.HSFE_FIS_Contract_Number__c='';
            oNewProposal.HSFE_FIS_Payer__c=null;
            oNewProposal.HSFE_Is_FIS__c=false;
            oNewProposal.HSFE_Contract_Duration_Months__c=null;
            oNewProposal.HSFE_Contract_Effective_Date__c=null;
            
            // Don't copy Operation Details Fields in Clone
            oNewProposal.HSFE_Carrier_Name__c=null;
            oNewProposal.HSFE_CSR_Hold__c=false;
            oNewProposal.HSFE_Delivery_Instruction__c='';
            oNewProposal.HSFE_Only_Complete_Delivery__c=false;
            oNewProposal.Apttus_QPConfig__PONumber__c='';
            oNewProposal.HSFE_Print_Message__c='Thank you';
            oNewProposal.HSFE_SAP_Shipping_Condition__c='Second Day';
            
            QuoteStatusBeforeCloning=oNewProposal.Apttus_Proposal__Approval_Stage__c;
            if(oNewProposal.Apttus_Proposal__Approval_Stage__c=='In Review')
                oNewProposal.Apttus_Proposal__Approval_Stage__c='Approval Required';
            else
                oNewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
            
            // Don't Copy Order Created and Freight Fields 
            oNewProposal.Apttus_QPConfig__AutoActivateOrder__c = false;
            oNewProposal.HSFE_Freight_Charges__c = null;
            oNewProposal.HSFE_Order_Creation_Date__c = null;
            oNewProposal.HSFE_Order_Failure_Reason__c = null;
            oNewProposal.HSFE_Order_Failure_Reason_Code__c = null;
            oNewProposal.HSFE_Order_Number__c = null;
            oNewProposal.HSFE_SAP_Comments__c = null;
            
            // 29/06/2015   While cloning, HSFE_Line_Con_Codes__c is inserted with null (Ajay Agnihotri).
            oNewProposal.HSFE_Line_Con_Codes__c = null;
            
            // New Proposal Inserted         
            insert oNewProposal;
            
            for (Apttus_Config2__ProductConfiguration__c oProductConfiguration: oProposal.Apttus_QPConfig__Configurations__r) {
                Apttus_Config2__ProductConfiguration__c oNewProductConfiguration = oProductConfiguration.clone(false,true);
                oNewProductConfiguration.Apttus_QPConfig__Proposald__c = oNewProposal.Id;
                oNewProductConfiguration.Apttus_Config2__BusinessObjectId__c= oNewProposal.Id;
                oNewProductConfiguration.Name= 'Product Config -'+oNewProposal.Apttus_Proposal__Proposal_Name__c;
                oNewProductConfiguration.Parent_Product_Config__c = oProductConfiguration.Id;
                
                if(QuoteStatusBeforeCloning=='In Review'){
                    oNewProductConfiguration.Apttus_CQApprov__Approval_Preview_Status__c='Pending';
                    oNewProductConfiguration.Apttus_CQApprov__Approval_Status__c='Approval Required';
                }
                lProductConfiguration.add(oNewProductConfiguration);
                lOLDProductConfiguration.add(oProductConfiguration.Id);
                // mOldNewProductConfiguration.put(oProductConfiguration.Id,oNewProductConfiguration.Id);
            }
            // New Product Config Inserted.
            insert lProductConfiguration;
            
            for(Apttus_Config2__ProductConfiguration__c oNewProductConfiguration:[SELECT ID,Parent_Product_Config__c from Apttus_Config2__ProductConfiguration__c where ID in: lProductConfiguration ]) {
                mOldNewProductConfiguration.put(oNewProductConfiguration.Parent_Product_Config__c,oNewProductConfiguration.Id );
            }

            /* we are passing the object API name to our custom method to get all the fields API Name*/
            string QueryStringFrLineItem='select '+ObjectFields('Apttus_Config2__LineItem__c')+' from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c IN: lOLDProductConfiguration';
            
            for(Apttus_Config2__LineItem__c oLineItem: Database.query(QueryStringFrLineItem)){      
                Apttus_Config2__LineItem__c oNewLineItem = oLineItem.clone(false, true);
                oNewLineItem.Apttus_Config2__ConfigurationId__c = mOldNewProductConfiguration.get(oLineItem.Apttus_Config2__ConfigurationId__c);
                oNewLineItem.HSFE_Line_Item_Extension__c=null;      //10/06/2015 Enhancement: HSFE_Line_Item_Extension__c column in Line Item is set to Null while cloning (Ajay Agnihotri)
                oNewLineItem.HSFE_Contract_Integration_Status__c='Not Synched'; //10/06/2015 Enhancement: “HSFE_Contract_Integration_Status__c”,” HSFE_Freight_Integration_Status__c” column in Line Item is set to 'Not Synched' while cloning.
                oNewLineItem.HSFE_Freight_Integration_Status__c='Not Synched';
                lLineItem.add(oNewLineItem);
            }        
            // New Line Items Inserted.
            insert lLineItem;
            
            
            
            /* we are passing the object API name to our custom method to get all the fields API Name*/
            string QueryStringFrTempObj='select '+ObjectFields('Apttus_Config2__TempObject__c')+' from Apttus_Config2__TempObject__c where Apttus_Config2__ConfigurationId__c IN: lOLDProductConfiguration';
       
            List<Apttus_Config2__TempObject__c> oTempObjectCPQLst = new List <Apttus_Config2__TempObject__c>();
            oTempObjectCPQLst = Database.query(QueryStringFrTempObj);
            for(Apttus_Config2__TempObject__c oTempObjectCPQ: oTempObjectCPQLst ){
                Apttus_Config2__TempObject__c oNewTempObjectCPQ = oTempObjectCPQ.clone(false,true);
                oNewTempObjectCPQ.Apttus_Config2__ConfigurationId__c = mOldNewProductConfiguration.get(oTempObjectCPQ.Apttus_Config2__ConfigurationId__c);
                lTempObjectCPQ.add(oNewTempObjectCPQ);
            }
            // New Line Item Inserted
            insert lTempObjectCPQ;
            
            /* we are passing the object API name to our custom method to get all the fields API Name*/
            string QueryStringFrSummaryGroup='select '+ObjectFields('Apttus_Config2__SummaryGroup__c')+' from Apttus_Config2__SummaryGroup__c where Apttus_Config2__ConfigurationId__c IN: lOLDProductConfiguration';

            
            List <Apttus_Config2__SummaryGroup__c> summaryGroupLst = new List <Apttus_Config2__SummaryGroup__c>();
            summaryGroupLst = Database.query(QueryStringFrSummaryGroup);
            for(Apttus_Config2__SummaryGroup__c oSummaryObject :summaryGroupLst){ 
                Apttus_Config2__SummaryGroup__c oNewSummaryGroup = oSummaryObject.clone(false,true);
                oNewSummaryGroup.Apttus_Config2__ConfigurationId__c = mOldNewProductConfiguration.get(oSummaryObject.Apttus_Config2__ConfigurationId__c);
                lSummaryGroup.add(oNewSummaryGroup);
            }        
            // New Summary Group inserted
            insert lSummaryGroup ;
            
            for(Apttus_Proposal__Proposal_Line_Item__c oProposalLineItem: oProposal.Apttus_Proposal__R00N70000001yUfBEAU__r){
                Apttus_Proposal__Proposal_Line_Item__c oNewProposalLineItem = oProposalLineItem.clone(false,true);
                oNewProposalLineItem.Apttus_Proposal__Proposal__c = oNewProposal.Id;
                lProposalLineItem.add(oNewProposalLineItem);
            }        
            insert lProposalLineItem;
            
            Apttus_Proposal__Proposal__c oNewProposalRetrieved = [Select Id,Apttus_Proposal__Opportunity__c , recordTypeId from Apttus_Proposal__Proposal__c where Id =: oNewProposal.Id];
            Id oNewRecordId= oNewProposalRetrieved.Id;
            Id iOpportunityId = oNewProposalRetrieved.Apttus_Proposal__Opportunity__c ;        
            String Url = '/' + oNewRecordId + '/e';
            PageReference oPage = new PageReference(Url);
            oPage.getParameters().put('cancelURL', '/apex/apttus_proposal__cancelactioninterceptor?actionName=create_oppty_proposal&objectId='+iOpportunityId+'&opportunityId='+iOpportunityId +'&proposalId='+oNewRecordId+'&rollbackId='+oNewRecordId);
            oPage.getParameters().put('retURL',oNewRecordId );
            return oPage;
            
        }Catch(DmlException ex){
        
            HSFE_ExceptionLogger.createExceptionLog(ex); 
            
            if(StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY == ex.getDmlType(0)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You are not a member of opportunity team or you do not have access to clone this quote.');
                ApexPages.addMessage(myMsg);
                DisplayError = true;
                String Url = '/apex/HSFE_Error_Message_Deep_Clone?Error=OpporunityOwner';
                PageReference oPage = new PageReference(Url);
                oPage.setRedirect(True);
                return oPage;                
            }
            String Url = '/apex/HSFE_Error_Message_Deep_Clone?Error=Exception';
            PageReference oPage = new PageReference(Url);
            oPage.setRedirect(True);
            return oPage;                
        }
        return null;               
    }
    
    // Below Method is used to generate the dynamic query for Apttus_Proposal__Proposal__c
    public string CreateParentToChildDynamicQueryForQuoteProposal(){
        string FinalQuoteProposalParentChildQueryString='';
        try{
            
            /* we are passing the object API name to our custom method to get all the fields API Name*/
            string FieldsFrQuoteProposal=ObjectFields('Apttus_Proposal__Proposal__c');      
            string FieldsFrNotesAndAttachments=ObjectFields('NoteAndAttachment');
            string FieldsFrTempObject=ObjectFields('Apttus__TempObject__c');    
            string FieldsFrProposalLineItem=ObjectFields('Apttus_Proposal__Proposal_Line_Item__c');
            string FieldsFrProductConfiguration=ObjectFields('Apttus_Config2__ProductConfiguration__c');
            
            /* we are passing the object API name to our custom method to get all the fields API Name*/
            FinalQuoteProposalParentChildQueryString = 'Select '+FieldsFrQuoteProposal+',(select '+FieldsFrNotesAndAttachments+' from NotesAndAttachments), (select '+FieldsFrTempObject+' from Apttus_Proposal__TempObjects__r), (select '+FieldsFrProposalLineItem+' from Apttus_Proposal__R00N70000001yUfBEAU__r), (select '+FieldsFrProductConfiguration+' from Apttus_QPConfig__Configurations__r) from Apttus_Proposal__Proposal__c where id=:sRecordId';

            return FinalQuoteProposalParentChildQueryString;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('________Exception in CreateParentToChildDynamicQueryForQuoteProposal Method of HSFE_OverrideProposalCloneExt __________________'+e.getMessage());
            return FinalQuoteProposalParentChildQueryString;
        }
        return FinalQuoteProposalParentChildQueryString;
    }
    
    
    //Getting the fields from object
    public String ObjectFields(String ObjectNameval){
        try{
            string fieldsVal = '';
            SObjectType objToken = Schema.getGlobalDescribe().get(ObjectNameval);

            /* For this method we are getting the object API name both for standard object and cutom object
               getGlobalDescribe()-method returns the map of all sobject names(Keyset) with sobject
               token(value paires)
                e.g. Assume if your org contains one custom object called Book(Book__c) with all standard
                       object.Then the result of getGlobalDescribe method will be 
                        Map<Book__c,Book object tokens> like with all standard objects.
            getGlobalDescribe().get(ObjectNameval)-As we know we get value pairs from map by using
            get() method.This will return an Book__c object type this we collected in SObjectType variable
            token. So the object token value is Book__c*/

            DescribeSObjectResult objDef = objToken.getDescribe();

            /*getDescribe()-An object(Book) that contains all the describe properties for the sobject(Book)
             or fields. 
                        e.g. getKeyPrefix, getLabel, getLabelPlural, getLocalName etc.
            */
               
            Map<String, SObjectField> fields = objDef.fields.getMap();
              
            /*Map of the fields value. e.g. {name=Name,author__c=Author__c,etc}*/
                    
            Set<String> fieldSet = fields.keySet();
                
            /*Collecting the fields API  into set variable fieldset.*/
                 
            for(string f : fieldSet){
                fieldsVal += f +',';
            }   
            if(fieldsVal.endsWith(','))
            fieldsVal= fieldsVal.substring(0,fieldsVal.length()-1);
                    
            /*Adding , string after every fields api name.
                e.g  fieldsVal-variable will contains the value like -Name,pincode__c,CreateDate etc.
            */
            return fieldsVal;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('________Exception in ObjectFields Method of HSFE_OverrideProposalCloneExt __________________'+e.getMessage());
            return null;
        }
        return null;
    }
}