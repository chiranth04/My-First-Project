/* 
* Class Name  : HSFE_PriceMatxEntryJson 
* Description : JSON Class for Price Matrix Entry Attribute
* Created By  : Yunus H Navalur
* Created On  : 06/25/2015


* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date                            Description
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

public class HSFE_PriceMatxEntryJson{

    public String id;
    public Decimal TargetPrice;
    public String CombinationKey;
    public Decimal AdjustAmount;
    public String DimensionValue;

    public HSFE_PriceMatxEntryJson(){

    }

    public HSFE_PriceMatxEntryJson(Apttus_Config2__PriceMatrixEntry__c PriceMatxEntry){

        this.id = PriceMatxEntry.id;
        this.TargetPrice = PriceMatxEntry.HSFE_Target_Price__c;
        this.CombinationKey = PriceMatxEntry.HSFE_Combination_Key__c;
        this.AdjustAmount = PriceMatxEntry.Apttus_Config2__AdjustmentAmount__c;
        this.DimensionValue = PriceMatxEntry.Apttus_Config2__Dimension1Value__c;
    }
    
    public static HSFE_PriceMatxEntryJson GetProductJsonRecord(String JSONString){
        return (HSFE_PriceMatxEntryJson) JSON.deserialize(JSONString, HSFE_PriceMatxEntryJson.class);
    }   
}