CLASS zcl_arm_mars_example DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: itab TYPE TABLE OF string.
    METHODS : reach_to_mars.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_arm_mars_example IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    me->reach_to_mars( ).
    out->write(  itab ).

    DELETE from /dmo/log_travel.
  ENDMETHOD.

  METHOD reach_to_mars.
    DATA(lo_earth) = NEW zcl_earth( ).
    DATA(lo_planet1) = NEW zcl_planet1( ).
    DATA(lo_mars) = NEW zcl_mars( ).

    DATA(lv_text) = lo_earth->start_engine( ).
    APPEND lv_text TO itab.
    lv_text = lo_earth->leave_orbit( ).
    APPEND lv_text TO itab.

    lv_text = lo_planet1->enter_orbit( ).
    APPEND lv_text TO itab.
    lv_text = lo_planet1->leave_orbit( ).
    APPEND lv_text TO itab.

    lv_text = lo_mars->enter_orbit( ).
    APPEND lv_text TO itab.
    lv_text = lo_mars->explore_mars( ).
    APPEND lv_text TO itab.
  ENDMETHOD.

ENDCLASS.


