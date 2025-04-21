@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suppliments Proc. Proj. layer'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: false
define view entity ZC_BOOK_SUPPL_PROC
  as projection on ZI_BOOK_SUPPL
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _booking : redirected to parent ZC_BOOKING_PROC,
      _PRODUCT,
      _supplementText,
      _travel  : redirected to ZC_TRAV_PROC
}
