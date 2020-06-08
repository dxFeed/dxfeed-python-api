import dxfeed.core.DXFeedPy as dxc
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
    exp_status = 'Connected'
    act_status = dxc.dxf_get_current_connection_status(connection)
    assert exp_status == act_status


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
