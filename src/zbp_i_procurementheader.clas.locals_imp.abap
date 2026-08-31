" ====================================================================
" 1. HEADER LEVEL BEHAVIOR IMPLEMENTATION (lhc_Header)
" ====================================================================
CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features
      FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Header
      RESULT result.

    METHODS get_instance_authorizations
      FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header
      RESULT result.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Header
      RESULT result.

    METHODS ApproveRequisition
      FOR MODIFY
      IMPORTING keys FOR ACTION Header~ApproveRequisition
      RESULT result.

    METHODS DuplicateRequisition
      FOR MODIFY
      IMPORTING keys FOR ACTION Header~DuplicateRequisition.

    METHODS ReassignSupplier
      FOR MODIFY
      IMPORTING keys FOR ACTION Header~ReassignSupplier
      RESULT result.

    METHODS RejectRequisition
      FOR MODIFY
      IMPORTING keys FOR ACTION Header~RejectRequisition
      RESULT result.

    METHODS setDefaultStatus
      FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Header~setDefaultStatus.

    METHODS calculateTotalAmount
      FOR DETERMINE ON SAVE
      IMPORTING keys FOR Header~calculateTotalAmount.

    METHODS validateSupplier
      FOR VALIDATE ON SAVE
      IMPORTING keys FOR Header~validateSupplier.

ENDCLASS.


CLASS lhc_header IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( RequisitionStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    result = VALUE #(
      FOR ls_header IN lt_header
      (
        %tky = ls_header-%tky

        %action-ApproveRequisition =
          COND #(
            WHEN ls_header-RequisitionStatus = 'A'
              OR ls_header-RequisitionStatus = 'R'
            THEN if_abap_behv=>fc-o-disabled
            ELSE if_abap_behv=>fc-o-enabled )

        %action-RejectRequisition =
          COND #(
            WHEN ls_header-RequisitionStatus = 'A'
              OR ls_header-RequisitionStatus = 'R'
            THEN if_abap_behv=>fc-o-disabled
            ELSE if_abap_behv=>fc-o-enabled )

        %action-ReassignSupplier =
          COND #(
            WHEN ls_header-RequisitionStatus = 'A'
              OR ls_header-RequisitionStatus = 'R'
            THEN if_abap_behv=>fc-o-disabled
            ELSE if_abap_behv=>fc-o-enabled )
      )
    ).

  ENDMETHOD.


  METHOD get_instance_authorizations.
    result = VALUE #(
      FOR ls_key IN keys
      (
        %tky = ls_key-%tky
        %action-ApproveRequisition = if_abap_behv=>auth-allowed
        %action-RejectRequisition  = if_abap_behv=>auth-allowed
        %action-ReassignSupplier   = if_abap_behv=>auth-allowed
      )
    ).
  ENDMETHOD.


  METHOD get_global_authorizations.
    result = VALUE #( %create = if_abap_behv=>auth-allowed ).
  ENDMETHOD.


  METHOD setDefaultStatus.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( RequisitionStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).
      IF <header>-RequisitionStatus IS INITIAL.
        APPEND VALUE #(
          %tky = <header>-%tky
          RequisitionStatus = 'N'
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header
        UPDATE FIELDS ( RequisitionStatus )
        WITH lt_update.
    ENDIF.

  ENDMETHOD.


  METHOD calculateTotalAmount.

    DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header BY \_ProcurementItem
      FIELDS ( ItemAmount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DATA lv_total TYPE zpr_header-total_amount.
      CLEAR lv_total.

      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<item>).
        IF <item>-pruuid = <key>-pruuid.
          lv_total = lv_total + <item>-ItemAmount.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #(
        %tky        = <key>-%tky
        TotalAmount = lv_total
      ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header
        UPDATE FIELDS ( TotalAmount )
        WITH lt_update.
    ENDIF.

  ENDMETHOD.


  METHOD validateSupplier.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( SupplierID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).

      IF <header>-SupplierID IS INITIAL.
        APPEND VALUE #(
          %tky = <header>-%tky
          %element-supplierid = if_abap_behv=>mk-on
          %msg = new_message(
            id       = 'ZPR'
            number   = '001'
            severity = if_abap_behv_message=>severity-error
            v1       = 'Supplier is mandatory'
          )
        ) TO reported-header.
        APPEND VALUE #( %tky = <header>-%tky ) TO failed-header.
        CONTINUE.
      ENDIF.

      SELECT SINGLE FROM zsupplier_master
        FIELDS supplier_id, is_active
        WHERE supplier_id = @<header>-SupplierID
        INTO @DATA(ls_supplier).

      IF sy-subrc <> 0.
        APPEND VALUE #(
          %tky = <header>-%tky
          %element-supplierid = if_abap_behv=>mk-on
          %msg = new_message(
            id       = 'ZPR'
            number   = '005'
            severity = if_abap_behv_message=>severity-error
            v1       = <header>-SupplierID
          )
        ) TO reported-header.
        APPEND VALUE #( %tky = <header>-%tky ) TO failed-header.

      ELSEIF ls_supplier-is_active <> 'X'.
        APPEND VALUE #(
          %tky = <header>-%tky
          %element-supplierid = if_abap_behv=>mk-on
          %msg = new_message(
            id       = 'ZPR'
            number   = '002'
            severity = if_abap_behv_message=>severity-error
            v1       = <header>-SupplierID
          )
        ) TO reported-header.
        APPEND VALUE #( %tky = <header>-%tky ) TO failed-header.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD ApproveRequisition.

    DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( RequisitionStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).

      IF <header>-RequisitionStatus = 'A'
         OR <header>-RequisitionStatus = 'R'.

        APPEND VALUE #(
          %tky = <header>-%tky
          %msg = new_message(
            id       = 'ZPR'
            number   = '003'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-header.

        APPEND VALUE #( %tky = <header>-%tky ) TO failed-header.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = <header>-%tky
        RequisitionStatus = 'A'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header
        UPDATE FIELDS ( RequisitionStatus )
        WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).

    result = VALUE #( FOR ls_updated IN lt_updated ( %tky = ls_updated-%tky %param = ls_updated ) ).

  ENDMETHOD.


  METHOD RejectRequisition.

    DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( RequisitionStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).

      IF <header>-RequisitionStatus = 'A'
         OR <header>-RequisitionStatus = 'R'.

        APPEND VALUE #(
          %tky = <header>-%tky
          %msg = new_message(
            id       = 'ZPR'
            number   = '004'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-header.

        APPEND VALUE #( %tky = <header>-%tky ) TO failed-header.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = <header>-%tky
        RequisitionStatus = 'R'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header
        UPDATE FIELDS ( RequisitionStatus )
        WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).

    result = VALUE #( FOR ls_updated IN lt_updated ( %tky = ls_updated-%tky %param = ls_updated ) ).

  ENDMETHOD.


  METHOD ReassignSupplier.

    DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( RequisitionStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      DATA(ls_header) = VALUE #( lt_header[ %tky = <key>-%tky ] OPTIONAL ).
      IF ls_header IS INITIAL. CONTINUE. ENDIF.

      IF ls_header-RequisitionStatus = 'A' OR ls_header-RequisitionStatus = 'R'.
        APPEND VALUE #(
          %tky = <key>-%tky
          %msg = new_message( id = 'ZPR' number = '004' severity = if_abap_behv_message=>severity-error )
        ) TO reported-header.
        APPEND VALUE #( %tky = <key>-%tky ) TO failed-header.
        CONTINUE.
      ENDIF.

      DATA(lv_supplier) = <key>-%param-NewSupplierID.

      IF lv_supplier IS INITIAL.
        APPEND VALUE #(
          %tky = <key>-%tky
          %msg = new_message(
            id       = 'ZPR'
            number   = '001'
            severity = if_abap_behv_message=>severity-error
            v1       = 'Supplier is mandatory'
          )
        ) TO reported-header.
        APPEND VALUE #( %tky = <key>-%tky ) TO failed-header.
        CONTINUE.
      ENDIF.

      SELECT SINGLE FROM zsupplier_master
        FIELDS supplier_id, is_active
        WHERE supplier_id = @lv_supplier
        INTO @DATA(ls_supplier_chk).

      IF sy-subrc <> 0.
        APPEND VALUE #(
          %tky = <key>-%tky
          %msg = new_message(
            id       = 'ZPR'
            number   = '005'
            severity = if_abap_behv_message=>severity-error
            v1       = lv_supplier
          )
        ) TO reported-header.
        APPEND VALUE #( %tky = <key>-%tky ) TO failed-header.
        CONTINUE.
      ENDIF.

      IF ls_supplier_chk-is_active <> 'X'.
        APPEND VALUE #(
          %tky = <key>-%tky
          %msg = new_message(
            id       = 'ZPR'
            number   = '002'
            severity = if_abap_behv_message=>severity-error
            v1       = lv_supplier
          )
        ) TO reported-header.
        APPEND VALUE #( %tky = <key>-%tky ) TO failed-header.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = <key>-%tky SupplierID = lv_supplier ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header
        UPDATE FIELDS ( SupplierID )
        WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).

    result = VALUE #( FOR ls_updated IN lt_updated ( %tky = ls_updated-%tky %param = ls_updated ) ).

  ENDMETHOD.


  METHOD DuplicateRequisition.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    DATA lt_create TYPE TABLE FOR CREATE zi_procurementheader.

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).
      DATA(lv_tabix) = sy-tabix.

      READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_key_idx>) INDEX lv_tabix.
      IF sy-subrc <> 0. CONTINUE. ENDIF.

      APPEND VALUE #(
        %cid              = <ls_key_idx>-%cid
        Description       = |Copy of { <header>-Description }|
        SupplierID        = <header>-SupplierID
        CurrencyCode      = <header>-CurrencyCode
        RequisitionStatus = 'N'
      ) TO lt_create.
    ENDLOOP.

    IF lt_create IS INITIAL. RETURN. ENDIF.

    MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      CREATE FIELDS ( Description SupplierID CurrencyCode RequisitionStatus )
      WITH lt_create
      MAPPED mapped
      FAILED failed
      REPORTED reported.

  ENDMETHOD.

ENDCLASS.
