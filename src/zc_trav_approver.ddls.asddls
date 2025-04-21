@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Processor Projection layer'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity ZC_TRAV_APPROVER
  provider contract transactional_query
  as projection on ZI_TRAV_ROOT
{
  key TravelId,

//      @ObjectModel.text.element: [ 'AgencyName' ]
//      @Consumption.valueHelpDefinition: [{entity.name: '/DMO/I_Agency_StdVH',
//                                          entity.element: 'AgencyId'}]
      AgencyId,

      @Semantics.text: true
      AgencyName,

      @ObjectModel.text.element: [ 'customername' ]
      @Consumption.valueHelpDefinition: [{entity.name: '/DMO/I_Customer',
                                    entity.element: 'CustomerID'}]
      CustomerId,

      @Semantics.text: true
      customername,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      CurrencyCode,
      Description,

      @ObjectModel.text.element: [ 'statustext' ]
      @Consumption.valueHelpDefinition: [{entity.name: '/DMO/I_Overall_Status_VH',
                              entity.element: 'OverallStatus'}]
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,

      @Semantics.text: true
      statustext,
      criticality,
      /* Associations */
      _agency,
      _booking : redirected to composition child ZC_BOOKING_APPROVER,
      _currency,
      _customer,


      _overallstatus
   
      
      
      
}
