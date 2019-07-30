from lib.wrapper.pxd_include.DXTypes cimport dxf_const_string_t
from cpython.ref cimport PyObject

cdef extern from *:
    PyObject * PyUnicode_FromWideChar(dxf_const_string_t w, Py_ssize_t size)

cdef object unicode_from_dxf_const_string_t(dxf_const_string_t wcs)