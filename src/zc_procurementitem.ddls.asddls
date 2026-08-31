@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Procurement Item Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZC_ProcurementItem
  as projection on ZI_ProcurementItem
{
    key PRUUID,
    key ItemUUID,

    ItemNumber,
    MaterialID,
    Plant,

    @Semantics.quantity.unitOfMeasure: 'Uom'
    Quantity,

    Uom,

    @Semantics.amount.currencyCode: 'CurrencyCode'
    ItemAmount,

    CurrencyCode,
    RequiredDeliveryDate,
    LocalLastChangedAt,
    
      /* Associations */
    _ProcurementHeader: redirected to parent ZC_ProcurementHeader,
    _AccountAssignment : redirected to composition child ZC_AccountAssignment,
    _Material
}
