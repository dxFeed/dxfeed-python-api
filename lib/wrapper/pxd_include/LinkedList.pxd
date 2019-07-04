
cdef extern from "LinkedList.c":
    ctypedef struct linked_list

    ctypedef struct linked_list :
        double price
        double volume
        int data
        linked_list * next_cell

    ctypedef struct linked_list_ext:
        linked_list * head
        linked_list * tail

    