import dxfeed as dx
import pytest
from datetime import datetime


class ValueStorage(object):  # config
    demo_address = 'demo.dxfeed.com:7300'
    event_types = ['Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
                   'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration']
    symbols = ['AAPL', 'MSFT']
    date_time = datetime.now()


@pytest.fixture(scope='function')
def dxfeed():
    dxf = dx.DXFeed(connection_address=ValueStorage.demo_address)
    yield dxf
    dxf.close_connection()


@pytest.fixture(scope='function', params=ValueStorage.event_types)
def subscription(dxfeed, request):
    sub = dxfeed.create_subscription(event_type=request.param)
    yield sub
    sub.close_subscription()


@pytest.fixture(scope='function', params=ValueStorage.event_types)
def subscription_timed(dxfeed, request):
    sub = dxfeed.create_subscription(event_type=request.param, date_time=ValueStorage.date_time)
    yield sub
    sub.close_subscription()


def test_subscription_event_type_property(subscription):
    assert subscription.event_type in ValueStorage.event_types


def test_subscription_timed_event_type_property(subscription_timed):
    assert subscription_timed.event_type in ValueStorage.event_types


def test_subscription_event_type_property(subscription):
    subscription = subscription.add_symbols(ValueStorage.symbols)
    assert subscription.symbols == ValueStorage.symbols


def test_subscription_timed_event_type_property(subscription_timed):
    subscription = subscription_timed.add_symbols(ValueStorage.symbols)
    assert subscription.symbols == ValueStorage.symbols


def test_remove_symbol(subscription):
    subscription = subscription.add_symbols(ValueStorage.symbols) \
                               .remove_symbols([ValueStorage.symbols[0]])
    assert subscription.symbols == ValueStorage.symbols[1:]


def test_remove_symbol_timed(subscription_timed):
    subscription_timed = subscription_timed.add_symbols(ValueStorage.symbols) \
                                           .remove_symbols([ValueStorage.symbols[0]])
    assert subscription_timed.symbols == ValueStorage.symbols[1:]


def test_remove_all_symbols(subscription):
    subscription = subscription.add_symbols(ValueStorage.symbols) \
                               .remove_symbols(remove_all=True)
    assert subscription.symbols == []


def test_remove_all_symbols_timed(subscription_timed):
    subscription_timed = subscription_timed.add_symbols(ValueStorage.symbols) \
                                           .remove_symbols(remove_all=True)
    assert subscription_timed.symbols == []
