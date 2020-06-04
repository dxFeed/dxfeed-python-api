from dxfeed.core.DXFeedPy import *
from typing import Iterable, Union, Optional
from datetime import datetime
import dxfeed.wrappers.class_utils as cu


class Subscription(object):
    """
    Class for subscription management. Recommended to be created only via create_subscription method in Endpoint class.
    Also stores incoming events

    Attributes
    ----------
    connection: dxfeed.core.DXFeedPy.ConnectionClass
        Core class written in cython, that handle connection related details on the low level
    event_type: str
        One of possible event types: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle',
        'TradeETH', 'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
    data_len: int
        The amount of events kept in Subscription class. By default event is received as list and each event is stored
        in deque of fixed size. To have no limits for the deque set this value to -1. Default 100000.
    date_time: str or datetime.datetime
        If present timed subscription will be created (conflated stream). For sting date format is following:
        %Y-%m-%d %H:%M:%S.%f. If None - stream subscription will be created (non-conflated). Default - None.

    Note
    ----
    Some event types (e.g. Candle) support only timed subscription.

    """
    def __init__(self, connection, event_type: str, date_time: Union[str, datetime], data_len: int = 100000):
        self.__event_type = event_type
        if date_time is None:
            self.__sub = dxf_create_subscription(cc=connection,
                                                 event_type=event_type,
                                                 data_len=data_len)
        else:
            date_time = cu.handle_datetime(date_time, fmt='%Y-%m-%d %H:%M:%S.%f')
            timestamp = int(date_time.timestamp() * 1000)
            self.__sub = dxf_create_subscription_timed(cc=connection,
                                                       event_type=event_type,
                                                       time=timestamp,
                                                       data_len=data_len)

    def __del__(self):
        self.close_subscription()

    @property
    def event_type(self):
        return self.__event_type

    @property
    def symbols(self):
        return dxf_get_symbols(self.__sub)

    def add_symbols(self, symbols: Union[str, Iterable[str]]):
        """
        Method to add symbol. Supports addition of one symbol as a string as well as list of symbols
        Parameters
        ----------
        symbols: str, Iterable
            Symbols to add. Previously added and remained symbols are ignored on C-API level

        Returns
        -------
        self: Subscription
        """
        dxf_add_symbols(sc=self.__sub, symbols=cu.to_iterable(symbols))
        return self

    def remove_symbols(self, symbols: Optional[Union[str, Iterable[str]]] = None):
        """
        Method removes symbols from subscription. If no symbols provided removes all symbols

        Parameters
        ----------
        symbols: str, Iterable
            One ticker or list of tickers to remove from subscription

        Returns
        -------
        self: Subscription
        """
        if symbols:
            dxf_remove_symbols(self.__sub, symbols=cu.to_iterable(symbols))
        else:
            dxf_clear_symbols(self.__sub)
        return self

    def close_subscription(self):
        """
        Method to close subscription. All received data will remain in the object.
        """
        dxf_close_subscription(sc=self.__sub)

    def attach_listener(self):
        """
        Method to attach default listener.

        Returns
        -------
        self: Subscription
        """
        dxf_attach_listener(self.__sub)
        return self

    def detach_listener(self):
        """
        Removes listener so new events won't be received

        Returns
        -------
        self: Subscription
        """
        dxf_detach_listener(self.__sub)
        return self

    def get_list(self):
        """
        Method to get data. When called internal field is cleared

        Returns
        -------
        data: list
            List of events. Each event contains list with data related to subscription type.
        """
        return self.__sub.get_data()

    def get_dataframe(self, keep: bool = True):
        """
        Method converts data to the Pandas DataFrame

        Parameters
        ----------
        keep: bool
            When True copies data to dataframe, otherwise pops. Default True

        Returns
        -------
        df: pandas.DataFrame
            Dataframe each row - one event.
        """
        return self.__sub.to_dataframe(keep)
