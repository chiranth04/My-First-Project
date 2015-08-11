/* Class Name :HSFE_TerritoryManagement_TestClass
*Description :This is used to test the functionality for HSFE_TerritoryManagement_Class.
*Created By :Sunil  Kumar
*Created On :07/20/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
Deloitte/Sunil              07/20/2015                      Created
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class HSFE_TerritoryManagement_TestClass{ 
     static testmethod void test() {
         Test.startTest();
             HSFE_TerritoryManagement_Class terr = new HSFE_TerritoryManagement_Class();
             terr.runLeadBatchJob();
         Test.stopTest();
     }
}