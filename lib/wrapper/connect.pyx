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


def py_add_symbol():
    my_string = u"AAPL"
    cdef Py_ssize_t length
    cdef wchar_t *c_symbols = PyUnicode_AsWideCharString(my_string, &length)
    print(f"{dxf_add_symbol(subscription, c_symbols)}")
    print('added')

cdef extern from "wchar.h":
    int wprintf(const wchar_t *, ...)

def py_get_smth():
    my_string = u"AAPL"
    cdef Py_ssize_t length
    cdef wchar_t *c_symbols = PyUnicode_AsWideCharString(my_string, &length)
    cdef dxf_event_data_t data
    cdef dxf_trade_t *trade
    print(f"{dxf_get_last_event(connection, 1, c_symbols, &data)}")
    print('Got')


    if data:
        trade = <dxf_trade_t*>data
        print(f"time {trade.time}")
        print(f"ex code {trade.exchange_code}")


        #wprintf("\nSymbol: %s; time=%lld, exchange code=%C, price=%f, size=%ld, tick=%ld, change=%f, day volume=%f, scope=%d\n",
        #        c_symbols, trade.time, trade.exchange_code, trade.price, trade.size, trade.tick, trade.change,
        #        trade.day_volume, <int>trade.scope)

        print(f"{trade.exchange_code}")
        print(f"{trade.price}")
        print(f"{trade.size}")
        print(f"{trade.tick}")
        print('if done')
    print('final')

def all_in_one():
    pyconnect()
    pysubscribe()
    py_add_symbol()
    py_get_smth()