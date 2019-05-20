from lib.wrapper.pxd_include.DXFeed cimport *

cdef dxf_connection_t connection

def pyconnect():
    print('connecting2')
    print(f"{dxf_create_connection('demo.dxfeed.com:7300', NULL, NULL, NULL, NULL, NULL, &connection)}")
    print('connected')

def pydisconnect():
    print('disconnecting')
    print(f"{dxf_close_connection(connection)}")
    print('disconnected')

cdef dxf_subscription_t subscription

def pysubscribe():
    print('subscribing')
    print(f"{dxf_create_subscription(connection, 1, &subscription)}")
    print('suscribed')

cdef extern from "Python.h":
    dxf_const_string_t PyUnicode_AsWideCharString(object, Py_ssize_t *)

# import numpy as np
# cimport numpy as np
def py_add_symbol():
    my_string = u"AAPL"
    # for i in range(len(symbols)):
    cdef Py_ssize_t length
    cdef dxf_const_string_t c_symbols = PyUnicode_AsWideCharString(my_string, &length)
    my_string2 = u"MSFT"
    cdef Py_ssize_t length2
    cdef dxf_const_string_t c_symbols2 = PyUnicode_AsWideCharString(my_string2, &length)
    # c_symbols = np.array(symbols)
    cdef dxf_const_string_t c_syms[2]
    c_syms[:] = [c_symbols, c_symbols2]
    #print(c_syms)
    # c_symbols[1] = my_string2
    print(f"{dxf_add_symbols(subscription, c_syms, 2)}")
    print('added')

cdef extern from "wchar.h":
    int wprintf(const wchar_t *, ...)

def py_get_smth():
    my_string = u"AAPL"
    cdef Py_ssize_t length
    cdef wchar_t *c_symbols = PyUnicode_AsWideCharString(my_string, &length)
    cdef dxf_event_data_t data
    cdef dxf_trade_t *trade
    n=10
    import time
    for _ in range(n):
        # event type in EventData.h (e.g. #define DXF_ET_TRADE         (1 << dx_eid_trade))
        dxf_get_last_event(connection, 1, c_symbols, &data)
        if data:
            trade = <dxf_trade_t*?>data
            print(f"time {trade.time}")
            print(f"ex code {trade.exchange_code}")

            print(f"{trade.price}")
            print(f"{trade.size}")
            print(f"{trade.tick}")
            print('if done')
        print('final')
        time.sleep(2)


def all_in_one():
    pyconnect()
    pysubscribe()
    py_add_symbol()
    py_get_smth()