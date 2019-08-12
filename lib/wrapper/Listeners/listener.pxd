
from lib.wrapper.pxd_include.DXTypes cimport dxf_int_t, dxf_const_string_t
from lib.wrapper.pxd_include.EventData cimport dxf_event_data_t, dxf_trade_t

cdef void some_listener(int event_type, dxf_const_string_t symbol_name,
			            const dxf_event_data_t* data, int data_count, void* user_data)