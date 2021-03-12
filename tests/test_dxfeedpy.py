import dxfeed.core.DXFeedPy as dxc
from dxfeed.core.utils.handler import DefaultHandler
import pytest


class ValueStorage(object):  # config
    demo_address = 'demo.dxfeed.com:7300'
    event_types = ['Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
                   'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration']


@pytest.fixture(scope='function')
def connection():
    # Setup
    con = dxc.dxf_create_connection(ValueStorage.demo_address)
    yield con  # pass var to test and test itself
    # Teardown
    dxc.dxf_close_connection(con)


def test_connection_status(connection):
    exp_statuses = ['Connected', 'Connected and authorized']
    act_status = dxc.dxf_get_current_connection_status(connection)
    assert act_status in exp_statuses


def test_connection_address(connection):
    exp_address = ValueStorage.demo_address
    act_address = dxc.dxf_get_current_connected_address(connection)
    assert exp_address == act_address


@pytest.mark.xfail()
def test_fail_connection_to_wrong_address():
    dxc.dxf_create_connection(address='8.8.8.8')


@pytest.mark.xfail()
def test_fail_create_subscription_with_no_connection():
    dxc.dxf_create_subscription()


@pytest.mark.xfail()
def test_fail_to_use_subscription_without_connection(connection):
    sub = dxc.dxf_create_subscription(cc=connection, event_type='Trade')
    dxc.dxf_close_connection(connection)
    dxc.dxf_add_symbols(sc=sub, symbols=['AAPL'])


@pytest.mark.parametrize('sub_type', ValueStorage.event_types)
def test_subscription_on_correct_types(connection, sub_type):
    sub = dxc.dxf_create_subscription(cc=connection, event_type=sub_type)
    act_sub_type = dxc.dxf_get_subscription_event_types(sc=sub)
    dxc.dxf_close_subscription(sub)
    assert act_sub_type == sub_type


@pytest.mark.parametrize('sub_type', ValueStorage.event_types)
def test_subscription_timed_on_correct_types(connection, sub_type):
    sub = dxc.dxf_create_subscription_timed(cc=connection, event_type=sub_type, time=0)
    act_sub_type = dxc.dxf_get_subscription_event_types(sc=sub)
    dxc.dxf_close_subscription(sub)
    assert act_sub_type == sub_type


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_time_type(connection):
    dxc.dxf_create_subscription_timed(cc=connection, event_type='Trade', time=5.2)


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_time_value(connection):
    dxc.dxf_create_subscription_timed(cc=connection, event_type='Trade', time=-7)


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_type(connection):
    dxc.dxf_create_subscription(cc=connection, event_type='TradeQuote')


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_type(connection):
    dxc.dxf_create_subscription_timed(cc=connection, event_type='TradeQuote', time=0)



def test_symbol_addition(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxc.dxf_create_subscription(cc=connection, event_type='Trade')
    dxc.dxf_add_symbols(sc=sub, symbols=symbols)
    actual_symbols = dxc.dxf_get_symbols(sc=sub)
    dxc.dxf_close_subscription(sub)
    assert symbols == actual_symbols


def test_symbol_deletion(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxc.dxf_create_subscription(cc=connection, event_type='Trade')
    dxc.dxf_add_symbols(sc=sub, symbols=symbols)
    dxc.dxf_remove_symbols(sc=sub, symbols=['AAPL'])
    actual_symbols = dxc.dxf_get_symbols(sc=sub)
    dxc.dxf_close_subscription(sub)
    assert ['GOOG'] == actual_symbols


@pytest.mark.filterwarnings('ignore::UserWarning')
def test_wrong_symbol_types_ignored(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxc.dxf_create_subscription(cc=connection, event_type='Trade')
    dxc.dxf_add_symbols(sc=sub, symbols=symbols + [1, 5.0, [], True, {}, ()])
    actual_symbols = dxc.dxf_get_symbols(sc=sub)
    dxc.dxf_close_subscription(sub)
    assert symbols == actual_symbols


def test_symbol_clearing(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxc.dxf_create_subscription(cc=connection, event_type='Trade')
    dxc.dxf_add_symbols(sc=sub, symbols=symbols)
    dxc.dxf_clear_symbols(sc=sub)
    actual_symbols = dxc.dxf_get_symbols(sc=sub)
    dxc.dxf_close_subscription(sub)
    assert actual_symbols == []


@pytest.mark.parametrize('sub_type', ValueStorage.event_types)
def test_default_event_handler(connection, sub_type):
    sub = dxc.dxf_create_subscription(cc=connection, event_type=sub_type)
    sub.set_event_handler(DefaultHandler())
    assert isinstance(sub.get_event_handler(), DefaultHandler)


def test_weakref():
    con = dxc.ConnectionClass()
    sub = dxc.SubscriptionClass()
    con.add_weakref(sub)
    assert con.get_weakrefs()[0] is sub


@pytest.mark.xfail
def test_weakref_fail_on_incorrect_type():
    con = dxc.ConnectionClass()
    obj = list()
    con.add_weakref(obj)


@pytest.mark.filterwarnings('ignore::Warning')
def test_double_event_handler_attachment(connection):
    handler1 = DefaultHandler()
    handler2 = DefaultHandler()
    sub = dxc.dxf_create_subscription(cc=connection, event_type='Trade')
    sub.set_event_handler(handler1)
    dxc.dxf_attach_listener(sub)
    symbols = ['AAPL', 'MSFT']
    dxc.dxf_add_symbols(sub, symbols)
    sub.set_event_handler(handler2)
    assert sub.get_event_handler() is handler2
    assert dxc.dxf_get_symbols(sub) == symbols
