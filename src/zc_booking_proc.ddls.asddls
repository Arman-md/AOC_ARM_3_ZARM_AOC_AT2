@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Processor Projection layer'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: false
define view entity ZC_BOOKING_PROC
  as projection on ZI_BOOKING
{
  key TravelId,

  key BookingId,
      BookingDate,
      @Consumption.valueHelpDefinition: [{entity.name: '/DMO/I_Customer_StdVH',
                                    entity.element: 'CustomerID'}]
      CustomerId,
      @Consumption.valueHelpDefinition: [{entity.name: '/DMO/I_Carrier_StdVH',
                                         entity.element: 'AirlineID'}]
      CarrierId,
      @Consumption.valueHelpDefinition: [{entity.name: '/DMO/I_Connection_StdVH',
                                   entity.element: 'ConnectionID',
                                   additionalBinding: [{
                                                        localElement: 'CarrierId',
                                                        element: 'AirlineID'  }]}]
      ConnectionId,
      FlightDate,
      FlightPrice,

      CurrencyCode,
      @Consumption.valueHelpDefinition: [{entity.name: '/DMO/I_Booking_Status_VH',
                                         entity.element: 'BookingStatus'}]
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _bookingstatus,

      _bookingsuppl : redirected to composition child ZC_BOOK_SUPPL_PROC,
      _carrier,
      _connection,
      _customer,
      _travel       : redirected to parent ZC_TRAV_PROC
}
