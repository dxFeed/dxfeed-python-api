

cdef class EventHandler:
    cdef public list columns

    cdef void __update(self, event) nogil

cdef class DefaultHandler(EventHandler):
    cdef object __data
