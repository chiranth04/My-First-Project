global class SchedulableEquipmentToProductLinkClass implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchEquipmentToProductsLink  batchClass = new batchEquipmentToProductsLink (); 
      database.executebatch(batchClass);
   }
}