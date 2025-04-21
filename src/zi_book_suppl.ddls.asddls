@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking suppliment leaf view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BOOK_SUPPL
  as select from /dmo/booksuppl_m
  association to parent ZI_BOOKING as _booking on $projection.BookingId = _booking.BookingId
                                              and $projection.TravelId   = _booking.TravelId
  association [1..1] to ZI_TRAV_ROOT          as _travel         on $projection.TravelId = _travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _PRODUCT        on $projection.SupplementId = _PRODUCT.SupplementID
  association [1..*] to /DMO/I_SupplementText as _supplementText on $projection.SupplementId = _supplementText.SupplementID

{

  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,

      //local etag field --> OData Etag
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _travel,
      _PRODUCT,
      _supplementText,
      _booking

}
