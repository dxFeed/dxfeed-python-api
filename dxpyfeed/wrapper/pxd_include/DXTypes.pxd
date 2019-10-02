# something about license

#ifndef DX_TYPES_H_INCLUDED
#define DX_TYPES_H_INCLUDED

cdef extern from "DXTypes.h":
    ctypedef int ERRORCODE
    ctypedef void* dxf_subscription_t
    ctypedef void* dxf_connection_t
    ctypedef void* dxf_candle_attributes_t
    ctypedef void* dxf_snapshot_t
    ctypedef void* dxf_price_level_book_t
    ctypedef void* dxf_regional_book_t

#ifdef _WIN32

#pxd_include <wchar.h>
from libc.stddef cimport wchar_t

cdef extern from "DXTypes.h":
    ctypedef unsigned char      dxf_bool_t           # 8 bit
    ctypedef char               dxf_byte_t           # 8 bit
    ctypedef unsigned char      dxf_ubyte_t  # 8 bit
    ctypedef wchar_t            dxf_char_t           # 16 bit
    #ctypedef unsigned wchar_t   dx_unsigned_char_t  # 16 bit
    ctypedef short int          dxf_short_t          # 16 bit
    ctypedef unsigned short int dxf_ushort_t # 16 bit
    ctypedef int                dxf_int_t            # 32 bit
    ctypedef unsigned int       dxf_uint_t   # 32 bit
    ctypedef float              dxf_float_t          # 32 bit
    ctypedef long long          dxf_long_t           # 64 bit
    ctypedef unsigned long long dxf_ulong_t  # 64 bit
    ctypedef double             dxf_double_t         # 64 bit
    ctypedef int                dxf_dayid_t

    ctypedef dxf_char_t*        dxf_string_t
    ctypedef const dxf_char_t*  dxf_const_string_t

#else /* POSIX? */

#pxd_include <stdint.h>
#pxd_include <wchar.h>

# ctypedef unsigned char    dxf_bool_t           # 8 bit
# ctypedef int8_t           dxf_byte_t           # 8 bit
# ctypedef uint8_t          dxf_ubyte_t  # 8 bit
# ctypedef wchar_t          dxf_char_t           # 16 bit
# #ctypedef unsigned wchar_t   dx_unsigned_char_t  # 16 bit
# ctypedef int16_t          dxf_short_t          # 16 bit
# ctypedef uint16_t         dxf_ushort_t # 16 bit
# ctypedef int32_t          dxf_int_t            # 32 bit
# ctypedef uint32_t         dxf_uint_t   # 32 bit
# ctypedef float            dxf_float_t          # 32 bit
# ctypedef int64_t          dxf_long_t           # 64 bit
# ctypedef uint64_t         dxf_ulong_t  # 64 bit
# ctypedef double           dxf_double_t         # 64 bit
# ctypedef int32_t          dxf_dayid_t
#
# ctypedef dxf_char_t*        dxf_string_t
# ctypedef const dxf_char_t*  dxf_const_string_t

#endif /* _WIN32/POSIX */

cdef extern from "DXTypes.h":
    ctypedef dxf_uint_t dxf_event_flags_t

    ctypedef struct dxf_byte_array_t:
        dxf_byte_t* elements,
        int size,
        int capacity,

    ctypedef struct dxf_property_item_t:
        dxf_string_t key,
        dxf_string_t value,

    ctypedef enum dxf_connection_status_t:
        dxf_cs_not_connected = 0,
        dxf_cs_connected,
        dxf_cs_login_required,
        dxf_cs_authorized

#endif /* DX_TYPES_H_INCLUDED */