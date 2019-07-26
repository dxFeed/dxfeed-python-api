from lib.wrapper.utils.LinkedList cimport *
from lib.wrapper.utils.LinkedListFunc cimport *
from libc.stdlib cimport free

# Wrapper over linked list
cdef class WrapperClass:
    """A wrapper class for a C/C++ data structure"""

    def __cinit__(self):
        self.ptr_owner = False

    def __dealloc__(self):
        # De-allocate if not null and flag is set
        if self._ptr is not NULL and self.ptr_owner is True:
            free(self._ptr)
            self._ptr = NULL

    @property
    def price(self):
        return self._ptr.tail.price if (self._ptr is not NULL) and (self._ptr.tail is not NULL) else None

    @property
    def volume(self):
        return self._ptr.tail.volume if (self._ptr is not NULL) and (self._ptr.tail is not NULL) else None

    @staticmethod
    cdef WrapperClass from_ptr(linked_list_ext *_ptr, bint owner):
        """Factory function to create WrapperClass objects from
        given my_c_struct pointer.

        Setting ``owner`` flag to ``True`` causes
        the extension type to ``free`` the structure pointed to by ``_ptr``
        when the wrapper object is deallocated."""
        # Call to __new__ bypasses __init__ constructor
        cdef WrapperClass wrapper = WrapperClass.__new__(WrapperClass)
        wrapper._ptr = _ptr
        wrapper.ptr_owner = owner
        wrapper.curr = _ptr.tail
        return wrapper

    def add_elem(self, double price, double volume):
        curr = self._ptr.tail
        next_cell = linked_list_init()
        curr.next_cell = next_cell
        curr.price = price
        curr.volume = volume
        curr.data = 1
        self._ptr.tail = next_cell

    def delete_list(self):
        cur = self._ptr.head
        #nextt = self._ptr.head
        while cur is not NULL:
            nextt = cur.next_cell
            free(cur)
            cur = nextt
        self._ptr.head = linked_list_init()
        self._ptr.tail = self._ptr.head

    def print_list(self):
        cur = self._ptr.head
        while cur is not NULL:
            print(cur.price, cur.volume, cur.data)
            cur = cur.next_cell

    def pop(self):
        prev_head = self._ptr.head
        if prev_head.data == 1:
            result = [prev_head.price, prev_head.volume]
            self._ptr.head = prev_head.next_cell
            free(prev_head)
            return result
        else:
            return [None, None]