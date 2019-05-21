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

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
def py_add_symbol(symbols=['AAPL', 'MSFT']):
    # my_string = u"AAPL"
    # for i in range(len(symbols)):
    # cdef Py_ssize_t length
    # cdef dxf_const_string_t c_symbols = PyUnicode_AsWideCharString(my_string, NULL)
    # my_string2 = u"MSFT"
    # cdef Py_ssize_t length2
    # cdef dxf_const_string_t c_symbols2 = PyUnicode_AsWideCharString(my_string2, NULL)
    # c_symbols = np.array(symbols)

    # allocate number * sizeof(double) bytes of memory
    # cdef double *my_array = <double *> malloc(number * sizeof(double))
    cdef int number = len(symbols)
    # cdef dxf_const_string_t *c_syms = <dxf_const_string_t *> malloc(number * sizeof(dxf_const_string_t))
    cdef dxf_const_string_t *c_syms = <dxf_const_string_t *> PyMem_Malloc(number * sizeof(dxf_const_string_t))

    # cdef dxf_const_string_t c_syms[2]
    for idx, sym in enumerate(symbols):
        c_syms[idx] = PyUnicode_AsWideCharString(sym, NULL)



    # c_syms[:] = [c_symbols, c_symbols2]
    #print(c_syms)
    # c_symbols[1] = my_string2
    print(f"{dxf_add_symbols(subscription, c_syms, number)}")
    PyMem_Free(c_syms)
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