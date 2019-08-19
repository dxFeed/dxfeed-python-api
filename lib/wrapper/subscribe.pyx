
from warnings import warn
from cython cimport always_allow_keywords
from lib.wrapper.utils.helpers cimport *
from lib.wrapper.utils.helpers import *
cimport lib.wrapper.pxd_include.DXFeed as clib
cimport lib.wrapper.listeners.listener as lis
# for importing variables
import lib.wrapper.listeners.listener as lis
from lib.wrapper.pxd_include.EventData cimport *


cdef class ConnectionClass:
    cdef clib.dxf_connection_t connection

    # @property
    # def ptr(self):
    #     return <uintptr_t>self.connection

    cpdef SubscriptionClass make_new_subscription(self):
        cdef SubscriptionClass out = SubscriptionClass()
        out.connection = self.connection
        return out

cdef class SubscriptionClass:
    cdef clib.dxf_connection_t connection
    cdef clib.dxf_subscription_t subscription
    cdef dxf_event_listener_t listener
    cdef object event_type_str
    cdef dict data
    cdef void * u_data

    def __init__(self):
        self.data = {'columns': [],
                     'data': []}
        self.u_data = <void *>self.data
        self.listener = NULL

    @property
    def data(self):
        return self.data

def dxf_create_connection(address='demo.dxfeed.com:7300'):
    cc = ConnectionClass()
    address = address.encode('utf-8')
    if not clib.dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, &cc.connection):
        process_last_error()
        return
    return cc

def dxf_create_subscription(ConnectionClass cc, event_type):
    sc = cc.make_new_subscription()
    sc.event_type_str = event_type
    et_type_int = event_type_convert(event_type)
    if not clib.dxf_create_subscription(sc.connection, et_type_int, &sc.subscription):
        process_last_error()
        return
    return sc

def dxf_add_symbols(SubscriptionClass sc, symbols: list):
    # number = len(symbols)  # Number of elements
    for idx, sym in enumerate(symbols):
        if not clib.dxf_add_symbol(sc.subscription, dxf_const_string_t_from_unicode(sym)):
            process_last_error()
            return

def dxf_attach_listener(SubscriptionClass sc):
    if sc.event_type_str == 'Trade':
        sc.data['columns'] = lis.TRADE_COLUMNS
        sc.listener =  lis.trade_default_listener
    elif sc.event_type_str == 'Quote':
        sc.data['columns'] = lis.QUOTE_COLUMNS
        sc.listener =  lis.quote_default_listener
    elif sc.event_type_str == 'Summary':
        sc.data['columns'] = lis.SUMMARY_COLUMNS
        sc.listener = lis.summary_default_listener
    elif sc.event_type_str == 'Profile':
        sc.data['columns'] = lis.PROFILE_COLUMNS
        sc.listener = lis.profile_default_listener

    if not clib.dxf_attach_event_listener(sc.subscription, sc.listener, sc.u_data):
        process_last_error()

def detach_listener(SubscriptionClass sc):
    if not clib.dxf_detach_event_listener(sc.subscription, sc.listener):
        process_last_error()

def dxf_close_connection(ConnectionClass cc):
    if not clib.dxf_close_connection(cc.connection):
        process_last_error()

cdef class Subscription:
    cdef clib.dxf_connection_t connection
    cdef clib.dxf_subscription_t subscription
    cdef dict data
    cdef void * u_data
    cdef object event_type_str
    cdef dxf_event_listener_t listener


    cdef int et_type_int

    def __init__(self, event_type):

        self.et_type_int = self.event_type_convert(event_type)
        self.event_type_str = event_type
        self.data = {'columns': [],
                     'data': []}
        self.u_data = <void *>self.data
        self.listener = NULL





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


    def attach_listener(self):
        if self.event_type_str == 'Trade':
            self.data['columns'] = lis.TRADE_COLUMNS
            self.listener =  lis.trade_default_listener
        elif self.event_type_str == 'Quote':
            self.data['columns'] = lis.QUOTE_COLUMNS
            self.listener =  lis.quote_default_listener
        elif self.event_type_str == 'Summary':
            self.data['columns'] = lis.SUMMARY_COLUMNS
            self.listener = lis.summary_default_listener
        elif self.event_type_str == 'Profile':
            self.data['columns'] = lis.PROFILE_COLUMNS
            self.listener = lis.profile_default_listener

        clib.dxf_attach_event_listener(self.subscription, self.listener, self.u_data)

    def detach_listener(self):
        clib.dxf_detach_event_listener(self.subscription, self.listener)
        # clib.dxf_detach_event_listener(self.subscription, quote_default_listener)