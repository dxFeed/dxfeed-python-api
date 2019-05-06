# cython: language_level=3

# https://stackoverflow.com/questions/19650195/cython-convert-unicode-string-to-wchar-array
from pxd_include.DXFeed cimport *

cdef dxf_connection_t connection
cdef dxf_subscription_t subscription

def pysubscribe():
    print('subscribing')
    dxf_create_subscription(connection, 1, &subscription)
    print('suscribed')

def py_add_symbol(symbols):
    c_symbols =
    dxf_add_symbol (dxf_subscription_t subscription, dxf_const_string_t c_symbols)

# typedef wchar_t            dxf_char_t;
# typedef const dxf_char_t*  dxf_const_string_t;
# static dxf_const_string_t g_symbols[] = { {L"IBM"}, {L"MSFT"}, {L"YHOO"}, {L"C"} };
# static wchar_t* g_symbols[] = { {L"IBM"}, {L"MSFT"}, {L"YHOO"}, {L"C"} };

cdef extern from "Python.h":
    dxf_const_string_t PyUnicode_AsWideCharString(object, Py_ssize_t *)

my_string = u"AAPL"
cdef Py_ssize_t length
cdef wchar_t *my_wchars = PyUnicode_AsWideCharString(my_string, &length)