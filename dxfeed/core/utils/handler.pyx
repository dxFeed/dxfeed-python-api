from warnings import warn

cdef class EventHandler:
    cdef void __update(self, event) nogil:
        with gil:
            self.update(event)

    def update(self, event):
        warn(Warning('You have not implemented update method in your EventHandler, that is called, when event comes!'))