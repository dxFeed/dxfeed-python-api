from lib.wrapper.pxd_include.DXTypes cimport dxf_const_string_t

cdef extern from "LinkedList.h":
    ctypedef struct node1

    ctypedef struct node1 :
        double price
        double volume
        dxf_const_string_t symbol
        int data
        node1 * next_cell

    ctypedef struct linked_list_ext:
        node1 * head
        node1 * tail

    node1 * linked_list_init()