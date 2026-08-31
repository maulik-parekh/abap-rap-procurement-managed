@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Search Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_SupplierVH
  as select from zsupplier_master
{
      @Search.defaultSearchElement: true
  key supplier_id   as SupplierID,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      supplier_name as SupplierName,
      country       as Country,
      city          as City,
      rating        as Rating,
      is_active     as IsActive
}
where is_active = 'X';
