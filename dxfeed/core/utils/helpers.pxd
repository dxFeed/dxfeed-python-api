from dxfeed.core.pxd_include.DXTypes cimport dxf_const_string_t
from cpython.ref cimport PyObject

cdef extern from *:
    PyObject * PyUnicode_FromWideChar(dxf_const_string_t w, Py_ssize_t size)
    dxf_const_string_t PyUnicode_AsWideCharString(object, Py_ssize_t *)

cdef object unicode_from_dxf_const_string_t(dxf_const_string_t wcs)

cdef dxf_const_string_t dxf_const_string_t_from_unicode(object symbol)