# /*
#  * The contents of this file are subject to the Mozilla Public License Version
#  * 1.1 (the "License"); you may not use this file except in compliance with
#  * the License. You may obtain a copy of the License at
#  * http://www.mozilla.org/MPL/
#  *
#  * Software distributed under the License is distributed on an "AS IS" basis,
#  * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
#  * for the specific language governing rights and limitations under the
#  * License.
#  *
#  * The Initial Developer of the Original Code is Devexperts LLC.
#  * Portions created by the Initial Developer are Copyright (C) 2010
#  * the Initial Developer. All Rights Reserved.
#  *
#  * Contributor(s):
#  *
#  */

#ifndef DX_ERROR_CODES_H_INCLUDED
#define DX_ERROR_CODES_H_INCLUDED

#include "DXTypes.h"
from dxfeed.core.pxd_include.DXTypes cimport *

# /**
#  * @file
#  * @brief dxFeed C API errors declarations
#  */
#
# /* -------------------------------------------------------------------------- */
# /*
#  *	Error codes
#  */
# /* -------------------------------------------------------------------------- */

cdef extern from "DXErrorCodes.h":
    # /// Error level
    ctypedef enum dx_error_level_t:
        dx_el_info = 0,
        dx_el_warn = 1,
        dx_el_error = 2

    # /// Error code
    ctypedef enum dx_error_code_t:
         # /* common error codes */

        dx_ec_success = 0,

        dx_ec_error_subsystem_failure = 1,	    # /* this code may be set if passed from another thread */
        dx_ec_invalid_func_param = 2,		    # /* the invalid param is submitted by client */
        dx_ec_invalid_func_param_internal = 3,  # /* the invalid param is a result of internal error */
        dx_ec_internal_assert_violation = 4,

         # /* memory error codes */

        dx_mec_insufficient_memory = 5,

         # /* socket error codes */

        dx_sec_socket_subsystem_init_failed = 6,		   # /* Win32-specific */
        dx_sec_socket_subsystem_init_required = 7,		   # /* Win32-specific */
        dx_sec_socket_subsystem_incompatible_version = 8,  # /* Win32-specific */
        dx_sec_connection_gracefully_closed = 9,
        dx_sec_network_is_down = 10,
        dx_sec_blocking_call_in_progress = 11,
        dx_sec_addr_family_not_supported = 12,
        dx_sec_no_sockets_available = 13,
        dx_sec_no_buffer_space_available = 14,
        dx_sec_proto_not_supported = 15,
        dx_sec_socket_type_proto_incompat = 16,
        dx_sec_socket_type_addrfam_incompat = 17,
        dx_sec_addr_already_in_use = 18,
        dx_sec_blocking_call_interrupted = 19,
        dx_sec_nonblocking_oper_pending = 20,
        dx_sec_addr_not_valid = 21,
        dx_sec_connection_refused = 22,
        dx_sec_invalid_ptr_arg = 23,
        dx_sec_invalid_arg = 24,
        dx_sec_sock_already_connected = 25,
        dx_sec_network_is_unreachable = 26,
        dx_sec_sock_oper_on_nonsocket = 27,
        dx_sec_connection_timed_out = 28,
        dx_sec_res_temporarily_unavail = 29,
        dx_sec_permission_denied = 30,
        dx_sec_network_dropped_connection = 31,
        dx_sec_socket_not_connected = 32,
        dx_sec_operation_not_supported = 33,
        dx_sec_socket_shutdown = 34,
        dx_sec_message_too_long = 35,
        dx_sec_no_route_to_host = 36,
        dx_sec_connection_aborted = 37,
        dx_sec_connection_reset = 38,
        dx_sec_persistent_temp_error = 39,
        dx_sec_unrecoverable_error = 40,
        dx_sec_not_enough_memory = 41,
        dx_sec_no_data_on_host = 42,
        dx_sec_host_not_found = 43,
        dx_sec_generic_error = 44,

         # /* thread error codes */

        dx_tec_not_enough_sys_resources = 45,
        dx_tec_permission_denied = 46,
        dx_tec_invalid_res_operation = 47,
        dx_tec_invalid_resource_id = 48,
        dx_tec_deadlock_detected = 49,
        dx_tec_not_enough_memory = 50,
        dx_tec_resource_busy = 51,
        dx_tec_generic_error = 52,

         # /* network error codes */

        dx_nec_invalid_port_value = 53,
        dx_nec_invalid_function_arg = 54,
        dx_nec_connection_closed = 55,
        dx_nec_open_connection_error = 56,
        dx_nec_unknown_codec = 57,

         # /* buffered I/O error codes */

        dx_bioec_buffer_overflow = 58,
        dx_bioec_buffer_not_initialized = 59,
        dx_bioec_index_out_of_bounds = 60,
        dx_bioec_buffer_underflow = 61,

         # /* UTF error codes */

        dx_utfec_bad_utf_data_format = 62,
        dx_utfec_bad_utf_data_format_server = 63,

         # /* penta codec error codes */

        dx_pcec_reserved_bit_sequence = 64,
        dx_pcec_invalid_symbol_length = 65,
        dx_pcec_invalid_event_flag = 66,

         # /* event subscription error codes */

        dx_esec_invalid_event_type = 67,
        dx_esec_invalid_subscr_id = 68,
        dx_esec_invalid_symbol_name = 69,
        dx_esec_invalid_listener = 70,

         # /* logger error codes */

        dx_lec_failed_to_open_file = 71,

         # /* protocol message error codes */

        dx_pmec_invalid_message_type = 72,

         # /* protocol error codes */

        dx_pec_unexpected_message_type = 73,
        dx_pec_unexpected_message_type_internal = 74,
        dx_pec_descr_record_field_info_corrupted = 75,
        dx_pec_message_incomplete = 76,
        dx_pec_invalid_message_length = 77,
        dx_pec_server_message_not_supported = 78,
        dx_pec_invalid_symbol = 79,
        dx_pec_record_description_not_received = 80,
        dx_pec_record_field_type_not_supported = 81,
        dx_pec_record_info_corrupted = 82,
        dx_pec_unknown_record_name = 83,
        dx_pec_record_not_supported = 84,
        dx_pec_describe_protocol_message_corrupted = 85,
        dx_pec_unexpected_message_sequence_internal = 86,
        dx_pec_local_message_not_supported_by_server = 87,
        dx_pec_inconsistent_message_support = 88,
        dx_pec_authentication_error = 89,
        dx_pec_credentials_required = 90,

         # /* connection error codes */

        dx_cec_invalid_connection_handle = 91,
        dx_cec_invalid_connection_handle_internal = 92,
        dx_cec_connection_context_not_initialized = 93,
        dx_cec_invalid_connection_context_subsystem_id = 94,

         # /* candle event error codes*/

        dx_ceec_invalid_candle_period_value = 95,

         # /* snapshot error codes */

        dx_ssec_invalid_snapshot_id = 96,
        dx_ssec_invalid_event_id = 97,
        dx_ssec_invalid_symbol = 98,
        dx_ssec_snapshot_exist = 99,
        dx_ssec_invalid_listener = 100,
        dx_ssec_unknown_state = 101,
        dx_ssec_duplicate_record = 102,

         # /* configuration record serialization deserialization error codes */

        dx_csdec_protocol_error = 103,
        dx_csdec_unsupported_version = 104,

         # /* miscellaneous error codes */

         # /* error code count */
         # /* this MUST be the last element in the enumeration */

        dx_ec_count


# /* -------------------------------------------------------------------------- */
# /**
#  * @ingroup c-api-common
#  *
#  * @brief Returns error description by error code
#  *
#  * @param[in] code Error code
#  *
#  * @returns Error description string
#  *
#  */
# /* -------------------------------------------------------------------------- */
cdef dxf_const_string_t dx_get_error_description(dx_error_code_t code)

# /* -------------------------------------------------------------------------- */
# /**
#  * @ingroup c-api-common
#  *
#  * @brief Returns error level by error code
#  *
#  * @param[in] code Error code
#  *
#  * @returns Error level
#  *
#  */
# /* -------------------------------------------------------------------------- */
cdef dx_error_level_t dx_get_error_level(dx_error_code_t code)

#endif /* DX_ERROR_CODES_H_INCLUDED */