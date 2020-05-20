# distutils: language = c++
# cython: always_allow_keywords=True

from dxfeed.core.utils.helpers cimport *
from dxfeed.core.utils.helpers import *
cimport dxfeed.core.pxd_include.DXFeed as clib
cimport dxfeed.core.pxd_include.DXErrorCodes as dxec
cimport dxfeed.core.listeners.listener as lis
from dxfeed.core.utils.data_class import DequeWithLock as deque_wl
from datetime import datetime
import pandas as pd
from typing import Optional, Union, Iterable
from warnings import warn
from weakref import WeakSet

# for importing variables
import dxfeed.core.listeners.listener as lis
from dxfeed.core.pxd_include.EventData cimport *

cpdef int process_last_error(verbose: bool=True):
    """
    Function retrieves last error

    Parameters
    ----------
    verbose: bool
        If True error description is printed
        
    Returns
    -------
    error_code: int
        Error code is returned
    """
    cdef int error_code = dxec.dx_ec_success
    cdef dxf_const_string_t error_descr = NULL
    cdef int res

    res = clib.dxf_get_last_error(&error_code, &error_descr)

    if res == clib.DXF_SUCCESS:
        if error_code == dxec.dx_ec_success and verbose:
            print("no error information is stored")

        if verbose:
            print("Error occurred and successfully retrieved:\n",
                  f"error code = {error_code}, description = {unicode_from_dxf_const_string_t(error_descr)}")

    return error_code


cdef class ConnectionClass:
    """
    Data structure that contains connection
    """
    cdef clib.dxf_connection_t connection
    cdef object __sub_refs

    def __init__(self):
        self.__sub_refs = WeakSet()

    def __dealloc__(self):
        dxf_close_connection(self)

    def get_sub_refs(self):
        """
        Method to get list of references to all subscriptions related to current connection

        Returns
        -------
        :list
            List of weakref objects. Empty list if no refs
        """
        return list(self.__sub_refs)

    cpdef SubscriptionClass make_new_subscription(self, data_len: int):
        cdef SubscriptionClass out = SubscriptionClass(data_len)
        out.connection = self.connection
        self.__sub_refs.add(out)
        return out


cdef class SubscriptionClass:
    """
    Data structure that contains subscription and related fields
    """
    cdef clib.dxf_connection_t connection
    cdef clib.dxf_subscription_t subscription
    cdef dxf_event_listener_t listener
    cdef object __weakref__  # Weak referencing enabling
    cdef object event_type_str
    cdef list columns
    cdef object data
    cdef void *u_data

    def __init__(self, data_len: int):
        """
        Parameters
        ----------
        data_len: int
            Sets maximum amount of events, that are kept in Subscription class
        """
        self.subscription = NULL
        self.columns = list()
        if data_len > 0:
            self.data = deque_wl(maxlen=data_len)
        else:
            self.data = deque_wl()
        self.u_data = <void *> self.data
        self.listener = NULL

    def __dealloc__(self):
        dxf_close_subscription(self)

    def get_data(self):
        """
        Method returns list with data, specified in event listener and returned data will be removed from object buffer

        Returns
        -------
        list
            List with data
        """
        return self.data.safe_get()

    def to_dataframe(self, keep: bool=True):
        """
        Method converts data to the Pandas DataFrame

        Parameters
        ----------
        keep: bool
            When True copies data to dataframe, otherwise pops. Default True

        Returns
        -------
        df: pandas DataFrame
        """
        if keep:
            df_data = self.data.copy()
        else:
            df_data = self.data.safe_get()

        df = pd.DataFrame(df_data, columns=self.columns)
        time_columns = df.columns[df.columns.str.contains('Time')]
        for column in time_columns:
            df.loc[:, column] = df.loc[:, column].astype('<M8[ms]')
        return df

def dxf_create_connection(address: Union[str, unicode, bytes] = 'demo.dxfeed.com:7300'):
    """
    Function creates connection to dxfeed given url address

    Parameters
    ----------
    address: str
        dxfeed url address

    Returns
    -------
    cc: ConnectionClass
        Cython ConnectionClass with information about connection
    """
    cc = ConnectionClass()
    address = address.encode('utf-8')
    clib.dxf_create_connection(address, NULL, NULL, NULL, NULL, NULL, &cc.connection)
    error_code = process_last_error(verbose=False)
    if error_code:
        raise RuntimeError(f"In underlying C-API library error {error_code} occurred!")
    return cc

def dxf_create_connection_auth_bearer(address: Union[str, unicode, bytes],
                                     token: Union[str, unicode, bytes]):
    """
    Function creates connection to dxfeed given url address and token

    Parameters
    ----------
    address: str
        dxfeed url address
    token: str
        dxfeed token

    Returns
    -------
    cc: ConnectionClass
        Cython ConnectionClass with information about connection
    """
    cc = ConnectionClass()
    address = address.encode('utf-8')
    token = token.encode('utf-8')
    clib.dxf_create_connection_auth_bearer(address, token,
                                           NULL, NULL, NULL, NULL, NULL, &cc.connection)
    error_code = process_last_error(verbose=False)
    if error_code:
        raise RuntimeError(f"In underlying C-API library error {error_code} occurred!")
    return cc

def dxf_create_subscription(ConnectionClass cc, event_type: str, candle_time: Optional[str] = None,
                            data_len: int = 100000):
    """
    Function creates subscription and writes all relevant information to SubscriptionClass

    Parameters
    ----------
    cc: ConnectionClass
        Variable with connection information
    event_type: str
        Event types: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH',
        'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
    candle_time: str
        String of %Y-%m-%d %H:%M:%S datetime format for retrieving candles. By default set to now
    data_len: int
        Sets maximum amount of events, that are kept in Subscription class

    Returns
    -------
    sc: SubscriptionClass
        Cython SubscriptionClass with information about subscription
    """
    if not cc.connection:
        raise ValueError('Connection is not valid')
    if event_type not in ['Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH',
                          'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration', ]:
        raise ValueError('Incorrect event type!')

    sc = cc.make_new_subscription(data_len=data_len)
    sc.event_type_str = event_type
    et_type_int = event_type_convert(event_type)

    try:
        candle_time = datetime.strptime(candle_time, '%Y-%m-%d %H:%M:%S') if candle_time else datetime.utcnow()
        timestamp = int((candle_time - datetime(1970, 1, 1)).total_seconds()) * 1000 - 5000
    except ValueError:
        raise Exception("Inappropriate date format, should be %Y-%m-%d %H:%M:%S")

    if event_type == 'Candle':
        clib.dxf_create_subscription_timed(sc.connection, et_type_int, timestamp, &sc.subscription)
    else:
        clib.dxf_create_subscription(sc.connection, et_type_int, &sc.subscription)

    error_code = process_last_error(verbose=False)
    if error_code:
        raise RuntimeError(f"In underlying C-API library error {error_code} occurred!")
    return sc

def dxf_add_symbols(SubscriptionClass sc, symbols: Iterable[str]):
    """
    Adds symbols to subscription

    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    symbols: list
        List of symbols to add
    """
    if not sc.subscription:
        raise ValueError('Subscription is not valid')
    for idx, sym in enumerate(symbols):
        if not isinstance(sym, str):
            warn(f'{sym} has type different from string')
            continue
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
    if not sc.subscription:
        raise ValueError('Subscription is not valid')
    if sc.event_type_str == 'Trade':
        sc.columns = lis.TRADE_COLUMNS
        sc.listener = lis.trade_default_listener
    elif sc.event_type_str == 'Quote':
        sc.columns = lis.QUOTE_COLUMNS
        sc.listener = lis.quote_default_listener
    elif sc.event_type_str == 'Summary':
        sc.columns = lis.SUMMARY_COLUMNS
        sc.listener = lis.summary_default_listener
    elif sc.event_type_str == 'Profile':
        sc.columns = lis.PROFILE_COLUMNS
        sc.listener = lis.profile_default_listener
    elif sc.event_type_str == 'TimeAndSale':
        sc.columns = lis.TIME_AND_SALE_COLUMNS
        sc.listener = lis.time_and_sale_default_listener
    elif sc.event_type_str == 'Candle':
        sc.columns = lis.CANDLE_COLUMNS
        sc.listener = lis.candle_default_listener
    elif sc.event_type_str == 'Order':
        sc.columns = lis.ORDER_COLUMNS
        sc.listener = lis.order_default_listener
    elif sc.event_type_str == 'TradeETH':
        sc.columns = lis.TRADE_COLUMNS
        sc.listener = lis.trade_default_listener
    elif sc.event_type_str == 'SpreadOrder':
        sc.columns = lis.ORDER_COLUMNS
        sc.listener = lis.order_default_listener
    elif sc.event_type_str == 'Greeks':
        sc.columns = lis.GREEKS_COLUMNS
        sc.listener = lis.greeks_default_listener
    elif sc.event_type_str == 'TheoPrice':
        sc.columns = lis.THEO_PRICE_COLUMNS
        sc.listener = lis.theo_price_default_listener
    elif sc.event_type_str == 'Underlying':
        sc.columns = lis.UNDERLYING_COLUMNS
        sc.listener = lis.underlying_default_listener
    elif sc.event_type_str == 'Series':
        sc.columns = lis.SERIES_COLUMNS
        sc.listener = lis.series_default_listener
    elif sc.event_type_str == 'Configuration':
        sc.columns = lis.CONFIGURATION_COLUMNS
        sc.listener = lis.configuration_default_listener
    else:
        raise Exception(f'No default listener for {sc.event_type_str} event type')

    if not clib.dxf_attach_event_listener(sc.subscription, sc.listener, sc.u_data):
        process_last_error()

def dxf_attach_custom_listener(SubscriptionClass sc, lis.FuncWrapper fw, columns: Iterable[str], data: Iterable = None):
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
    if not sc.subscription:
        raise ValueError('Subscription is not valid')
    if data:
        sc.data = data
    sc.columns = columns
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
    if not sc.subscription:
        raise ValueError('Subscription is not valid')
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
    if cc.connection:
        related_subs = cc.get_sub_refs()
        for sub in related_subs:
            dxf_close_subscription(sub)

        clib.dxf_close_connection(cc.connection)
        cc.connection = NULL

def dxf_close_subscription(SubscriptionClass sc):
    """
    Closes subscription

    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    """
    if sc.subscription:
        clib.dxf_close_subscription(sc.subscription)
        sc.subscription = NULL

def dxf_get_current_connection_status(ConnectionClass cc, return_str: bool=True):
    """
    Returns one of four possible statuses

    Parameters
    ----------
    cc: ConnectionClass
        Variable with connection information
    return_str: bool
        When True returns connection status in string format, otherwise internal c representation as integer


    """
    status_mapping = {
        0: 'Not connected',
        1: 'Connected',
        2: 'Login required',
        3: 'Connected and authorized'
    }

    cdef clib.dxf_connection_status_t status
    clib.dxf_get_current_connection_status(cc.connection, &status)
    result = status
    if return_str:
        result = status_mapping[status]

    return result

def dxf_get_current_connected_address(ConnectionClass cc):
    """
    Returns current connected address

    Parameters
    ----------
    cc: ConnectionClass
        Variable with connection information

    Returns
    -------
    address: str
        Current connected address
    """
    if not cc.connection:
        raise ValueError('Connection is not valid')

    cdef char * address
    clib.dxf_get_current_connected_address(cc.connection, &address)
    return (<bytes>address).decode('UTF-8')

def dxf_initialize_logger(file_name: str, rewrite_file: bool, show_timezone_info: bool, verbose: bool):
    """
    Initializes the internal logger.
    Various actions and events, including the errors, are being logged throughout the library. They may be stored
    into the file.

    Parameters
    ----------
    file_name: str
        A full path to the file where the log is to be stored
    rewrite_file: bool
        A flag defining the file open mode if it's True then the log file will be rewritten
    show_timezone_info: bool
        A flag defining the time display option in the log file if it's True then the time will be displayed
        with the timezone suffix
    verbose: bool
        A flag defining the logging mode if it's True then the verbose logging will be enabled

    """
    clib.dxf_initialize_logger(file_name.encode('UTF-8'), int(rewrite_file), int(show_timezone_info), int(verbose))

def dxf_get_subscription_event_types(SubscriptionClass sc, return_str: bool=True):
    """
    Gets subscription event type

    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    return_str: bool
        When True returns event type in string format, otherwise internal c representation as integer

    Returns
    -------
    str or int
        Subscription type
    """
    if not sc.subscription:
        raise ValueError('Invalid subscription')

    cdef int event_type

    et_mapping = {
        1: 'Trade',
        2: 'Quote',
        4: 'Summary',
        8: 'Profile',
        16: 'Order',
        32: 'TimeAndSale',
        64: 'Candle',
        128: 'TradeETH',
        256: 'SpreadOrder',
        512: 'Greeks',
        1024: 'TheoPrice',
        2048: 'Underlying',
        4096: 'Series',
        8192: 'Configuration',
        -16384: ''
    }

    clib.dxf_get_subscription_event_types (sc.subscription, &event_type)
    result = event_type
    if return_str:
        result = et_mapping[event_type]

    return result

def dxf_get_symbols(SubscriptionClass sc):
    """
    Retrieves the list of symbols currently added to the subscription.

    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription

    Returns
    -------
    list
        List of unicode strings of subscription symbols
    """
    if not sc.subscription:
        raise ValueError('Invalid subscription')

    cdef dxf_const_string_t * symbols
    symbols_list = list()
    cdef int symbol_count
    cdef int i

    clib.dxf_get_symbols(sc.subscription, &symbols, &symbol_count)
    for i in range(symbol_count):
        symbols_list.append(unicode_from_dxf_const_string_t(symbols[i]))

    return symbols_list

def dxf_remove_symbols(SubscriptionClass sc, symbols: Iterable[str]):
    """
    Removes several symbols from the subscription

    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    symbols: list
        List of symbols to remove
    """
    if not sc.subscription:
        raise ValueError('Invalid subscription')

    for symbol in symbols:
        clib.dxf_remove_symbol(sc.subscription, dxf_const_string_t_from_unicode(symbol))

def dxf_clear_symbols(SubscriptionClass sc):
    """
    Removes all symbols from the subscription

    Parameters
    ----------
    sc: SubscriptionClass
        SubscriptionClass with information about subscription
    """
    if not sc.subscription:
        raise ValueError('Invalid subscription')

    clib.dxf_clear_symbols(sc.subscription)
