@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Child'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BOOKING
  as select from /dmo/booking_m
  composition[0..*] of ZI_BOOK_SUPPL as _bookingsuppl
  association        to parent ZI_TRAV_ROOT      as _travel        on  $projection.TravelId = _travel.TravelId
  association [1]    to /DMO/I_Customer          as _customer      on  $projection.CustomerId = _customer.CustomerID
  association [1]    to /DMO/I_Carrier           as _carrier       on  $projection.CarrierId = _carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _connection    on  $projection.ConnectionId = _connection.ConnectionID
                                                                   and $projection.CarrierId    = _connection.AirlineID
  association [1..1] to /DMO/I_Booking_Status_VH as _bookingstatus on  $projection.BookingStatus = _bookingstatus.BookingStatus



{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      // expose associations
      _customer,
      _carrier,
      _connection,
      _bookingstatus,
      _travel,
      _bookingsuppl


}
