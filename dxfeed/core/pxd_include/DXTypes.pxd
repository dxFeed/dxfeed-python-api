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
#
# /**
#  * @file
#  * @brief dxFeed C API types declarations
#  */

#ifndef DX_TYPES_H_INCLUDED
#define DX_TYPES_H_INCLUDED

#ifdef __GNUC__
#	define DX_MAYBE_UNUSED __attribute__((__unused__))
#else
#	define DX_MAYBE_UNUSED
#endif

#ifndef DOXYGEN_SHOULD_SKIP_THIS
#	ifdef DXFEED_EXPORTS
#		define DXFEED_API __declspec(dllexport)
#	elif DXFEED_IMPORTS
#		define DXFEED_API __declspec(dllimport)
#	elif __cplusplus
#		define DXFEED_API extern "C"
#	else
#		define DXFEED_API
#	endif
#endif	// DOXYGEN_SHOULD_SKIP_THIS

#ifndef OUT
#	ifndef DOXYGEN_SHOULD_SKIP_THIS
#		define OUT
#	endif	// DOXYGEN_SHOULD_SKIP_THIS
#endif		/* OUT */

#pxd_include <wchar.h>
from libc.stddef cimport wchar_t
from libc.stdint cimport *

cdef extern from "DXTypes.h":
    #/// Error code
    ctypedef int ERRORCODE

    #/// Subscription
    ctypedef void* dxf_subscription_t

    #/// Connection
    ctypedef void* dxf_connection_t

    #/// Candle attributes
    ctypedef void* dxf_candle_attributes_t

    #/// Snapshot
    ctypedef void* dxf_snapshot_t

    #/// Price level book
    ctypedef void* dxf_price_level_book_t

    #/// Regional book
    ctypedef void* dxf_regional_book_t

    #ifdef _WIN32

    #	include <wchar.h>

    ctypedef unsigned char dxf_bool_t; # // 8 bit
    ctypedef char dxf_byte_t;		 # // 8 bit
    ctypedef unsigned char dxf_ubyte_t; # // 8 bit
    ctypedef wchar_t dxf_char_t;		 # // 16 bit
    # // ctypedef unsigned wchar_t   dx_unsigned_char_t;  // 16 bit
    ctypedef short int dxf_short_t;			  # // 16 bit
    ctypedef unsigned short int dxf_ushort_t;  # // 16 bit
    ctypedef int dxf_int_t;					  # // 32 bit
    ctypedef unsigned int dxf_uint_t;		  # // 32 bit
    ctypedef float dxf_float_t;				  # // 32 bit
    ctypedef long long dxf_long_t;			  # // 64 bit
    ctypedef unsigned long long dxf_ulong_t;	  # // 64 bit
    ctypedef double dxf_double_t;			  # // 64 bit
    #/// Identifier of the day is the number of days passed since January 1, 1970.
    ctypedef int dxf_dayid_t

    #/// String
    ctypedef dxf_char_t* dxf_string_t

    #/// Const String
    ctypedef const dxf_char_t* dxf_const_string_t

    #else /* POSIX? */

    #	include <stdint.h>
    #	include <wchar.h>

    #/// Boolean
    ctypedef unsigned char dxf_bool_t;  # // 8 bit

    #/// Byte
    ctypedef int8_t dxf_byte_t; # // 8 bit

    #/// Unsigned byte
    ctypedef uint8_t dxf_ubyte_t;  # // 8 bit

    #/// Char
    ctypedef wchar_t dxf_char_t;	 # // 16 bit
    #// ctypedef unsigned wchar_t   dx_unsigned_char_t;  # // 16 bit

    #/// Short
    ctypedef int16_t dxf_short_t;  # // 16 bit

    #/// Unsigned short
    ctypedef uint16_t dxf_ushort_t; # // 16 bit

    #/// Int
    ctypedef int32_t dxf_int_t; # // 32 bit

    #/// Unsigned int
    ctypedef uint32_t dxf_uint_t;  # // 32 bit

    #/// Float
    ctypedef float dxf_float_t; # // 32 bit

    #/// Long
    ctypedef int64_t dxf_long_t;	 # // 64 bit

    #/// Unsigned long
    ctypedef uint64_t dxf_ulong_t;  # // 64 bit

    #/// Double
    ctypedef double dxf_double_t;  # // 64 bit

    #/// DayId
    ctypedef int32_t dxf_dayid_t

    #/// String
    ctypedef dxf_char_t* dxf_string_t

    #/// Const String
    ctypedef const dxf_char_t* dxf_const_string_t

    #endif /* _WIN32/POSIX */

    #/// Event flags
    ctypedef dxf_uint_t dxf_event_flags_t

    #/// Byte array
    ctypedef struct dxf_byte_array_t:
        dxf_byte_t* elements,
        int size,
        int capacity

    #/// Property item
    ctypedef struct dxf_property_item_t:
        dxf_string_t key,
        dxf_string_t value,

    #/// Connection status
    ctypedef enum dxf_connection_status_t:
        dxf_cs_not_connected = 0,
        dxf_cs_connected,
        dxf_cs_login_required,
        dxf_cs_authorized

#endif /* DX_TYPES_H_INCLUDED */