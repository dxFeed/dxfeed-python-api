from typing import Iterable, Union, Optional
from datetime import datetime
from warnings import simplefilter

from dxfeed.core import DXFeedPy as dxp
from dxfeed.core.utils.handler import DefaultHandler
import dxfeed.wrappers.class_utils as cu


class Subscription(object):
    """
    Class for subscription management. Recommended to be created only via create_subscription method in Endpoint class.
    Also stores incoming events

    Attributes
    ----------
    event_type: str
        One of possible event types: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle',
        'TradeETH', 'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
    symbols: Iterable
        Symbols of current subscription.

    Note
    ----
    Some event types (e.g. Candle) support only timed subscription.

    """
    def __init__(self, connection, event_type: str, date_time: Union[str, datetime], exact_format: bool = True):
        """

        Parameters
        ----------
        connection: dxfeed.core.DXFeedPy.ConnectionClass
            Core class written in cython, that handle connection related details on the low level
        event_type: str
            One of possible event types: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle',
            'TradeETH', 'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
        date_time: str or datetime.datetime
            If present timed subscription will be created (conflated stream). For sting date format is following:
            %Y-%m-%d %H:%M:%S.%f. If None - stream subscription will be created (non-conflated). Default - None.
        exact_format: bool
            If False no warning will be thrown in case of incomplete date_time parameter. Default - True
        """
        self.__event_type = event_type
        if date_time is None:
            self.__sub = dxp.dxf_create_subscription(cc=connection,
                                                     event_type=event_type)
        else:
            date_time = cu.handle_datetime(date_time, fmt='%Y-%m-%d %H:%M:%S.%f', exact_format=exact_format)
            timestamp = int(date_time.timestamp() * 1000)
            self.__sub = dxp.dxf_create_subscription_timed(cc=connection,
                                                           event_type=event_type,
                                                           time=timestamp)

    def __del__(self):
        self.close_subscription()

    @property
    def event_type(self):
        return self.__event_type

    @property
    def symbols(self):
        return dxp.dxf_get_symbols(self.__sub)

    def add_symbols(self, symbols: Union[str, Iterable[str]]):
        """
        Method to add symbol. Supports addition of one symbol as a string as well as list of symbols.
        If no event handler was set, DefaultHandler will be initialized.

        Parameters
        ----------
        symbols: str, Iterable
            Symbols to add. Previously added and remained symbols are ignored on C-API level

        Returns
        -------
        self: Subscription
        """
        self._attach_default_listener()
        dxp.dxf_add_symbols(sc=self.__sub, symbols=cu.to_iterable(symbols))
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
            dxp.dxf_remove_symbols(self.__sub, symbols=cu.to_iterable(symbols))
        else:
            dxp.dxf_clear_symbols(self.__sub)
        return self

    def close_subscription(self):
        """
        Method to close subscription. All received data will remain in the object.
        """
        dxp.dxf_close_subscription(sc=self.__sub)

    def _attach_default_listener(self):
        """
        Method to attach default listener. If event handler was not previously set, DefaultHandler will be initialized.

        Returns
        -------
        self: Subscription
        """
        if not self.get_event_handler():
            self.set_event_handler(DefaultHandler())
            simplefilter(action='ignore', category=FutureWarning)

        dxp.dxf_attach_listener(self.__sub)

        simplefilter(action='default', category=FutureWarning)

        return self

    def _detach_listener(self):
        """
        Removes listener so new events won't be received

        Returns
        -------
        self: Subscription
        """
        dxp.dxf_detach_listener(self.__sub)
        return self

    def get_event_handler(self):
        """
        Method to get event handler. If no handlers passed previously returns None.

        Returns
        -------
        handler: EventHandler
        """
        return self.__sub.get_event_handler()

    def set_event_handler(self, handler: dxp.EventHandler):
        """
        Method to set the handler.

        Parameters
        ----------
        handler: EventHandler
            Event handler with `update` method defined.

        Returns
        -------
        self: Subscription
        """
        self.__sub.set_event_handler(handler)
        return self
