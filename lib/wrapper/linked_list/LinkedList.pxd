from lib.wrapper.pxd_include.DXTypes cimport dxf_const_string_t

cdef extern from "LinkedList.h":
    ctypedef struct linked_list

    ctypedef struct linked_list :
        double price
        double volume
        dxf_const_string_t symbol
        int data
        linked_list * next_cell

    ctypedef struct linked_list_ext:
        linked_list * head
        linked_list * tail

    linked_list * linked_list_init()