CLASS zcl_pr_data_generator DEFINITION

  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_pr_data_generator IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    TRY.


        "============================================================
        " Local Types
        "============================================================

        TYPES:

          BEGIN OF ty_pr_seed,

            pr_number          TYPE zpr_header-pr_number,
            description        TYPE zpr_header-description,
            requisition_status TYPE zpr_header-requisition_status,
            supplier_id        TYPE zpr_header-supplier_id,
            total_amount       TYPE zpr_header-total_amount,
            currency_code      TYPE zpr_header-currency_code,

          END OF ty_pr_seed,


          BEGIN OF ty_item_seed,

            pr_number       TYPE zpr_header-pr_number,
            item_number     TYPE zpr_item-item_number,
            material_id     TYPE zpr_item-material_id,
            plant           TYPE zpr_item-plant,
            quantity        TYPE zpr_item-quantity,
            uom             TYPE zpr_item-uom,
            item_amount     TYPE zpr_item-item_amount,
            currency_code   TYPE zpr_item-currency_code,
            date_offset     TYPE i,
            cost_center_id  TYPE zpr_account-cost_center_id,
            controlling_area TYPE zpr_account-controlling_area,

          END OF ty_item_seed.


        "============================================================
        " Clear Existing Data
        "============================================================

        DELETE FROM zpr_account.
        DELETE FROM zpr_item.
        DELETE FROM zpr_header.

        DELETE FROM zsupplier_master.
        DELETE FROM zmaterial_master.
        DELETE FROM zcost_center_m.


        "============================================================
        " Current Timestamp / Date
        "============================================================

        DATA(lv_ts) = utclong_current( ).

        DATA(lv_date) =
          cl_abap_context_info=>get_system_date( ).


        "============================================================
        " 1. Supplier Master
        "============================================================

        DATA lt_suppliers TYPE TABLE OF zsupplier_master.

        lt_suppliers = VALUE #(

          (
            client        = sy-mandt
            supplier_id   = 'SUPP000001'
            supplier_name = 'Acme Industrial Solutions'
            country       = 'DE'
            city          = 'Walldorf'
            rating        = 5
            is_active     = abap_true
          )

          (
            client        = sy-mandt
            supplier_id   = 'SUPP000002'
            supplier_name = 'Global Tech Components'
            country       = 'US'
            city          = 'Austin'
            rating        = 4
            is_active     = abap_true
          )

          (
            client        = sy-mandt
            supplier_id   = 'SUPP000003'
            supplier_name = 'Bharat Office Systems'
            country       = 'IN'
            city          = 'Bangalore'
            rating        = 4
            is_active     = abap_true
          )

          (
            client        = sy-mandt
            supplier_id   = 'SUPP000004'
            supplier_name = 'Euro Industrial Supplies'
            country       = 'FR'
            city          = 'Paris'
            rating        = 3
            is_active     = abap_true
          )

          (
            client        = sy-mandt
            supplier_id   = 'SUPP000005'
            supplier_name = 'Inactive Logistics Ltd'
            country       = 'IN'
            city          = 'Mumbai'
            rating        = 1
            is_active     = abap_false
          )

        ).

        INSERT zsupplier_master FROM TABLE @lt_suppliers.


        "============================================================
        " 2. Material Master
        "============================================================

        DATA lt_materials TYPE TABLE OF zmaterial_master.

        lt_materials = VALUE #(

          (
            client         = sy-mandt
            material_id    = 'MAT0001'
            description    = 'High-Speed Server Module'
            material_group = 'IT_HW'
            base_uom       = 'EA'
            unit_price     = '1200.00'
            currency       = 'EUR'
          )

          (
            client         = sy-mandt
            material_id    = 'MAT0002'
            description    = 'Ergonomic Desk Chair'
            material_group = 'OFF_FUR'
            base_uom       = 'EA'
            unit_price     = '350.00'
            currency       = 'EUR'
          )

          (
            client         = sy-mandt
            material_id    = 'MAT0003'
            description    = 'Business Laptop'
            material_group = 'IT_HW'
            base_uom       = 'EA'
            unit_price     = '950.00'
            currency       = 'EUR'
          )

          (
            client         = sy-mandt
            material_id    = 'MAT0004'
            description    = 'Wireless Keyboard'
            material_group = 'IT_ACC'
            base_uom       = 'EA'
            unit_price     = '80.00'
            currency       = 'EUR'
          )

          (
            client         = sy-mandt
            material_id    = 'MAT0005'
            description    = '27 Inch Monitor'
            material_group = 'IT_HW'
            base_uom       = 'EA'
            unit_price     = '420.00'
            currency       = 'EUR'
          )

        ).

        INSERT zmaterial_master FROM TABLE @lt_materials.


        "============================================================
        " 3. Cost Center Master
        "============================================================

        DATA lt_cost_centers TYPE TABLE OF zcost_center_m.

        lt_cost_centers = VALUE #(

          (
            client           = sy-mandt
            cost_center_id   = 'CC1001'
            controlling_area = '1000'
            description      = 'IT Infrastructure'
            manager_name     = 'John Doe'
          )

          (
            client           = sy-mandt
            cost_center_id   = 'CC1002'
            controlling_area = '1000'
            description      = 'Corporate Operations'
            manager_name     = 'Jane Smith'
          )

          (
            client           = sy-mandt
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
            description      = 'Finance Department'
            manager_name     = 'Robert Brown'
          )

          (
            client           = sy-mandt
            cost_center_id   = 'CC1004'
            controlling_area = '1000'
            description      = 'Human Resources'
            manager_name     = 'Emily Davis'
          )

          (
            client           = sy-mandt
            cost_center_id   = 'CC1005'
            controlling_area = '1000'
            description      = 'Research and Development'
            manager_name     = 'Michael Wilson'
          )

        ).

        INSERT zcost_center_m FROM TABLE @lt_cost_centers.


        "============================================================
        " 4. PR Header Seed Data
        "============================================================

        DATA lt_pr_seed TYPE TABLE OF ty_pr_seed.

        lt_pr_seed = VALUE #(

          (
            pr_number          = '1000000001'
            description        = 'Q3 IT Hardware Expansion'
            requisition_status = 'N'
            supplier_id        = 'SUPP000001'
            total_amount       = '9550.00'
            currency_code      = 'EUR'
          )

          (
            pr_number          = '1000000002'
            description        = 'Office Furniture Requirement'
            requisition_status = 'N'
            supplier_id        = 'SUPP000002'
            total_amount       = '8260.00'
            currency_code      = 'EUR'
          )

          (
            pr_number          = '1000000003'
            description        = 'Finance Laptop Upgrade'
            requisition_status = 'A'
            supplier_id        = 'SUPP000003'
            total_amount       = '9810.00'
            currency_code      = 'EUR'
          )

          (
            pr_number          = '1000000004'
            description        = 'HR Office Equipment'
            requisition_status = 'N'
            supplier_id        = 'SUPP000004'
            total_amount       = '5740.00'
            currency_code      = 'EUR'
          )

          (
            pr_number          = '1000000005'
            description        = 'R&D Technology Procurement'
            requisition_status = 'N'
            supplier_id        = 'SUPP000003'
            total_amount       = '8780.00'
            currency_code      = 'EUR'
          )

        ).


        "============================================================
        " 5. Create PR Headers
        "============================================================

        DATA lt_headers TYPE TABLE OF zpr_header.

        LOOP AT lt_pr_seed ASSIGNING FIELD-SYMBOL(<ls_pr>).

          DATA(lv_pr_uuid) =
            cl_system_uuid=>create_uuid_x16_static( ).

          APPEND VALUE #(

            client                = sy-mandt
            pr_uuid               = lv_pr_uuid
            pr_number             = <ls_pr>-pr_number
            description           = <ls_pr>-description
            requisition_status    = <ls_pr>-requisition_status
            supplier_id           = <ls_pr>-supplier_id
            total_amount          = <ls_pr>-total_amount
            currency_code         = <ls_pr>-currency_code
            created_by            = sy-uname
            created_at            = lv_ts
            last_changed_by       = sy-uname
            last_changed_at       = lv_ts
            local_last_changed_at = lv_ts

          ) TO lt_headers.

        ENDLOOP.


        "============================================================
        " 6. PR Item Seed Data
        "============================================================

        DATA lt_item_seed TYPE TABLE OF ty_item_seed.

        lt_item_seed = VALUE #(

          "----------------------------------------------------------
          " PR 1
          "----------------------------------------------------------

          (
            pr_number        = '1000000001'
            item_number      = '00010'
            material_id      = 'MAT0001'
            plant            = '1001'
            quantity         = '2'
            uom              = 'EA'
            item_amount      = '2400.00'
            currency_code    = 'EUR'
            date_offset      = 30
            cost_center_id   = 'CC1001'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000001'
            item_number      = '00020'
            material_id      = 'MAT0002'
            plant            = '1001'
            quantity         = '4'
            uom              = 'EA'
            item_amount      = '1400.00'
            currency_code    = 'EUR'
            date_offset      = 35
            cost_center_id   = 'CC1002'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000001'
            item_number      = '00030'
            material_id      = 'MAT0003'
            plant            = '1001'
            quantity         = '3'
            uom              = 'EA'
            item_amount      = '2850.00'
            currency_code    = 'EUR'
            date_offset      = 40
            cost_center_id   = 'CC1001'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000001'
            item_number      = '00040'
            material_id      = 'MAT0004'
            plant            = '1001'
            quantity         = '10'
            uom              = 'EA'
            item_amount      = '800.00'
            currency_code    = 'EUR'
            date_offset      = 25
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000001'
            item_number      = '00050'
            material_id      = 'MAT0005'
            plant            = '1001'
            quantity         = '5'
            uom              = 'EA'
            item_amount      = '2100.00'
            currency_code    = 'EUR'
            date_offset      = 45
            cost_center_id   = 'CC1001'
            controlling_area = '1000'
          )


          "----------------------------------------------------------
          " PR 2
          "----------------------------------------------------------

          (
            pr_number        = '1000000002'
            item_number      = '00010'
            material_id      = 'MAT0002'
            plant            = '1001'
            quantity         = '10'
            uom              = 'EA'
            item_amount      = '3500.00'
            currency_code    = 'EUR'
            date_offset      = 30
            cost_center_id   = 'CC1002'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000002'
            item_number      = '00020'
            material_id      = 'MAT0004'
            plant            = '1001'
            quantity         = '5'
            uom              = 'EA'
            item_amount      = '400.00'
            currency_code    = 'EUR'
            date_offset      = 35
            cost_center_id   = 'CC1002'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000002'
            item_number      = '00030'
            material_id      = 'MAT0005'
            plant            = '1001'
            quantity         = '3'
            uom              = 'EA'
            item_amount      = '1260.00'
            currency_code    = 'EUR'
            date_offset      = 40
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000002'
            item_number      = '00040'
            material_id      = 'MAT0001'
            plant            = '1001'
            quantity         = '1'
            uom              = 'EA'
            item_amount      = '1200.00'
            currency_code    = 'EUR'
            date_offset      = 45
            cost_center_id   = 'CC1004'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000002'
            item_number      = '00050'
            material_id      = 'MAT0003'
            plant            = '1001'
            quantity         = '2'
            uom              = 'EA'
            item_amount      = '1900.00'
            currency_code    = 'EUR'
            date_offset      = 50
            cost_center_id   = 'CC1005'
            controlling_area = '1000'
          )


          "----------------------------------------------------------
          " PR 3
          "----------------------------------------------------------

          (
            pr_number        = '1000000003'
            item_number      = '00010'
            material_id      = 'MAT0003'
            plant            = '1001'
            quantity         = '5'
            uom              = 'EA'
            item_amount      = '4750.00'
            currency_code    = 'EUR'
            date_offset      = 30
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000003'
            item_number      = '00020'
            material_id      = 'MAT0004'
            plant            = '1001'
            quantity         = '8'
            uom              = 'EA'
            item_amount      = '640.00'
            currency_code    = 'EUR'
            date_offset      = 35
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000003'
            item_number      = '00030'
            material_id      = 'MAT0005'
            plant            = '1001'
            quantity         = '4'
            uom              = 'EA'
            item_amount      = '1680.00'
            currency_code    = 'EUR'
            date_offset      = 40
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000003'
            item_number      = '00040'
            material_id      = 'MAT0001'
            plant            = '1001'
            quantity         = '1'
            uom              = 'EA'
            item_amount      = '1200.00'
            currency_code    = 'EUR'
            date_offset      = 45
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000003'
            item_number      = '00050'
            material_id      = 'MAT0002'
            plant            = '1001'
            quantity         = '2'
            uom              = 'EA'
            item_amount      = '700.00'
            currency_code    = 'EUR'
            date_offset      = 50
            cost_center_id   = 'CC1003'
            controlling_area = '1000'
          )


          "----------------------------------------------------------
          " PR 4
          "----------------------------------------------------------

          (
            pr_number        = '1000000004'
            item_number      = '00010'
            material_id      = 'MAT0002'
            plant            = '1001'
            quantity         = '4'
            uom              = 'EA'
            item_amount      = '1400.00'
            currency_code    = 'EUR'
            date_offset      = 30
            cost_center_id   = 'CC1004'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000004'
            item_number      = '00020'
            material_id      = 'MAT0004'
            plant            = '1001'
            quantity         = '5'
            uom              = 'EA'
            item_amount      = '400.00'
            currency_code    = 'EUR'
            date_offset      = 35
            cost_center_id   = 'CC1004'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000004'
            item_number      = '00030'
            material_id      = 'MAT0005'
            plant            = '1001'
            quantity         = '2'
            uom              = 'EA'
            item_amount      = '840.00'
            currency_code    = 'EUR'
            date_offset      = 40
            cost_center_id   = 'CC1004'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000004'
            item_number      = '00040'
            material_id      = 'MAT0001'
            plant            = '1001'
            quantity         = '1'
            uom              = 'EA'
            item_amount      = '1200.00'
            currency_code    = 'EUR'
            date_offset      = 45
            cost_center_id   = 'CC1004'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000004'
            item_number      = '00050'
            material_id      = 'MAT0003'
            plant            = '1001'
            quantity         = '2'
            uom              = 'EA'
            item_amount      = '1900.00'
            currency_code    = 'EUR'
            date_offset      = 50
            cost_center_id   = 'CC1004'
            controlling_area = '1000'
          )


          "----------------------------------------------------------
          " PR 5
          "----------------------------------------------------------

          (
            pr_number        = '1000000005'
            item_number      = '00010'
            material_id      = 'MAT0001'
            plant            = '1001'
            quantity         = '2'
            uom              = 'EA'
            item_amount      = '2400.00'
            currency_code    = 'EUR'
            date_offset      = 30
            cost_center_id   = 'CC1005'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000005'
            item_number      = '00020'
            material_id      = 'MAT0003'
            plant            = '1001'
            quantity         = '3'
            uom              = 'EA'
            item_amount      = '2850.00'
            currency_code    = 'EUR'
            date_offset      = 35
            cost_center_id   = 'CC1005'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000005'
            item_number      = '00030'
            material_id      = 'MAT0004'
            plant            = '1001'
            quantity         = '10'
            uom              = 'EA'
            item_amount      = '800.00'
            currency_code    = 'EUR'
            date_offset      = 40
            cost_center_id   = 'CC1005'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000005'
            item_number      = '00040'
            material_id      = 'MAT0005'
            plant            = '1001'
            quantity         = '4'
            uom              = 'EA'
            item_amount      = '1680.00'
            currency_code    = 'EUR'
            date_offset      = 45
            cost_center_id   = 'CC1005'
            controlling_area = '1000'
          )

          (
            pr_number        = '1000000005'
            item_number      = '00050'
            material_id      = 'MAT0002'
            plant            = '1001'
            quantity         = '3'
            uom              = 'EA'
            item_amount      = '1050.00'
            currency_code    = 'EUR'
            date_offset      = 50
            cost_center_id   = 'CC1005'
            controlling_area = '1000'
          )

        ).


        "============================================================
        " 7. Create Items and Account Assignments
        "============================================================

        DATA lt_items TYPE TABLE OF zpr_item.

        DATA lt_accounts TYPE TABLE OF zpr_account.


        LOOP AT lt_item_seed ASSIGNING FIELD-SYMBOL(<ls_item_seed>).


          "----------------------------------------------------------
          " Find corresponding PR Header
          "----------------------------------------------------------

          READ TABLE lt_headers
            ASSIGNING FIELD-SYMBOL(<ls_header>)
            WITH KEY pr_number = <ls_item_seed>-pr_number.


          IF sy-subrc <> 0.

            out->write(
              |PR { <ls_item_seed>-pr_number } not found|
            ).

            CONTINUE.

          ENDIF.


          "----------------------------------------------------------
          " Generate Item UUID
          "----------------------------------------------------------

          DATA(lv_item_uuid) =
            cl_system_uuid=>create_uuid_x16_static( ).


          "----------------------------------------------------------
          " Create Item
          "----------------------------------------------------------

          APPEND VALUE #(

            client                 = sy-mandt
            pr_uuid                = <ls_header>-pr_uuid
            item_uuid              = lv_item_uuid
            item_number            = <ls_item_seed>-item_number
            material_id            = <ls_item_seed>-material_id
            plant                  = <ls_item_seed>-plant
            quantity               = <ls_item_seed>-quantity
            uom                    = <ls_item_seed>-uom
            item_amount            = <ls_item_seed>-item_amount
            currency_code          = <ls_item_seed>-currency_code
            required_delivery_date = lv_date +
                                     <ls_item_seed>-date_offset
            local_last_changed_at  = lv_ts

          ) TO lt_items.


          "----------------------------------------------------------
          " Generate Account UUID
          "----------------------------------------------------------

          DATA(lv_account_uuid) =
            cl_system_uuid=>create_uuid_x16_static( ).


          "----------------------------------------------------------
          " Create Account Assignment
          "----------------------------------------------------------

          APPEND VALUE #(

            client                = sy-mandt
            pr_uuid               = <ls_header>-pr_uuid
            item_uuid             = lv_item_uuid
            account_uuid          = lv_account_uuid
            cost_center_id        = <ls_item_seed>-cost_center_id
            controlling_area      = <ls_item_seed>-controlling_area
            percentage            = '100.00'
            local_last_changed_at = lv_ts

          ) TO lt_accounts.


        ENDLOOP.


        "============================================================
        " 8. Insert PR Headers
        "============================================================

        INSERT zpr_header FROM TABLE @lt_headers.


        IF sy-subrc <> 0.

          out->write(
            |Error inserting PR headers. SY-SUBRC = { sy-subrc }|
          ).

          RETURN.

        ENDIF.


        "============================================================
        " 9. Insert PR Items
        "============================================================

        INSERT zpr_item FROM TABLE @lt_items.


        IF sy-subrc <> 0.

          out->write(
            |Error inserting PR items. SY-SUBRC = { sy-subrc }|
          ).

          RETURN.

        ENDIF.


        "============================================================
        " 10. Insert Account Assignments
        "============================================================

        INSERT zpr_account FROM TABLE @lt_accounts.


        IF sy-subrc <> 0.

          out->write(
            |Error inserting account assignments. SY-SUBRC = { sy-subrc }|
          ).

          RETURN.

        ENDIF.


        "============================================================
        " 11. Success Output
        "============================================================

        out->write(
          |==============================================|
        ).

        out->write(
          |PR Data Generator completed successfully.|
        ).

        out->write(
          |==============================================|
        ).

        out->write(
          |Suppliers          : { lines( lt_suppliers ) }|
        ).

        out->write(
          |Materials          : { lines( lt_materials ) }|
        ).

        out->write(
          |Cost Centers       : { lines( lt_cost_centers ) }|
        ).

        out->write(
          |PR Headers         : { lines( lt_headers ) }|
        ).

        out->write(
          |PR Items           : { lines( lt_items ) }|
        ).

        out->write(
          |Account Assignments: { lines( lt_accounts ) }|
        ).

        out->write(
          |==============================================|
        ).


      "==============================================================
      " UUID Exception Handling
      "==============================================================

      CATCH cx_uuid_error INTO DATA(lx_uuid).

        out->write(
          |UUID generation failed.|
        ).

        out->write(
          |Error: { lx_uuid->get_text( ) }|
        ).


      "==============================================================
      " General Exception Handling
      "==============================================================

      CATCH cx_root INTO DATA(lx_root).

        out->write(
          |Unexpected error occurred.|
        ).

        out->write(
          |Error: { lx_root->get_text( ) }|
        ).


    ENDTRY.


  ENDMETHOD.

ENDCLASS.
