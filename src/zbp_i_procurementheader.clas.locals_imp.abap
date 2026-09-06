"======================================================================
" Local Types
"======================================================================

CLASS lhc_header DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features
      FOR INSTANCE FEATURES
      IMPORTING
        keys REQUEST requested_features
      FOR Header
      RESULT result.

    METHODS get_instance_authorizations
      FOR INSTANCE AUTHORIZATION
      IMPORTING
        keys REQUEST requested_authorizations
      FOR Header
      RESULT result.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING
        REQUEST requested_authorizations
      FOR Header
      RESULT result.

    METHODS ApproveRequisition
      FOR MODIFY
      IMPORTING
        keys FOR ACTION Header~ApproveRequisition
      RESULT result.

    METHODS RejectRequisition
      FOR MODIFY
      IMPORTING
        keys FOR ACTION Header~RejectRequisition
      RESULT result.

    METHODS ReassignSupplier
      FOR MODIFY
      IMPORTING
        keys FOR ACTION Header~ReassignSupplier
      RESULT result.

    METHODS DuplicateRequisition
      FOR MODIFY
      IMPORTING
        keys FOR ACTION Header~DuplicateRequisition.

    METHODS setDefaultStatus
      FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR Header~setDefaultStatus.

    METHODS validateSupplier
      FOR VALIDATE ON SAVE
      IMPORTING
        keys FOR Header~validateSupplier.
    METHODS setDefaultPRNumber FOR DETERMINE ON MODIFY
      keys FOR Header~setDefaultPRNumber.

ENDCLASS.


CLASS lhc_item DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateHeaderTotal
      FOR DETERMINE ON SAVE
      IMPORTING
        keys FOR Item~calculateHeaderTotal.

    METHODS validateRequiredDeliveryDate
      FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateRequiredDeliveryDate.

    METHODS setDefaultItemNumber
      FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR Item~setDefaultItemNumber.

ENDCLASS.


"======================================================================
" Header Handler Implementation
"======================================================================

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

        %action-ApproveRequisition =
          if_abap_behv=>auth-allowed

        %action-RejectRequisition =
          if_abap_behv=>auth-allowed

        %action-ReassignSupplier =
          if_abap_behv=>auth-allowed
      )
    ).

  ENDMETHOD.


  METHOD get_global_authorizations.

    result = VALUE #(
      %create = if_abap_behv=>auth-allowed
    ).

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


  METHOD validateSupplier.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( SupplierID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).

      "------------------------------------------------------------
      " Supplier is mandatory
      "------------------------------------------------------------
      IF <header>-SupplierID IS INITIAL.

        APPEND VALUE #(
          %tky = <header>-%tky

          %element-SupplierID =
            if_abap_behv=>mk-on

          %msg = new_message(
            id       = 'ZPR'
            number   = '001'
            severity = if_abap_behv_message=>severity-error
            v1       = 'Supplier is mandatory'
          )
        ) TO reported-header.

        APPEND VALUE #(
          %tky = <header>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Check supplier existence and active status
      "------------------------------------------------------------
      SELECT SINGLE
        FROM zsupplier_master
        FIELDS
          supplier_id,
          is_active
        WHERE supplier_id = @<header>-SupplierID
        INTO @DATA(ls_supplier).


      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = <header>-%tky

          %element-SupplierID =
            if_abap_behv=>mk-on

          %msg = new_message(
            id       = 'ZPR'
            number   = '005'
            severity = if_abap_behv_message=>severity-error
            v1       = <header>-SupplierID
          )
        ) TO reported-header.

        APPEND VALUE #(
          %tky = <header>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      IF ls_supplier-is_active <> 'X'.

        APPEND VALUE #(
          %tky = <header>-%tky

          %element-SupplierID =
            if_abap_behv=>mk-on

          %msg = new_message(
            id       = 'ZPR'
            number   = '002'
            severity = if_abap_behv_message=>severity-error
            v1       = <header>-SupplierID
          )
        ) TO reported-header.

        APPEND VALUE #(
          %tky = <header>-%tky
        ) TO failed-header.

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

      "------------------------------------------------------------
      " Already processed
      "------------------------------------------------------------
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

        APPEND VALUE #(
          %tky = <header>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Approve
      "------------------------------------------------------------
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


    "--------------------------------------------------------------
    " Return updated entity
    "--------------------------------------------------------------
    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).


    result = VALUE #(
      FOR ls_updated IN lt_updated
      (
        %tky   = ls_updated-%tky
        %param = ls_updated
      )
    ).

  ENDMETHOD.


  METHOD RejectRequisition.

    DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( RequisitionStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).


    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).

      "------------------------------------------------------------
      " Already processed
      "------------------------------------------------------------
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

        APPEND VALUE #(
          %tky = <header>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Reject
      "------------------------------------------------------------
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


    "--------------------------------------------------------------
    " Return updated entity
    "--------------------------------------------------------------
    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).


    result = VALUE #(
      FOR ls_updated IN lt_updated
      (
        %tky   = ls_updated-%tky
        %param = ls_updated
      )
    ).

  ENDMETHOD.


  METHOD ReassignSupplier.

    DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( RequisitionStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).


    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      "------------------------------------------------------------
      " Find corresponding header by technical key
      "------------------------------------------------------------
      READ TABLE lt_header
        ASSIGNING FIELD-SYMBOL(<header>)
        WITH KEY %tky = <key>-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      "------------------------------------------------------------
      " Cannot reassign completed requisition
      "------------------------------------------------------------
      IF <header>-RequisitionStatus = 'A'
         OR <header>-RequisitionStatus = 'R'.

        APPEND VALUE #(
          %tky = <key>-%tky

          %msg = new_message(
            id       = 'ZPR'
            number   = '004'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-header.

        APPEND VALUE #(
          %tky = <key>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Get action parameter
      "------------------------------------------------------------
      DATA(lv_supplier) =
        <key>-%param-NewSupplierID.


      "------------------------------------------------------------
      " Supplier mandatory
      "------------------------------------------------------------
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

        APPEND VALUE #(
          %tky = <key>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Validate new supplier
      "------------------------------------------------------------
      SELECT SINGLE
        FROM zsupplier_master
        FIELDS
          supplier_id,
          is_active
        WHERE supplier_id = @lv_supplier
        INTO @DATA(ls_supplier).


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

        APPEND VALUE #(
          %tky = <key>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      IF ls_supplier-is_active <> 'X'.

        APPEND VALUE #(
          %tky = <key>-%tky

          %msg = new_message(
            id       = 'ZPR'
            number   = '002'
            severity = if_abap_behv_message=>severity-error
            v1       = lv_supplier
          )
        ) TO reported-header.

        APPEND VALUE #(
          %tky = <key>-%tky
        ) TO failed-header.

        CONTINUE.

      ENDIF.


      "------------------------------------------------------------
      " Update supplier
      "------------------------------------------------------------
      APPEND VALUE #(
        %tky       = <key>-%tky
        SupplierID = lv_supplier
      ) TO lt_update.

    ENDLOOP.


    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header
        UPDATE FIELDS ( SupplierID )
        WITH lt_update.

    ENDIF.


    "--------------------------------------------------------------
    " Return updated entity
    "--------------------------------------------------------------
    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).


    result = VALUE #(
      FOR ls_updated IN lt_updated
      (
        %tky   = ls_updated-%tky
        %param = ls_updated
      )
    ).

  ENDMETHOD.


  METHOD DuplicateRequisition.

    DATA lt_create TYPE TABLE FOR CREATE zi_procurementheader.


    "--------------------------------------------------------------
    " Read original requisitions
    "--------------------------------------------------------------
    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).


    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      "------------------------------------------------------------
      " Find exact header instead of relying on table index
      "------------------------------------------------------------
      READ TABLE lt_header
        ASSIGNING FIELD-SYMBOL(<header>)
        WITH KEY %tky = <key>-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      "------------------------------------------------------------
      " Create duplicate header
      "------------------------------------------------------------
      APPEND VALUE #(
        %cid              = <key>-%cid
        Description       = |Copy of { <header>-Description }|
        SupplierID        = <header>-SupplierID
        CurrencyCode      = <header>-CurrencyCode
        RequisitionStatus = 'N'
      ) TO lt_create.

    ENDLOOP.


    IF lt_create IS INITIAL.
      RETURN.
    ENDIF.


    "--------------------------------------------------------------
    " Create new requisition
    "--------------------------------------------------------------
    MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      CREATE FIELDS
      (
        Description
        SupplierID
        CurrencyCode
        RequisitionStatus
      )
      WITH lt_create
      MAPPED mapped
      FAILED failed
      REPORTED reported.

  ENDMETHOD.

  METHOD setDefaultPRNumber.

  DATA lt_update TYPE TABLE FOR UPDATE zi_procurementheader.

  READ ENTITIES OF zi_procurementheader IN LOCAL MODE
    ENTITY Header
    FIELDS ( PRNumber )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

  "------------------------------------------------------------
  " Find current maximum PRNumber
  "------------------------------------------------------------
  SELECT MAX( pr_number )
    FROM zpr_header
    INTO @DATA(lv_max_pr_number).

  "------------------------------------------------------------
  " Convert MAX value to integer
  "------------------------------------------------------------
  DATA(lv_next_pr_number) = 0.

  IF lv_max_pr_number IS NOT INITIAL.
    lv_next_pr_number = CONV i( lv_max_pr_number ).
  ENDIF.

  LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).

    IF <header>-PRNumber IS INITIAL.

      lv_next_pr_number = lv_next_pr_number + 1.

      APPEND VALUE #(
        %tky     = <header>-%tky
        PRNumber = |{ lv_next_pr_number WIDTH = 10 ALIGN = RIGHT PAD = '0' }|
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      UPDATE FIELDS ( PRNumber )
      WITH lt_update.

  ENDIF.

ENDMETHOD.

ENDCLASS.



"======================================================================
" Item Handler Implementation
"======================================================================

CLASS lhc_item IMPLEMENTATION.


  METHOD calculateHeaderTotal.

    DATA lt_header_update TYPE TABLE FOR UPDATE zi_procurementheader.

    DATA lt_header_keys
      TYPE TABLE FOR READ IMPORT zi_procurementheader.


    "--------------------------------------------------------------
    " Get the PRUUID of changed items
    "--------------------------------------------------------------
    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Item
      FIELDS ( PRUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_changed_items).


    IF lt_changed_items IS INITIAL.
      RETURN.
    ENDIF.


    "--------------------------------------------------------------
    " Build unique parent header keys
    "--------------------------------------------------------------
    LOOP AT lt_changed_items
      ASSIGNING FIELD-SYMBOL(<changed_item>).

      APPEND VALUE #(
        PRUUID = <changed_item>-PRUUID
      ) TO lt_header_keys.

    ENDLOOP.


    SORT lt_header_keys BY PRUUID.

    DELETE ADJACENT DUPLICATES FROM lt_header_keys
      COMPARING PRUUID.


    "--------------------------------------------------------------
    " Read affected headers
    "--------------------------------------------------------------
    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header
      FIELDS ( PRUUID )
      WITH lt_header_keys
      RESULT DATA(lt_headers).


    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.


    "--------------------------------------------------------------
    " Read all items for affected headers
    "--------------------------------------------------------------
    READ ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Header BY \_ProcurementItem
      FIELDS ( PRUUID ItemAmount )
      WITH CORRESPONDING #( lt_headers )
      RESULT DATA(lt_all_items).


    "--------------------------------------------------------------
    " Calculate total for every affected header
    "--------------------------------------------------------------
    LOOP AT lt_headers ASSIGNING FIELD-SYMBOL(<header>).

      DATA(lv_total) =
        CONV zpr_header-total_amount( 0 ).

      LOOP AT lt_all_items
        ASSIGNING FIELD-SYMBOL(<item>)
        USING KEY entity
        WHERE PRUUID = <header>-PRUUID.

        lv_total = lv_total + <item>-ItemAmount.

      ENDLOOP.

      APPEND VALUE #(
        %tky        = <header>-%tky
        TotalAmount = lv_total
      ) TO lt_header_update.

    ENDLOOP.


    "--------------------------------------------------------------
    " Update header totals
    "--------------------------------------------------------------
    IF lt_header_update IS NOT INITIAL.

      MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header
        UPDATE FIELDS ( TotalAmount )
        WITH lt_header_update.

    ENDIF.

  ENDMETHOD.

  METHOD validateRequiredDeliveryDate.

  READ ENTITIES OF zi_procurementheader IN LOCAL MODE
    ENTITY Item
    FIELDS ( RequiredDeliveryDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

  LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<item>).

    IF <item>-RequiredDeliveryDate < cl_abap_context_info=>get_system_date( ).

      APPEND VALUE #(
        %tky = <item>-%tky
      ) TO failed-item.

      APPEND VALUE #(
        %tky = <item>-%tky
        %msg = new_message(
          id       = 'ZPR'
          number   = '006'
          severity = if_abap_behv_message=>severity-error
        )
        %element-RequiredDeliveryDate = if_abap_behv=>mk-on
      ) TO reported-item.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

METHOD setDefaultItemNumber.

  DATA lt_update TYPE TABLE FOR UPDATE zi_procurementitem.

  READ ENTITIES OF zi_procurementheader IN LOCAL MODE
    ENTITY Item
    FIELDS ( PRUUID ItemNumber )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

  LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<item>).

    IF <item>-ItemNumber IS INITIAL.

      "------------------------------------------------------------
      " Read existing items belonging to the same PR
      "------------------------------------------------------------
      READ ENTITIES OF zi_procurementheader IN LOCAL MODE
        ENTITY Header BY \_ProcurementItem
        FIELDS ( ItemNumber )
        WITH VALUE #(
          (
            %tky = VALUE #(
              PRUUID = <item>-PRUUID
            )
          )
        )
        RESULT DATA(lt_existing_items).

      "------------------------------------------------------------
      " Find highest existing ItemNumber
      "------------------------------------------------------------
      DATA(lv_max_item_number) = 0.

      LOOP AT lt_existing_items
        ASSIGNING FIELD-SYMBOL(<existing_item>).

        IF <existing_item>-ItemNumber IS NOT INITIAL.

          DATA(lv_item_number) =
            CONV i( <existing_item>-ItemNumber ).

          IF lv_item_number > lv_max_item_number.
            lv_max_item_number = lv_item_number.
          ENDIF.

        ENDIF.

      ENDLOOP.

      "------------------------------------------------------------
      " Generate next ItemNumber
      " 00010, 00020, 00030...
      "------------------------------------------------------------
      DATA(lv_new_item_number) =
        lv_max_item_number + 10.

      APPEND VALUE #(
        %tky       = <item>-%tky
        ItemNumber = |{ lv_new_item_number WIDTH = 5 ALIGN = RIGHT PAD = '0' }|
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  "--------------------------------------------------------------
  " Update ItemNumber
  "--------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_procurementheader IN LOCAL MODE
      ENTITY Item
      UPDATE FIELDS ( ItemNumber )
      WITH lt_update.

  ENDIF.

ENDMETHOD.

ENDCLASS.
