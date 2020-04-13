from dxfeed.core.DXFeedPy import *


class DXFeedSubscription(object):
    def __init__(self, connection, event_type: str, data_len: int = 100000):
        self.__sub = dxf_create_subscription(cc=connection,
                                             event_type=event_type,
                                             data_len=data_len)

    def add_symbols(self, symbols: Iterable[str]):
        dxf_add_symbols(sc=self.__sub, symbols=symbols)
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

    def to_dataframe(self):
        return self.__sub.to_dataframe()

    def __del__(self):
        self.close_subscription()