

cdef class EventHandler:
    cdef void __update(self, event) nogil:
        with gil:
            self.update(event)

    def update(self, event):
        print(f' Got {event} from __update')