from dxfeed.core.DXFeedPy import *
from dxfeed.wrappers.subscription import Subscription


class Endpoint(object):
    """
    Class for connection management. After successful creation Instance will be connected to server
    with provided credentials

    Attributes
    ----------
    connection_address: str
        One of possible connection addresses:
        
        - the single address: `host:port` or just `host`
        - address with credentials: `host:port[username=xxx,password=yyy]`
        - multiple addresses: `(host1:port1)(host2)(host3:port3[username=xxx,password=yyy])`
        
        Default: demo.dxfeed.com:7300
    connect: bool
        When True `connect` method  is called during instance creation. Default - True
    """
    def __init__(self, connection_address: str = 'demo.dxfeed.com:7300', connect: bool = True):
        self.__con_address = connection_address
        self.__connection = ConnectionClass()
        if connect:
            self.connect()

    def __del__(self):
        self.close_connection()

    @property
    def connection_status(self):
        return dxf_get_current_connection_status(self.__connection, return_str=True)

    @property
    def address(self):
        return self.__con_address

    def connect(self, reconnect: bool = True):
        """
        Creates connection. If connection status differs from "Not connected" and `reconnect` is False, does nothing

        Parameters
        ----------
        reconnect: bool
            When True closes previous connection. Default - True

        Returns
        -------
        self: Endpoint
        """
        if reconnect:
            dxf_close_connection(self.__connection)

        con_status = dxf_get_current_connection_status(self.__connection, return_str=True)

        if con_status == 'Not connected':
            self.__connection = dxf_create_connection(self.address)

        return self

    def create_subscription(self, event_type: str, data_len: int = 100000, date_time: Union[str, datetime] = None):
        """
        Method creates certain event type subscription and returns Subscription class

        Parameters
        ----------
        event_type: str
            One of possible event types: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle',
            'TradeETH', 'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
        data_len: int
            The amount of events kept in Subscription class. To have no limits set this value to -1
        date_time: str or datetime.datetime
            If present timed subscription will be created (conflated stream). For sting date format is following:
            %Y-%m-%d %H:%M:%S.%f. If None - stream subscription will be created. Default - None.

        Note
        ----
        Some event types (e.g. Candle) support only timed subscription.

        Returns
        -------
        subscription: Subscription
            Subscription class related to current connection
        """
        con_status = dxf_get_current_connection_status(self.__connection, return_str=False)
        if con_status == 0 or con_status == 2:
            raise ValueError('Connection is not established')
        subscription = Subscription(connection=self.__connection,
                                    event_type=event_type,
                                    date_time=date_time,
                                    data_len=data_len)
        return subscription

    def close_connection(self):
        """
        Method to close connections and all related subscriptions.
        """
        dxf_close_connection(self.__connection)
