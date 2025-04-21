*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations


CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Bookingsuppl.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculatetotalprice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.
  METHOD earlynumbering_cba_Bookingsupp.
    DATA: max_bookingsuppl_id TYPE /dmo/booking_supplement_id.

    "" STEP 1 GET ALL BOOKING IDS AND THEIR BOOKING SUPPL IDS
    READ ENTITIES OF zi_trav_root IN LOCAL MODE
         ENTITY Booking BY \_bookingsuppl
         FROM CORRESPONDING #( entities )
         LINK DATA(bookingsuppl).

    "" loop at unique ids

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<book_grp>) GROUP BY <book_grp>-%tky.
      "" Step 2 get the highest existing booking suppl id
      LOOP AT bookingsuppl INTO DATA(ls_bookingsuppl) "USING KEY entity
           WHERE     source-TravelId  = <book_grp>-TravelId
                 AND source-BookingId = <book_grp>-BookingId.
        IF max_bookingsuppl_id < ls_bookingsuppl-target-BookingSupplementId.
          max_bookingsuppl_id = ls_bookingsuppl-target-BookingSupplementId.
        ENDIF.
      ENDLOOP.
      "" step 3 get the assigned booking suppl number for incoming requests
      LOOP AT entities INTO DATA(ls_entity) "USING KEY entity
           WHERE TravelId = <book_grp>-TravelId AND BookingId = <book_grp>-BookingId.
        LOOP AT ls_entity-%target INTO DATA(ls_target).
          IF max_bookingsuppl_id < ls_bookingsuppl-target-BookingSupplementId.
            max_bookingsuppl_id = ls_bookingsuppl-target-BookingSupplementId.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      "" step 4 loop over all the entities of booking id
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>)
          " USING KEY entity
           WHERE TravelId = <book_grp>-TravelId AND BookingId = <book_grp>-BookingId.
        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<bookingsuppl_wo_num>).
          APPEND CORRESPONDING #( <bookingsuppl_wo_num> ) TO mapped-booking_suppl
                 ASSIGNING FIELD-SYMBOL(<mapped_bookingsuppl>).
          "" step 5 assign booking suppl ids to the same booking
          IF <mapped_bookingsuppl>-BookingSupplementId IS INITIAL.
            max_bookingsuppl_id += 1.
            <mapped_bookingsuppl>-BookingSupplementId = max_bookingsuppl_id.
            <mapped_bookingsuppl>-%is_draft = <bookingsuppl_wo_num>-%is_draft.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatetotalprice.
    DATA : travel_ids TYPE STANDARD TABLE OF zi_trav_root WITH UNIQUE HASHED KEY
                                                      key COMPONENTS travelid.
    travel_ids = CORRESPONDING #(  keys DISCARDING DUPLICATES MAPPING travelid = travelid ).

*    MODIFY ENTITIES OF zi_trav_root IN LOCAL MODE
*    ENTITY travel
*    EXECUTE recalctotalprice
*    FROM CORRESPONDING #(  travel_ids ).


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

ENDCLASS.
