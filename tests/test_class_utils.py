from dxfeed.wrappers import class_utils as cu
import pytest


def test_to_iterable_of_strings_with_string():
    symbol = 'AAPL'
    actual_symbol = cu.to_iterable_of_strings(symbol)
    assert actual_symbol == [symbol]


def test_to_iterable_of_strings_with_iterable():
    symbols = ('AAPL', 'MSFT')
    actual_symbols = cu.to_iterable_of_strings(symbols)
    assert actual_symbols == symbols


@pytest.mark.xfail
def test_to_iterable_of_strings_with_incorrect_type():
    cu.to_iterable_of_strings(123)
