# distutils: language = c++

from cpython.ref cimport PyObject
from libc.stdio cimport printf
cdef void some_listener(int event_type, dxf_const_string_t symbol_name,
			            const dxf_event_data_t* data, int data_count, void* user_data):
    cdef dxf_int_t i = 0
    cdef dxf_trade_t* trades = <dxf_trade_t*>data
    cdef dict py_data = <dict>user_data
    
    printf("{symbol=%s, ", symbol_name)
    for i in range(data_count):
        py_data['data'].append([trades[i].price,
                                trades[i].exchange_code,
                                trades[i].price,
                                trades[i].size,
                                trades[i].tick,
                                trades[i].change,
                                trades[i].day_volume
                                ]
                               )
        printf(", exchangeCode=%c, price=%f, size=%i, tick=%i, change=%f, day volume=%.0f}\n",
                trades[i].exchange_code, trades[i].price, trades[i].size, trades[i].tick, trades[i].change,
            trades[i].day_volume)
    pass