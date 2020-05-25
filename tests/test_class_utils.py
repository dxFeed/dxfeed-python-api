from dxfeed.wrappers import class_utils as cu


def test_to_iterable_of_strings_with_string():
    symbol = 'AAPL'
    actual_symbol = cu.to_iterable_of_strings(symbol)
    assert actual_symbol == [symbol]
