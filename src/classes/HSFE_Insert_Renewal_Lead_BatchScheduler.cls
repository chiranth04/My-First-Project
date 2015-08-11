/* Class Name :HSFE_Insert_Renewal_Lead_BatchScheduler 
*Description :This class is used to schedule the HSFE_Insert_Renewal_Lead_Batch class 
*Created By :Chiranth Aradhya
*Created On :06/09/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public class HSFE_Insert_Renewal_Lead_BatchScheduler implements Schedulable {
   public void execute(SchedulableContext sc) {
      HSFE_Insert_Renewal_Lead_BatchClass batchClass = new HSFE_Insert_Renewal_Lead_BatchClass (); 
      database.executebatch(batchClass);
   }
}