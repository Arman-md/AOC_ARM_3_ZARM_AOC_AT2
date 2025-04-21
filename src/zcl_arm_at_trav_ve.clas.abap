CLASS zcl_arm_at_trav_ve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_arm_at_trav_ve IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    CHECK NOT it_original_data IS INITIAL.

    DATA: lt_calc_data TYPE STANDARD TABLE OF zc_trav_proc WITH DEFAULT KEY.
*          lv_rate      TYPE p DECIMALS 2 VALUE '0.025'.

    lt_calc_data = CORRESPONDING #( it_original_data ).

    LOOP AT  lt_calc_data ASSIGNING FIELD-SYMBOL(<fs_calc>).
      <fs_calc>-co2tax = ( <fs_calc>-TotalPrice * 25 ) / 100.


        " get day of the date
      cl_scal_utils=>date_compute_day(
      EXPORTING
      iv_date =  <fs_calc>-BeginDate
      IMPORTING
      ev_weekday_name = DATA(lv_day)
        ).
      <fs_calc>-flightday = lv_day.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_calc_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
