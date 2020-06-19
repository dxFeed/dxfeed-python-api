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
def endpoint():
    dxf = dx.Endpoint(connection_address=ValueStorage.demo_address)
    yield dxf
    dxf.close_connection()


@pytest.fixture(scope='function', params=ValueStorage.event_types)
def subscription(endpoint, request):
    sub = endpoint.create_subscription(event_type=request.param)
    yield sub
    sub.close_subscription()


@pytest.fixture(scope='function', params=ValueStorage.event_types)
def subscription_timed(endpoint, request):
    sub = endpoint.create_subscription(event_type=request.param, date_time=ValueStorage.date_time)
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
                               .remove_symbols()
    assert subscription.symbols == []


def test_remove_all_symbols_timed(subscription_timed):
    subscription_timed = subscription_timed.add_symbols(ValueStorage.symbols) \
                                           .remove_symbols()
    assert subscription_timed.symbols == []


def test_default_event_handler(endpoint):
    sub = endpoint.create_subscription(event_type='Trade').add_symbols(ValueStorage.symbols)
    assert isinstance(sub.get_event_handler(), dx.DefaultHandler)


def test_default_event_handler_timed(endpoint):
    sub = endpoint.create_subscription(event_type='Trade', date_time=ValueStorage.date_time).add_symbols(ValueStorage.symbols)
    assert isinstance(sub.get_event_handler(), dx.DefaultHandler)


def test_event_handler_setter(endpoint):
    handler = dx.EventHandler()
    sub = endpoint.create_subscription(event_type='Trade').set_event_handler(handler)
    assert sub.get_event_handler() is handler


def test_event_handler_setter_timed(endpoint):
    handler = dx.EventHandler()
    sub = endpoint.create_subscription(event_type='Trade', date_time=ValueStorage.date_time).set_event_handler(handler)
    assert sub.get_event_handler() is handler
