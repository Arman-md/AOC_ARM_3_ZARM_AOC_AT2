@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel attachment view'
@Metadata.ignorePropagatedAnnotations: false
define view entity ZI_U_TRAV_ATTACH
  as select from zarm_tab_attch
    association        to parent ZI_TRAV_ROOT      as _travel        on  $projection.TravelId = _travel.TravelId
{
  key travel_id             as TravelId,
  
    @EndUserText.label: 'Attachment Id'
  key id                    as Id,
  @EndUserText.label: 'Comments'
      memo                  as Memo,


      @Semantics.largeObject.mimeType: 'Filetype'
      @Semantics.largeObject.fileName: 'Filename'
      @Semantics.largeObject.contentDispositionPreference: #INLINE
  //    @Semantics.largeObject.acceptableMimeTypes: [ 'application/octet-stream' ]
      attachment            as Attachment,
      
        @EndUserText.label: 'File Name'
      filename              as Filename,

        @EndUserText.label: 'File Type'
      @Semantics.mimeType: true // means multimedia true
      filetype              as Filetype,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,

      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _travel
}
