from dxpyfeed.wrapper.utils.helpers cimport *

cdef class FuncWrapper:
    def __cinit__(self):
       self.func = NULL

    @staticmethod
    cdef FuncWrapper make_from_ptr(dxf_event_listener_t f):
        cdef FuncWrapper out = FuncWrapper()
        out.func = f
        return out

TRADE_COLUMNS = ['Symbol', 'Price', 'ExchangeCode', 'Size', 'Tick', 'Change', 'DayVolume', 'Time']
cdef void trade_default_listener(int event_type, dxf_const_string_t symbol_name,
			            const dxf_event_data_t* data, int data_count, void* user_data):

    cdef dxf_trade_t* trades = <dxf_trade_t*>data
    cdef dict py_data = <dict>user_data

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

QUOTE_COLUMNS = [
    'Symbol', 'BidTime', 'BidExchangeCode', 'BidPrice', 'BidSize',
              'AskTime', 'AskExchangeCode', 'AskPrice', 'AskSize', 'Scope'
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
                                quotes[i].ask_size,
                                <int>quotes[i].scope
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


PROFILE_COLUMNS = [
    'Symbol', 'Beta', 'EPS', 'DivFreq', 'exd_div_amount',
              'exd_div_date', '_52_high_price', '_52_low_price', 'shares',
              'description', 'raw_flags', 'status_reason'
]
cdef void profile_default_listener(int event_type, dxf_const_string_t symbol_name,
			                     const dxf_event_data_t* data, int data_count, void* user_data):
    cdef dxf_profile_t* p = <dxf_profile_t*>data
    cdef dict py_data = <dict>user_data
    for i in range(data_count):
        py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                p[i].beta,
                                p[i].eps,
                                p[i].div_freq,
                                p[i].exd_div_amount,
                                p[i].exd_div_date,
                                p[i]._52_high_price,
                                p[i]._52_low_price,
                                p[i].shares,
                                unicode_from_dxf_const_string_t(p[i].description),
                                p[i].raw_flags,
                                unicode_from_dxf_const_string_t(p[i].status_reason)
                                ]
                               )

TIME_AND_SALE_COLUMNS = [
    'Symbol', 'event_flags', 'index', 'time', 'exchange_code', 'price', 'size', 'bid_price', 'ask_price',
              'exchange_sale_conditions', 'raw_flags', 'buyer', 'seller', 'side', 'type', 'is_valid_tick',
              'is_eth_trade', 'trade_through_exempt', 'is_spread_leg',
]
cdef void time_and_sale_default_listener(int event_type, dxf_const_string_t symbol_name,
			                     const dxf_event_data_t* data, int data_count, void* user_data):
    cdef dxf_time_and_sale_t* tns = <dxf_time_and_sale_t*>data
    cdef dict py_data = <dict>user_data
    for i in range(data_count):
        py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                tns[i].event_flags,
                                tns[i].index,
                                tns[i].time,
                                tns[i].exchange_code,
                                tns[i].price,
                                tns[i].size,
                                tns[i].bid_price,
                                tns[i].ask_price,
                                unicode_from_dxf_const_string_t(tns[i].exchange_sale_conditions),
                                tns[i].raw_flags,
                                unicode_from_dxf_const_string_t(tns[i].buyer),
                                unicode_from_dxf_const_string_t(tns[i].seller),
                                tns[i].side,
                                tns[i].type,
                                tns[i].is_valid_tick,
                                tns[i].is_eth_trade,
                                tns[i].trade_through_exempt,
                                tns[i].is_spread_leg
                                ]
                               )

CANDLE_COLUMNS = [
    'Symbol', 'event_flags', 'index', 'time', 'sequence', 'count', 'open', 'high', 'low', 'close', 'volume',
              'vwap', 'bid_volume', 'ask_volume', 'open_interest', 'imp_volatility',
]
cdef void candle_default_listener(int event_type, dxf_const_string_t symbol_name,
			                     const dxf_event_data_t* data, int data_count, void* user_data):
    cdef dxf_candle_t* candle = <dxf_candle_t*>data
    cdef dict py_data = <dict>user_data
    for i in range(data_count):
        py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                candle[i].event_flags,
                                candle[i].index,
                                candle[i].time,
                                candle[i].sequence,
                                candle[i].count,
                                candle[i].open,
                                candle[i].high,
                                candle[i].low,
                                candle[i].close,
                                candle[i].volume,
                                candle[i].vwap,
                                candle[i].bid_volume,
                                candle[i].ask_volume,
                                candle[i].open_interest,
                                candle[i].imp_volatility
                                ]
                               )