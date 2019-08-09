# distutils: language = c++
cdef object unicode_from_dxf_const_string_t(dxf_const_string_t wcs):
    if wcs == NULL:
      return ''
    ret_val = <object>PyUnicode_FromWideChar(wcs, -1)
    return ret_val

cdef dxf_const_string_t dxf_const_string_t_from_unicode(object symbol):
    return PyUnicode_AsWideCharString(symbol, NULL)