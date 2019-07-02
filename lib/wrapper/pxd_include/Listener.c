#include "DXFeed.h"
#include "DXErrorCodes.h"
#include "Logger.h"
#include <stdio.h>
#include <time.h>
#include <Windows.h>



#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct node {
	double price;
	double volume;
	bool data;
	struct node * next;
} linked_list;

linked_list * linked_list_init() {
	linked_list * init = (linked_list *)malloc(sizeof(linked_list));
	init->data = false;
	init->next = NULL;
	return init;
}

linked_list * add_elem(linked_list * node, double price, double volume) {
	linked_list * next = linked_list_init();
	node->next = next;
	node->price = price;
	node->data = true;
	node->volume = volume;
	next->next = NULL;
	return next;
};

void print_list(linked_list * head) {

	linked_list * curr = head;
	int i = 0;
	while (curr && curr->data) {
		printf("Node number %o: %f, %f\n", i++, curr->price, curr->volume);
		curr = curr->next;
	};
};

double * pop(linked_list ** head) {
	double * res;
	if ((*head)->data) {
		res = (double *)malloc(sizeof(double) * 2);
		res[0] = (*head)->price;
		res[1] = (*head)->volume;
		linked_list * prev_head = *head;
		*head = (*head)->next;
		free(prev_head);
	} else {
		res = NULL;
	}
	return res;
}

void delete_list(linked_list ** head) {
    linked_list * curr = * head,
    			* next = * head;
	printf("-----------1----------\n");
    while (curr) {
        next = curr->next;
        free(curr);
        curr = next;
    }
    printf("-----------2----------\n");
    *head = linked_list_init();
}

// https://stackoverflow.com/questions/40575432/send-data-from-c-parent-to-python-child-and-back-using-a-pipe








void listener(int event_type, dxf_const_string_t symbol_name,
			const dxf_event_data_t* data, int data_count, void* user_data) {
	dxf_int_t i = 0;

    linked_list * a = (linked_list *)user_data;
	wprintf(L"%s{symbol=%s, ", dx_event_type_to_string(event_type), symbol_name);

    dxf_trade_t* trades = (dxf_trade_t*)data;

    for (; i < data_count; ++i) {
          add_elem(a, trades[i].price, trades[i].size);
//			print_timestamp(trades[i].time);
//        a[0] = trades[i].exchange_code;
//        a[1] = trades[i].price;
//        a[2] = trades[i].size;
//        a[3] = trades[i].tick;
//        a[4] = trades[i].change;
//        a[5] = trades[i].day_volume;
//        a[6] = trades[i].scope;
        wprintf(L", exchangeCode=%c, price=%f, size=%i, tick=%i, change=%f, day volume=%.0f, scope=%d}\n",
                trades[i].exchange_code, trades[i].price, trades[i].size, trades[i].tick, trades[i].change,
            trades[i].day_volume, (int)trades[i].scope);
    }
}