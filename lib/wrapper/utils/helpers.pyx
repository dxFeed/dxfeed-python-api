from warnings import warn
from lib.wrapper.pxd_include.DXErrorCodes cimport *
from lib.wrapper.pxd_include.DXFeed cimport *
from lib.wrapper.pxd_include.DXTypes cimport *


cdef object unicode_from_dxf_const_string_t(dxf_const_string_t wcs):
    if wcs == NULL:
      return ''
    ret_val = <object>PyUnicode_FromWideChar(wcs, -1)
    return ret_val

cdef dxf_const_string_t dxf_const_string_t_from_unicode(object symbol):
    return PyUnicode_AsWideCharString(symbol, NULL)

def event_type_convert(event_type: str):
    """
    The function converts event type given as string to int, used in C dxfeed lib

    Parameters
    ----------
    event_type: str
        Event type: 'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'Time&Sale', 'Candle', 'TradeETH', 'SpreadOrder',
                    'Greeks', 'THEO_PRICE', 'Underlying', 'Series', 'Configuration' or ''
    Returns
    -------
    : int
        Integer that corresponds to event type in C dxfeed lib
    """
    et_mapping = {
        'Trade': 1,
        'Quote': 2,
        'Summary': 4,
        'Profile': 8,
        'Order': 16,
        'Time&Sale': 32,
        'Candle': 64,
        'TradeETH': 128,
        'SpreadOrder': 256,
        'Greeks': 512,
        'THEO_PRICE': 1024,
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

cdef void process_last_error():
    cdef int error_code = dx_ec_success
    cdef dxf_const_string_t error_descr = NULL
    cdef int res

    res = dxf_get_last_error(&error_code, &error_descr)

    if res == DXF_SUCCESS:
        if error_code == dx_ec_success:
            print("no error information is stored")

        print("Error occurred and successfully retrieved:\n",
              f"error code = {error_code}, description = {unicode_from_dxf_const_string_t(error_descr)}")
    print("An error occurred but the error subsystem failed to initialize\n")
