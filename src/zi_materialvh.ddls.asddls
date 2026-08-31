@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Search Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_MaterialVH
  as select from zmaterial_master
{
      @Search.defaultSearchElement: true
  key material_id    as MaterialID,
      @Search.defaultSearchElement: true
      description    as Description,
      material_group as MaterialGroup,
      base_uom       as BaseUom,
      @Semantics.amount.currencyCode: 'Currency'
      unit_price     as UnitPrice,
      currency       as Currency
};
