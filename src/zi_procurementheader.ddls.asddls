@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Procurement Header CDS View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ProcurementHeader
  as select from zpr_header
  composition [0..*] of ZI_ProcurementItem as _ProcurementItem
  association [0..1] to ZI_SupplierVH      as _Supplier on $projection.SupplierID = _Supplier.SupplierID
{
  key pr_uuid               as PRUUID,
      pr_number             as PRNumber,
      description           as Description,
      requisition_status    as RequisitionStatus,
      
      case requisition_status
        when 'A' then 3   // Green (Checkmark Icon)
        when 'R' then 1   // Red (Error Cross Icon)
        else 2            // Yellow/Orange (Warning Triangle Icon)
      end                   as StatusCriticality,
      
      supplier_id           as SupplierID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_amount          as TotalAmount,
      currency_code         as CurrencyCode,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _ProcurementItem,
      _Supplier
}
