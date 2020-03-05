import dxfeed as dx
import pytest


demo_address = 'demo.dxfeed.com:7300'
symbols = ['AAPL', 'C']

def test_connection():
    con = dx.dxf_create_connection(demo_address)
    exp_status = 'Connected'
    act_status = dx.dxf_get_current_connection_status(con)
    assert exp_status == act_status

@pytest.mark.xfail()
def test_fail_create_subscription_with_no_connection():
    dx.dxf_create_subscription()