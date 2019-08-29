from dxpyfeed.wrapper.utils.helpers cimport *
from dxpyfeed.wrapper.utils.helpers import *
cimport dxpyfeed.wrapper.pxd_include.DXFeed as clib
cimport dxpyfeed.wrapper.pxd_include.DXErrorCodes as dxec
cimport dxpyfeed.wrapper.listeners.listener as lis
from libc.stdlib cimport free
from datetime import datetime
# for importing variables
import dxpyfeed.wrapper.listeners.listener as lis
from dxpyfeed.wrapper.pxd_include.EventData cimport *


cdef void process_last_error():
    cdef int error_code = dxec.dx_ec_success
    cdef dxf_const_string_t error_descr = NULL
    cdef int res

    res = clib.dxf_get_last_error(&error_code, &error_descr)

    if res == clib.DXF_SUCCESS:
        if error_code == dxec.dx_ec_success:
            print("no error information is stored")

        print("Error occurred and successfully retrieved:\n",
              f"error code = {error_code}, description = {unicode_from_dxf_const_string_t(error_descr)}")
    print("An error occurred but the error subsystem failed to initialize\n")


cdef class ConnectionClass:
    """
    Data structure that contains connection
    """
    cdef clib.dxf_connection_t connection
    cpdef SubscriptionClass make_new_subscription(self):
        cdef SubscriptionClass out = SubscriptionClass()
        out.connection = self.connection
        return out

cdef class SubscriptionClass:
    """
    Data structure that contains subscription and related fields
    """
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

    def __dealloc__(self):
        free(self.u_data)
        free(self.listener)
        free(self.subscription)

    @property
    def data(self):
        return self.data

    @data.setter
    def data(self, new_val: dict):
        self.data = new_val

def dxf_create_connection(address='demo.dxfeed.com:7300'):
    """
    Function creates connection to dxfeed given url address

    Parameters
    ----------
    address
        dxfeed url address

    Returns
    -------
    cc: ConnectionClass
        Cython ConnectionClass with information about connection
    """
    cc = ConnectionClass()
    address = address.encode('utf-8')
    if not clib.dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, &cc.connection):
        process_last_error()
        return
    return cc

def dxf_create_subscription(ConnectionClass cc, event_type, candle_time=None):
    """
    Function creates subscription and writes all relevant information to SubscriptionClass
    Parameters
    ----------
    cc: ConnectionClass
        Variable with connection information
    event_type
        Event type: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
                    'Greeks', 'THEO_PRICE', 'Underlying', 'Series', 'Configuration' or ''
    candle_time: str
        String of %Y-%m-%d %H:%M:%S datetime format for retrieving candles. By default set to now

    Returns
    -------
    sc: SubscriptionClass
        Cython SubscriptionClass with information about subscription
    """
    sc = cc.make_new_subscription()
    sc.event_type_str = event_type
    et_type_int = event_type_convert(event_type)

    if event_type == 'Candle':
        if not candle_time:
            candle_time = datetime.utcnow()
        else:
            try:
                candle_time = datetime.strptime(candle_time, '%Y-%m-%d %H:%M:%S')
            except ValueError:
                raise Exception("Inapropriate date format, should be %Y-%m-%d %H:%M:%S")
        timestamp = int((candle_time - datetime(1970, 1, 1)).total_seconds()) * 1000 - 5000
        print(timestamp)
        if not clib.dxf_create_subscription_timed(sc.connection, et_type_int, timestamp, &sc.subscription):
            process_last_error()
            return
    elif not clib.dxf_create_subscription(sc.connection, et_type_int, &sc.subscription):
        process_last_error()
        return
    return sc

def dxf_add_symbols(SubscriptionClass sc, symbols: list):
    """
    Adds symbols to subscription
    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    symbols: list
        List of symbols to add
    """
    for idx, sym in enumerate(symbols):
        if not clib.dxf_add_symbol(sc.subscription, dxf_const_string_t_from_unicode(sym)):
            process_last_error()

def dxf_attach_listener(SubscriptionClass sc):
    """
    Function attaches default listener according to subscription type
    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    """
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
    elif sc.event_type_str == 'TimeAndSale':
        sc.data['columns'] = lis.TIME_AND_SALE_COLUMNS
        sc.listener = lis.time_and_sale_default_listener
    elif sc.event_type_str == 'Candle':
        sc.data['columns'] = lis.CANDLE_COLUMNS
        sc.listener = lis.candle_default_listener
    else:
        raise Exception(f'No default listener for {sc.event_type_str} event type')

    if not clib.dxf_attach_event_listener(sc.subscription, sc.listener, sc.u_data):
        process_last_error()

def dxf_attach_custom_listener(SubscriptionClass sc, lis.FuncWrapper fw, columns: list, data: dict = None):
    """
    Attaches custom listener
    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    fw: FuncWrapper
        c function wrapped in FuncWrapper class with Cython
    columns: list
        Columns for internal data of SubscriptionClass
    data: dict
        Dict with new internal data structure of  SubscriptionClass
    """
    if data:
        sc.data = data
    sc.data['columns'] = columns
    sc.listener = fw.func
    if not clib.dxf_attach_event_listener(sc.subscription, sc.listener, sc.u_data):
        process_last_error()


def dxf_detach_listener(SubscriptionClass sc):
    """
    Detaches any listener
    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    """
    if not clib.dxf_detach_event_listener(sc.subscription, sc.listener):
        process_last_error()

def dxf_close_connection(ConnectionClass cc):
    """
    Closes connection
    Parameters
    ----------
    cc: ConnectionClass
        Variable with connection information
    """
    if not clib.dxf_close_connection(cc.connection):
        process_last_error()

