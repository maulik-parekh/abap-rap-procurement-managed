@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Procurement Header Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_ProcurementHeader
  provider contract transactional_query
  as projection on ZI_ProcurementHeader
{
    key PRUUID,

    @Search.defaultSearchElement: true
    PRNumber,

    Description,
    RequisitionStatus,
    StatusCriticality,
    SupplierID,

    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalAmount,

    CurrencyCode,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PR_VIRTUAL_ELEMENTS'
    virtual ApprovalRiskLevel : abap.char(10),

    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PR_VIRTUAL_ELEMENTS'
    virtual DaysUntilDelivery : abap.int4,

      /* Associations */
    _ProcurementItem : redirected to composition child ZC_ProcurementItem,

    _Supplier
}
