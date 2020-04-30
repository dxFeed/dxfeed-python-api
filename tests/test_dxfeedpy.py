import dxfeed.core.DXFeedPy as dxс
import pytest


class ValueStorage(object):  # config
    demo_address = 'demo.dxfeed.com:7300'
    event_types = ['Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
                   'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration']


@pytest.fixture(scope='function')
def connection():
    # Setup
    con = dxс.dxf_create_connection(ValueStorage.demo_address)
    yield con  # pass var to test and test itself
    # Teardown
    dxс.dxf_close_connection(con)


def test_connection_status(connection):
    exp_status = 'Connected'
    act_status = dxс.dxf_get_current_connection_status(connection)
    assert exp_status == act_status


def test_connection_address(connection):
    exp_address = ValueStorage.demo_address
    act_address = dxс.dxf_get_current_connected_address(connection)
    assert exp_address == act_address


@pytest.mark.xfail()
def test_fail_connection_to_wrong_address():
    dxс.dxf_create_connection(address='8.8.8.8')


@pytest.mark.xfail()
def test_fail_create_subscription_with_no_connection():
    dxс.dxf_create_subscription()


@pytest.mark.xfail()
def test_fail_to_use_subscription_without_connection():
    connection = dxс.dxf_create_connection(ValueStorage.demo_address)
    sub = dxс.dxf_create_subscription(cc=connection, event_type='Trade')
    dxс.dxf_close_connection(connection)
    dxс.dxf_add_symbols(sc=sub, symbols=['AAPL'])


@pytest.mark.parametrize('sub_type', ValueStorage.event_types)
def test_subscription_on_correct_types(connection, sub_type):
    sub = dxс.dxf_create_subscription(cc=connection, event_type=sub_type)
    act_sub_type = dxс.dxf_get_subscription_event_types(sc=sub)
    dxс.dxf_close_subscription(sub)
    assert act_sub_type == sub_type


@pytest.mark.parametrize('sub_type', ValueStorage.event_types)
def test_subscription_timed_on_correct_types(connection, sub_type):
    sub = dxс.dxf_create_subscription_timed(cc=connection, event_type=sub_type, time=0)
    act_sub_type = dxс.dxf_get_subscription_event_types(sc=sub)
    dxс.dxf_close_subscription(sub)
    assert act_sub_type == sub_type


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_time_type(connection):
    dxс.dxf_create_subscription_timed(cc=connection, event_type='Trade', time=5.2)


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_time_value(connection):
    dxс.dxf_create_subscription_timed(cc=connection, event_type='Trade', time=-7)


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_type(connection):
    dxс.dxf_create_subscription(cc=connection, event_type='TradeQuote')


@pytest.mark.xfail()
def test_subscription_fail_on_incorrect_type(connection):
    dxс.dxf_create_subscription_timed(cc=connection, event_type='TradeQuote', time=0)



def test_symbol_addition(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxс.dxf_create_subscription(cc=connection, event_type='Trade')
    dxс.dxf_add_symbols(sc=sub, symbols=symbols)
    actual_symbols = dxс.dxf_get_symbols(sc=sub)
    dxс.dxf_close_subscription(sub)
    assert symbols == actual_symbols


def test_symbol_deletion(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxс.dxf_create_subscription(cc=connection, event_type='Trade')
    dxс.dxf_add_symbols(sc=sub, symbols=symbols)
    dxс.dxf_remove_symbols(sc=sub, symbols=['AAPL'])
    actual_symbols = dxс.dxf_get_symbols(sc=sub)
    dxс.dxf_close_subscription(sub)
    assert ['GOOG'] == actual_symbols


@pytest.mark.filterwarnings('ignore::UserWarning')
def test_wrong_symbol_types_ignored(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxс.dxf_create_subscription(cc=connection, event_type='Trade')
    dxс.dxf_add_symbols(sc=sub, symbols=symbols + [1, 5.0, [], True, {}, ()])
    actual_symbols = dxс.dxf_get_symbols(sc=sub)
    dxс.dxf_close_subscription(sub)
    assert symbols == actual_symbols


def test_symbol_clearing(connection):
    symbols = ['AAPL', 'GOOG']
    sub = dxс.dxf_create_subscription(cc=connection, event_type='Trade')
    dxс.dxf_add_symbols(sc=sub, symbols=symbols)
    dxс.dxf_clear_symbols(sc=sub)
    actual_symbols = dxс.dxf_get_symbols(sc=sub)
    dxс.dxf_close_subscription(sub)
    assert actual_symbols == []


@pytest.mark.parametrize('sub_type', ValueStorage.event_types)
def test_default_listeners(sub_type):
    # fixture usage causes errors with, probably, threads
    connection = dxс.dxf_create_connection(ValueStorage.demo_address)
    con_err_status = dxс.process_last_error(verbose=False)
    sub = dxс.dxf_create_subscription(connection, sub_type)
    sub_err_status = dxс.process_last_error(verbose=False)
    dxс.dxf_attach_listener(sub)
    add_lis_err_status = dxс.process_last_error(verbose=False)
    dxс.dxf_detach_listener(sub)
    drop_lis_err_status = dxс.process_last_error(verbose=False)
    dxс.dxf_close_subscription(sub)
    dxс.dxf_close_connection(connection)
    assert (con_err_status, sub_err_status, add_lis_err_status, drop_lis_err_status) == (0, 0, 0, 0)

