CLASS lsc_zi_trav_root DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_trav_root IMPLEMENTATION.

  METHOD save_modified.

    DATA : travel_log_update TYPE STANDARD TABLE OF /dmo/log_travel,
           final_changes     TYPE STANDARD TABLE OF /dmo/log_travel.


    IF update-travel IS NOT INITIAL.
      travel_log_update = CORRESPONDING #(  update-travel MAPPING
                                                          travel_id = TravelId ).
      LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<travel_log_update>).

        ASSIGN travel_log_update[ travel_id = <travel_log_update>-TravelId ]
        TO FIELD-SYMBOL(<travel_log_db>).

        GET TIME STAMP FIELD <travel_log_db>-created_at.

        IF <travel_log_update>-%control-CustomerId = if_abap_behv=>mk-on.

          TRY.
              <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.

          <travel_log_db>-changed_field_name = 'arman_cust'.
          <travel_log_db>-changed_value = <travel_log_update>-CustomerId.
          <travel_log_db>-changing_operation = 'CHANGE'.

          APPEND <travel_log_db> TO final_changes.
        ENDIF.


        IF <travel_log_update>-%control-AgencyId = if_abap_behv=>mk-on.

          TRY.
              <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.

          <travel_log_db>-changed_field_name = 'arman_agency'.
          <travel_log_db>-changed_value = <travel_log_update>-AgencyId.
          <travel_log_db>-changing_operation = 'CHANGE'.

          APPEND <travel_log_db> TO final_changes.

        ENDIF.
      ENDLOOP.
    ENDIF.

    INSERT /dmo/log_travel FROM TABLE @final_changes.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS validateheaderdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateheaderdata.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE travel.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.

    TYPES: t_entity_create   TYPE TABLE FOR CREATE zi_trav_root,
           t_entity_update   TYPE TABLE FOR UPDATE zi_trav_root,
           t_entity_reported TYPE TABLE FOR REPORTED zi_trav_root,
           t_entity_error    TYPE TABLE FOR FAILED zi_trav_root.

    METHODS  precheck_reuse IMPORTING entities_u  TYPE t_entity_update OPTIONAL
                                      entities_c  TYPE t_entity_create OPTIONAL
                            EXPORTING lt_reported TYPE t_entity_reported
                                      lt_failed   TYPE t_entity_error.
ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    DATA : ls_result LIKE LINE OF result.
    " step 1 : get the instnace data
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel
    FIELDS (  TravelId OverallStatus )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(lt_travel)
    FAILED DATA(lt_failed).

    " step 2 : loop at the data
    LOOP AT lt_travel INTO DATA(ls_travel).

      " step 3 : check if instnace status is cancelled
      IF ls_travel-OverallStatus = 'X'.
        DATA(lv_auth) = abap_false.

        " step 4 : check authorization
*        "
*        AUTHORITY-CHECK OBJECT 'CUSTOM_AUTH_OBJ'
*        ID 'FIELD_NAME' FIELD field1.

        IF sy-subrc <> 0.
          lv_auth =  abap_true.
        ENDIF.
      ELSE.
        lv_auth = abap_true.
      ENDIF.

      " If permission is denied then pass the result to result table.
      " step 5 : if permission is denied, reject edit operation
      ls_result = VALUE #(  TravelId = ls_travel-TravelId
                            %update = COND #(  WHEN lv_auth = abap_false
                                                THEN if_abap_behv=>auth-unauthorized
                                                ELSE if_abap_behv=>auth-allowed )
                            %action-copytravel = COND #(  WHEN lv_auth = abap_false
                                                THEN if_abap_behv=>auth-unauthorized
                                                ELSE if_abap_behv=>auth-allowed ) ).

      APPEND ls_result TO result.

    ENDLOOP.


  ENDMETHOD.


  METHOD earlynumbering_create.
    DATA entity     TYPE STRUCTURE FOR CREATE zi_trav_root.
    DATA travid_max TYPE /dmo/travel_id.

    "" step 1 ensure travel id is not set for the record:
    LOOP AT entities INTO entity WHERE TravelId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.

    DATA(entities_wo_travid) = entities.

    DELETE entities_wo_travid WHERE TravelId IS NOT INITIAL.
    "" step 2 get the sequence number from the SNRO
    TRY.
        cl_NUMBERRANGE_RUNTIME=>number_get( EXPORTING nr_range_nr       = '01'
                                                      object            = '/DMO/TRAVL'
                                                      quantity          = CONV #( lines( entities_wo_travid ) )

                                            IMPORTING number            = DATA(number_range_key)
                                                      returncode        = DATA(number_range_code)
                                                      returned_quantity = DATA(number_range_qty) ).

        "" step 3 if there is an exception, throw an exception
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT entities_wo_travid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = lx_number_ranges  )
                 TO reported-travel.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key  ) TO failed-travel.
        ENDLOOP.
        EXIT.
    ENDTRY.

    "" step 4 handle the special cases where the number range exceeds the total digits

    CASE number_range_code.
      WHEN '1'.
        LOOP AT entities_wo_travid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>number_range_depleted
                                                              severity = if_abap_behv_message=>severity-warning )  )
                 TO reported-travel.
        ENDLOOP.
        "" step 5 the number range return last number or number exhausted.
      WHEN '2' OR '3'.
        LOOP AT entities_wo_travid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>not_sufficient_numbers
                                                              severity = if_abap_behv_message=>severity-warning )  )
                 TO reported-travel.

          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %fail-cause = if_abap_behv=>cause-conflict  ) TO failed-travel.
        ENDLOOP.
    ENDCASE.

    "" step 6 final check for all numbers
    ASSERT number_range_qty = lines( entities_wo_travid ).

    "" step 7 loop over incoming travel data and assign the numbers and return the mapped data
    " initialize the travel id
    travid_max = number_range_key - number_range_qty.
    LOOP AT entities_wo_travid INTO entity.
      travid_max +=  1.
      entity-TravelId = travid_max.
      APPEND VALUE #(  %cid = entity-%cid %key = entity-%key
                        " Map also the draft flag
                        %is_draft = entity-%is_draft
                        ) TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA: max_booking_id TYPE /dmo/booking_id.
    "" STEP 1 GET ALL TRAVEL IDS AND THEIR BOOKING IDS
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel BY \_booking
    FROM CORRESPONDING #( entities )
    LINK DATA(bookings).

    "" loop at unique ids

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<trav_grp>) GROUP BY <trav_grp>-TravelId.
      "" Step 2 get the highest existing booking id
      LOOP AT bookings INTO DATA(ls_bookings) "USING KEY entity
      WHERE source-TravelId = <trav_grp>-TravelId.
        IF max_booking_id < ls_bookings-target-BookingId.
          max_booking_id = ls_bookings-target-BookingId.
        ENDIF.
      ENDLOOP.
      "" step 3 get the assigned booking number for incoming requests
      LOOP AT entities INTO DATA(ls_entity) "USING KEY entity
      WHERE TravelId = <trav_grp>-TravelId.
        LOOP AT ls_entity-%target INTO DATA(ls_target).
          IF max_booking_id < ls_bookings-target-BookingId.
            max_booking_id = ls_bookings-target-BookingId.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      "" step 4 loop over all the entities of travel id
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>)
      "USING KEY entity
      WHERE TravelId = <trav_grp>-TravelId.
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_num>) .
          APPEND CORRESPONDING #( <booking_wo_num> ) TO mapped-booking
          ASSIGNING FIELD-SYMBOL(<mapped_booking>).
          IF <mapped_booking>-BookingId IS INITIAL.
            max_booking_id += 10.
            <mapped_booking>-BookingId = max_booking_id.
            <mapped_booking>-%is_draft = <booking_wo_num>-%is_draft.
          ENDIF.
        ENDLOOP.

      ENDLOOP.
      "" step 5 assign booking ids to the same travel id
    ENDLOOP.
  ENDMETHOD.

  METHOD copytravel.
    " create itabs
    DATA: lt_trav TYPE TABLE FOR CREATE zi_trav_root.
    DATA: lt_book_cba TYPE TABLE FOR CREATE zi_trav_root\\Travel\_booking.
    DATA: lt_booksuppl_cba TYPE TABLE FOR CREATE zi_trav_root\\Booking\_bookingsuppl.

    " step 1 : remove the travel instances with initial %cid
    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.

    " step 2 : read all travel, booking, book suppl data
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
         ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(travel_read_result)
         FAILED failed.

    READ ENTITIES OF zi_trav_root IN LOCAL MODE
         ENTITY travel BY \_booking ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(book_read_result)
         FAILED failed.

    READ ENTITIES OF zi_trav_root IN LOCAL MODE
         ENTITY Booking BY \_bookingsuppl ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(booksuppl_read_result)
         FAILED failed.

    " step 3 : fill travel itab, for travel data creation - %cid lets say 12345

    LOOP AT travel_read_result ASSIGNING FIELD-SYMBOL(<travel>).

      " Prepare Travel Data
      APPEND VALUE #(  %cid = keys[ %tky = <travel>-%tky ]-%cid
                       %data = CORRESPONDING #( <travel> EXCEPT travelId  ) ) TO lt_trav
                       ASSIGNING FIELD-SYMBOL(<new_trav>).

      " step 4 : fill booking itab, for booking data creation - %cid_ref = 12345
      <new_trav>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <new_trav>-endDate = cl_abap_context_info=>get_system_date( ) + 30.
      <new_trav>-OverallStatus = 'O'.

      " Prepare Booking data
      APPEND VALUE #(  %cid_ref = keys[ %tky = <travel>-%tky ]-%cid ) TO lt_book_cba
                       ASSIGNING FIELD-SYMBOL(<book>).

      LOOP AT book_read_result ASSIGNING FIELD-SYMBOL(<book_read>) "USING KEY entity
      WHERE TravelId = <travel>-TravelId.
        APPEND VALUE #( %cid = keys[ %tky = <travel>-%tky ]-%cid && <book_read>-BookingId
                        %data    = CORRESPONDING #( book_read_result[ %tky = <book_read>-%tky ] EXCEPT travelId )
                       ) TO <book>-%target ASSIGNING FIELD-SYMBOL(<new_book>).

        <new_book>-BookingStatus = 'N'.
        " step 5 : fill book suppl itab for suppl data attach %cid_ref

        " Prepare Booking suppl data
        APPEND VALUE #(  %cid_ref = keys[ %tky = <travel>-%tky ]-%cid && <book_read>-BookingId )
        TO lt_booksuppl_cba ASSIGNING FIELD-SYMBOL(<booksuppl>).
        LOOP AT booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl_read>) WHERE TravelId = <travel>-TravelId
                                                                                                  AND BookingId = <book_read>-BookingId.

          APPEND VALUE #( %cid = keys[  %tky = <travel>-%tky ]-%cid && <book_read>-BookingId && <booksuppl_read>-BookingSupplementId
                          %data    = CORRESPONDING #( <booksuppl_read> EXCEPT travelId BookingId )
                         ) TO <booksuppl>-%target ASSIGNING FIELD-SYMBOL(<new_booksuppl>).
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    " step 6 : call modify entity to create new BO instanace

    MODIFY ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel
    CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate TotalPrice CurrencyCode OverallStatus    )
    WITH lt_trav
    CREATE BY \_booking FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus  )
    WITH lt_book_cba

    ENTITY Booking
    CREATE BY \_bookingsuppl
    FIELDS ( BookingSupplementId  CurrencyCode Price SupplementId  )
    WITH lt_booksuppl_cba
    MAPPED DATA(mapped_create)
    FAILED failed
    REPORTED reported.

    mapped-travel = mapped_create-travel.
*    mapped-booking = mapped_create-booking.
*    mapped-booking_suppl = mapped_create-booking_suppl.

  ENDMETHOD.

  METHOD get_instance_features.

    " step 1: read travel status
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)
    FAILED failed.
    " step 2 : return the result with booking creation possible or not

    READ TABLE travels ASSIGNING FIELD-SYMBOL(<fs_travels>) INDEX 1.
    IF  <fs_travels> IS ASSIGNED.
      IF <fs_travels>-OverallStatus = 'X'. " REJECTED
        DATA(lv_allow) = if_abap_behv=>fc-o-disabled.
      ELSE.
        lv_allow = if_abap_behv=>fc-o-enabled.
      ENDIF.
    ENDIF.

    result = VALUE #( FOR travel IN travels
                       (  %tky = travel-%tky
                          %action-acceptTravel = COND #( WHEN travel-OverallStatus = 'A'
                                                            THEN if_abap_behv=>fc-o-disabled
                                                            ELSE if_abap_behv=>fc-o-enabled )

                        %action-rejectTravel = COND #( WHEN travel-OverallStatus = 'X'
                                                            THEN if_abap_behv=>fc-o-disabled
                                                            ELSE if_abap_behv=>fc-o-enabled )
                          %assoc-_booking = lv_allow )
                     ).


  ENDMETHOD.

  METHOD recalctotalprice.

    " define a structure & itab where we can store all the booking fees
    TYPES : BEGIN OF ty_amount_per_currency,
              amount        TYPE /dmo/total_price,
              currency_code TYPE /dmo/currency_code,
            END OF ty_amount_per_currency.
    DATA : amount_per_curr TYPE STANDARD TABLE OF ty_amount_per_currency.

    " read all travel instnaces , subsequent booking using EML

    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    " read booking

    READ ENTITIES OF zi_trav_root IN LOCAL MODE
ENTITY Travel BY \_booking
FIELDS ( FlightPrice CurrencyCode )
WITH CORRESPONDING #( travels )
RESULT DATA(bookings).
    " read booking supplements

    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY booking BY \_bookingsuppl
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( bookings )
    RESULT DATA(bookingsuppls).


    " delete all itab travels where you dont have currency
    DELETE travels WHERE CurrencyCode IS INITIAL.
    DELETE Bookings WHERE CurrencyCode IS INITIAL.
    DELETE bookingsuppls WHERE CurrencyCode IS INITIAL.

    " total all booking and supplement amounts which are in common currency

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      " set the first value for total price by adding the booking fee from header
      amount_per_curr =  VALUE #( ( amount = <travel>-BookingFee
                                  currency_code = <travel>-CurrencyCode ) ).
      " below 'using key entity' is just to avoid compiler waring

      " for bookings
      LOOP AT bookings INTO DATA(booking) USING KEY entity
      WHERE travelid = <travel>-TravelId.

        COLLECT VALUE ty_amount_per_currency(   amount = booking-FlightPrice
                                                 currency_code = booking-CurrencyCode
                                              ) INTO amount_per_curr.



        " for booking supplements

        LOOP AT bookingsuppls INTO DATA(booksuppl) USING KEY entity
        WHERE travelid = <travel>-TravelId
                                                                                .

          COLLECT VALUE ty_amount_per_currency(   amount = booksuppl-Price
                                                   currency_code = booksuppl-CurrencyCode
                                                ) INTO amount_per_curr.



        ENDLOOP.

        " clear existing total price
        CLEAR <travel>-TotalPrice.

        " perform currency conversion

        LOOP AT amount_per_curr INTO DATA(amountpercurr).

          " if same curr code then just add all the child amounts to header travel amount
          IF amountpercurr-currency_code = <travel>-CurrencyCode.
            <travel>-TotalPrice += amountpercurr-amount.
          ELSE.

            " convert to target currency from source currency
            /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                iv_amount               = amountpercurr-amount
                iv_currency_code_source = amountpercurr-currency_code
                iv_currency_code_target = <travel>-CurrencyCode
                iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
              IMPORTING
                ev_amount               = DATA(taregtamount)
            ).
            <travel>-TotalPrice += taregtamount.
          ENDIF.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP..
    " put back the amount to entity travel

    MODIFY ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS (  TotalPrice )
    WITH CORRESPONDING #( travels ).



  ENDMETHOD.

  METHOD calculatetotalprice.

    " invoke the internal action

    MODIFY ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel
    EXECUTE recalctotalprice
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD validateheaderdata.
    " step 1 : read travel header data
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel
    FIELDS ( CustomerId BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).


    " step 2 : declare a sorted table for customer IDs
    DATA: customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    " step 3 : extract the unique customer  ids in our table
    customers = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING
                                      customer_id = CustomerId EXCEPT * ).

    DELETE customers WHERE customer_id IS INITIAL.
    " get the validation done to all customer ids


    IF customers IS NOT INITIAL.
      SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @customers
      WHERE customer_id =  @customers-customer_id
      INTO TABLE @DATA(lt_cust_db).

    ENDIF.


    LOOP AT lt_travel INTO DATA(ls_travel).
      " validate customer ID
      IF ls_travel-CustomerId IS INITIAL OR
        NOT line_exists( lt_cust_db[ customer_id = ls_travel-CustomerId ]  ).

        "" inform rap to terminate

        APPEND VALUE #(  %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = ls_travel-%tky
                         %element-customerid = if_abap_behv=>mk-on
                         %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>customer_unkown
          customer_id           = ls_travel-CustomerId
          severity              =  if_abap_behv_message=>severity-error

        ) ) TO reported-travel.

      ENDIF.


      " validate the dates

      IF ( ls_travel-EndDate < ls_travel-BeginDate ) .
        "" exercise : validation
        " check if begin and end date is empty
        " check if end date is always greater than begin date
        " check if end date is always in future.

        APPEND VALUE #(  %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = ls_travel-%tky
                         %element-begindate = if_abap_behv=>mk-on
                         %element-enddate = if_abap_behv=>mk-on
                         %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>begin_date_bef_end_date
          begin_date           = ls_travel-BeginDate
          end_date           = ls_travel-EndDate
          severity              =  if_abap_behv_message=>severity-error

        ) ) TO reported-travel.


      ENDIF.


      IF ( ls_travel-EndDate IS INITIAL ).
        APPEND VALUE #(  %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = ls_travel-%tky
                         %element-enddate = if_abap_behv=>mk-on
                         %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>enter_end_date
          end_date           = ls_travel-EndDate
          severity              =  if_abap_behv_message=>severity-error

        ) ) TO reported-travel.

      ENDIF.

      IF ls_travel-BeginDate IS INITIAL .

        APPEND VALUE #(  %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = ls_travel-%tky
                         %element-enddate = if_abap_behv=>mk-on
                         %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>enter_begin_date
          begin_date           = ls_travel-BeginDate
          severity              =  if_abap_behv_message=>severity-error

        ) ) TO reported-travel.

      ENDIF.


      IF  ls_travel-EndDate < cl_abap_context_info=>get_system_date( ) .

        APPEND VALUE #(  %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = ls_travel-%tky
                         %element-enddate = if_abap_behv=>mk-on
                         %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
          end_date           = ls_travel-EndDate
          severity              =  if_abap_behv_message=>severity-error

        ) ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_create.



    precheck_reuse(
      EXPORTING
*        entities_u =
        entities_c = entities
      IMPORTING
        lt_reported   = reported-travel
        lt_failed     = failed-travel
    ).

  ENDMETHOD.

  METHOD precheck_update.

    precheck_reuse(
      EXPORTING
*        entities_u =
        entities_u = entities
      IMPORTING
        lt_reported   = reported-travel
        lt_failed     = failed-travel
    ).


  ENDMETHOD.

  METHOD precheck_reuse.

    " step 1 : declare data
    DATA : entities  TYPE t_entity_update,
           operation TYPE if_abap_behv=>t_char01,
           agencies  TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id,
           customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

*    " step 2 : check if entity create or update was passed.
*    ASSERT NOT (  entities_c IS INITIAL EQUIV entities_u IS  INITIAL ).

    " step 3 : perform validation only if agency or customer was changed.
    IF entities_c IS NOT INITIAL.
      entities = CORRESPONDING #( entities_c ).
      operation = if_abap_behv=>op-m-create.
    ELSE.
      entities = CORRESPONDING #( entities_u ).
      operation = if_abap_behv=>op-m-update.
    ENDIF.

    DELETE entities WHERE %control-AgencyId = if_abap_behv=>mk-off AND
                          %control-CustomerId = if_abap_behv=>mk-off.

    " step 4 : get all the unique agency and customers in a table

    agencies = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING agency_id = agencyid EXCEPT * ).
    customers = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    " step 5 : get agency and cust data

    SELECT FROM /dmo/agency FIELDS agency_id, country_code
    FOR ALL ENTRIES IN @agencies WHERE agency_id = @agencies-agency_id
    INTO TABLE @DATA(agency_cntry_codes).

    SELECT FROM /dmo/customer FIELDS customer_id, country_code
FOR ALL ENTRIES IN @customers WHERE customer_id = @customers-customer_id
INTO TABLE @DATA(customer_cntry_codes).


    " step 6 : loop over incoming entities and compare each agency and customer country
    LOOP AT entities INTO DATA(entity).
      READ TABLE agency_cntry_codes WITH KEY agency_id = entity-AgencyId INTO DATA(ls_agency).
      CHECK sy-subrc = 0.
      READ TABLE customer_cntry_codes WITH KEY customer_id = entity-CustomerId INTO DATA(ls_customer).
      CHECK sy-subrc = 0.
      IF ls_agency-country_code <> ls_customer-country_code.
        " step 7 : country doesnt match throw error


        APPEND VALUE #(   %cid = COND #(  WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                          %is_draft = entity-%is_draft
                          %fail-cause = if_abap_behv=>cause-conflict
                         )  TO lt_failed.

        APPEND VALUE #(  %cid = COND #(  WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                  %is_draft = entity-%is_draft
                 %msg = NEW /dmo/cm_flight_messages(
                                            textid                = VALUE #(
                                                                             msgid = 'SY'
                                                                             msgno = 499
                                                                              attr1 = 'The Countru codes for agency and customer dont match'

                                          )
          agency_id             = entity-AgencyId
          customer_id           = entity-CustomerId
          severity              = if_abap_behv_message=>severity-error
            )
          %element-agencyid       = if_abap_behv=>mk-on

                 ) TO lt_reported.

      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD acceptTravel.

    " perform the chnage of BO instance to chnage status
    MODIFY ENTITIES OF Zi_TRAV_ROOT IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys
                ( %tky = key-%tky
                  %is_draft = key-%is_draft
                  OverallStatus = 'A' )
                  ).
    " read the BO instance on which we wanna make the changes
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR travel IN lt_result
                        ( %tky = travel-%tky
                          %param = travel ) ).


  ENDMETHOD.

  METHOD rejectTravel.

    " perform the chnage of BO instance to chnage status
    MODIFY ENTITIES OF Zi_TRAV_ROOT IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys
                ( %tky = key-%tky
                  %is_draft = key-%is_draft
                  OverallStatus = 'X' )
                  ).
    " read the BO instance on which we wanna make the changes
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR travel IN lt_result
                        ( %tky = travel-%tky
                          %param = travel ) ).


  ENDMETHOD.

ENDCLASS.
