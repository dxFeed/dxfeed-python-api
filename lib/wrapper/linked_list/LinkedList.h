#ifndef LINKEDLIST_H
#define LINKEDLIST_H


#include <stdio.h>
#include <stdlib.h>
#include "DXTypes.h"

typedef struct node1 {
	double price;
	double volume;
	dxf_const_string_t symbol;
	int data;
	struct node1 * next_cell;
} node1;

typedef struct {
    node1 * head;
    node1 * tail;
} linked_list_ext;








#endif

node1 * linked_list_init();