import dxfeed as dx
import pytest


@pytest.fixture()
def connection():
    # Setup
    con = dx.dxf_create_connection('demo.dxfeed.com:7300')
    yield con  # Test here
    # Teardown
    dx.dxf_close_connection(con)


def test_connection(connection):
    exp_status = 'Connected'
    act_status = dx.dxf_get_current_connection_status(connection)
    assert exp_status == act_status


def test_connection_address(connection):
    exp_address = 'demo.dxfeed.com:7300'
    act_address = dx.dxf_get_current_connected_address(connection)
    assert exp_address == act_address


@pytest.mark.xfail()
def test_fail_create_subscription_with_no_connection():
    dx.dxf_create_subscription()

# with pytest.raises(TypeError):
#     pass