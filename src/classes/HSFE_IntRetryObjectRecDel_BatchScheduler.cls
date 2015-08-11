public class HSFE_IntRetryObjectRecDel_BatchScheduler implements Schedulable {
   public void execute(SchedulableContext sc) {
      HSFE_IntRetryObjRecordsDelete_BatchClass  batchClass = new HSFE_IntRetryObjRecordsDelete_BatchClass (); 
      database.executebatch(batchClass);
   }
}