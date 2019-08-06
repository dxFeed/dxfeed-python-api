//#ifndef LINKEDLIST_C
//#define LINKEDLIST_C

#include "LinkedList.h"


node1 * linked_list_init() {
	node1 * init = (node1 *)malloc(sizeof(node1));
	init->data = 0;
	init->symbol = (dxf_const_string_t)malloc(100);
	init->next_cell = NULL;
	return init;
}


//#endif