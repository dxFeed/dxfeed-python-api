#ifndef LINKEDLIST_H
#define LINKEDLIST_H


#include <stdio.h>
#include <stdlib.h>
#include "DXTypes.h"

typedef struct linked_list {
	double price;
	double volume;
	dxf_const_string_t symbol;
	int data;
	struct linked_list * next_cell;
} linked_list;

typedef struct {
    linked_list * head;
    linked_list * tail;
} linked_list_ext;








#endif

linked_list * linked_list_init();