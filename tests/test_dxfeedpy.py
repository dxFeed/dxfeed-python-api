import dxfeed as dx
import pytest


class ValueStorage(object):  # config
    demo_address = 'demo.dxfeed.com:7300'
    subscription_types = ['Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH',
                          'SpreadOrder', 'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration']


@pytest.fixture
def connection():
    # Setup
    con = dx.dxf_create_connection(ValueStorage.demo_address)
    yield con  # pass var to test and test itself
    # Teardown
    dx.dxf_close_connection(con)


def test_connection_status(connection):
    exp_status = 'Connected'
    act_status = dx.dxf_get_current_connection_status(connection)
    assert exp_status == act_status


def test_connection_address(connection):
    exp_address = ValueStorage.demo_address
    act_address = dx.dxf_get_current_connected_address(connection)
    assert exp_address == act_address


@pytest.mark.xfail()
def test_fail_create_subscription_with_no_connection():
    dx.dxf_create_subscription()


def test_subscription_on_correct_types(connection):

    actual_types = list()
    for sub_type in ValueStorage.subscription_types:
        sub = dx.dxf_create_subscription(cc=connection, event_type=sub_type)
        actual_types.append(dx.dxf_get_subscription_event_types(sc=sub))
        dx.dxf_close_subscription(sub)
    assert ValueStorage.subscription_types == actual_types


def test_symbol_addition(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dx.dxf_create_subscription(cc=connection, event_type='Trade')
    dx.dxf_add_symbols(sc=sub, symbols=symbols)
    actual_symbols = dx.dxf_get_symbols(sc=sub)
    dx.dxf_close_subscription(sub)
    assert symbols == actual_symbols


def test_symbol_deletion(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dx.dxf_create_subscription(cc=connection, event_type='Trade')
    dx.dxf_add_symbols(sc=sub, symbols=symbols)
    dx.dxf_remove_symbols(sc=sub, symbols=['AAPL'])
    actual_symbols = dx.dxf_get_symbols(sc=sub)
    dx.dxf_close_subscription(sub)
    assert ['GOOG'] == actual_symbols
