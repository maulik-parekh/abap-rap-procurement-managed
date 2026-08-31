" ====================================================================
" ABAP UNIT TEST CLASS
" ====================================================================

CLASS ltc_procurementheader DEFINITION
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create_header
      FOR TESTING.

    METHODS test_approve_requisition
      FOR TESTING.

    METHODS test_reject_requisition
      FOR TESTING.

    METHODS test_duplicate_requisition
      FOR TESTING.

ENDCLASS.


CLASS ltc_procurementheader IMPLEMENTATION.


  METHOD test_create_header.

    DATA lt_create TYPE TABLE FOR CREATE zi_procurementheader.

    lt_create = VALUE #(
      (
        %cid              = 'CREATE1'
        Description       = 'ABAP Unit Test'
        RequisitionStatus = 'N'
      )
    ).

    MODIFY ENTITIES OF zi_procurementheader
      ENTITY Header
      CREATE FIELDS
      (
        Description
        RequisitionStatus
      )
      WITH lt_create
      MAPPED DATA(mapped_create)
      FAILED DATA(failed_create)
      REPORTED DATA(reported_create).

    cl_abap_unit_assert=>assert_initial(
      act = failed_create
    ).

    cl_abap_unit_assert=>assert_not_initial(
      act = mapped_create-header
    ).

  ENDMETHOD.


  METHOD test_approve_requisition.

    DATA lt_create TYPE TABLE FOR CREATE zi_procurementheader.

    lt_create = VALUE #(
      (
        %cid              = 'APPROVE1'
        Description       = 'Approve Test'
        RequisitionStatus = 'N'
      )
    ).

    MODIFY ENTITIES OF zi_procurementheader
      ENTITY Header
      CREATE FIELDS
      (
        Description
        RequisitionStatus
      )
      WITH lt_create
      MAPPED DATA(mapped_create)
      FAILED DATA(failed_create)
      REPORTED DATA(reported_create).

    cl_abap_unit_assert=>assert_initial(
      act = failed_create
    ).

    DATA lt_action
      TYPE TABLE FOR ACTION IMPORT zi_procurementheader~ApproveRequisition.

    lt_action = VALUE #(
      (
        %tky = mapped_create-header[ 1 ]-%tky
      )
    ).

    MODIFY ENTITIES OF zi_procurementheader
      ENTITY Header
      EXECUTE ApproveRequisition
      FROM lt_action
      RESULT DATA(result)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    cl_abap_unit_assert=>assert_initial(
      act = failed
    ).

    cl_abap_unit_assert=>assert_not_initial(
      act = result
    ).

    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-%param-RequisitionStatus
      exp = 'A'
    ).

  ENDMETHOD.


  METHOD test_reject_requisition.

    DATA lt_create TYPE TABLE FOR CREATE zi_procurementheader.

    lt_create = VALUE #(
      (
        %cid              = 'REJECT1'
        Description       = 'Reject Test'
        RequisitionStatus = 'N'
      )
    ).

    MODIFY ENTITIES OF zi_procurementheader
      ENTITY Header
      CREATE FIELDS
      (
        Description
        RequisitionStatus
      )
      WITH lt_create
      MAPPED DATA(mapped_create)
      FAILED DATA(failed_create)
      REPORTED DATA(reported_create).

    cl_abap_unit_assert=>assert_initial(
      act = failed_create
    ).

    DATA lt_action
      TYPE TABLE FOR ACTION IMPORT zi_procurementheader~RejectRequisition.

    lt_action = VALUE #(
      (
        %tky = mapped_create-header[ 1 ]-%tky
      )
    ).

    MODIFY ENTITIES OF zi_procurementheader
      ENTITY Header
      EXECUTE RejectRequisition
      FROM lt_action
      RESULT DATA(result)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    cl_abap_unit_assert=>assert_initial(
      act = failed
    ).

    cl_abap_unit_assert=>assert_not_initial(
      act = result
    ).

    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-%param-RequisitionStatus
      exp = 'R'
    ).

  ENDMETHOD.


  METHOD test_duplicate_requisition.

    DATA lt_create TYPE TABLE FOR CREATE zi_procurementheader.

    lt_create = VALUE #(
      (
        %cid              = 'ORIGINAL1'
        Description       = 'Original Requisition'
        SupplierID        = 'SUP001'
        CurrencyCode      = 'INR'
        RequisitionStatus = 'N'
      )
    ).

    MODIFY ENTITIES OF zi_procurementheader
      ENTITY Header
      CREATE FIELDS
      (
        Description
        SupplierID
        CurrencyCode
        RequisitionStatus
      )
      WITH lt_create
      MAPPED DATA(mapped_create)
      FAILED DATA(failed_create)
      REPORTED DATA(reported_create).

    cl_abap_unit_assert=>assert_initial(
      act = failed_create
    ).

    DATA lt_action
      TYPE TABLE FOR ACTION IMPORT zi_procurementheader~DuplicateRequisition.

    lt_action = VALUE #(
      (
        %tky = mapped_create-header[ 1 ]-%tky
        %cid = 'DUPLICATE1'
      )
    ).

    MODIFY ENTITIES OF zi_procurementheader
      ENTITY Header
      EXECUTE DuplicateRequisition
      FROM lt_action
      MAPPED DATA(mapped_duplicate)
      FAILED DATA(failed_duplicate)
      REPORTED DATA(reported_duplicate).

    cl_abap_unit_assert=>assert_initial(
      act = failed_duplicate
    ).

    cl_abap_unit_assert=>assert_not_initial(
      act = mapped_duplicate-header
    ).

  ENDMETHOD.


ENDCLASS.
