//#ifndef LINKEDLIST_C
//#define LINKEDLIST_C

#include "LinkedList.h"


linked_list * linked_list_init() {
	linked_list * init = (linked_list *)malloc(sizeof(linked_list));
	init->data = 0;
	init->symbol = (dxf_const_string_t)malloc(100);
	init->next_cell = NULL;
	return init;
}


//#endif