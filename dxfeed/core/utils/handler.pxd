

cdef class EventHandler:
    cdef list columns

    cdef void __update(self, event) nogil
