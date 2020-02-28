from warnings import warn
from dxfeed.core.pxd_include.DXErrorCodes cimport *
from dxfeed.core.pxd_include.DXFeed cimport *
from dxfeed.core.pxd_include.DXTypes cimport *
from pathlib import Path
import dxfeed

cdef object unicode_from_dxf_const_string_t(dxf_const_string_t wcs):
    """
    Cython function, callable from C to convert dxf_const_string_t(wchar_t) to unicode
    
    Parameters
    ----------
    wcs: dxf_const_string_t, wchar_t
        C string
        
    Returns
    -------
    unicode
        Python unicode string
    """
    if wcs == NULL:
      return ''
    ret_val = <object>PyUnicode_FromWideChar(wcs, -1)
    return ret_val

cdef dxf_const_string_t dxf_const_string_t_from_unicode(object symbol):
    """
    Cython function, callable from C that converts python unicode string to wchar_t. 
    
    Parameters
    ----------
    symbol: unicode
        Unicode string, usually ticker
    Returns
    -------
    wchar_t
        Wide Char
    """
    return PyUnicode_AsWideCharString(symbol, NULL)

def event_type_convert(event_type: str):
    """
    The function converts event type given as string to int, used in C dxfeed dxfeed

    Parameters
    ----------
    event_type: str
        Event type: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
                    'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' or ''
    Returns
    -------
    : int
        Integer that corresponds to event type in C dxfeed dxfeed
    """
    et_mapping = {
        'Trade': 1,
        'Quote': 2,
        'Summary': 4,
        'Profile': 8,
        'Order': 16,
        'TimeAndSale': 32,
        'Candle': 64,
        'TradeETH': 128,
        'SpreadOrder': 256,
        'Greeks': 512,
        'TheoPrice': 1024,
        'Underlying': 2048,
        'Series': 4096,
        'Configuration': 8192,
        '': -16384
    }
    try:
        return et_mapping[event_type]
    except KeyError:
        warn(f'No mapping for {event_type}, please choose one from {et_mapping.keys()}')
        return -16384

def get_include():
    """
    Function returns paths to header files of dxfeed-c-api library. Used for writing custom listeners

    Returns
    -------
    out_dir: list
        List of paths to header files
    """
    out_dir = list()
    out_dir.append(str(Path(dxfeed.__file__).resolve().parent.joinpath('dxfeed-c-api', 'include')))
    return out_dir