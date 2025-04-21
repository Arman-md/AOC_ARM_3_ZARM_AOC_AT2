@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Processor Projection layer'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: false
define view entity ZC_TRAV_ATTACH_PROC
  as projection on ZI_U_TRAV_ATTACH
{
  key TravelId,
  key Id,
      Memo,
      Attachment,
      Filename,
      Filetype,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _travel : redirected to parent ZC_TRAV_PROC
}
