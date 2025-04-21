@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Processor Projection layer'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: false
define view entity ZC_BOOKING_APPROVER
  as projection on ZI_BOOKING
{
  key TravelId,

  key BookingId,
      BookingDate,

      CustomerId,

      CarrierId,

      ConnectionId,
      FlightDate,
      FlightPrice,

      CurrencyCode,

      BookingStatus,
      LastChangedAt,
      /* Associations */
      _bookingstatus,
      
      _carrier,
      _connection,
      _customer,
      _travel       : redirected to parent ZC_TRAV_APPROVER
}
