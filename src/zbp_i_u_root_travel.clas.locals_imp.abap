CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES : tt_travel_failed   TYPE TABLE FOR FAILED zi_u_root_travel,
            tt_travel_reported TYPE TABLE FOR REPORTED zi_u_root_travel.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK travel.

    METHODS setbookstatus FOR MODIFY
      IMPORTING keys FOR ACTION travel~setbookstatus RESULT result.

    " custom reuse function which can capture messages coming from old legacy code in the format what RAP understands
    METHODS : map_messages IMPORTING
                             cid          TYPE string OPTIONAL
                             travelid     TYPE /dmo/travel_id OPTIONAL
                             messages     TYPE /dmo/t_message
                           EXPORTING
                             failed_added TYPE abap_bool
                           CHANGING
                             failed       TYPE tt_travel_failed
                             reported     TYPE tt_travel_reported.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    "" step 1 : data declaration
    DATA : messages   TYPE /dmo/t_message,
           travel_in  TYPE /dmo/travel,
           travel_out TYPE /dmo/travel.


    "" step 2 : get the incoming data in a structure which our legacy code understands
    " loop at incoming data from FIORI APP
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_create>).
      travel_in = CORRESPONDING #( <travel_create> MAPPING FROM ENTITY USING CONTROL ).
      "" step 3 : call the legacy code(old code) to set the data to transaction buffer
      /dmo/cl_flight_legacy=>get_instance( )->create_travel(
        EXPORTING
          is_travel             = CORRESPONDING /dmo/s_travel_in( travel_in )
        IMPORTING
          es_travel             = travel_out
          et_messages           = DATA(lt_messages)
      ).
      "" step 4 : handle the incoming error messages
      /dmo/cl_flight_legacy=>get_instance( )->convert_messages(
        EXPORTING
          it_messages = lt_messages
        IMPORTING
          et_messages = messages
      ).
      "" step 5 : map the messages to the RAP output
      map_messages(
        EXPORTING
          cid          = <travel_create>-%cid
          travelid     = <travel_create>-TravelId
          messages     = messages
        IMPORTING
          failed_added = DATA(data_failed)
        CHANGING
          failed       = failed-travel
          reported     = reported-travel
      ).

      IF data_failed = abap_true.
        INSERT VALUE #(  %cid = <travel_create>-%cid
                         travelid = <travel_create>-TravelId ) INTO TABLE mapped-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.

    "" step 1 : data declaration
    DATA : messages  TYPE /dmo/t_message,
           travel_in TYPE /dmo/travel,
           travel_u  TYPE /dmo/s_travel_inx.


    "" step 2 : get the incoming data in a structure which our legacy code understands
    " loop at incoming data from FIORI APP
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_update>).
      travel_in = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY USING CONTROL ).

      travel_u-travel_id = travel_in-travel_id.
      travel_u-_intx = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).
      "" step 3 : call the legacy code(old code) to set the data to transaction buffer
      /dmo/cl_flight_legacy=>get_instance( )->update_travel(
        EXPORTING
          is_travel             = CORRESPONDING /dmo/s_travel_in( travel_in )
          is_travelx            = travel_u
        IMPORTING
          et_messages           = DATA(lt_messages)
      ).
      "" step 4 : handle the incoming error messages
      /dmo/cl_flight_legacy=>get_instance( )->convert_messages(
        EXPORTING
          it_messages = lt_messages
        IMPORTING
          et_messages = messages
      ).
      "" step 5 : map the messages to the RAP output
      map_messages(
        EXPORTING
          cid          = <travel_update>-%cid_ref
          travelid     = <travel_update>-TravelId
          messages     = messages
        IMPORTING
          failed_added = DATA(data_failed)
        CHANGING
          failed       = failed-travel
          reported     = reported-travel
      ).

*      IF data_failed = abap_true.
*        INSERT VALUE #(  %cid = <travel_update>-%cid_ref
*                         travelid = <travel_update>-TravelId ) INTO TABLE mapped-travel.
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA : messages  TYPE /dmo/t_message.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_delete>).
      /dmo/cl_flight_legacy=>get_instance( )->delete_travel(
        EXPORTING
          iv_travel_id = <travel_delete>-TravelId
        IMPORTING
          et_messages  = DATA(lt_messages)
      ).


      "" step 4 : handle the incoming error messages
      /dmo/cl_flight_legacy=>get_instance( )->convert_messages(
        EXPORTING
          it_messages = lt_messages
        IMPORTING
          et_messages = messages
      ).
      "" step 5 : map the messages to the RAP output
      map_messages(
        EXPORTING
          cid          = <travel_delete>-%cid_ref
          travelid     = <travel_delete>-TravelId
          messages     = messages
        IMPORTING
          failed_added = DATA(data_failed)
        CHANGING
          failed       = failed-travel
          reported     = reported-travel
      ).


    ENDLOOP.
  ENDMETHOD.

  METHOD read.

    DATA: travel_out TYPE /dmo/travel,
          messages   TYPE /dmo/t_message,
          lv_failed  TYPE abap_boolean.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_read>) GROUP BY <travel_read>-TravelId.
      /dmo/cl_flight_legacy=>get_instance( )->get_travel(
        EXPORTING
          iv_travel_id           = <travel_read>-TravelId
          iv_include_buffer      = abap_false " means dont read the data from the buffer
        IMPORTING
          es_travel              = travel_out
          et_messages            = DATA(lt_messages)
      ).

      "" step 4 : handle the incoming error messages
      /dmo/cl_flight_legacy=>get_instance( )->convert_messages(
        EXPORTING
          it_messages = lt_messages
        IMPORTING
          et_messages = messages
      ).


      "" step 5 : map the messages to the RAP output
      map_messages(
        EXPORTING
          travelid     = <travel_read>-TravelId
          messages     = messages
        IMPORTING
          failed_added = DATA(data_failed)
        CHANGING
          failed       = failed-travel
          reported     = reported-travel
      ).


      IF data_failed = abap_true.
        INSERT CORRESPONDING #(  travel_out ) INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD setbookstatus.


    " define a structure & itab where we can store all the booking fees
    TYPES : BEGIN OF ty_amount_per_currency,
              amount        TYPE /dmo/total_price,
              currency_code TYPE /dmo/currency_code,
            END OF ty_amount_per_currency.

    " read all travel instnaces , subsequent booking using EML

    READ ENTITIES OF zi_U_ROOT_TRAVEL IN LOCAL MODE
    ENTITY Travel
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).



    " total all booking and supplement amounts which are in common currency

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-Status = 'A'.
    ENDLOOP.

    MODIFY ENTITIES OF zi_U_ROOT_TRAVEL IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( status )
    WITH CORRESPONDING #( travels ).


  ENDMETHOD.

  METHOD map_messages.
    failed_added = abap_false.
    LOOP AT messages INTO DATA(message).
      IF message-msgty = 'E' OR message-msgty = 'A'.
        APPEND VALUE #( %cid = cid
                        travelid = travelid
                        %fail-cause = /dmo/cl_travel_auxiliary=>get_cause_from_message(
                                        msgid        = message-msgid
                                        msgno        = message-msgno
                                        is_dependend = abap_false
                                      ) ) TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg = new_message(  id = message-msgid
                                           number = message-msgno
                                           v1 = message-msgv1
                                           v2 = message-msgv2
                                           v3 = message-msgv3
                                           v4 = message-msgv4
                                           severity = if_abap_behv_message=>severity-information
                                            )
                                            %cid = cid
                                            travelid = travelid ) TO reported.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_U_ROOT_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_U_ROOT_TRAVEL IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    /dmo/cl_flight_legacy=>get_instance( )->save( ).
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
