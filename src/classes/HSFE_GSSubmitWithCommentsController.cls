/**
 *  Apttus CPQ Approvals Management
 *  GSSubmitWithCommentsController
 *   
 *  @2015 Apttus Inc. All rights reserved.
 */
public with sharing class HSFE_GSSubmitWithCommentsController {

    // invoked from quote view?
    private Boolean fromQuote = false;
    private ID quoteId = null;
    
    // user initiated action (submit/cancel/return)    
    private String actionTaken = null;   

    // return button label
    private String returnButtonLabel = null;
    
    // show header & sidebar ?
    private Boolean showHeader = false;
    private Boolean showSidebar = false;
    
    // approval request fieldset name
    private String arFieldSetName = null;
        
    // component params
    private Apttus_Approval.SObjectApprovalContextParam2 ctxParam2 = null;

    // product configuration identifier
    private ID configId = null;
    private ID configRequestId = null;      
        
    // context header
    private Apttus_Config2__ProductConfiguration__c configSO = null;

    // single context
    private ID lineItemId = null;
    
    // return id or page but not both, id takes preference
    private ID returnId = null;
    private String returnPage = null;
    
    // show cart header
    private Boolean showCartHeader = true;
    private Boolean isDialog = false;
       
    // salesforce1 mode indicator
    private Boolean inSf1Mode = false;
    // page initially loaded
    private Boolean pageLoaded = false;
    public Boolean showError{get;set;}
    // page URL
    private String pageURL = null;
    
    static final String PROP_SYSTEM_PROPERTIES = 'System Properties';
    
    public final String PARAM_RETURNID = 'returnId';
    public final String PARAM_RETURNPAGE = 'returnPage';
    public final String PARAM_QUOTE_ID = 'quoteId';
    public final String PARAM_IS_DIALOG = 'isDialog';
    public final String PARAM_CONFIG_ID = 'Id';
    public final String PARAM_SOBJECTID = 'sObjectId';
    public final String PARAM_SOBJECTTYPE = 'sObjectType';
    public final String PARAM_SHOW_HEADER = 'showHeader';
    public final String PARAM_SHOW_SIDEBAR = 'showSidebar';
    public final String PARAM_LINEITEM_IDS = 'lineItemIds';
    public final String PARAM_AR_FIELDSET_NAME = 'arFieldSetName'; 
    public final String PARAM_CONFIG_REQUEST_ID = 'configRequestId';
    public final String PARAM_RETURN_BUTTON_LABEL = 'returnButtonLabel';
    public final String PARAM_INCLUDE_HEADER_APPROVALS = 'includeHeaderApprovals';
    public final String PARAM_HEADER_SOBJECTID = 'headerSObjectId'; // in case of Cart, it is the quoteId
    public final String PARAM_HEADER_SOBJECT_TITLE = 'headerSObjectTitle'; // proposal name 
    public final String ERROR_MSG = 'Error'; 
     
    
    //Actions
    public final String ACTION_CANCEL = 'cancel';
    public final String ACTION_SUBMIT = 'submit';
    public final String ACTION_SUBMIT_WITH_ATTACHMENTS = 'submitWithAttachments';
    
    public final String SOBJECT_CART_HEADER = 'Apttus_Config2__ProductConfiguration__c';
    public final String STATUS_APPROVAL_REQUIRED = 'Approval Required';
    public final String PREVIEW_PENDING = 'Pending';
    public final String PREVIEW_COMPLETE = 'Complete';
    public final String QUOTE_CONFIG_PAGE = 'Apttus_QPConfig__ProposalConfiguration';
    public final String USE_ADVANCED_APPROVAL = 'useAdvancedApproval';
    public final String CART_PAGE = 'Apttus_Config2__CartDetailView';
    
    // customer portal user types
    public final String USERTYPE_HIGHVOLUMEPORTAL = 'CspLitePortal';
    public final String USERTYPE_CUSTOMERPORTAL_USER = 'CustomerSuccess';
    public final String USERTYPE_CUSTOMERPORTAL_MANAGER = 'PowerCustomerSuccess';
    public final String USERTYPE_PARTNER = 'PowerPartner';
    //Cart page URL
    public String productConfigId;
    public String configsRequestId;
    
    /**
     * Class Constructor 
     * @param stdController the standard controller
     */
    public HSFE_GSSubmitWithCommentsController() {
        //[Sk]08/05/2015
        productConfigId = Apexpages.currentPage().getParameters().get('id');
        configsRequestId = Apexpages.currentPage().getParameters().get('configRequestId');
        showError = false;
        //End of change
        // show header
        String showHeaderStr = ApexPages.currentPage().getParameters().get(PARAM_SHOW_HEADER);
        if (! nullOrEmpty(showHeaderStr)) {
            showHeader = Boolean.valueOf(String.escapeSingleQuotes(showHeaderStr));
        }
        
        // show sidebar
        String showSidebarStr = ApexPages.currentPage().getParameters().get(PARAM_SHOW_SIDEBAR);
        if (! nullOrEmpty(showSidebarStr)) {
            showSidebar = Boolean.valueOf(String.escapeSingleQuotes(showSidebarStr));
        }
        
        // approval request fieldset name?
        String arFieldSetNameStr = ApexPages.currentPage().getParameters().get(PARAM_AR_FIELDSET_NAME);
        if (arFieldSetNameStr != null) {
            arFieldSetName = String.escapeSingleQuotes(arFieldSetNameStr);
        }

        // return/exit button label shown inside the component
        String returnButtonLabelStr = ApexPages.currentPage().getParameters().get(PARAM_RETURN_BUTTON_LABEL);
        if (returnButtonLabelStr != null) {
            returnButtonLabel = String.escapeSingleQuotes(returnButtonLabelStr);
        }
        
        // quote id
        String quoteIdStr = ApexPages.currentPage().getParameters().get(PARAM_QUOTE_ID);
        if (! nullOrEmpty(quoteIdStr)) {
            quoteId = String.escapeSingleQuotes(quoteIdStr);
            fromQuote = true;
        }
        
        // cart id
        String configIdStr = ApexPages.currentPage().getParameters().get(PARAM_CONFIG_ID);
        if (! nullOrEmpty(configIdStr)) {
            configId = String.escapeSingleQuotes(configIdStr);
        }       
        
        // return id
        String returnIdStr = ApexPages.currentPage().getParameters().get(PARAM_RETURNID);
        if (! nullOrEmpty(returnIdStr)) {
            returnId = ID.valueOf(String.escapeSingleQuotes(returnIdStr));
        }
        
        // return page
        String returnPageStr = ApexPages.currentPage().getParameters().get(PARAM_RETURNPAGE);
        if (! nullOrEmpty(returnPageStr)) {
            returnPage = String.escapeSingleQuotes(returnPageStr);
        }

        if (fromQuote) { // from quote
            // return label
            showCartHeader = false;
            if (returnButtonLabel == null) {
                returnButtonLabel = 'Return';    //Label.Apttus_Config2.Return;
            }
        } else if (configId != null){ // from cart
            
            // config request id
            String configRequestIdStr = ApexPages.currentPage().getParameters().get(PARAM_CONFIG_REQUEST_ID);
            if (configRequestIdStr != null) {
                configRequestId = String.escapeSingleQuotes(configRequestIdStr);
            }
            
            // default return button label
            if (returnButtonLabel == null) {
                returnButtonLabel = Label.Apttus_Config2.ReturnToCart;
            }

            // get selected line item id
            String lineItemIdStr = ApexPages.currentPage().getParameters().get(PARAM_LINEITEM_IDS);
            if (lineItemIdStr != null) {
                lineItemId = String.escapeSingleQuotes(lineItemIdStr);
            }
               
            // include header approvals?
            String showCartHeaderStr = ApexPages.currentPage().getParameters().get(PARAM_INCLUDE_HEADER_APPROVALS);
            if (! nullOrEmpty(showCartHeaderStr)) {
                showCartHeader = Boolean.valueOf(String.escapeSingleQuotes(showCartHeaderStr));
            } 
            
        }
        
        // are we within a iframe?
        String isDialogStr = ApexPages.currentPage().getParameters().get(PARAM_IS_DIALOG);
        if (! nullOrEmpty(isDialogStr)) {
            isDialog = Boolean.valueOf(String.escapeSingleQuotes(isDialogStr));
        }
        
              
        // get related quote id & preview status
        List<Apttus_Config2__ProductConfiguration__c> configSOList = null;
        configSOList = [select Id, Apttus_Config2__BusinessObjectId__c
                        , Apttus_CQApprov__Approval_Preview_Status__c
                        , Apttus_CQApprov__Approval_Status__c
                        from Apttus_Config2__ProductConfiguration__c
                        where Id = :configId];
        if ( ! nullOrEmpty(configSOList)) {
            configSO = configSOList[0];
            quoteId = configSO.Apttus_Config2__BusinessObjectId__c;
        }   
        
        // prepare context
        prepareContext();
        
        // LOAD ANY ADDITIONAL DATA FOR DISPLAY.......
        
        // force return to cart
        fromQuote = false;
        
    }
    
    /**
     * Gets context param object for component
     */
    private void prepareContext() {             
        
        // prepare param
        ctxParam2 = new Apttus_Approval.SObjectApprovalContextParam2();
        
        ctxParam2.ctxSObjectType = SOBJECT_CART_HEADER;
        ctxParam2.ctxSObjectId = configSO.Id;
        
        // single context?
        if (lineItemId != null) {
            ctxParam2.ctxChildSObjectId = lineItemId;
        }
        
        ctxParam2.ctxApprovalStatus = configSO.Apttus_CQApprov__Approval_Status__c;
        
        // auto-preview?
        if ((STATUS_APPROVAL_REQUIRED == configSO.Apttus_CQApprov__Approval_Status__c)
                && (PREVIEW_PENDING == configSO.Apttus_CQApprov__Approval_Preview_Status__c)) {
            ctxParam2.autoPreviewIndicator = true;
        }
        
        ctxParam2.returnButtonLabel = returnButtonLabel;
        ctxParam2.processingMode = Apttus_Approval.SObjectApprovalContextParam2.PROCESSING_MODE_PREVIEW;
        ctxParam2.inDialogMode = isDialog;
        
        // use return id or page but not both, id takes preference
        if (! nullOrEmpty(returnPage)) {
            // return to custom page
            ctxParam2.returnPage = returnPage;

        } else {
            // return to quote
            ctxParam2.returnId = quoteId;
        }

        if (arFieldSetName != null) {
            ctxParam2.dspFieldSetName = arFieldSetName;
        }

        // hide cart header and return button if approvals are being reviewed within a dialog
        if (isDialog) {
            showCartHeader = false; 
            returnButtonLabel = null;
            ctxParam2.returnButtonLabel = null;     
        }                                       

        // in salesforce1 mode?
        ctxParam2.inSf1Mode = inSf1Mode;
        
        // show custom buttons instead of the ones inside the managed component
        //ctxParam2.inDialogMode = true;

        // set Quote as header in header section
        //ctxParam2.headerSObjectId = quoteId; Sourav Commented
        ctxParam2.ctxSObjectId = quoteId; //Sourav Added
        
        // since quote name is not the 'Name' field in Apttus_Proposal__Proposal__c object,
        //  retrieve the name form 'Proposal_Name__c' field and pass it along in context param object
        //  so that receiving routine can use it to override the 'Name' field value in the header
        //ctxParam2.headerSObjectTitle = getQuoteName(quoteId); Sourav Commented
        
    }
    
    /**
     * Set the controller mode to Salesforce1 when assignTo is passed in actionFunction param
     * @param mode true if we are in Salesforce1 mode, false otherwise
     */
    public void setInSf1Mode(Boolean mode) {
        inSf1Mode = mode;
    }

    /**
     * Check if the controller is in Salesforce1 mode
     * @return true if we are in Salesforce1 mode, false otherwise
     */
    public Boolean getInSf1Mode() {
        return inSf1Mode;
    }
    
    /**
     * Test if the page has been initially loaded
     * @return true if the page has been initially loaded, false otherwise
     */
    public Boolean getPageLoaded() {  
        return pageLoaded;  
    }
    
        
    /**
     * Launch SObject approvals
     * @return pageRef page reference to appropriate page
     */
    public PageReference doLaunchSObjectApprovals() {
        // save the sf1 mode
        ctxParam2.inSf1Mode = inSf1Mode;
        
        // indicate we have initially loaded the page
        pageLoaded = true;
        
        // stay on same page so we can use sforce1 redirection in the visualforce page
        pageURL = null;
        return null;
    
    }
    
       
    /**
     * Get appropriate label based on caller
     */
    public String getReturnLabel() {
        return returnButtonLabel;
    }
    
    /*
     * Get approval request fieldset name
     */
    public String getFieldSetName() {
        return arFieldSetName;
    }
    
    /**
     * Gets show header indicator
     */
    public Boolean getShowHeader() {
        return showHeader;
    }
    
    /**
     * Gets show sidebar indicator
     */
    public Boolean getShowSidebar() {
        return showSidebar;
    }   

    /**
     * Gets context param object for component
     */
    public Apttus_Approval.SObjectApprovalContextParam2 getContextInfo() {
        return ctxParam2;
    }

    /**
     * Sets context param object
     * @param ctxInfo 
     */
    public void setContextInfo(Apttus_Approval.SObjectApprovalContextParam2 info) {
        
    }

    /**
     * Initial call to submit page
     */
    public PageReference doSubmit() {           
        //[SK 07/31/2015]Real time integration call.                    
         String msg = HSFE_ContractFrieghtUpdate.fetchLineItem(configId); 
        //End of change.
        // save the sf1 mode
        ctxParam2.inSf1Mode = inSf1Mode;
        
        // indicate we have initially loaded the page
        pageLoaded = true;
        
        if(ctxParam2.autoPreviewIndicator == true){
            Apttus_Approval.ApprovalsWebService.previewApprovals('Apttus_Config2__ProductConfiguration__c',configId);
        }
        actionTaken = ACTION_SUBMIT;
        if(msg == ERROR_MSG){
            showError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Not getting proper response from Mule, please try it again'));
            return null;
        }
        else{
            return doReturnInternal();            
        }
        
    }
    
    
    /**
     * Return
     */    
   @TestVisible private PageReference doReturnInternal() {

        // mark cart approvals as previewed
        Apttus_Config2__ProductConfiguration__c cartSO = new Apttus_Config2__ProductConfiguration__c(Id = configId);
        cartSO.Apttus_CQApprov__Approval_Preview_Status__c = PREVIEW_COMPLETE;
        update cartSO;

        // get quote name
        String quoteName = null;
        if (quoteId != null) {
            quoteName = getQuoteName(quoteId);
            
        }

        // return url
        PageReference pageRef = null;
        if ((actionTaken == ACTION_SUBMIT) ||
            (actionTaken == ACTION_SUBMIT_WITH_ATTACHMENTS)) {
            
            pageRef = (getInSf1Mode())
                    ? new PageReference(getPageUrl('Apttus_Approval__SObjectApprovals2SubmitSf1'))
                    : new PageReference(getPageUrl('Apttus_Approval__SObjectApprovals2Submit'));

            // specify cart header and cart id parameters
            pageRef.getParameters().put(PARAM_SOBJECTTYPE, SOBJECT_CART_HEADER);
            pageRef.getParameters().put(PARAM_SOBJECTID, configId);
            pageRef.getParameters().put(PARAM_HEADER_SOBJECTID, quoteId);
            pageRef.getParameters().put(PARAM_HEADER_SOBJECT_TITLE, quoteName);

            // return to quote or custom page but not both, quote takes preference
            if (! nullOrEmpty(returnPage)) {
                pageRef.getParameters().put(PARAM_RETURNPAGE, returnPage);
            } else {                                
                pageRef.getParameters().put(PARAM_RETURNID, quoteId);
            }
            String cartPageURL = QUOTE_CONFIG_PAGE;
            cartPageURL += '?id=';
            cartPageURL += quoteId;
            cartPageURL += '&';
            cartPageUrl += USE_ADVANCED_APPROVAL + '=true';

            
            pageRef.getParameters().put(PARAM_RETURNID, quoteId);
            // return to cart
            //pageRef.getParameters().put(PARAM_RETURNPAGE, cartPageUrl);
            
        } else {
            if (actionTaken == ACTION_CANCEL) {
                // reset cart status to approval required
                cartSO.Apttus_Config2__Status__c = STATUS_APPROVAL_REQUIRED;
                update cartSO;
            }

            // force back to cart for testing
            //fromQuote = false;
            if (! nullOrEmpty(returnPage)) {
                // return page provided, use it
                pageRef = new PageReference(getPageUrl(returnPage));
                
            } else if (fromQuote) {
                // return to quote
                pageRef = new PageReference(getPageUrlForObjectId(quoteId));
            
            } else {                          
                // return to cart
                pageRef = new PageReference(getPageUrl(QUOTE_CONFIG_PAGE));
                pageRef.getParameters().put('id', quoteId);
                pageRef.getParameters().put(USE_ADVANCED_APPROVAL, 'true');

            }
        }

        // redirect to the target page
        if (getInSf1Mode()) {
            // mark the page as loaded
            pageLoaded = true;
            
            // stay on same page so we can use sforce1 redirection in the visualforce page
            pageURL = pageRef.getURL();
            return null;
            
        } else {
            // navigate to the new page
            pageRef.setRedirect(true);
            return pageRef;
            
        }

    }
    
     /**
     * Checks if the given string value is null or empty.
     * @param strValue the string to check
     * @return <code>true</code> if the string value is null or empty, <code>false</code> otherwise
     */
    private Boolean nullOrEmpty(String strValue) {
        // check if null or zero length string
        return (strValue == null || strValue.trim().length() == 0);
        
    }
    
    /**
     * Checks if the given list of objects is null or empty.
     * @param objList the list of objects to check
     * @return <code>true</code> if the list is null or empty, <code>false</code> otherwise
     */
    private Boolean nullOrEmpty(List<Object> objList) {
        // check if null or empty
        return (objList == null || objList.isEmpty());
        
    }
    
    /**
     * Gets proposal name for the give quote/proposal identifier
     * @param quoteId quote/proposal identifier
     * @return proposal name
     */
    private String getQuoteName(ID quoteId) {
        
        List<Apttus_Proposal__Proposal__c> quoteList = [select Id, Name, Apttus_Proposal__Proposal_Name__c
                                                        from Apttus_Proposal__Proposal__c
                                                        where Id = :quoteId
                                                        limit 1];
        if ( ! nullOrEmpty(quoteList)) {
            return quoteList[0].Apttus_Proposal__Proposal_Name__c;
        }
        return null;
    }
    
    /**
     * Gets the page url for the given page
     * @param pageName the name of the page
     * @return the page url 
     */
    @TestVisible private String getPageUrl(String pageName) {
        
        // instance url
        String instanceUrl = getInstanceUrl();
        // build the custom page url
        String pageURL = (instanceUrl != null ? instanceUrl : '');
        // check if force.com domain    
        if (!isCommunitiesUser(UserInfo.getUserType())
            || isPortalUser(UserInfo.getUserType())) {
            // not a communities user or a portal user, add apex
            pageURL += '/apex';
            
        } 
        
        // page name
        pageURL += '/' + pageName;
        
        return pageURL;
        
    }
    
    /**
     * Gets the page url for the given object id
     * @param objectId the id of the object to navigate to
     * @return the page url 
     */
    @TestVisible private String getPageUrlForObjectId(ID objectId) {
        
        // instance url
        String instanceUrl = getInstanceUrl();
        // build the custom page url
        String pageURL = (instanceUrl != null ? instanceUrl : '');
        
        // page name
        pageURL += '/' + objectId;
        
        return pageURL;
        
    }
    
     /**
     * Gets the instance url
     * @return the instance url 
     */
    private String getInstanceUrl() {
        
        // check the user type
        if (isCommunitiesUser(UserInfo.getUserType()) &&
            !nullOrEmpty(Site.getBaseUrl())) {    
                
            String siteUrl = Site.getBaseUrl();
            
            if (siteUrl.endsWith('/')) {
                siteUrl = siteUrl.substring(0, siteUrl.length()-1);
                
            }
            
            return siteUrl;
            
        } 
        
        // get the system property dataset
        Apttus_Approval__ApprovalsSystemProperties__c prop = getSystemProperties();
                                
        return (prop != null && !nullOrEmpty(prop.Apttus_Approval__InstanceUrl__c) 
                ? prop.Apttus_Approval__InstanceUrl__c 
                : null);
                
    }
    
     /**
     * Checks if the given user indicates a communities user
     * @return <code>true</code> if communities user, <code>false</code> otherwise 
     */
    private Boolean isCommunitiesUser(String userType) {
        return (USERTYPE_PARTNER == userType ||
                USERTYPE_CUSTOMERPORTAL_MANAGER == userType ||
                USERTYPE_HIGHVOLUMEPORTAL == userType ||
                USERTYPE_CUSTOMERPORTAL_USER == userType );
                
    }
    
    /**
     * Checks if the given user indicates a portal user
     * @return <code>true</code> if portal user, <code>false</code> otherwise 
     */
    private Boolean isPortalUser(String userType) {
        return (isCommunitiesUser(userType) && nullOrEmpty(Site.getBaseUrl()))
                ? true
                : false;
                
    }
    
    /**
     * Gets the system properties sobject
     * @return the system properties sobject
     */
    private Apttus_Approval__ApprovalsSystemProperties__c getSystemProperties() {
        return Apttus_Approval__ApprovalsSystemProperties__c.getInstance(PROP_SYSTEM_PROPERTIES);
        
    }
    //[SK]08/03/2015
    /***************************************************************************************************************************************
     * Method Name:redirectToCart
     * Description:This will redirect the control back to Cart Detail page.
     * Return Type: Pagereference.
     ***************************************************************************************************************************************/
    public Pagereference redirectToCart(){
        PageReference cartDetailPage = System.Page.Apttus_Config2__CartDetailView;
        cartDetailPage.getParameters().put('Id', productConfigId);
        cartDetailPage.getParameters().put('configRequestId', configsRequestId);
        return cartDetailPage;
    }

}