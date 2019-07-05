from lib.wrapper.pxd_include.DXTypes cimport *
from lib.wrapper.pxd_include.EventData cimport *
# /* -------------------------------------------------------------------------- */
# /*
#  *	DXFeed API generic types
#  */
# /* -------------------------------------------------------------------------- */

cdef extern from "Listener.h":
    void listener(int event_type, dxf_const_string_t symbol_name,
                  const dxf_event_data_t* data, int data_count, void* user_data)