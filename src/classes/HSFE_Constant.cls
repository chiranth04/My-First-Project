/* Class Name : HSFE_Constant
*Description :  It contains all the global constant variables.
*Created By :   Sunil Kumar
*Created On :   03/10/2015
* Modification log:
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                           Modification Id                       Description
* Deloitte/Sunil              2/10/2015                     Created 
* Deloitte/Yunus              4/1/2015                      Modified v2      
* Deloitte/Chiranth           5/19/2015                     Modified                              Declared variables for event object
* Ajay Agnihotri             29/06/2015                     Modified                              Declared variables to Cover Static values used in Version Class.   
* Ajay Agnihotri             01/07/2015                     Modified                              Declared variables For Quote Stage.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public class HSFE_Constant {
    
    // Territory User's Role
    public static string AVP = 'AVP';
    public static string RVP = 'RSD/RVP';
    public static string SALESREP = 'Sales Rep';
    public static string TEAMLEAD = 'Team Lead';
    public static string VP = 'VP';
    public static string TM = 'EAM/TM';
    public static string INSIDESALES = 'Inside Sales';
    public static string DVP = 'VP';
    public static string GVP = 'GVP';
    //Lead Speciality
    public static string SURGICAL = 'Surgical';
    public static string MEDICAL = 'Medical';
    
    //Group Name
    public static string QUEUENAME = 'Inside Sales Team';  
    
    //Contact 
    public static string YES = 'Yes';
    public static string NO = 'No';
    
    //Event
    public static String EVENT_MEETING='Meeting';
    public static String ON_PATIENT_EVALUATION='On Patient Evaluation';
    public static String DEMONSTRATION='Demonstration';
    public static String INSERVICE='InService';
    public static String ADMIN='Administrative';
    public static String Elton_Order_RecordType='HSFE_Event_Elton_Order';
    
    
    //Custom Pricing
    public static string LINE_TYPE_PRODUCT_SERVICE = 'Product/Service';
    public static string CHARGE_TYPE_KIT_OP = 'Charge Type Kit Op';
    public static string NA_STOCKING_KIT = 'Same as kit';
    public static string COUSTOM_NEW = 'New';
    public static string COUSTOM_TRADE_COMPETITOR = 'Trade-In - Competitor';
    public static string COUSTOM_TRADE_OLYMPUS = 'Trade-In - Olympus';
    public static string COUSTOM_USED = 'Used';
    public static string COUSTOM_RECOMMENDED = 'Recommended Products';
    public static string COUSTOM_OPTIONAL = 'Optional Accessories';
    public static string COUSTOM_MANDATORY = 'Mandatory Accessories';
    public static string COUSTOM_FREE_GOODS = 'Free Goods';
    public static string COUSTOM_ACCESSORY = 'Accessory';
    public static string COUSTOM_CHEMICAL = 'Chemical';
    public static string COUSTOM_CAPITAL = 'Capital';
    public static string COUSTOM_NOT_APPLICABLE = 'Not Applicable';
    public static string COUSTOM_SERVICE = 'Service/RepairCharge';
    public static string COUSTOM_SKP = 'SKP';
    public static string COUSTOM_PKP = 'PKP';
    public static string COUSTOM_TRADE_COMPETITOR_PRICE = 'Trade-In - Competitor';
    public static set<string> CUSTOM_PRICELISTITEM_QUERYSET = new set<string>{'New','Trade-In - Competitor'};    
    
    public static set<string> CUSTOM_SKIP_ADJUSTMENT = new set<string>{'Trade-In - Competitor','Trade-In - Olympus','Used'};
    public static set<String> CUSTOM_CATEGORYLABEL = new Set<String>{'Capital','Disposable','Accessory', 'Services','Promotion','Competitive Trade-Ins','Chemical'};
    // Inactive Account Name
    public static string ACCOUNTNAME = 'Inactive Contacts';

    //Opportunity Details
    public static string CUSTOM_ClOSED_WON = 'Closed Won';  
    public static string CUSTOM_ClOSED_LOST = 'Closed Lost';  
    public static string CUSTOM_VERBALLY_ACCEPTED = 'Verbally Accepted';  
    
    // Quote Details
    public static string CUSTOM_QUOTE_ACCEPTED = 'Accepted';  
    public static string CUSTOM_QUOTE_VERBALLY_ACCEPTED='Verbally Accepted';
    public static string CUSTOM_DEFAULT_PRICELIST = 'Olympus_MSG_NA';
    public static string CUSTOM_QUOTE_ORDER_STATUS_COMPLETED = 'Completed';  
    public static string CUSTOM_QUOTE_ORDER_STATUS_CREATED = 'Created';  
    
    //Opprtunity Sales Stage for Reminder
    public static set<String> OPPTY_REMINDER_STAGE_SET = new set<String>{'Verbally Accepted','Closed Won','Closed Lost'};    
    public static integer NUMBER_OF_DAYS = 4;
    
    //Lead immport default contact name functionality
    public static string LEAD_TBD_NAME = 'TBD';
    
    //Lotus Event Type Meeting
    public static string MEETING = 'Meeting';
    public static Id MULE_INTEGRATION_USER = '00511000002Ol7f';
    public static string LOTUS_NOTES_ENDPOINT = 'http://12.189.73.247:8888/esb/sfdc/updateSFDCEventInNotes?Id=';
    
    //Integration Status Constants
    public static String EMPTY_STRING = '';
    public static String ERROR = 'Error';
    public static String NOT_SYNCED = 'Not Synched';
    public static String SENT_TO_SAP = 'Sent to SAP';
    public static String SYNCED = 'Synched';
    public static String CONFIRMED = 'Confirmed';
    public static String NOT_INITIATED = 'Not Initiated';
    public static String IN_PROCESS = 'In Process';
    public static String FAILED = 'Failed';
    public static String SUBMITTED = 'Submitted';
    
    //Integration Interface Name Constants
    public static String CONTRACT_PRICING = 'Contract_Pricing';
    public static String FREIGHT_CHARGES = 'Freight_Charges';
    public static String LOTUS_NOTES = 'Lotus_Notes';
    public static String QUOTE_TO_ORDER = 'Quote_to_Order';
    public static String CONTRACT_PRICING_SYNC = 'Contract_Pricing_Synchronous';
    public static String SERIAL_NUM_CHECK='Serial_Number';
    
    public static String LINE_ITEM_OBJECT_API_NAME = 'Apttus_Config2__LineItem__c';
    public static String LINE_ITEM_EXTENSION_OBJECT_API_NAME = 'HSFE_Line_Item_Extension__c';
    public static String EVENT_OBJECT_API_NAME = 'Event'; 
    public static String QUOTE_PROPOSAL_OBJECT_API_NAME = 'Apttus_Proposal__Proposal__c';
    public static String NOT_IN_SAP = 'Not in SAP';
    public static Integer STATUS_CODE_SUCCESS = 200;

    //Error Meassage
    public static String SUCCESS = 'Success';
    public static String ERRORATTACH = 'ErrorAttachment';
    public static String ERRORMAIL ='ErrorMail';
    public static String ERRORUPDATE = 'ErrorUpdate';
    public static String RESPONSEERROR = 'Error';
    
    //Summary Group Name Constants
    public static String GRAND_TOTAL = 'Grand Total';
    public static String PRICE_OVERRIDE = 'Price Override';
    public static set<String> PRODUCT_CLASSFICATION_LABELS = new set<String>{'Capital','Disposal'}; 
    
    //Adjustment Type
    public static String PERDISCOUNT ='Percntg Dis';
    public static String DISAMOUNT ='Discount Amount';
    public static String PRICEOVERRIDE  ='Price Override';

    //Matric Calculation
    Public Static String CUSTOM_SEPRTOR = '-----';

    //Line Item
    public static Set <string> stringContractCodes = new Set<string>{'VA1','VA2'};
    
    //Account SAP Status
    public static String IN_PROGRESS = 'In Progress';
    
    //Elton Order Type
    public static String Order_Type_Evaluation='Evaluation';
     public static String Order_Type_Demonstration='Demonstration';
   
    // Proposal Field Constants Used in Version Clone Logic
    public static String Print_Message='Thank you';
    public static String SAP_Shipping_Condition_SD='Second Day';
    
    // Proposal Approval Stages
    public static String ProposalApproval_Stage_IR='In Review';
    public static String ProposalApproval_Stage_AR='Approval Required';
    public static String ProposalApproval_Stage_DR='Draft';
    
    // Product Config Status
    public static String ProductConfiguration_Status_RFF='Ready For Finalization';
    public static String ProductConfiguration_Status_SA='Saved';
    
    // Product Config Preview Status
    public static String ProductConfiguration_PreviewStatus_PE='Pending';
    
    // Product Config Approval Status
    public static String ProductConfiguration_ApprovalStatus_AR='Approval Required';
    
    //Quote Status Values
    public static String Proposal_ApprovalStage_AP='Approved';
    public static String Proposal_ApprovalStage_IR='In Review';

}