@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Center Search Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_CostCenterVH
  as select from zcost_center_m
{
      @Search.defaultSearchElement: true
  key cost_center_id   as CostCenterID,
  key controlling_area as ControllingArea,
      @Search.defaultSearchElement: true
      description      as Description,
      manager_name     as ManagerName
};
