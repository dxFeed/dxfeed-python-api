# from cpython.ref cimport PyObject
#
# cdef extern from *:
#     PyObject * PyUnicode_FromWideChar(dxf_const_string_t w, Py_ssize_t size)

cdef object unicode_from_dxf_const_string_t(dxf_const_string_t wcs):
    if wcs == NULL:
      return ''
    ret_val = <object>PyUnicode_FromWideChar(wcs, -1)
    return ret_val