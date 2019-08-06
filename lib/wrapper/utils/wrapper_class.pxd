from lib.wrapper.linked_list.LinkedList cimport *
from lib.wrapper.linked_list.LinkedListFunc cimport *

# Wrapper over linked list
cdef class WrapperClass:
    """A wrapper class for a C/C++ data structure"""
    cdef linked_list_ext * _ptr
    cdef bint ptr_owner
    cdef linked_list * curr
    cdef linked_list * next_cell
    cdef linked_list * init

    @staticmethod
    cdef WrapperClass from_ptr(linked_list_ext *_ptr, bint owner)
