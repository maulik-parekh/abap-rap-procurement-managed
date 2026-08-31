CLASS zcl_pr_virtual_elements DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.

ENDCLASS.


CLASS zcl_pr_virtual_elements IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE TABLE OF zc_procurementheader.

    lt_original_data = CORRESPONDING #( it_original_data ).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_header>).

      "------------------------------------------------------------
      " Calculate Approval Risk Level
      "------------------------------------------------------------

      IF <fs_header>-TotalAmount > 10000.

        <fs_header>-ApprovalRiskLevel = 'High'.

      ELSEIF <fs_header>-TotalAmount >= 2000.

        <fs_header>-ApprovalRiskLevel = 'Medium'.

      ELSE.

        <fs_header>-ApprovalRiskLevel = 'Low'.

      ENDIF.


      "------------------------------------------------------------
      " Calculate Days Until Delivery
      "------------------------------------------------------------

      SELECT MIN( required_delivery_date )
        FROM zpr_item
        WHERE pr_uuid = @<fs_header>-PRUUID
        INTO @DATA(lv_min_date).

      IF lv_min_date IS NOT INITIAL.

        <fs_header>-DaysUntilDelivery =
          lv_min_date - lv_today.

      ELSE.

        <fs_header>-DaysUntilDelivery = 0.

      ENDIF.

    ENDLOOP.


    " Return calculated virtual elements
    ct_calculated_data =
      CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    "------------------------------------------------------------
    " ApprovalRiskLevel depends on TotalAmount
    "------------------------------------------------------------

    IF line_exists(
         it_requested_calc_elements[
           table_line = 'APPROVALRISKLEVEL'
         ]
       ).

      INSERT CONV string( 'TOTALAMOUNT' )
        INTO TABLE et_requested_orig_elements.

    ENDIF.


    "------------------------------------------------------------
    " DaysUntilDelivery depends on PRUUID
    "------------------------------------------------------------

    IF line_exists(
         it_requested_calc_elements[
           table_line = 'DAYSUNTILDELIVERY'
         ]
       ).

      INSERT CONV string( 'PRUUID' )
        INTO TABLE et_requested_orig_elements.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
