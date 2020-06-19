

cdef class EventHandler:
    cdef public list columns

    cdef void cython_internal_update_method(self, event) nogil

cdef class DefaultHandler(EventHandler):
    cdef object __data
