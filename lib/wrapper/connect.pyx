cimport lib.wrapper.pxd_include.DXFeed as clib
from cpython.mem cimport PyMem_Malloc, PyMem_Free
from warnings import warn
from cython cimport always_allow_keywords
from libc.stdlib cimport realloc, malloc, free


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



# Linked List realization
ctypedef struct linked_list

ctypedef struct linked_list:
    double price
    double volume
    bint data
    linked_list *next_cell

ctypedef struct linked_list_ext:
    linked_list * head
    linked_list * tail

cdef linked_list * linked_list_init():
    init = <linked_list *>malloc(sizeof(linked_list))
    init.data = False
    init.next_cell = NULL
    return init

cdef linked_list_ext * linked_list_ext_init():
    init = <linked_list_ext *>malloc(sizeof(linked_list_ext))
    init.head = linked_list_init()
    init.tail = init.head
    return init

cdef linked_list_ext * lle = linked_list_ext_init()


cdef class WrapperClass:
    """A wrapper class for a C/C++ data structure"""
    cdef linked_list_ext * _ptr
    cdef bint ptr_owner
    cdef linked_list * curr
    cdef linked_list * next_cell
    cdef linked_list * init
#     cdef linked_list * next_node

    def __cinit__(self):
        self.ptr_owner = False

    def __dealloc__(self):
        # De-allocate if not null and flag is set
        if self._ptr is not NULL and self.ptr_owner is True:
            free(self._ptr)
            self._ptr = NULL

    @property
    def price(self):
        return self._ptr.tail.price if (self._ptr is not NULL) and (self._ptr.tail is not NULL) else None

    @property
    def volume(self):
        return self._ptr.tail.volume if (self._ptr is not NULL) and (self._ptr.tail is not NULL) else None

    @staticmethod
    cdef WrapperClass from_ptr(linked_list_ext *_ptr, bint owner=False):
        """Factory function to create WrapperClass objects from
        given my_c_struct pointer.

        Setting ``owner`` flag to ``True`` causes
        the extension type to ``free`` the structure pointed to by ``_ptr``
        when the wrapper object is deallocated."""
        # Call to __new__ bypasses __init__ constructor
        cdef WrapperClass wrapper = WrapperClass.__new__(WrapperClass)
        wrapper._ptr = _ptr
        wrapper.ptr_owner = owner
        wrapper.curr = _ptr.tail
        return wrapper

    def add_elem(self, double price, double volume):
        curr = self._ptr.tail
        next_cell = linked_list_init()
        curr.next_cell = next_cell
        curr.price = price
        curr.volume = volume
        curr.data = True
        self._ptr.tail = next_cell

    def delete_list(self):
        cur = self._ptr.head
        #nextt = self._ptr.head
        while cur is not NULL:
            nextt = cur.next_cell
            free(cur)
            cur = nextt
        self._ptr.head = linked_list_init()
        self._ptr.tail = self._ptr.head

    def print_list(self):
        cur = self._ptr.head
        while cur is not NULL:
            print(cur.price, cur.volume, cur.data)
            cur = cur.next_cell

    def pop(self):
        prev_head = self._ptr.head
        if prev_head.data:
            result = [prev_head.price, prev_head.volume]
            self._ptr.head = prev_head.next_cell
            free(prev_head)
            return result
        else:
            return [None, None]

data = WrapperClass.from_ptr(lle, owner=True)


cimport lib.wrapper.pxd_include.Listeners as lis

cdef void * u_data =  <void*> lle

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
    # print(a)
    # import time
    # for a in range(5):
    #     print(a)
    #     time.sleep(1)
    # dxf_get_last_event(my_string='MSFT')