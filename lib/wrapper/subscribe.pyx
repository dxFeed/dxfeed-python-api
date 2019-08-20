
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

def dxf_attach_custom_listener(SubscriptionClass sc, lis.FuncWrapper fw, columns: list):
    sc.data['columns'] = columns
    sc.listener = fw.func
    if not clib.dxf_attach_event_listener(sc.subscription, sc.listener, sc.u_data):
        process_last_error()


def detach_listener(SubscriptionClass sc):
    if not clib.dxf_detach_event_listener(sc.subscription, sc.listener):
        process_last_error()

def dxf_close_connection(ConnectionClass cc):
    if not clib.dxf_close_connection(cc.connection):
        process_last_error()

