from dxfeed.core.utils.helpers cimport *
from dxfeed.core.utils.handler cimport EventHandler


cdef class FuncWrapper:
    def __cinit__(self):
        self.func = NULL

    @staticmethod
    cdef FuncWrapper make_from_ptr(dxf_event_listener_t f):
        cdef FuncWrapper out = FuncWrapper()
        out.func = f
        return out


TRADE_COLUMNS = ['Symbol', 'Sequence', 'Price', 'ExchangeCode', 'Size', 'Tick', 'Change', 'DayVolume',
                 'DayTurnover', 'Direction', 'Time', 'Nanos', 'RawFlags', 'IsETH', 'Scope']
cdef void trade_default_listener(int event_type,
                                 dxf_const_string_t symbol_name,
                                 const dxf_event_data_t*data,
                                 int data_count, void*user_data) nogil:
    cdef dxf_trade_t* trades = <dxf_trade_t*> data
    with gil:
        py_data = <EventHandler> user_data

        for i in range(data_count):

            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              trades[i].sequence,
                              trades[i].price,
                              unicode_from_dxf_const_string_t(&trades[i].exchange_code),
                              trades[i].size,
                              trades[i].tick,
                              trades[i].change,
                              trades[i].day_volume,
                              trades[i].day_turnover,
                              trades[i].direction,
                              trades[i].time,
                              trades[i].time_nanos,
                              trades[i].raw_flags,
                              trades[i].is_eth,
                              trades[i].scope])

QUOTE_COLUMNS = ['Symbol', 'Sequence', 'Time', 'Nanos', 'BidTime', 'BidExchangeCode', 'BidPrice', 'BidSize', 'AskTime',
                 'AskExchangeCode', 'AskPrice', 'AskSize', 'Scope']
cdef void quote_default_listener(int event_type,
                                 dxf_const_string_t symbol_name,
                                 const dxf_event_data_t*data,
                                 int data_count,
                                 void*user_data) nogil:
    cdef dxf_quote_t*quotes = <dxf_quote_t*> data
    with gil:
        py_data = <EventHandler> user_data

        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              quotes[i].sequence,
                              quotes[i].time,
                              quotes[i].time_nanos,
                              quotes[i].bid_time,
                              unicode_from_dxf_const_string_t(&quotes[i].bid_exchange_code),
                              quotes[i].bid_price,
                              quotes[i].bid_size,
                              quotes[i].ask_time,
                              unicode_from_dxf_const_string_t(&quotes[i].ask_exchange_code),
                              quotes[i].ask_price,
                              quotes[i].ask_size,
                              <int> quotes[i].scope])

SUMMARY_COLUMNS = ['Symbol', 'DayId', 'DayOpenPrice', 'DayHighPrice', 'DayLowPrice', 'DayClosePrice', 'PrevDayId',
                   'PrevDayClosePrice', 'PrevDayVolume', 'OpenInterest', 'RawFlags', 'ExchangeCode',
                   'DayClosePriceType', 'PrevDayClosePriceType', 'Scope']
cdef void summary_default_listener(int event_type, dxf_const_string_t symbol_name,
                                   const dxf_event_data_t*data, int data_count, void*user_data) nogil:
    cdef dxf_summary_t*summary = <dxf_summary_t*> data

    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              summary[i].day_id,
                              summary[i].day_open_price,
                              summary[i].day_high_price,
                              summary[i].day_low_price,
                              summary[i].day_close_price,
                              summary[i].prev_day_id,
                              summary[i].prev_day_close_price,
                              summary[i].prev_day_volume,
                              summary[i].open_interest,
                              summary[i].raw_flags,
                              unicode_from_dxf_const_string_t(&summary[i].exchange_code),
                              summary[i].day_close_price_type,
                              summary[i].prev_day_close_price_type,
                              summary[i].scope])

PROFILE_COLUMNS = ['Symbol', 'Beta', 'EPS', 'DivFreq', 'ExdDivAmount', 'ExdDivDate', '52HighPrice', '52LowPrice',
                   'Shares', 'FreeFloat', 'HighLimitPrice', 'LowLimitPrice', 'HaltStartTime', 'HaltEndTime',
                   'Description', 'RawFlags', 'StatusReason', 'TradingStatus', 'ShortSaleRestriction']
cdef void profile_default_listener(int event_type,
                                   dxf_const_string_t symbol_name,
                                   const dxf_event_data_t*data,
                                   int data_count,
                                   void*user_data)  nogil:
    cdef dxf_profile_t*p = <dxf_profile_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              p[i].beta,
                              p[i].eps,
                              p[i].div_freq,
                              p[i].exd_div_amount,
                              p[i].exd_div_date,
                              p[i]._52_high_price,
                              p[i]._52_low_price,
                              p[i].shares,
                              p[i].free_float,
                              p[i].high_limit_price,
                              p[i].low_limit_price,
                              p[i].halt_start_time,
                              p[i].halt_end_time,
                              unicode_from_dxf_const_string_t(p[i].description),
                              p[i].raw_flags,
                              unicode_from_dxf_const_string_t(p[i].status_reason),
                              p[i].trading_status,
                              p[i].ssr])

TIME_AND_SALE_COLUMNS = ['Symbol', 'EventFlags', 'Index', 'Time', 'ExchangeCode', 'Price', 'Size', 'BidPrice',
                         'AskPrice', 'ExchangeSaleConditions', 'RawFlags', 'Buyer', 'Seller', 'Side', 'Type',
                         'IsValidTick', 'IsEthTrade', 'TradeThroughExempt', 'IsSpreadLeg', 'Scope']
cdef void time_and_sale_default_listener(int event_type,
                                         dxf_const_string_t symbol_name,
                                         const dxf_event_data_t*data,
                                         int data_count,
                                         void*user_data) nogil:
    cdef dxf_time_and_sale_t*tns = <dxf_time_and_sale_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              tns[i].event_flags,
                              tns[i].index,
                              tns[i].time,
                              unicode_from_dxf_const_string_t(&tns[i].exchange_code),
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
                              tns[i].is_spread_leg,
                              tns[i].scope])

CANDLE_COLUMNS = ['Symbol', 'EventFlags', 'Index', 'Time', 'Sequence', 'Count', 'Open', 'High', 'Low', 'Close', 'Volume', 'VWap',
                  'BidVolume', 'AskVolume', 'OpenInterest', 'ImpVolatility']
cdef void candle_default_listener(int event_type,
                                  dxf_const_string_t symbol_name,
                                  const dxf_event_data_t*data,
                                  int data_count,
                                  void*user_data) nogil:
    cdef dxf_candle_t*candle = <dxf_candle_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
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
                              candle[i].imp_volatility])

ORDER_COLUMNS = ['Symbol', 'EventFlags', 'Index', 'Time', 'Nanos', 'Sequence', 'Price', 'Size', 'Count', 'Scope',
                 'Side', 'ExchangeCode', 'MarketMaker', 'SpreadSymbol']
cdef void order_default_listener(int event_type,
                                 dxf_const_string_t symbol_name,
                                 const dxf_event_data_t*data,
                                 int data_count,
                                 void*user_data) nogil:
    cdef dxf_order_t*order = <dxf_order_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              order[i].event_flags,
                              order[i].index,
                              order[i].time,
                              order[i].time_nanos,
                              order[i].sequence,
                              order[i].price,
                              order[i].size,
                              order[i].count,
                              order[i].scope,
                              order[i].side,
                              unicode_from_dxf_const_string_t(&order[i].exchange_code),
                              unicode_from_dxf_const_string_t(order[i].market_maker),
                              unicode_from_dxf_const_string_t(order[i].spread_symbol)])

GREEKS_COLUMNS = ['Symbol', 'EventFlags', 'Index', 'Time', 'Price', 'Volatility', 'Delta', 'Gamma', 'Theta', 'Rho',
                  'Vega']
cdef void greeks_default_listener(int event_type,
                                  dxf_const_string_t symbol_name,
                                  const dxf_event_data_t*data,
                                  int data_count,
                                  void*user_data) nogil:
    cdef dxf_greeks_t*greeks = <dxf_greeks_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              greeks[i].event_flags,
                              greeks[i].index,
                              greeks[i].time,
                              greeks[i].price,
                              greeks[i].volatility,
                              greeks[i].delta,
                              greeks[i].gamma,
                              greeks[i].theta,
                              greeks[i].rho,
                              greeks[i].vega])

THEO_PRICE_COLUMNS = ['Symbol', 'Time', 'Price', 'UnderlyingPrice', 'Delta', 'Gamma', 'Dividend', 'Interest']
cdef void theo_price_default_listener(int event_type,
                                      dxf_const_string_t symbol_name,
                                      const dxf_event_data_t*data,
                                      int data_count,
                                      void*user_data) nogil:
    cdef dxf_theo_price_t*theo_price = <dxf_theo_price_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              theo_price[i].time,
                              theo_price[i].price,
                              theo_price[i].underlying_price,
                              theo_price[i].delta,
                              theo_price[i].gamma,
                              theo_price[i].dividend,
                              theo_price[i].interest])

UNDERLYING_COLUMNS = ['Symbol', 'Volatility', 'FrontVolatility', 'BackVolatility', 'PutCallRatio']
cdef void underlying_default_listener(int event_type,
                                      dxf_const_string_t symbol_name,
                                      const dxf_event_data_t*data,
                                      int data_count,
                                      void*user_data) nogil:
    cdef dxf_underlying_t*underlying = <dxf_underlying_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              underlying[i].volatility,
                              underlying[i].front_volatility,
                              underlying[i].back_volatility,
                              underlying[i].put_call_ratio])

SERIES_COLUMNS = ['Symbol', 'EventFlags', 'Index', 'Time', 'Sequence', 'Sequence', 'Expiration', 'Volatility',
                  'PutCallRatio', 'ForwardPrice', 'Dividend', 'Interest']
cdef void series_default_listener(int event_type,
                                  dxf_const_string_t symbol_name,
                                  const dxf_event_data_t*data,
                                  int data_count,
                                  void*user_data) nogil:
    cdef dxf_series_t*series = <dxf_series_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              series[i].event_flags,
                              series[i].index,
                              series[i].time,
                              series[i].sequence,
                              series[i].sequence,
                              series[i].expiration,
                              series[i].volatility,
                              series[i].put_call_ratio,
                              series[i].forward_price,
                              series[i].dividend,
                              series[i].interest])

CONFIGURATION_COLUMNS = ['Symbol', 'Version', 'Object']
cdef void configuration_default_listener(int event_type,
                                         dxf_const_string_t symbol_name,
                                         const dxf_event_data_t*data,
                                         int data_count,
                                         void*user_data) nogil:
    cdef dxf_configuration_t*config = <dxf_configuration_t*> data
    with gil:
        py_data = <EventHandler> user_data
        for i in range(data_count):
            py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                              config[i].version,
                              unicode_from_dxf_const_string_t(config[i].object)])
