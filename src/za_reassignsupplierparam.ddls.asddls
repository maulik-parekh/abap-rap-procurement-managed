@EndUserText.label: 'Supplier Reassignment Parameters'
define abstract entity ZA_ReassignSupplierParam
{
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_SupplierVH', element: 'SupplierID' } }]
  NewSupplierID : abap.char(10);
  ReasonCode    : abap.char(4);
}
