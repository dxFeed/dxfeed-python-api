from dxfeed.core.DXFeedPy import *
from typing import Iterable


class DXFeedSubscription(object):
    def __init__(self, connection, event_type: str, data_len: int = 100000):
        self.__sub = dxf_create_subscription(cc=connection,
                                             event_type=event_type,
                                             data_len=data_len)

    @property
    def event_type(self):
        return dxf_get_subscription_event_types(self.__sub, return_str=True)

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
        dxf_close_connection(sc=self.__sub)

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
