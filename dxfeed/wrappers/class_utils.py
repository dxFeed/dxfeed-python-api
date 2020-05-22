from typing import Union, Iterable
import collections


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
