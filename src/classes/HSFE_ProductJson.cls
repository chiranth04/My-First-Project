/* 
* Class Name``: HSFE_ProductJson
* Description : JSON Class for Product Attribute
* Created By  : Yunus H Navalur
* Created On  : 02/24/2015
*
* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

public class HSFE_ProductJson {

    public boolean IsBatch;
    public boolean IsStocking;
    public ID Id;
    public String conditions;
    public boolean IsSerial;
    public String chargeType;
    public string ProductType;

    public HSFE_ProductJson(){
        
    }
    
    public HSFE_ProductJson(Product2 ProdRec){
        this.chargeType = ProdRec.HSFE_Charge_Type__c; 
        this.conditions = ProdRec.HSFE_Product_Conditions_Multi__c; 
        this.Id = ProdRec.Id;
        this.IsBatch = ProdRec.HSFE_Is_Batch__c;
        this.IsSerial = ProdRec.HSFE_Is_Serial__c;
        this.IsStocking = ProdRec.Is_Stocking_Kit__c;
        this.ProductType = ProdRec.HSFE_Product_Type__c;    
    }
    
     public static HSFE_ProductJson GetProductJsonRecord(String JSONString){
        return (HSFE_ProductJson) JSON.deserialize(JSONString, HSFE_ProductJson.class);
     }            
}