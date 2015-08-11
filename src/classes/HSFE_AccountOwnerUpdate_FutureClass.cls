/* Class Name :HSFE_AccountOwnerUpdate_FutureClass 
*Description :This is a future method used to update the account owner
*Created By :Sunil Kumar
*Created On :04/27/2015

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
public class HSFE_AccountOwnerUpdate_FutureClass {
    @future
    public static void updateAccountOwner(Set<ID> accountList, String userid){
        try{
            
            List<Account> accUpdateList = new List<Account>();          
            for(Account a : [select id,ownerid from account where id IN:accountList]){
                a.OwnerId = userid;
                accUpdateList.add(a);
            }
            
            update accUpdateList; // update owner 
        }catch(Exception e){
           HSFE_ExceptionLogger.createExceptionLog(e);// Create a log file for an exception.
        }       
        
    }
}