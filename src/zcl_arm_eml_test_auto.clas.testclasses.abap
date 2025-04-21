*"!@testing SRVB:ZSB_V2_PROC
*CLASS ltc_CREATE DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
*
*PRIVATE SECTION.
*
*
*METHODS: SETUP RAISING cx_static_check,
* CREATE FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*CLASS ltc_CREATE IMPLEMENTATION.
*
*
*METHOD CREATE.
*DATA:
*  ls_business_data TYPE zi_trav_root,
*  lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*  lo_request       TYPE REF TO /iwbep/if_cp_request_create,
*  lo_response      TYPE REF TO /iwbep/if_cp_response_create.
*
*
*lo_client_proxy = /iwbep/cl_cp_factory_unit_tst=>create_v2_local_proxy(
*                EXPORTING
*                  is_service_key     = VALUE #( service_id      = 'ZSB_V2_PROC'
*
*                                                service_version = '0001' )
*                   iv_do_write_traces = abap_true ).
*
*
** Prepare business data
*ls_business_data = VALUE #(
*          m_delete         = abap_true
*          m_update         = abap_true
*          o__booking       = abap_true
*          travelid         = '1'
*          v_travelid       = 'VTravelid'
*          agencyid         = '1'
*          v_agencyid       = 'VAgencyid'
*          agencyname       = 'Agencyname'
*          v_agencyname     = 'VAgencyname'
*          customerid       = '1'
*          v_customerid     = 'VCustomerid'
*          customername     = 'Customername'
*          v_customername   = 'VCustomername'
*          begindate        = '20170101'
*          v_begindate      = 'VBegindate'
*          enddate          = '20170101'
*          v_enddate        = 'VEnddate'
*          bookingfee       = '1'
*          v_bookingfee     = 'VBookingfee'
*          totalprice       = '1'
*          v_totalprice     = 'VTotalprice'
*          currencycode     = 'Currencycode'
*          v_currencycode   = 'VCurrencycode'
*          description      = 'Description'
*          v_description    = 'VDescription'
*          overallstatus    = 'Overallstatus'
*          v_overallstatus  = 'VOverallstatus'
*          createdby        = 'Createdby'
*          v_createdby      = 'VCreatedby'
*          createdat        = 20170101123000
*          v_createdat      = 'VCreatedat'
*          lastchangedby    = 'Lastchangedby'
*          v_lastchangedby  = 'VLastchangedby'
*          lastchangedat    = 20170101123000
*          v_lastchangedat  = 'VLastchangedat'
*          statustext       = 'Statustext'
*          v_statustext     = 'VStatustext'
*          criticality      = 'Criticality'
*          v_criticality    = 'VCriticality' ).
*
*" Navigate to the resource and create a request for the create operation
*lo_request = lo_client_proxy->create_resource_for_entity_set( 'travel' )->create_request_for_create( ).
*
*" Set the business data for the created entity
*lo_request->set_business_data( ls_business_data ).
*
*" Execute the request
*lo_response = lo_request->execute( ).
*
*" Get the after image
**lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).
*
*cl_abap_unit_assert=>fail( 'Implement your assertions' ).
*ENDMETHOD.
*
*ENDCLASS.
*
*"!@testing SRVB:ZSB_V2_PROC
*CLASS ltc_READ_ENTITY DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
*
*PRIVATE SECTION.
*
*
*METHODS: SETUP RAISING cx_static_check,
* READ_ENTITY FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*CLASS ltc_READ_ENTITY IMPLEMENTATION.
*
*
*METHOD READ_ENTITY.
*DATA:
*  ls_entity_key    TYPE <structure_name>,
*  ls_business_data TYPE <structure_name>,
*  lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
*  lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*  lo_request       TYPE REF TO /iwbep/if_cp_request_read,
*  lo_response      TYPE REF TO /iwbep/if_cp_response_read.
*
*
*
*     lo_client_proxy = /iwbep/cl_cp_factory_unit_tst=>create_v2_local_proxy(
*                     EXPORTING
*                       is_service_key     = VALUE #( service_id      = 'ZSB_V2_PROC'
*
*                                                     service_version = '0001' )
*                        iv_do_write_traces = abap_true ).
*
*
*" Set entity key
*ls_entity_key = VALUE #(
*          travelid  = '1' ).
*
*" Navigate to the resource
*lo_resource = lo_client_proxy->create_resource_for_entity_set( 'travel' )->navigate_with_key( ls_entity_key ).
*
*" Execute the request and retrieve the business data
*lo_response = lo_resource->create_request_for_read( )->execute( ).
*lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).
*
*cl_abap_unit_assert=>fail( 'Implement your assertions' ).
*ENDMETHOD.
*
*ENDCLASS.
*
*"!@testing SRVB:ZSB_V2_PROC
*CLASS ltc_READ_LIST DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
*
*PRIVATE SECTION.
*
*
*METHODS: SETUP RAISING cx_static_check,
* READ_LIST FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*CLASS ltc_READ_LIST IMPLEMENTATION.
*
*
*METHOD READ_LIST.
*DATA:
*  lt_business_data TYPE TABLE OF <structure_name>,
*  lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*  lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
*  lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.
*
**DATA:
** lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
** lo_filter_node_1    TYPE REF TO /iwbep/if_cp_filter_node,
** lo_filter_node_2    TYPE REF TO /iwbep/if_cp_filter_node,
** lo_filter_node_root TYPE REF TO /iwbep/if_cp_filter_node,
** lt_range_M_DELETE TYPE RANGE OF sadl_gw_dynamic_meth_property,
** lt_range_M_UPDATE TYPE RANGE OF sadl_gw_dynamic_meth_property.
*
*
*
*     lo_client_proxy = /iwbep/cl_cp_factory_unit_tst=>create_v2_local_proxy(
*                     EXPORTING
*                       is_service_key     = VALUE #( service_id      = 'ZSB_V2_PROC'
*
*                                                     service_version = '0001' )
*                        iv_do_write_traces = abap_true ).
*
*
*" Navigate to the resource and create a request for the read operation
*lo_request = lo_client_proxy->create_resource_for_entity_set( 'travel' )->create_request_for_read( ).
*
*" Create the filter tree
**lo_filter_factory = lo_request->create_filter_factory( ).
**
**lo_filter_node_1  = lo_filter_factory->create_by_range( iv_property_path     = 'M_DELETE'
**                                                        it_range             = lt_range_M_DELETE ).
**lo_filter_node_2  = lo_filter_factory->create_by_range( iv_property_path     = 'M_UPDATE'
**                                                        it_range             = lt_range_M_UPDATE ).
*
**lo_filter_node_root = lo_filter_node_1->and( lo_filter_node_2 ).
**lo_request->set_filter( lo_filter_node_root ).
*
*lo_request->set_top( 50 )->set_skip( 0 ).
*
*" Execute the request and retrieve the business data
*lo_response = lo_request->execute( ).
*lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
*
*cl_abap_unit_assert=>fail( 'Implement your assertions' ).
*ENDMETHOD.
*
*ENDCLASS.
*
*"!@testing SRVB:ZSB_V2_PROC
*CLASS ltc_UPDATE DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
*
*PRIVATE SECTION.
*
*
*METHODS: SETUP RAISING cx_static_check,
* UPDATE FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*CLASS ltc_UPDATE IMPLEMENTATION.
*
*
*METHOD UPDATE.
*DATA:
*  ls_business_data TYPE <structure_name>,
*  ls_entity_key    TYPE <structure_name>,
*  lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*  lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
*  lo_request       TYPE REF TO /iwbep/if_cp_request_update,
*  lo_response      TYPE REF TO /iwbep/if_cp_response_update.
*
*
*
*lo_client_proxy = /iwbep/cl_cp_factory_unit_tst=>create_v2_local_proxy(
*                EXPORTING
*                  is_service_key     = VALUE #( service_id      = 'ZSB_V2_PROC'
*
*                                                service_version = '0001' )
*                   iv_do_write_traces = abap_true ).
*
*
*" Set entity key
*ls_entity_key = VALUE #(
*          travelid  = '1' ).
*
*" Prepare the business data
*ls_business_data = VALUE #(
*          m_delete         = abap_true
*          m_update         = abap_true
*          o__booking       = abap_true
*          travelid         = '1'
*          v_travelid       = 'VTravelid'
*          agencyid         = '1'
*          v_agencyid       = 'VAgencyid'
*          agencyname       = 'Agencyname'
*          v_agencyname     = 'VAgencyname'
*          customerid       = '1'
*          v_customerid     = 'VCustomerid'
*          customername     = 'Customername'
*          v_customername   = 'VCustomername'
*          begindate        = '20170101'
*          v_begindate      = 'VBegindate'
*          enddate          = '20170101'
*          v_enddate        = 'VEnddate'
*          bookingfee       = '1'
*          v_bookingfee     = 'VBookingfee'
*          totalprice       = '1'
*          v_totalprice     = 'VTotalprice'
*          currencycode     = 'Currencycode'
*          v_currencycode   = 'VCurrencycode'
*          description      = 'Description'
*          v_description    = 'VDescription'
*          overallstatus    = 'Overallstatus'
*          v_overallstatus  = 'VOverallstatus'
*          createdby        = 'Createdby'
*          v_createdby      = 'VCreatedby'
*          createdat        = 20170101123000
*          v_createdat      = 'VCreatedat'
*          lastchangedby    = 'Lastchangedby'
*          v_lastchangedby  = 'VLastchangedby'
*          lastchangedat    = 20170101123000
*          v_lastchangedat  = 'VLastchangedat'
*          statustext       = 'Statustext'
*          v_statustext     = 'VStatustext'
*          criticality      = 'Criticality'
*          v_criticality    = 'VCriticality' ).
*
*" Navigate to the resource and create a request for the update operation
*lo_resource = lo_client_proxy->create_resource_for_entity_set( 'travel' )->navigate_with_key( ls_entity_key ).
*lo_request = lo_resource->create_request_for_update( /iwbep/if_cp_request_update=>gcs_update_semantic-put ).
*
*
*lo_request->set_business_data( ls_business_data ).
*
*" Execute the request and retrieve the business data
*lo_response = lo_request->execute( ).
*
*" Get updated entity
**CLEAR ls_business_data.
**lo_response->get_business_data( importing es_business_data = ls_business_data ).
*cl_abap_unit_assert=>fail( 'Implement your assertions' ).
*ENDMETHOD.
*
*ENDCLASS.
*
*"!@testing SRVB:ZSB_V2_PROC
*CLASS ltc_DELETE_ENTITY DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
*
*PRIVATE SECTION.
*
*
*METHODS: SETUP RAISING cx_static_check,
* DELETE_ENTITY FOR TESTING RAISING cx_static_check.
*
*ENDCLASS.
*
*CLASS ltc_DELETE_ENTITY IMPLEMENTATION.
*
*
*METHOD DELETE_ENTITY.
*DATA:
*  ls_entity_key    TYPE <structure_name>,
*  ls_business_data TYPE <structure_name>,
*  lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
*  lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*  lo_request       TYPE REF TO /iwbep/if_cp_request_delete.
*
*
*     lo_client_proxy = /iwbep/cl_cp_factory_unit_tst=>create_v2_local_proxy(
*                     EXPORTING
*                       is_service_key     = VALUE #( service_id      = 'ZSB_V2_PROC'
*
*                                                     service_version = '0001' )
*                        iv_do_write_traces = abap_true ).
*
*
*"Set entity key
*ls_entity_key = VALUE #(
*          travelid  = '1' ).
*
*"Navigate to the resource and create a request for the delete operation
*lo_resource = lo_client_proxy->create_resource_for_entity_set( 'travel' )->navigate_with_key( ls_entity_key ).
*lo_request = lo_resource->create_request_for_delete( ).
*
*
*" Execute the request
*lo_request->execute( ).
*
*cl_abap_unit_assert=>fail( 'Implement your assertions' ).
*ENDMETHOD.
*
*ENDCLASS.
