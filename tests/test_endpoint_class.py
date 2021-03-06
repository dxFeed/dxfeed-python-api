import dxfeed as dx
import pytest


class ValueStorage(object):  # config
    demo_address = 'demo.dxfeed.com:7300'


@pytest.fixture(scope='function')
def dxfeed():
    dxf = dx.Endpoint(connection_address=ValueStorage.demo_address)
    yield dxf
    dxf.close_connection()


def test_endpoint_no_arguments():
    dxf = dx.Endpoint()
    assert 'Connected' == dxf.connection_status


def test_connection_status_property(dxfeed):
    assert 'Connected' == dxfeed.connection_status


def test_create_endpoint_without_connection():
    dxf = dx.Endpoint(connect=False)
    assert 'Not connected' == dxf.connection_status


def test_address_property(dxfeed):
    assert dxfeed.address == ValueStorage.demo_address


def test_closing_connection(dxfeed):
    dxfeed.close_connection()
    assert 'Not connected' == dxfeed.connection_status


@pytest.mark.xfail()
def test_connection_fail_on_incorrect_address():
    dxfeed = dx.Endpoint(connection_address='8.8.8.8')
