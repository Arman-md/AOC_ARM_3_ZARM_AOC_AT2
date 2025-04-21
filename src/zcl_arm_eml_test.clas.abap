CLASS zcl_arm_eml_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA: lv_op TYPE c LENGTH 1 VALUE 'C'.
    INTERFACES : if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_arm_eml_test IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    CASE lv_op.
      WHEN 'R'.
        READ ENTITIES OF zc_trav_proc
             ENTITY travel
             "ALL FIELDS WITH
             FIELDS ( TravelId AgencyId CustomerId criticality CreatedBy Description ) WITH
             VALUE #( ( TravelId = '12345678' )
                      ( TravelId = '00000067' )
                      ( TravelId = '99998768' ) )
             RESULT DATA(lt_result)
             FAILED DATA(lt_failed)
             REPORTED DATA(lt_reported).

        out->write( lt_result ).
        out->write( lt_failed ).
        out->write( lt_reported ).

      WHEN 'C'.
        DATA(lv_descp) = 'ARMAN LOVES RAP'.
        DATA(lv_agencyid) = '070017'.
        DATA(lv_custid)   = '1234'.

        MODIFY ENTITIES OF zc_trav_proc ENTITY travel
               CREATE FIELDS ( TravelId AgencyId CurrencyCode BeginDate EndDate Description OverallStatus )
               WITH VALUE #( ( %cid          = 'ARMANMOHAMMED' " Mandatory( Unique for every record)
                               TravelId      = '00000001'
                               Description   = lv_descp
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'A' )
                             ( %cid          = 'ARMANMOHAMMED2'
                               TravelId      = '11112233'
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'R' )
                             ( %cid          = 'ARMANMOHAMMED3'
                               TravelId      = '11112232'
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'O' )
                             ( %cid          = 'ARMANMOHAMMED4'
                               TravelId      = '11112231'
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'O' ) )
               MAPPED DATA(lt_mapped)
               FAILED lt_failed
               REPORTED lt_reported.
        out->write( lt_result ).
        out->write( lt_failed ).
        out->write( lt_reported ).
        COMMIT ENTITIES.
      WHEN 'U'.
        lv_descp = 'UPDATED Descr.'.
        lv_agencyid = '070017'.
        lv_custid   = '1234'.
        MODIFY ENTITIES OF zc_trav_proc ENTITY travel
               UPDATE FIELDS ( TravelId AgencyId CurrencyCode BeginDate EndDate Description OverallStatus )
               WITH VALUE #( ( TravelId      = '00000004'
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'R' )
                             ( TravelId      = '00000005'
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'R' )
                             ( TravelId      = '00000007'
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'R' )
                             ( TravelId      = '000000048'
                               AgencyId      = lv_agencyid
                               BeginDate     = cl_abap_context_info=>get_system_date( )
                               EndDate       = cl_abap_context_info=>get_system_date( ) + 30
                               OverallStatus = 'R' ) )
               MAPPED lt_mapped
               FAILED lt_failed
               REPORTED lt_reported.
        out->write( lt_result ).
        out->write( lt_failed ).
        out->write( lt_reported ).
        COMMIT ENTITIES.
      WHEN 'D'.

        MODIFY ENTITIES OF zc_trav_proc ENTITY travel
               DELETE FROM VALUE #( ( TravelId      = '00000001' ) )
               MAPPED lt_mapped
               FAILED lt_failed
               REPORTED lt_reported.

        COMMIT ENTITIES.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
