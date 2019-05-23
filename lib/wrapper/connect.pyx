from lib.wrapper.pxd_include.DXFeed cimport *
from cpython.mem cimport PyMem_Malloc, PyMem_Free

cdef extern from "Python.h":
    # Convert unicode to wchar
    dxf_const_string_t PyUnicode_AsWideCharString(object, Py_ssize_t *)

cdef dxf_connection_t connection

def pyconnect(address='demo.dxfeed.com:7300'):
    print('connecting2')
    address = address.encode('utf-8')#, 'ignore')
    print(f"{dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, &connection)}")
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

def py_add_symbol(symbols: list):
    cdef int number = len(symbols)  # Number of elements
    cdef int idx # for faster loops
    # define array with dynamic memory allocation
    cdef dxf_const_string_t *c_syms = <dxf_const_string_t *> PyMem_Malloc(number * sizeof(dxf_const_string_t))
    # create array with cycle
    for idx, sym in enumerate(symbols):
        c_syms[idx] = PyUnicode_AsWideCharString(sym, NULL)
    # call c function
    dxf_add_symbols(subscription, c_syms, number)
    for idx in range(number):
        PyMem_Free(c_syms[idx])
    PyMem_Free(c_syms)  # free memory
    print('added')

def py_get_smth():
    my_string = u"AAPL"
    cdef wchar_t *c_symbols = PyUnicode_AsWideCharString(my_string, NULL)
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
    py_add_symbol(['AAPL', 'MSFT', 'C'])
    py_get_smth()