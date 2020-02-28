# something about license
 
#ifndef EVENT_DATA_H_INCLUDED
#define EVENT_DATA_H_INCLUDED

#pxd_include "RecordData.h"
from dxfeed.core.pxd_include.RecordData cimport *
#pxd_include "DXTypes.h"
from dxfeed.core.pxd_include.DXTypes cimport *
#ifndef OUT
    #define OUT
#endif /* OUT */

# /* -------------------------------------------------------------------------- */
# /*
#  *	Event type constants
#  */
# /* -------------------------------------------------------------------------- */
cdef extern from "EventData.h":
    enum dx_event_id_t:
        dx_eid_begin = 0,
        dx_eid_trade = dx_eid_begin,
        dx_eid_quote,
        dx_eid_summary,
        dx_eid_profile,
        dx_eid_order,
        dx_eid_time_and_sale,
        dx_eid_candle,
        dx_eid_trade_eth,
        dx_eid_spread_order,
        dx_eid_greeks,
        dx_eid_theo_price,
        dx_eid_underlying,
        dx_eid_series,
        dx_eid_configuration,

        # /* add new event id above this line */

        dx_eid_count,
        dx_eid_invalid


#define DXF_ET_TRADE         (1 << dx_eid_trade)
#define DXF_ET_QUOTE         (1 << dx_eid_quote)
#define DXF_ET_SUMMARY       (1 << dx_eid_summary)
#define DXF_ET_PROFILE       (1 << dx_eid_profile)
#define DXF_ET_ORDER         (1 << dx_eid_order)
#define DXF_ET_TIME_AND_SALE (1 << dx_eid_time_and_sale)
#define DXF_ET_CANDLE        (1 << dx_eid_candle)
#define DXF_ET_TRADE_ETH     (1 << dx_eid_trade_eth)
#define DXF_ET_SPREAD_ORDER  (1 << dx_eid_spread_order)
#define DXF_ET_GREEKS        (1 << dx_eid_greeks)
#define DXF_ET_THEO_PRICE    (1 << dx_eid_theo_price)
#define DXF_ET_UNDERLYING    (1 << dx_eid_underlying)
#define DXF_ET_SERIES        (1 << dx_eid_series)
#define DXF_ET_CONFIGURATION (1 << dx_eid_configuration)
#define DXF_ET_UNUSED        (~((1 << dx_eid_count) - 1))

#define DX_EVENT_BIT_MASK(event_id) (1 << event_id)

# // The length of record suffix including including the terminating null character
#define DXF_RECORD_SUFFIX_SIZE 5
DEF DXF_RECORD_SUFFIX_SIZE = 5
# /* -------------------------------------------------------------------------- */
# /*
# *	Source suffix array
# */
# /* -------------------------------------------------------------------------- */
cdef extern from "EventData.h":
    struct dx_suffix_t:
        dxf_char_t suffix[DXF_RECORD_SUFFIX_SIZE]


    struct dx_order_source_array_t:
        dx_suffix_t *elements,
        size_t size,
        size_t capacity


    ctypedef dx_order_source_array_t* dx_order_source_array_ptr_t

# /* -------------------------------------------------------------------------- */
# /*
#  *	Event data structures and support
#  */
# /* -------------------------------------------------------------------------- */

    ctypedef void* dxf_event_data_t

    ctypedef enum dxf_order_scope_t:
        dxf_osc_composite = 0,
        dxf_osc_regional = 1,
        dxf_osc_aggregate = 2,
        dxf_osc_order = 3


# /* Trade & Trade ETH -------------------------------------------------------- */

    ctypedef enum dxf_direction_t:
        dxf_dir_undefined = 0,
        dxf_dir_down = 1,
        dxf_dir_zero_down = 2,
        dxf_dir_zero = 3,
        dxf_dir_zero_up = 4,
        dxf_dir_up = 5


    ctypedef struct dxf_trade_t:
        dxf_long_t time,
        dxf_int_t sequence,
        dxf_int_t time_nanos,
        dxf_char_t exchange_code,
        dxf_double_t price,
        dxf_int_t size,
        # /* This field is absent in TradeETH */
        dxf_int_t tick,
        # /* This field is absent in TradeETH */
        dxf_double_t change,
        dxf_int_t raw_flags,
        dxf_double_t day_volume,
        dxf_double_t day_turnover,
        dxf_direction_t direction,
        dxf_bool_t is_eth,
        dxf_order_scope_t scope


# /* Quote -------------------------------------------------------------------- */

    ctypedef struct dxf_quote_t:
        dxf_long_t time,
        dxf_int_t sequence,
        dxf_int_t time_nanos,
        dxf_long_t bid_time,
        dxf_char_t bid_exchange_code,
        dxf_double_t bid_price,
        dxf_int_t bid_size,
        dxf_long_t ask_time,
        dxf_char_t ask_exchange_code,
        dxf_double_t ask_price,
        dxf_int_t ask_size,
        dxf_order_scope_t scope


# /* Summary ------------------------------------------------------------------ */

    ctypedef enum dxf_price_type_t:
        dxf_pt_regular = 0,
        dxf_pt_indicative = 1,
        dxf_pt_preliminary = 2,
        dxf_pt_final = 3


    ctypedef struct dxf_summary_t:
        dxf_dayid_t day_id,
        dxf_double_t day_open_price,
        dxf_double_t day_high_price,
        dxf_double_t day_low_price,
        dxf_double_t day_close_price,
        dxf_dayid_t prev_day_id,
        dxf_double_t prev_day_close_price,
        dxf_double_t prev_day_volume,
        dxf_int_t open_interest,
        dxf_int_t raw_flags,
        dxf_char_t exchange_code,
        dxf_price_type_t day_close_price_type,
        dxf_price_type_t prev_day_close_price_type


# /* Profile ------------------------------------------------------------------ */

    ctypedef enum dxf_trading_status_t:
      dxf_ts_undefined = 0,
      dxf_ts_halted = 1,
      dxf_ts_active = 2


    ctypedef enum dxf_short_sale_restriction_t:
      dxf_ssr_undefined = 0,
      dxf_ssr_active = 1,
      dxf_ssr_inactive = 2


    ctypedef struct dxf_profile_t:
        dxf_double_t beta,
        dxf_double_t eps,
        dxf_int_t div_freq,
        dxf_double_t exd_div_amount,
        dxf_dayid_t exd_div_date,
        dxf_double_t _52_high_price,
        dxf_double_t _52_low_price,
        dxf_double_t shares,
        dxf_double_t free_float,
        dxf_double_t high_limit_price,
        dxf_double_t low_limit_price,
        dxf_long_t halt_start_time,
        dxf_long_t halt_end_time,
        dxf_int_t raw_flags,
        dxf_const_string_t description,
        dxf_const_string_t status_reason,
        dxf_trading_status_t trading_status,
        dxf_short_sale_restriction_t ssr


# /* Order & Spread Order ----------------------------------------------------- */

    ctypedef enum dxf_order_side_t:
        dxf_osd_undefined = 0,
        dxf_osd_buy = 1,
        dxf_osd_sell = 2

    # union _inner_oso:
    #     dxf_const_string_t market_maker,
    #     dxf_const_string_t spread_symbol


    ctypedef struct dxf_order_t:
        dxf_event_flags_t event_flags,
        dxf_long_t index,
        dxf_long_t time,
        dxf_int_t time_nanos,
        dxf_int_t sequence,
        dxf_double_t price,
        dxf_int_t size,
        dxf_int_t count,
        dxf_order_scope_t scope,
        dxf_order_side_t side,
        dxf_char_t exchange_code,
        dxf_char_t source[DXF_RECORD_SUFFIX_SIZE],
        # _inner_oso # probably there should be some name (p58 of cython book)
        dxf_const_string_t market_maker,
        dxf_const_string_t spread_symbol

# /* Time And Sale ------------------------------------------------------------ */

    ctypedef enum dxf_tns_type_t:
        dxf_tnst_new = 0,
        dxf_tnst_correction = 1,
        dxf_tnst_cancel = 2


    ctypedef struct dxf_time_and_sale_t:
        dxf_event_flags_t event_flags,
        dxf_long_t index,
        dxf_long_t time,
        dxf_char_t exchange_code,
        dxf_double_t price,
        dxf_int_t size,
        dxf_double_t bid_price,
        dxf_double_t ask_price,
        dxf_const_string_t exchange_sale_conditions,
        dxf_int_t raw_flags,
        dxf_const_string_t buyer,
        dxf_const_string_t seller,
        dxf_order_side_t side,
        dxf_tns_type_t type,
        dxf_bool_t is_valid_tick,
        dxf_bool_t is_eth_trade,
        dxf_char_t trade_through_exempt,
        dxf_bool_t is_spread_leg


# /* Candle ------------------------------------------------------------------- */
    ctypedef struct dxf_candle_t:
        dxf_event_flags_t event_flags,
        dxf_long_t index,
        dxf_long_t time,
        dxf_int_t sequence,
        dxf_double_t count,
        dxf_double_t open,
        dxf_double_t high,
        dxf_double_t low,
        dxf_double_t close,
        dxf_double_t volume,
        dxf_double_t vwap,
        dxf_double_t bid_volume,
        dxf_double_t ask_volume,
        dxf_int_t open_interest,
        dxf_double_t imp_volatility


# /* Greeks ------------------------------------------------------------------- */
    ctypedef struct dxf_greeks_t:
        dxf_event_flags_t event_flags,
        dxf_long_t index,
        dxf_long_t time,
        dxf_double_t price,
        dxf_double_t volatility,
        dxf_double_t delta,
        dxf_double_t gamma,
        dxf_double_t theta,
        dxf_double_t rho,
        dxf_double_t vega

# /* TheoPrice ---------------------------------------------------------------- */
# /* Event and record are the same */
    ctypedef dx_theo_price_t dxf_theo_price_t

# /* Underlying --------------------------------------------------------------- */
# /* Event and record are the same */
    ctypedef dx_underlying_t dxf_underlying_t

# /* Series ------------------------------------------------------------------- */
    ctypedef struct dxf_series_t:
        dxf_event_flags_t event_flags,
        dxf_long_t index,
        dxf_long_t time,
        dxf_int_t sequence,
        dxf_dayid_t expiration,
        dxf_double_t volatility,
        dxf_double_t put_call_ratio,
        dxf_double_t forward_price,
        dxf_double_t dividend,
        dxf_double_t interest


    ctypedef struct dxf_configuration_t:
        dxf_int_t version,
        dxf_string_t object


# /* -------------------------------------------------------------------------- */
# /*
#  *	Event data constants
#  */
# /* -------------------------------------------------------------------------- */

    # ctypedef static dxf_const_string_t DXF_ORDER_COMPOSITE_BID_STR = L"COMPOSITE_BID"
    # ctypedef static dxf_const_string_t DXF_ORDER_COMPOSITE_ASK_STR = L"COMPOSITE_ASK"

    # cdef static dxf_const_string_t DXF_ORDER_COMPOSITE_BID_STR = "COMPOSITE_BID"
    # cdef static dxf_const_string_t DXF_ORDER_COMPOSITE_ASK_STR = "COMPOSITE_ASK"

    cdef dxf_const_string_t DXF_ORDER_COMPOSITE_BID_STR = "COMPOSITE_BID"
    cdef dxf_const_string_t DXF_ORDER_COMPOSITE_ASK_STR = "COMPOSITE_ASK"

# /* -------------------------------------------------------------------------- */
# /*
#  *	Event candle attributes
#  */
# /* -------------------------------------------------------------------------- */

#define DXF_CANDLE_EXCHANGE_CODE_COMPOSITE_ATTRIBUTE L'\0'
#define DXF_CANDLE_EXCHANGE_CODE_ATTRIBUTE_DEFAULT DXF_CANDLE_EXCHANGE_CODE_COMPOSITE_ATTRIBUTE
#define DXF_CANDLE_PERIOD_VALUE_ATTRIBUTE_DEFAULT 1.0

    ctypedef enum dxf_candle_price_attribute_t:
        dxf_cpa_last,
        dxf_cpa_bid,
        dxf_cpa_ask,
        dxf_cpa_mark,
        dxf_cpa_settlement,

        dxf_cpa_count,

        dxf_cpa_default = dxf_cpa_last


    ctypedef enum dxf_candle_session_attribute_t:
        dxf_csa_any,
        dxf_csa_regular,

        dxf_csa_count,

        dxf_csa_default = dxf_csa_any


    ctypedef enum dxf_candle_type_period_attribute_t:
        dxf_ctpa_tick,
        dxf_ctpa_second,
        dxf_ctpa_minute,
        dxf_ctpa_hour,
        dxf_ctpa_day,
        dxf_ctpa_week,
        dxf_ctpa_month,
        dxf_ctpa_optexp,
        dxf_ctpa_year,
        dxf_ctpa_volume,
        dxf_ctpa_price,
        dxf_ctpa_price_momentum,
        dxf_ctpa_price_renko,

        dxf_ctpa_count,

        dxf_ctpa_default = dxf_ctpa_tick


    ctypedef enum dxf_candle_alignment_attribute_t:
        dxf_caa_midnight,
        dxf_caa_session,

        dxf_caa_count,

        dxf_caa_default = dxf_caa_midnight


# /* -------------------------------------------------------------------------- */
# /*
#  *	Events flag constants
#  */
# /* -------------------------------------------------------------------------- */

    ctypedef enum dxf_event_flag:
        dxf_ef_tx_pending = 0x01,
        dxf_ef_remove_event = 0x02,
        dxf_ef_snapshot_begin = 0x04,
        dxf_ef_snapshot_end = 0x08,
        dxf_ef_snapshot_snip = 0x10,
        dxf_ef_remove_symbol = 0x20


# /* -------------------------------------------------------------------------- */
# /*
# *   Additional event params struct
# */
# /* -------------------------------------------------------------------------- */

    ctypedef dxf_ulong_t dxf_time_int_field_t

    ctypedef struct dxf_event_params_t:
        dxf_event_flags_t flags,
        dxf_time_int_field_t time_int_field,
        dxf_ulong_t snapshot_key


# /* -------------------------------------------------------------------------- */
# /*
#  *	Event listener prototype
#
#  *  event type here is a one-bit mask, not an integer
#  *  from dx_eid_begin to dx_eid_count
#  */
# /* -------------------------------------------------------------------------- */


    ctypedef void (*dxf_event_listener_t) (int event_type, dxf_const_string_t symbol_name,
                                          const dxf_event_data_t* data, int data_count,
                                          void* user_data)

    ctypedef void (*dxf_event_listener_v2_t) (int event_type, dxf_const_string_t symbol_name,
                                          const dxf_event_data_t* data, int data_count,
                                          const dxf_event_params_t* event_params, void* user_data)

# /* -------------------------------------------------------------------------- */
# /*
#  *	Various event functions
#  */
# /* -------------------------------------------------------------------------- */
cdef extern from "EventData.h":
    cdef dxf_const_string_t dx_event_type_to_string (int event_type)
    cdef int dx_get_event_data_struct_size (int event_id)
    cdef dx_event_id_t dx_get_event_id_by_bitmask (int event_bitmask)

# /* -------------------------------------------------------------------------- */
# /*
#  *	Event subscription stuff
#  */
# /* -------------------------------------------------------------------------- */

    enum dx_subscription_type_t:
        dx_st_begin = 0,

        dx_st_ticker = dx_st_begin,
        dx_st_stream,
        dx_st_history,

        # /* add new subscription types above this line */

        dx_st_count


    struct dx_event_subscription_param_t:
        dx_record_id_t record_id,
        dx_subscription_type_t subscription_type


    struct dx_event_subscription_param_list_t:
        dx_event_subscription_param_t* elements,
        size_t size,
        size_t capacity


# /*
#  * Returns the list of subscription params. Fills records list according to event_id.
#  *
#  * You need to call dx_free(params.elements) to free resources.
#  */
    cdef size_t dx_get_event_subscription_params(dxf_connection_t connection, dx_order_source_array_ptr_t order_source, dx_event_id_t event_id,
                                        dxf_uint_t subscr_flags, dx_event_subscription_param_list_t* params)

# /* -------------------------------------------------------------------------- */
# /*
# *  Snapshot data structs
# */
# /* -------------------------------------------------------------------------- */
    #Not sure if it will go
    struct dxf_snapshot_data_t:
        int event_type,
        dxf_string_t symbol,

        size_t records_count,
        const dxf_event_data_t* records

    ctypedef dxf_snapshot_data_t* dxf_snapshot_data_ptr_t

#
# /* -------------------------------------------------------------------------- */
# /*
# *  Snapshot listener prototype
#
# *  snapshot_data - pointer to the received snapshot data
# *  user_data     - pointer to user struct, use NULL by default
# */
# /* -------------------------------------------------------------------------- */
#
    ctypedef void(*dxf_snapshot_listener_t) (const dxf_snapshot_data_ptr_t snapshot_data, void* user_data)
#
# /* -------------------------------------------------------------------------- */
# /*
# *  Incremental Snapshot listener prototype
#
# *  snapshot_data - pointer to the received snapshot data
# *  new_snapshot  - flag, is this call with new snapshot or incremental update.
# *  user_data     - pointer to user struct, use NULL by default
# */
# /* -------------------------------------------------------------------------- */
# #define DXF_IS_CANDLE_REMOVAL(c) (((c)->event_flags & dxf_ef_remove_event) != 0)
# #define DXF_IS_ORDER_REMOVAL(o) ((((o)->event_flags & dxf_ef_remove_event) != 0) || ((o)->size == 0))
# #define DXF_IS_SPREAD_ORDER_REMOVAL(o) ((((o)->event_flags & dxf_ef_remove_event) != 0) || ((o)->size == 0))
# #define DXF_IS_TIME_AND_SALE_REMOVAL(t) (((t)->event_flags & dxf_ef_remove_event) != 0)
# #define DXF_IS_GREEKS_REMOVAL(g) (((g)->event_flags & dxf_ef_remove_event) != 0)
# #define DXF_IS_SERIES_REMOVAL(s) (((s)->event_flags & dxf_ef_remove_event) != 0)
    ctypedef void(*dxf_snapshot_inc_listener_t) (const dxf_snapshot_data_ptr_t snapshot_data, int new_snapshot, void* user_data)
#
# /* -------------------------------------------------------------------------- */
# /*
# *  Price Level data structs
# */
# /* -------------------------------------------------------------------------- */
    struct dxf_price_level_element_t:
        dxf_double_t price
        dxf_long_t size
        dxf_long_t time



    struct dxf_price_level_book_data_t:
        dxf_const_string_t symbol

        size_t bids_count
        const dxf_price_level_element_t *bids

        size_t asks_count
        const dxf_price_level_element_t *asks

    ctypedef dxf_price_level_book_data_t* dxf_price_level_book_data_ptr_t

# /* -------------------------------------------------------------------------- */
# /*
# *  Price Level listener prototype
#
# *  book          - pointer to the received price book data.
# *                  bids and asks are sorted by price,
# *                  best bid (with largest price) and best ask
# *                  (with smallest price) are first elements
# *                  of corresponding arrays.
# *  user_data     - pointer to user struct, use NULL by default
# */
# /* -------------------------------------------------------------------------- */
#
    ctypedef void(*dxf_price_level_book_listener_t) (const dxf_price_level_book_data_ptr_t book, void* user_data)
#
# /* -------------------------------------------------------------------------- */
# /*
# *  Price Level listener prototype
#
# *  quote         - pointer to the received regional quote
# *  user_data     - pointer to user struct, use NULL by default
# */
# /* -------------------------------------------------------------------------- */
#
    ctypedef void(*dxf_regional_quote_listener_t) (dxf_const_string_t symbol, const dxf_quote_t* quotes, int count, void* user_data)
#
# /* -------------------------------------------------------------------------- */
# /*
#  *	Event data navigation functions
#  */
# /* -------------------------------------------------------------------------- */
#
# #ifdef __cplusplus
#     extern "C"
# #endif
# const dxf_event_data_t dx_get_event_data_item (int event_mask, const dxf_event_data_t data, size_t index)
#
# #endif /* EVENT_DATA_H_INCLUDED */