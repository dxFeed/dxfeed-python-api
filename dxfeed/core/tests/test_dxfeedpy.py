import nose
from nose.tools import assert_equal, assert_true, assert_false, raises
import dxfeed as dx


class TestConnection(object):
    @classmethod
    def setup_class(cls):
        cls._symbols = ['GOOGL', 'AAPL']
        cls._address = 'demo.dxfeed.com:7300'

    def test_suceccful_conection_to_demo(self):
        con = dx.dxf_create_connection(cls._address)