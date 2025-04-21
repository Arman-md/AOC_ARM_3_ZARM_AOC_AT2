@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unmanaged travel root view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_U_ROOT_TRAVEL
  as select from /dmo/travel
  association [1] to ZI_U_AGENCY             as _agency   on $projection.AgencyId = _agency.AgencyId
  association [1] to ZI_U_CUSTOMER           as _customer on $projection.CustomerId = _customer.CustomerId
  association [1] to I_Currency              as _currency on $projection.CurrencyCode = _currency.Currency
  association [1] to /DMO/I_Travel_Status_VH as _travstat on $projection.Status = _travstat.TravelStatus
{
      @ObjectModel.text.element: [ 'Description' ]
  key /dmo/travel.travel_id                                              as TravelId,

      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_U_AGENCY',
                                                     element: 'AgencyId'} }]
      /dmo/travel.agency_id                                              as AgencyId,
      _agency.Name                                                       as AgencyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_U_CUSTOMER',
                                                     element: 'CustomerId'} }]
      /dmo/travel.customer_id                                            as CustomerId,
      _customer.CustomerName                                             as CustomerName,
      /dmo/travel.begin_date                                             as BeginDate,
      /dmo/travel.end_date                                               as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      /dmo/travel.booking_fee                                            as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      /dmo/travel.total_price                                            as TotalPrice,
      /dmo/travel.currency_code                                          as CurrencyCode,
      /dmo/travel.description                                            as Description,

      @ObjectModel.text.element: [ 'TravelStatus' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Travel_Status_VH',
                                                     element: 'TravelStatus'} }]
      /dmo/travel.status                                                 as Status,
      _travstat._Text[Language = $session.system_language ].TravelStatus as TravelStatus,
      /dmo/travel.createdby                                              as Createdby,
      /dmo/travel.createdat                                              as Createdat,
      /dmo/travel.lastchangedby                                          as Lastchangedby,
      /dmo/travel.lastchangedat                                          as Lastchangedat,
      _agency,
      _customer,
      _currency,
      _travstat
}
