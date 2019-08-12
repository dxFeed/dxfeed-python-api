
cimport lib.wrapper.pxd_include.DXFeed as clib
from warnings import warn
from cython cimport always_allow_keywords
from lib.wrapper.utils.helpers cimport *

from lib.wrapper.listeners.listener cimport *



cdef class Subscription:
    cdef clib.dxf_connection_t connection
    cdef clib.dxf_subscription_t subscription
    cdef dict data
    cdef void * u_data
    cdef object event_type_str


    cdef int et_type_int

    def __init__(self, event_type):

        self.et_type_int = self.event_type_convert(event_type)
        self.event_type_str = event_type
        self.data = {'columns': [],
                     'data': []}
        self.u_data = <void *>self.data





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
        for idx, sym in enumerate(symbols):
            clib.dxf_add_symbol(self.subscription, dxf_const_string_t_from_unicode(sym))

    cdef void listener2(self):
        pass

    def attach_listener(self):
        # clib.dxf_attach_event_listener(self.subscription, self.listener2, self.u_data)
        clib.dxf_attach_event_listener(self.subscription, quote_default_listener, self.u_data)
    def detach_listener(self):
        # clib.dxf_detach_event_listener(self.subscription, self.listener2)
        clib.dxf_detach_event_listener(self.subscription, quote_default_listener)