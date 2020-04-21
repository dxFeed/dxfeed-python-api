# distutils: language = c++
# cython: always_allow_keywords=True
from libcpp.map cimport map as cppmap
from libc.stdlib cimport malloc, free

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

# for importing variables
import dxfeed.core.listeners.listener as lis
from dxfeed.core.pxd_include.EventData cimport *

cdef extern from "Python.h":
    char* PyUnicode_AsUTF8(object unicode)

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
    cdef cppmap[int, void **] con_users_map # contains pointers to all connection users
    # each user has its own index in a list
    cdef int con_users

    def __init__(self):
        self.con_users = 0

    def __dealloc__(self):
        dxf_close_connection(self)

    cpdef SubscriptionClass make_new_subscription(self, data_len: int):
        cdef SubscriptionClass out = SubscriptionClass(data_len)
        out.connection = self.connection
        self.con_users_map[self.con_users] = &out.subscription # append pointer to new subscription
        out.subscription_order = self.con_users  # assign each subscription an index
        self.con_users += 1
        out.con_users_map_ptr = &self.con_users_map  # reverse pointer to pointers list
        return out

    cpdef PriceLevelBookClass make_new_price_level_book(self, data_len: int):
        cdef PriceLevelBookClass out = PriceLevelBookClass(data_len)
        out.connection = self.connection
        self.con_users_map[self.con_users] = &out.book
        out.book_order_id = self.con_users
        self.con_users += 1
        out.con_users_map_ptr = &self.con_users_map  # reverse pointer to pointers list
        return out

cdef class ConnectionUserClass:
    """
    C-level class, that contains common for dxf_connection_t users C-level fields, e.g. connection, data field pointer,
    etc
    """
    cdef clib.dxf_connection_t connection
    cdef cppmap[int, void **] *con_users_map_ptr   # pointer to map of connection users' pointers
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
        self.columns = list()
        if data_len > 0:
            self.data = deque_wl(maxlen=data_len)
        else:
            self.data = deque_wl()
        self.u_data = <void *> self.data

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

cdef class SubscriptionClass(ConnectionUserClass):
    """
    Data structure that contains subscription and related fields
    """
    cdef clib.dxf_subscription_t subscription
    cdef int subscription_order  # index in list of subscription pointers
    cdef dxf_event_listener_t listener
    cdef object event_type_str

    def __init__(self, data_len: int):
        super().__init__(data_len)
        self.subscription = NULL
        self.listener = NULL

    def __dealloc__(self):
        if self.subscription:  # if connection is not closed
            clib.dxf_close_subscription(self.subscription)
            self.con_users_map_ptr[0][self.subscription_order] = NULL

cdef class PriceLevelBookClass(ConnectionUserClass):
    """
    Class responsible for price level book. Contains related fields
    """
    cdef clib.dxf_price_level_book_t book
    cdef int book_order_id  # index in list of subscription pointers
    cdef clib.dxf_price_level_book_listener_t book_listener


    def __init__(self, data_len: int):
        super().__init__(data_len)
        self.book = NULL
        self.book_listener = NULL

    def __dealloc__(self):
        if self.book:
            clib.dxf_close_price_level_book(self.book)
            self.con_users_map_ptr[0][self.book_order_id] = NULL


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

def dxf_create_subscription(ConnectionClass cc, event_type: str, data_len: int = 100000):
    """
    Function creates subscription and writes all relevant information to SubscriptionClass

    Parameters
    ----------
    cc: ConnectionClass
        Variable with connection information
    event_type: str
        Event types: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH',
        'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
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

    clib.dxf_create_subscription(sc.connection, et_type_int, &sc.subscription)

    error_code = process_last_error(verbose=False)
    if error_code:
        raise RuntimeError(f"In underlying C-API library error {error_code} occurred!")
    return sc

def dxf_create_subscription_timed(ConnectionClass cc, event_type: str, time: int,  data_len: int = 100000):
    """
    Creates a timed subscription with the specified parameters.

    Notes
    -----
    Default limit for 'Candle' event type is 8000 records. The other event types have default limit of 1000 records.

    Parameters
    ----------
    cc: ConnectionClass
        Variable with connection information
    event_type: str
        Event types: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH',
        'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
    time: int
        UTC time in the past (unix time in milliseconds)
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
    if time < 0 or not isinstance(time, int):
        raise ValueError('time argument should be non-negative integer!')

    sc = cc.make_new_subscription(data_len=data_len)
    sc.event_type_str = event_type
    et_type_int = event_type_convert(event_type)

    clib.dxf_create_subscription_timed(sc.connection, et_type_int, time, &sc.subscription)

    error_code = process_last_error(verbose=False)
    if error_code:
        raise RuntimeError(f"In underlying C-API library error {error_code} occurred!")
    return sc

def dxf_create_price_level_book(ConnectionClass connection, symbol: str,
                                sources: Iterable[str], data_len: int = 100000):
    """
    Creates Price Level book with the specified parameters.

    Parameters
    ----------
    connection: ConnectionClass
        ConnectionClass with initialized connection
    symbol: str
        Base symbol to use
    sources: list
        Order sources for Order. Each element can be one of following: "BYX", "BZX", "DEA", "DEX", "ISE", "IST", "NTV".
    data_len: int
        Amount of events that will be stored in returned object's field as deque

    Returns
    -------
    pl_book: PriceLevelBookClass
        Object with all needed fields initialized
    """
    if not connection.connection:
        raise ValueError('Connection is not valid')

    pl_book = connection.make_new_price_level_book(data_len)
    base_symbol = dxf_const_string_t_from_unicode(symbol)


    cdef const char ** base_sources =  <const char **>malloc((len(sources)+1) * sizeof(const char *))
    for i in range(len(sources)):
        base_sources[i] = PyUnicode_AsUTF8(sources[i])
    base_sources[len(sources)+1] = NULL
    clib.dxf_create_price_level_book(pl_book.connection, base_symbol, base_sources, &pl_book.book)
    free(base_sources)

    error_code = process_last_error(verbose=False)
    if error_code:
        raise RuntimeError(f"In underlying C-API library error {error_code} occurred!")
    return pl_book

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

def dxf_attach_price_level_book_listener(PriceLevelBookClass price_level_book):
    """
    Function attaches default listener.

    Parameters
    ----------
    price_level_book: PriceLevelBookClass
        PriceLevelBookClass initialized with dxf_create_price_level_book
    """
    if not price_level_book.book:
        raise ValueError('Subscription is not valid')
    price_level_book.book_listener = lis.book_default_listener
    price_level_book.columns = lis.BOOK_COLUMNS

    if not clib.dxf_attach_price_level_book_listener(price_level_book.book,
                                                     price_level_book.book_listener,
                                                     price_level_book.u_data):
        process_last_error()

def dxf_detach_price_level_book_listener(PriceLevelBookClass price_level_book):
    """
    Function detaches listener.

    Parameters
    ----------
    price_level_book: PriceLevelBookClass
        PriceLevelBookClass with attached listener
    """
    if not price_level_book.book:
        raise ValueError('PriceLevelBookClass is not valid')
    if not clib.dxf_detach_price_level_book_listener(price_level_book.book,
                                                     price_level_book.book_listener):
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

    # close all subscriptions before closing the connection
    for i in range(cc.con_users_map.size()):
        if cc.con_users_map[i]:  # subscription should not be closed previously
            clib.dxf_close_subscription(cc.con_users_map[i][0])
            cc.con_users_map[i][0] = NULL  # mark subscription as closed

    cc.con_users_map.clear()

    if cc.connection:
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
