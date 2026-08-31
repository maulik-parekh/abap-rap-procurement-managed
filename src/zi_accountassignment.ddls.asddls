@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Account Assignment CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_AccountAssignment
  as select from zpr_account
  association to parent ZI_ProcurementItem as _ProcurementItem  on  $projection.PRUUID   = _ProcurementItem.PRUUID
                                                                and $projection.ItemUUID = _ProcurementItem.ItemUUID
  association [1..1] to ZI_ProcurementHeader as _ProcurementHeader on $projection.PRUUID = _ProcurementHeader.PRUUID
  association [0..1] to ZI_CostCenterVH as _CostCenter          on  $projection.CostCenterID    = _CostCenter.CostCenterID
                                                                and $projection.ControllingArea = _CostCenter.ControllingArea
{
  key pr_uuid      as PRUUID,
    key item_uuid    as ItemUUID,
    key account_uuid as AccountUUID,

        cost_center_id  as CostCenterID,
        controlling_area as ControllingArea,
        percentage      as Percentage,

        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        local_last_changed_at as LocalLastChangedAt,

        _ProcurementItem,
        _ProcurementHeader,
        _CostCenter
}
