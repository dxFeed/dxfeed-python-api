cimport lib.wrapper.pxd_include.DXFeed as clib
from cpython.mem cimport PyMem_Malloc, PyMem_Free
from warnings import warn
from cython cimport always_allow_keywords


cdef extern from "Python.h":
    # Convert unicode to wchar
    clib.dxf_const_string_t PyUnicode_AsWideCharString(object, Py_ssize_t *)

cdef clib.dxf_connection_t connection
cdef clib.dxf_subscription_t subscription

def event_type_convert(event_type: str):
    """
    The function converts event type given as string to int, used in C dxfeed lib

    Parameters
    ----------
    event_type: str
        Event type: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'Time&Sale', 'Candle', 'TradeETH', 'SpreadOrder',
                    'Greeks', 'THEO_PRICE', 'Underlying', 'Series', 'Configuration' or ''
    Returns
    -------
    : int
        Integer that corresponds to event type in C dxfeed lib
    """
    et_mapping = {
        'Trade': 1,
        'Quote': 2,
        'Summary': 4,
        'Profile': 8,
        'Order': 16,
        'Time&Sale': 32,
        'Candle': 64,
        'TradeETH': 128,
        'SpreadOrder': 256,
        'Greeks': 512,
        'THEO_PRICE': 1024,
        'Underlying': 2048,
        'Series': 4096,
        'Configuration': 8192,
        '': -16384
    }
    try:
        return et_mapping[event_type]
    except KeyError:
        warn(f'No mapping for {event_type}, please choose one from {et_mapping.keys()}')
        return -16384

def dxf_create_connection(address='demo.dxfeed.com:7300'):
    address = address.encode('utf-8')
    # clib.dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, cython.address(connection))
    clib.dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, &connection)

def dxf_close_connection():
    clib.dxf_close_connection(connection)

@always_allow_keywords(True)
# Decorator for allowing argname usage in func when there is only one
# https://github.com/cython/cython/issues/2881
def dxf_create_subscription(event_types):
    # pprint(f"sus: {type(event_types)}")
    et = event_type_convert(event_types)
    # cdef int et_int = et
    clib.dxf_create_subscription(connection, et, &subscription)

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

# https://stackoverflow.com/questions/40575432/send-data-from-c-parent-to-python-child-and-back-using-a-pipe

# from cpython cimport array
# import array

# cdef array.array a =  array.array('f', [0.1] * 20)
# a.data.as_floats
import numpy as np
cimport numpy as np

a = np.zeros(5, dtype='f')

cdef float[::1] arr_memview = a
cdef void * u_data =  <void*>&arr_memview[0]


cdef void listener(int event_type, clib.dxf_const_string_t symbol_name,
                   const clib.dxf_event_data_t* data, int data_count, void* user_data):
    # print(1)
    cdef clib.dxf_trade_t* trades = <clib.dxf_trade_t*?>data
    a[0] = 23.0

    for  i in range(1, data_count):
        # print(f"time {trades.time}")
        # print(f"ex code {trades.exchange_code}")
        # pass
        a[i] = trades[i].price
        # print(trades[i].size)
        # print(trades[i].tick)

cimport lib.wrapper.pxd_include.Listeners as lis



def attach_listener():
    # clib.dxf_attach_event_listener(subscription, listener, u_data)
    clib.dxf_attach_event_listener(subscription, lis.listener, u_data)
    # clib.dxf_attach_event_listener(subscription, lis.listener, &a)
    # print(u_data)

def detach_listener():
    clib.dxf_detach_event_listener(subscription, lis.listener)

# @always_allow_keywords(True)
# def dxf_get_last_event(my_string):
#     cdef clib.wchar_t *c_symbols = PyUnicode_AsWideCharString(my_string, NULL)
#     cdef clib.dxf_event_data_t data
#     cdef clib.dxf_trade_t *trade
#     n=2
#     import time
#     for _ in range(n):
#         # event type in EventData.h (e.g. #define DXF_ET_TRADE         (1 << dx_eid_trade))
#         clib.dxf_get_last_event(connection, 1, c_symbols, &data)
#         if data:
#             trade = <clib.dxf_trade_t*?>data
#             print(f"time {trade.time}")
#             print(f"ex code {trade.exchange_code}")
#             print(f"{trade.price}")
#             print(f"{trade.size}")
#             print(f"{trade.tick}")
#             print('if done')
#         print('final')
#         time.sleep(2)

import time
def all_in_one():
    dxf_create_connection()
    dxf_create_subscription(event_types='Trade')
    dxf_add_symbols(['AAPL', 'MSFT', 'C'])
    attach_listener()
    time.sleep(3)
    detach_listener()
    print(a)
    # import time
    # for a in range(5):
    #     print(a)
    #     time.sleep(1)
    # dxf_get_last_event(my_string='MSFT')