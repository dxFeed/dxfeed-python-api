# from lib.wrapper.pxd_include.DXFeed cimport *
cimport lib.wrapper.pxd_include.DXFeed as clib
from cpython.mem cimport PyMem_Malloc, PyMem_Free

cdef extern from "Python.h":
    # Convert unicode to wchar
    clib.dxf_const_string_t PyUnicode_AsWideCharString(object, Py_ssize_t *)

cdef clib.dxf_connection_t connection
cdef clib.dxf_subscription_t subscription

def dxf_create_connection(address='demo.dxfeed.com:7300'):
    address = address.encode('utf-8')
    clib.dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, &connection)

def dxf_close_connection():
    clib.dxf_close_connection(connection)

def dxf_create_subscription():
    clib.dxf_create_subscription(connection, 1, &subscription)

def dxf_add_symbols(symbols: list):
    cdef int number = len(symbols)  # Number of elements
    cdef int idx # for faster loops
    # define array with dynamic memory allocation
    cdef clib.dxf_const_string_t *c_syms = <clib.dxf_const_string_t *> PyMem_Malloc(number * sizeof(clib.dxf_const_string_t))
    # create array with cycle
    for idx, sym in enumerate(symbols):
        c_syms[idx] = PyUnicode_AsWideCharString(sym, NULL)
    # call c function
    clib.dxf_add_symbols(subscription, c_syms, number)
    # free memory
    for idx in range(number):
        PyMem_Free(c_syms[idx])
    PyMem_Free(c_syms)
    print('added')

def dxf_get_last_event():
    my_string = u"AAPL"
    cdef clib.wchar_t *c_symbols = PyUnicode_AsWideCharString(my_string, NULL)
    cdef clib.dxf_event_data_t data
    cdef clib.dxf_trade_t *trade
    n=10
    import time
    for _ in range(n):
        # event type in EventData.h (e.g. #define DXF_ET_TRADE         (1 << dx_eid_trade))
        clib.dxf_get_last_event(connection, 1, c_symbols, &data)
        if data:
            trade = <clib.dxf_trade_t*?>data
            print(f"time {trade.time}")
            print(f"ex code {trade.exchange_code}")
            print(f"{trade.price}")
            print(f"{trade.size}")
            print(f"{trade.tick}")
            print('if done')
        print('final')
        time.sleep(2)


def all_in_one():
    dxf_create_connection()
    dxf_create_subscription()
    dxf_add_symbols(['AAPL', 'MSFT', 'C'])
    dxf_get_last_event()