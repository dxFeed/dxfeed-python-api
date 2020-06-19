from typing import Union, Iterable
import collections
from warnings import warn
from datetime import datetime
import pandas as pd


def to_iterable(value: Union[str, Iterable[str]]) -> Iterable[str]:
    """
    Function to correctly wrap string into iterable object

    Parameters
    ----------
    value: str, iterable
        String or iterable object

    Returns
    -------
    : iterable
    """
    if isinstance(value, str):
        value = [value]
    if not isinstance(value, collections.abc.Iterable):
        raise TypeError(f'Expected string or iterable type, got {type(value)}')
    return value


def handle_datetime(date_time: Union[str, datetime], fmt: str = '%Y-%m-%d %H:%M:%S.%f', exact_format: bool = True):
    """
    Function to convert string of date and time to datetime object.

    Parameters
    ----------
    date_time: str, datetime.datetime
        Datetime to convert
    fmt: str
        Format of expected datetime
    exact_format: bool
        If False no warning will be thrown in case of incomplete date_time parameter. Default - True

    Returns
    -------
    date_time: datetime.datetime
        date_time argument converted to datetime.datetime object.
    """
    if isinstance(date_time, str):
        try:
            date_time = datetime.strptime(date_time, fmt)
        except ValueError:
            try:
                date_time = pd.to_datetime(date_time, format=fmt, infer_datetime_format=True)
                if exact_format:
                    warn(Warning(f'Datetime argument does not exactly match {fmt} format,' +
                                 ' date was parsed automatically as ' +
                                 date_time.strftime(format=fmt)))
            except ValueError:
                raise ValueError(f'Datetime should use {fmt} format!')
    if not isinstance(date_time, datetime):
        raise TypeError(f'Datetime has incorrect type of {type(date_time)}, should be string or datetime')
    return date_time
