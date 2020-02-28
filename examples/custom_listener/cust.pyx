from dxfeed.core.listeners.listener cimport *
from dxfeed.core.utils.helpers cimport *

cdef void trade_custom_listener(int event_type,
                                 dxf_const_string_t symbol_name,
                                 const dxf_event_data_t*data,
                                 int data_count, void*user_data) nogil:
    cdef dxf_trade_t*trades = <dxf_trade_t*> data
    with gil:
        py_data = <object> user_data

        for i in range(data_count):
            py_data.safe_append([unicode_from_dxf_const_string_t(symbol_name),
                                 trades[i].price])

tc = FuncWrapper.make_from_ptr(trade_custom_listener)
