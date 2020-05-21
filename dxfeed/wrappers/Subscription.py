from dxfeed.core.DXFeedPy import *
from typing import Iterable, Union
from datetime import datetime
import pandas as pd
from warnings import warn


class Subscription(object):
    def __init__(self, connection, event_type: str, date_time: Union[str, datetime], data_len: int = 100000):
        self.__event_type = event_type
        if date_time is not None:
            if isinstance(date_time, str):
                try:
                    date_time = datetime.strptime(date_time, '%Y-%m-%d %H:%M:%S.%f')
                except ValueError:
                    try:
                        date_time = pd.to_datetime(date_time, format='%Y-%m-%d %H:%M:%S.%f', infer_datetime_format=True)
                        warn_message = 'date_time argument does not exactly match %Y-%m-%d %H:%M:%S.%f format,' + \
                                       ' date was parsed automatically as ' + \
                                       date_time.strftime(format="%Y-%m-%d %H:%M:%S.%f")
                        warn(warn_message)
                    except ValueError:
                        raise ValueError('date_time should use %Y-%m-%d %H:%M:%S.%f format!')
            timestamp = int(date_time.timestamp() * 1000)
            self.__sub = dxf_create_subscription_timed(cc=connection,
                                                       event_type=event_type,
                                                       time=timestamp,
                                                       data_len=data_len)
        else:
            self.__sub = dxf_create_subscription(cc=connection,
                                                 event_type=event_type,
                                                 data_len=data_len)

    @property
    def event_type(self):
        return self.__event_type

    @property
    def symbols(self):
        return dxf_get_symbols(self.__sub)

    def add_symbols(self, symbols: Iterable[str]):
        dxf_add_symbols(sc=self.__sub, symbols=symbols)
        return self

    def remove_symbols(self, symbols: Iterable[str] = [''], remove_all: bool = False):
        if remove_all:
            dxf_clear_symbols(self.__sub)
        else:
            dxf_remove_symbols(self.__sub, symbols=symbols)
        return self

    def close_subscription(self):
        dxf_close_subscription(sc=self.__sub)

    def attach_listener(self):
        dxf_attach_listener(self.__sub)
        return self

    def detach_listener(self):
        dxf_detach_listener(self.__sub)
        return self

    def get_data(self):
        return self.__sub.get_data()

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
        return self.__sub.to_dataframe(keep)

    def __del__(self):
        self.close_subscription()
