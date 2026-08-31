@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Procurement Line Item CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ProcurementItem
  as select from zpr_item
  association to parent ZI_ProcurementHeader as _ProcurementHeader  on $projection.PRUUID = _ProcurementHeader.PRUUID
  composition [0..*] of ZI_AccountAssignment as _AccountAssignment 
  association [0..1] to ZI_MaterialVH as _Material                  on $projection.MaterialID = _Material.MaterialID
{
    key pr_uuid   as PRUUID,
    key item_uuid as ItemUUID,

        item_number as ItemNumber,
        material_id as MaterialID,
        plant as Plant,

        @Semantics.quantity.unitOfMeasure: 'Uom'
        quantity as Quantity,

        uom as Uom,

        @Semantics.amount.currencyCode: 'CurrencyCode'
        item_amount as ItemAmount,

        currency_code as CurrencyCode,

        required_delivery_date as RequiredDeliveryDate,

        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        local_last_changed_at as LocalLastChangedAt,

        _ProcurementHeader,
        _AccountAssignment,
        _Material
}
