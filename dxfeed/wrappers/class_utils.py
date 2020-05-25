from typing import Union, Iterable
import collections
from warnings import warn
from datetime import datetime


def to_iterable_of_strings(value: Union[str, Iterable[str]]) -> Iterable[str]:
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
        return [value]

    if isinstance(value, collections.abc.Iterable):
        return value
    else:
        raise TypeError(f'Expected string or iterable type, got {type(value)}')


def handle_datetime(date_time: Union[str, datetime], fmt: str = '%Y-%m-%d %H:%M:%S.%f'):
    if isinstance(date_time, str):
        try:
            date_time = datetime.strptime(date_time, fmt)
        except ValueError:
            try:
                date_time = pd.to_datetime(date_time, format=fmt, infer_datetime_format=True)
                warn_message = f'datetime argument does not exactly match {fmt} format,' + \
                               ' date was parsed automatically as ' + \
                               date_time.strftime(format=fmt)
                warn(warn_message)
            except ValueError:
                raise ValueError(f'datetime should use {fmt} format!')
    return date_time
