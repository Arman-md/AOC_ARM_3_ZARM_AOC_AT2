CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE travel.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE travel.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD augment_create.

    DATA: travel_create TYPE TABLE FOR CREATE zi_trav_root.

    travel_create =  CORRESPONDING #(  entities ).

    LOOP AT travel_create ASSIGNING FIELD-SYMBOL(<travel>).

*      <travel>-BeginDate =  cl_abap_context_info=>get_system_date( ).
*      <travel>-CurrencyCode = 'USD'.
      <travel>-AgencyId = '70003'.
      <travel>-OverallStatus = 'O'.
      <travel>-%control-AgencyId = if_abap_behv=>mk-on.
      <travel>-%control-OverallStatus = if_abap_behv=>mk-on.

    ENDLOOP.

    MODIFY AUGMENTING ENTITIES OF zi_trav_root
    ENTITY travel
    CREATE FROM travel_create.
  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

ENDCLASS.
