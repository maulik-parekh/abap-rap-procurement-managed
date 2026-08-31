@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Account Assignment Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZC_AccountAssignment
  as projection on ZI_AccountAssignment
{
    key PRUUID,
    key ItemUUID,
    key AccountUUID,

    CostCenterID,
    ControllingArea,
    Percentage,

    LocalLastChangedAt,

    _ProcurementItem : redirected to parent ZC_ProcurementItem,
    _ProcurementHeader : redirected to ZC_ProcurementHeader,
    _CostCenter
}
