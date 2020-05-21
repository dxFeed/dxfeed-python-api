import dxfeed as dx
import pytest


class ValueStorage(object):  # config
    demo_address = 'demo.dxfeed.com:7300'


@pytest.fixture(scope='function')
def dxfeed():
    dxf = dx.Endpoint(connection_address=ValueStorage.demo_address)
    yield dxf
    dxf.close_connection()


def test_connection_status_property(dxfeed):
    expected_status = 'Connected'
    assert expected_status == dxfeed.connection_status


def test_address_property(dxfeed):
    assert dxfeed.address == ValueStorage.demo_address


def test_closing_connection(dxfeed):
    dxfeed.close_connection()
    expected_status = 'Not connected'
    assert expected_status == dxfeed.connection_status


@pytest.mark.xfail()
def test_connection_fail_on_incorrect_address():
    dxfeed = dx.Endpoint(connection_address='8.8.8.8')
