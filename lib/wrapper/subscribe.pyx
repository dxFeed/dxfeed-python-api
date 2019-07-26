cimport lib.wrapper.pxd_include.DXFeed as clib
from cpython.mem cimport PyMem_Malloc, PyMem_Free
from warnings import warn
from cython cimport always_allow_keywords
from lib.wrapper.utils.LinkedList cimport *
from lib.wrapper.utils.LinkedListFunc cimport *
cimport lib.wrapper.Listeners.Listeners as lis
from lib.wrapper.utils.wrapper_class cimport WrapperClass


cdef extern from "Python.h":
    # Convert unicode to wchar
    clib.dxf_const_string_t PyUnicode_AsWideCharString(object, Py_ssize_t *)

cdef class Subscription:
    cdef clib.dxf_connection_t connection
    cdef clib.dxf_subscription_t subscription
    # from LinkedListFunc
    cdef linked_list_ext * lle
    cdef WrapperClass data
    cdef void * u_data

    cdef int et_type_int
    def __init__(self, EventType):
        self.et_type_int = self.event_type_convert(EventType)
        # pointer and data
        self.lle = linked_list_ext_init()
        self.data = WrapperClass.from_ptr(self.lle, owner=True)
        self.u_data =  <void*> self.lle

    @property
    def data(self):
        return self.data

    def event_type_convert(self, event_type: str):
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

    def dxf_create_connection(self, address='demo.dxfeed.com:7300'):
        address = address.encode('utf-8')
        clib.dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, &self.connection)

    def dxf_close_connection(self):
        clib.dxf_close_connection(self.connection)

    @always_allow_keywords(True)
    # Decorator for allowing argname usage in func when there is only one
    # https://github.com/cython/cython/issues/2881
    def dxf_create_subscription(self):
        clib.dxf_create_subscription(self.connection, self.et_type_int, &self.subscription)

    def dxf_add_symbols(self, symbols: list):
        cdef int number = len(symbols)  # Number of elements
        cdef int idx # for faster loops
        # define array with dynamic memory allocation
        cdef clib.dxf_const_string_t *c_syms = <clib.dxf_const_string_t *> PyMem_Malloc(number * sizeof(clib.dxf_const_string_t))
        # create array with cycle
        for idx, sym in enumerate(symbols):
            c_syms[idx] = PyUnicode_AsWideCharString(sym, NULL)
        # call c function
        clib.dxf_add_symbols(self.subscription, c_syms, number)
        # free memory
        for idx in range(number):
            PyMem_Free(c_syms[idx])
        PyMem_Free(c_syms)
        print('added')

    def attach_listener(self):
        clib.dxf_attach_event_listener(self.subscription, lis.listener, self.u_data)

    def detach_listener(self):
        clib.dxf_detach_event_listener(self.subscription, lis.listener)