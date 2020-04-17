from dxfeed.core.DXFeedPy import *
from dxfeed.wrappers.DXFeedSubscription import DXFeedSubscription


class DXFeed(object):
    def __init__(self, connection_address: str = 'demo.dxfeed.com:7300'):
        self.__con_address = connection_address
        self.__connection = ConnectionClass()
        self.connect()

    @property
    def connection_status(self):
        return dxf_get_current_connection_status(self.__connection, return_str=True)

    @property
    def address(self):
        return dxf_get_current_connected_address(self.__connection)

    def connect(self):
        if dxf_get_current_connection_status(self.__connection, return_str=False):
            dxf_close_connection(self.__connection)
        self.__connection = dxf_create_connection(self.__con_address)
        return self

    def create_subscription(self, event_type: str, data_len: int = 100000, date_time: Union[str, datetime] = None):
        con_status = dxf_get_current_connection_status(self.__connection, return_str=False)
        if con_status == 0 or con_status == 2:
            raise ValueError('Connection is not established')
        subscription = DXFeedSubscription(connection=self.__connection,
                                          event_type=event_type,
                                          date_time=date_time,
                                          data_len=data_len)
        return subscription

    def close_connection(self):
        dxf_close_connection(self.__connection)

    def __del__(self):
        self.close_connection()
