from dxfeed.core.pxd_include.DXTypes cimport *

cdef extern from "DXErrorCodes.h":
    ctypedef enum dx_error_code_t:
    # # /* common error codes */
    
        dx_ec_success = 0
        
        dx_ec_error_subsystem_failure  # # /* this code may be set if passed from another thread */
        
        dx_ec_invalid_func_param  # # /* the invalid param is submitted by client */
        dx_ec_invalid_func_param_internal  # # /* the invalid param is a result of internal error */
        
        dx_ec_internal_assert_violation
        
        # # /* memory error codes */
        
        dx_mec_insufficient_memory
        
        # # /* socket error codes */
        
        dx_sec_socket_subsystem_init_failed,  # # /* Win32-specific */
        dx_sec_socket_subsystem_init_required,  # # /* Win32-specific */
        dx_sec_socket_subsystem_incompatible_version,  # # /* Win32-specific */
        dx_sec_connection_gracefully_closed
        dx_sec_network_is_down
        dx_sec_blocking_call_in_progress
        dx_sec_addr_family_not_supported
        dx_sec_no_sockets_available
        dx_sec_no_buffer_space_available
        dx_sec_proto_not_supported
        dx_sec_socket_type_proto_incompat
        dx_sec_socket_type_addrfam_incompat
        dx_sec_addr_already_in_use
        dx_sec_blocking_call_interrupted
        dx_sec_nonblocking_oper_pending
        dx_sec_addr_not_valid
        dx_sec_connection_refused
        dx_sec_invalid_ptr_arg
        dx_sec_invalid_arg
        dx_sec_sock_already_connected
        dx_sec_network_is_unreachable
        dx_sec_sock_oper_on_nonsocket
        dx_sec_connection_timed_out
        dx_sec_res_temporarily_unavail
        dx_sec_permission_denied
        dx_sec_network_dropped_connection
        dx_sec_socket_not_connected
        dx_sec_operation_not_supported
        dx_sec_socket_shutdown
        dx_sec_message_too_long
        dx_sec_no_route_to_host
        dx_sec_connection_aborted
        dx_sec_connection_reset
        dx_sec_persistent_temp_error
        dx_sec_unrecoverable_error
        dx_sec_not_enough_memory
        dx_sec_no_data_on_host
        dx_sec_host_not_found
    
        dx_sec_generic_error
        
        # /* thread error codes */
        
        dx_tec_not_enough_sys_resources
        dx_tec_permission_denied
        dx_tec_invalid_res_operation
        dx_tec_invalid_resource_id
        dx_tec_deadlock_detected
        dx_tec_not_enough_memory
        dx_tec_resource_busy
    
        dx_tec_generic_error
        
        # /* network error codes */
        
        dx_nec_invalid_port_value
        dx_nec_invalid_function_arg
        dx_nec_connection_closed
        dx_nec_open_connection_error
        dx_nec_unknown_codec
        
        # /* buffered I/O error codes */
        
        dx_bioec_buffer_overflow
        dx_bioec_buffer_not_initialized
        dx_bioec_index_out_of_bounds
        dx_bioec_buffer_underflow
        
        # /* UTF error codes */
        
        dx_utfec_bad_utf_data_format
        dx_utfec_bad_utf_data_format_server
        
        # /* penta codec error codes */
        
        dx_pcec_reserved_bit_sequence
        dx_pcec_invalid_symbol_length
        dx_pcec_invalid_event_flag
        
        # /* event subscription error codes */
        
        dx_esec_invalid_event_type
        dx_esec_invalid_subscr_id
        dx_esec_invalid_symbol_name
        dx_esec_invalid_listener
        
        # /* logger error codes */
        
        dx_lec_failed_to_open_file
        
        # /* protocol message error codes */
        
        dx_pmec_invalid_message_type
        
        # /* protocol error codes */
        
        dx_pec_unexpected_message_type
        dx_pec_unexpected_message_type_internal
        dx_pec_descr_record_field_info_corrupted
        dx_pec_message_incomplete
        dx_pec_invalid_message_length
        dx_pec_server_message_not_supported
        dx_pec_invalid_symbol
        dx_pec_record_description_not_received
        dx_pec_record_field_type_not_supported
        dx_pec_record_info_corrupted
        dx_pec_unknown_record_name
        dx_pec_record_not_supported
        dx_pec_describe_protocol_message_corrupted
        dx_pec_unexpected_message_sequence_internal
        dx_pec_local_message_not_supported_by_server
        dx_pec_inconsistent_message_support
        dx_pec_authentication_error
        dx_pec_credentials_required
        
        # /* connection error codes */
        
        dx_cec_invalid_connection_handle
        dx_cec_invalid_connection_handle_internal
        dx_cec_connection_context_not_initialized
        dx_cec_invalid_connection_context_subsystem_id
    
        # /* candle event error codes*/
    
        dx_ceec_invalid_candle_period_value
    
    
        # /* snapshot error codes */
    
        dx_ssec_invalid_snapshot_id
        dx_ssec_invalid_event_id
        dx_ssec_invalid_symbol
        dx_ssec_snapshot_exist
        dx_ssec_invalid_listener
        dx_ssec_unknown_state
        dx_ssec_duplicate_record
    
        # /* configuration record serialization deserialization error codes */
    
        dx_csdec_protocol_error
        dx_csdec_unsupported_version
        
        # /* miscellaneous error codes */
        
        # /* error code count */
        # /* this MUST be the last element in the enumeration */
        
        dx_ec_count


# # /* -------------------------------------------------------------------------- */
# # /*
#  *	Message description functions
#  */
# # /* -------------------------------------------------------------------------- */

cdef dxf_const_string_t dx_get_error_description (dx_error_code_t code)
    