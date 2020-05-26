from dxfeed.core.DXFeedPy import *
from typing import Iterable, Union
from datetime import datetime
import pandas as pd
from warnings import warn
import dxfeed.wrappers.class_utils as cu


class Subscription(object):
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
        dxf_add_symbols(sc=self.__sub, symbols=cu.to_iterable_of_strings(symbols))
        return self

    def remove_symbols(self, symbols: Union[str, Iterable[str]] = None):
        """
        Method removes symbols from subscription. If no symbols provided removes all symbols

        Parameters
        ----------
        symbols: str, iterable
            One ticker or list of tickers to remove from subscription

        Returns
        -------
        self: Subscription
        """
        if symbols:
            dxf_remove_symbols(self.__sub, symbols=cu.to_iterable_of_strings(symbols))
        else:
            dxf_clear_symbols(self.__sub)
        return self

    def close_subscription(self):
        dxf_close_subscription(sc=self.__sub)

    def attach_listener(self):
        dxf_attach_listener(self.__sub)
        return self

    def detach_listener(self):
        dxf_detach_listener(self.__sub)
        return self

    def get_list(self):
        return self.__sub.get_data()

    def get_dataframe(self, keep: bool=True):
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
        return self.__sub.to_dataframe(keep)