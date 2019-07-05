#include "DXFeed.h"
#include "DXErrorCodes.h"
#include "Logger.h"
#include <stdio.h>
#include <time.h>
#include <Windows.h>

#include "LinkedList.h"


void add_elem(linked_list_ext * lle, double price, double volume) {
//    printf('\n');
    printf("Node number %f\n", price);
    linked_list * node = lle->tail;
	linked_list * next_cell = linked_list_init();
	node->next_cell = next_cell;
	node->price = price;
	node->data = 1;
	node->volume = volume;
    lle->tail = next_cell;
};

void print_list(linked_list_ext * lle) {

	linked_list * curr = lle->head;
	int i = 0;
	while (curr && curr->data == 1) {
		printf("Node number %o: %f, %f\n", i++, curr->price, curr->volume);
		curr = curr->next_cell;
	};
};

//double * pop(linked_list_ext * lle) {
//	double * res;
//	linked_list * head = lle->head;
//	if ((*head)->data) {
//		res = (double *)malloc(sizeof(double) * 2);
//		res[0] = (*head)->price;
//		res[1] = (*head)->volume;
//		linked_list * prev_head = *head;
//		*head = (*head)->next;
//		free(prev_head);
//	} else {
//		res = NULL;
//	}
//	return res;
//}

void delete_list(linked_list_ext * lle) {
    linked_list * curr = lle->head,
    			* next_cell = lle->head;
	printf("-----------1----------\n");
    while (curr) {
        next_cell = curr->next_cell;
        free(curr);
        curr = next_cell;
    }
    printf("-----------2----------\n");
    lle->head = linked_list_init();
    lle->tail = lle->head;
}

// https://stackoverflow.com/questions/40575432/send-data-from-c-parent-to-python-child-and-back-using-a-pipe








void listener(int event_type, dxf_const_string_t symbol_name,
			const dxf_event_data_t* data, int data_count, void* user_data) {
	dxf_int_t i = 0;

    //linked_list * head = (linked_list *) user_data;
    linked_list_ext * a = (linked_list_ext *) user_data;
	wprintf(L"%s{symbol=%s, ", dx_event_type_to_string(event_type), symbol_name);

    dxf_trade_t* trades = (dxf_trade_t*)data;
//    printf(L"written: %i", data_count);
    for (; i < data_count; ++i) {
        add_elem(a, trades[i].price, trades[i].size);
//        printf(L"written: %f", a->tail->price);

        wprintf(L", exchangeCode=%c, price=%f, size=%i, tick=%i, change=%f, day volume=%.0f, scope=%d}\n",
                trades[i].exchange_code, trades[i].price, trades[i].size, trades[i].tick, trades[i].change,
            trades[i].day_volume, (int)trades[i].scope);
        //print_list(head)
        //*user_data = (void *)&a;
    }
}