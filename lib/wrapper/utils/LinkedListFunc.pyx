from libc.stdlib cimport realloc, malloc, free
cimport lib.wrapper.utils.LinkedList as ll

cdef ll.linked_list_ext * linked_list_ext_init():
    init = <ll.linked_list_ext *>malloc(sizeof(ll.linked_list_ext))
    init.head = ll.linked_list_init()
    init.tail = init.head
    return init

