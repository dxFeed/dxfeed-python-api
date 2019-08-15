from libc.stdio cimport printf
from lib.wrapper.utils.helpers cimport *



TRADE_COLUMNS = ['Symbol', 'Price', 'ExchangeCode', 'Size', 'Tick', 'Change', 'DayVolume', 'Time']
cdef void trade_default_listener(int event_type, dxf_const_string_t symbol_name,
			            const dxf_event_data_t* data, int data_count, void* user_data):

    cdef dxf_trade_t* trades = <dxf_trade_t*>data
    cdef dict py_data = <dict>user_data
    
    printf("{symbol=%s, ", symbol_name)
    for i in range(data_count):
        py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                trades[i].price,
                                trades[i].exchange_code,
                                trades[i].size,
                                trades[i].tick,
                                trades[i].change,
                                trades[i].day_volume,
                                trades[i].time
                                ]
                               )
        printf(", exchangeCode=%c, price=%f, size=%i, tick=%i, change=%f, day volume=%.0f}\n",
                trades[i].exchange_code, trades[i].price, trades[i].size, trades[i].tick, trades[i].change,
            trades[i].day_volume)

QUOTE_COLUMNS = [
    'Symbol', 'BidTime', 'BidExchangeCode', 'BidPrice', 'BidSize',
              'AskTime', 'AskExchangeCode', 'AskPrice', 'AskSize'
]
cdef void quote_default_listener(int event_type, dxf_const_string_t symbol_name,
			                     const dxf_event_data_t* data, int data_count, void* user_data):
    cdef dxf_quote_t* quotes = <dxf_quote_t*>data
    cdef dict py_data = <dict>user_data
    for i in range(data_count):
        py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                quotes[i].bid_time,
                                quotes[i].bid_exchange_code,
                                quotes[i].bid_price,
                                quotes[i].bid_size,
                                quotes[i].ask_time,
                                quotes[i].ask_exchange_code,
                                quotes[i].ask_price,
                                quotes[i].ask_size
                                ]
                               )
SUMMARY_COLUMNS = [
    'Symbol', 'day_id', 'day_high_price', 'day_low_price', 'day_close_price',
              'prev_day_id', 'prev_day_close_price', 'prev_day_volume', 'open_interest'
]
cdef void summary_default_listener(int event_type, dxf_const_string_t symbol_name,
			                     const dxf_event_data_t* data, int data_count, void* user_data):
    cdef dxf_summary_t* summary = <dxf_summary_t*>data
    cdef dict py_data = <dict>user_data
    for i in range(data_count):
        py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                summary[i].day_id,
                                summary[i].day_high_price,
                                summary[i].day_low_price,
                                summary[i].day_close_price,
                                summary[i].prev_day_id,
                                summary[i].prev_day_close_price,
                                summary[i].prev_day_volume,
                                summary[i].open_interest
                                ]
                               )
