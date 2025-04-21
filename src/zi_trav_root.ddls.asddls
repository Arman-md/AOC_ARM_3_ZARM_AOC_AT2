@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel root view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TRAV_ROOT
  as select from /dmo/travel_m
  -- composition child for travel viz booking
  composition [0..*] of ZI_BOOKING               as _booking
  -- Association to get dependant data
  
  composition [0..*] of ZI_U_TRAV_ATTACH as _attachment
  association [1]    to /DMO/I_Agency               as _agency     on $projection.AgencyId = _agency.AgencyID
  association [1]    to /DMO/I_Customer             as _customer   on $projection.CustomerId = _customer.CustomerID
  association [1]    to I_Currency                  as _currency   on $projection.CurrencyCode = _currency.Currency
  association [1..1] to /DMO/I_Overall_Status_VH as _overallstatus on $projection.OverallStatus = _overallstatus.OverallStatus
{
  key travel_id           as TravelId,
      agency_id           as AgencyId,
      _agency.Name        as AgencyName,
      customer_id         as CustomerId,
      _customer.FirstName as customername,
      begin_date          as BeginDate,
      end_date            as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee         as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price         as TotalPrice,
      currency_code       as CurrencyCode,
      description         as Description,
      overall_status      as OverallStatus,

      @Semantics.user.createdBy: true
      created_by          as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at          as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by     as LastChangedBy,

      //local etag field --> OData Etag
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at     as LastChangedAt,
      case overall_status
      when 'O' then 'Open'
      when 'A' then 'Approved'
      when 'R' then 'Rejected'
      when 'X' then 'Cancelled'
      else 'NULL'
      end                 as statustext,

      case overall_status
      when 'O' then '1'
      when 'A' then '3'
      when 'R' then '2'
      when 'X' then '2'
      else 'NULL'
      end                 as criticality,
      /*Expose the associations*/
      _booking,
      _attachment,
      _agency,
      _customer,
      _currency,
      _overallstatus
      

}
