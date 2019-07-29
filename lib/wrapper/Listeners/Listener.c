#include "DXFeed.h"
#include "DXErrorCodes.h"
#include "Logger.h"
#include <stdio.h>
#include <time.h>
#include <Windows.h>

#include "LinkedList.h"
// https://www.oreilly.com/library/view/c-in-a/0596006977/re264.html
#include <wchar.h>

void add_elem(linked_list_ext * lle, double price, double volume, dxf_const_string_t symbol) {
//    printf('\n');
    printf("Node number %f\n", price);
    linked_list * node = lle->tail;
	linked_list * next_cell = linked_list_init();
	node->next_cell = next_cell;
	node->price = price;

//
//	wcscpy_s(node->symbol,wcslen(symbol), symbol);
    wcscpy(node->symbol, symbol);
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
        add_elem(a, trades[i].price, trades[i].size, symbol_name);
//        printf(L"written: %f", a->tail->price);

        wprintf(L", exchangeCode=%c, price=%f, size=%i, tick=%i, change=%f, day volume=%.0f, scope=%d}\n",
                trades[i].exchange_code, trades[i].price, trades[i].size, trades[i].tick, trades[i].change,
            trades[i].day_volume, (int)trades[i].scope);
        //print_list(head)
        //*user_data = (void *)&a;
    }
}