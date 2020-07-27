from dxfeed.wrappers import class_utils as cu
import pytest
from datetime import datetime


class ValueStorage(object):
    dt_formats = ['%Y-%m-%d %H:%M:%S.%f', '%Y-%m-%d %H:%M:%S', '%Y/%m/%d %H:%M:%S']
    base_format = '%Y-%m-%d %H:%M:%S.%f'
    dt = datetime(2007, 12, 6, 16, 29, 43, 79043)


def test_to_iterable_of_strings_with_string():
    symbol = 'AAPL'
    actual_symbol = cu.to_iterable(symbol)
    assert actual_symbol == [symbol]


def test_to_iterable_of_strings_with_iterable():
    symbols = ('AAPL', 'MSFT')
    actual_symbols = cu.to_iterable(symbols)
    assert actual_symbols == symbols


@pytest.mark.xfail
def test_to_iterable_of_strings_with_incorrect_type():
    cu.to_iterable(123)


@pytest.mark.parametrize('dt_fmt', ValueStorage.dt_formats)
def test_handle_datetime_from_datetime(dt_fmt):
    date_time = datetime.now()
    actual_datetime = cu.handle_datetime(date_time, fmt=dt_fmt)
    assert date_time == actual_datetime


@pytest.mark.parametrize('dt_fmt', ValueStorage.dt_formats)
def test_handle_datetime_with_complete_string_format(dt_fmt):
    date_time = ValueStorage.dt.strftime(format=dt_fmt)
    expected_date_time = datetime.strptime(date_time, dt_fmt)
    actual_datetime = cu.handle_datetime(expected_date_time, fmt=dt_fmt)
    assert expected_date_time == actual_datetime


@pytest.mark.filterwarnings('ignore::Warning')
@pytest.mark.parametrize('dt_fmt', ValueStorage.dt_formats)
def test_handle_datetime_with_no_seconds_string_format(dt_fmt):
    fmt = dt_fmt[:dt_fmt.rfind('%S')-1]
    date_time = ValueStorage.dt.strftime(fmt)
    actual_datetime = cu.handle_datetime(date_time, fmt=dt_fmt)
    expected_datetime = ValueStorage.dt.replace(second=0, microsecond=0)
    assert actual_datetime == expected_datetime


@pytest.mark.filterwarnings('ignore::Warning')
@pytest.mark.parametrize('dt_fmt', ValueStorage.dt_formats)
def test_handle_datetime_with_no_mins_string_format(dt_fmt):
    fmt = dt_fmt[:dt_fmt.rfind('%M')-1]
    date_time = ValueStorage.dt.strftime(fmt)
    actual_datetime = cu.handle_datetime(date_time, fmt=dt_fmt)
    expected_datetime = ValueStorage.dt.replace(minute=0, second=0, microsecond=0)
    assert actual_datetime == expected_datetime


@pytest.mark.filterwarnings('ignore::Warning')
@pytest.mark.parametrize('dt_fmt', ValueStorage.dt_formats)
def test_handle_datetime_with_no_hours_string_format(dt_fmt):
    fmt = dt_fmt[:dt_fmt.rfind('%H')-1]
    date_time = ValueStorage.dt.strftime(fmt)
    actual_datetime = cu.handle_datetime(date_time, fmt=dt_fmt)
    expected_datetime = ValueStorage.dt.replace(hour=0, minute=0, second=0, microsecond=0)
    assert actual_datetime == expected_datetime


@pytest.mark.xfail
def test_handle_datetime_wrong_type():
    cu.handle_datetime(20201010)
