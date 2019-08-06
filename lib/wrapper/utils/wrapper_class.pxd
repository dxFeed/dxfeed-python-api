from lib.wrapper.linked_list.LinkedList cimport *
from lib.wrapper.linked_list.LinkedListFunc cimport *

# Wrapper over linked list
cdef class WrapperClass:
    """A wrapper class for a C/C++ data structure"""
    cdef linked_list_ext * _ptr
    cdef bint ptr_owner
    cdef node1 * curr
    cdef node1 * next_cell
    cdef node1 * init

    @staticmethod
    cdef WrapperClass from_ptr(linked_list_ext *_ptr, bint owner)
