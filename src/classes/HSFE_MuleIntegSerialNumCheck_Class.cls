/*Class Name :HSFE_MuleIntegSerialNumCheck_Class 
*Description :This class is used to store the request parameter for serial number check.
*Created By :Divya A N
*Created On :08/05/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class HSFE_MuleIntegSerialNumCheck_Class {

    //public class innerInterface{
        public String interfaceName;
        public String SAPId;
        public List<LineItem> lineItemList;
    //}
    public Class LineItem {
        public String lineItemId;
        public String productNumber;
        public String serialNumber;
    }
}