#ifndef EVENT_DATA_H_INCLUDED
#define EVENT_DATA_H_INCLUDED

from dxfeed.core.pxd_include cimport RecordData as rd
from dxfeed.core.pxd_include cimport DXTypes as dxt
#ifndef OUT
    #define OUT
#endif /* OUT */

cdef extern from "<EventData.h>":
    enum dxf_order_action_t:
        dxf_oa_undefined = 0,
        dxf_oa_new = 1,
        dxf_oa_replace = 2,
        dxf_oa_modify = 3,
        dxf_oa_delete = 4,
        dxf_oa_partial = 5,
        dxf_oa_execute = 6,
        dxf_oa_trade = 7,
        dxf_oa_bust = 8,
        dxf_oa_last = dxf_oa_bust


# /* -------------------------------------------------------------------------- */
# /*
#  *	Event type constants
#  */
# /* -------------------------------------------------------------------------- */
cdef extern from "<EventData.h>":
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
cdef extern from "<EventData.h>":
    cdef int DXF_RECORD_SUFFIX_SIZE = DXF_RECORD_SUFFIX_SIZE

cdef extern from "<EventData.h>":
    ctypedef enum dx_event_subscr_flag_t:
#	/// (0x0) Used for default subscription
        dx_esf_default = 0x0u,
#	/// (0x1) Used for subscribing on one record only in case of snapshots
        dx_esf_single_record = 0x1u,
#	/// (0x2) Used with #dx_esf_single_record flag and for #dx_eid_order (Order) event
        dx_esf_sr_market_maker_order = 0x2u,
#	/// (0x4) Used for time series subscription
        dx_esf_time_series = 0x4u,
#	/// (0x8) Used for regional quotes
        dx_esf_quotes_regional = 0x8u,
#	/// (0x10) Used for wildcard ("*") subscription
        dx_esf_wildcard = 0x10u,
#	/// (0x20) Used for forcing subscription to ticker data
        dx_esf_force_ticker = 0x20u,
#	/// (0x40) Used for forcing subscription to stream data
        dx_esf_force_stream = 0x40u,
#	/// (0x80) Used for forcing subscription to history data
        dx_esf_force_history = 0x80u

    ctypedef dx_event_subscr_flag_t dx_event_subscr_flag

# /* -------------------------------------------------------------------------- */
# /*
# *	Source suffix array
# */
# /* -------------------------------------------------------------------------- */
cdef extern from "<EventData.h>":
    struct dx_suffix_t:
        dxt.dxf_char_t suffix[DXF_RECORD_SUFFIX_SIZE]


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
        dxt.dxf_long_t time,
        dxt.dxf_int_t sequence,
        dxt.dxf_int_t time_nanos,
        dxt.dxf_char_t exchange_code,
        dxt.dxf_double_t price,
        dxt.dxf_double_t size,
        # /* This field is absent in TradeETH */
        dxt.dxf_int_t tick,
        dxt.dxf_double_t change,
        dxt.dxf_dayid_t day_id,
        dxt.dxf_double_t day_volume,
        dxt.dxf_double_t day_turnover,
        dxt.dxf_int_t raw_flags,
        dxf_direction_t direction,
        dxt.dxf_bool_t is_eth,
        dxf_order_scope_t scope

    ctypedef dxf_trade_t dxf_trade_eth_t

# /* Quote -------------------------------------------------------------------- */

    ctypedef struct dxf_quote_t:
        dxt.dxf_long_t time,
        dxt.dxf_int_t sequence,
        dxt.dxf_int_t time_nanos,
        dxt.dxf_long_t bid_time,
        dxt.dxf_char_t bid_exchange_code,
        dxt.dxf_double_t bid_price,
        dxt.dxf_double_t bid_size,
        dxt.dxf_long_t ask_time,
        dxt.dxf_char_t ask_exchange_code,
        dxt.dxf_double_t ask_price,
        dxt.dxf_double_t ask_size,
        dxf_order_scope_t scope


# /* Summary ------------------------------------------------------------------ */

    ctypedef enum dxf_price_type_t:
        dxf_pt_regular = 0,
        dxf_pt_indicative = 1,
        dxf_pt_preliminary = 2,
        dxf_pt_final = 3


    ctypedef struct dxf_summary_t:
        dxt.dxf_dayid_t day_id,
        dxt.dxf_double_t day_open_price,
        dxt.dxf_double_t day_high_price,
        dxt.dxf_double_t day_low_price,
        dxt.dxf_double_t day_close_price,
        dxt.dxf_dayid_t prev_day_id,
        dxt.dxf_double_t prev_day_close_price,
        dxt.dxf_double_t prev_day_volume,
        dxt.dxf_double_t open_interest,
        dxt.dxf_int_t raw_flags,
        dxt.dxf_char_t exchange_code,
        dxf_price_type_t day_close_price_type,
        dxf_price_type_t prev_day_close_price_type,
        dxf_order_scope_t scope


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
        dxt.dxf_double_t beta,
        dxt.dxf_double_t eps,
        dxt.dxf_double_t div_freq,
        dxt.dxf_double_t exd_div_amount,
        dxt.dxf_dayid_t exd_div_date,
        dxt.dxf_double_t high_52_week_price,
        dxt.dxf_double_t low_52_week_price,
        dxt.dxf_double_t shares,
        dxt.dxf_double_t free_float,
        dxt.dxf_double_t high_limit_price,
        dxt.dxf_double_t low_limit_price,
        dxt.dxf_long_t halt_start_time,
        dxt.dxf_long_t halt_end_time,
        dxt.dxf_int_t raw_flags,
        dxt.dxf_const_string_t description,
        dxt.dxf_const_string_t status_reason,
        dxf_trading_status_t trading_status,
        dxf_short_sale_restriction_t ssr


# /* Order & Spread Order ----------------------------------------------------- */

    ctypedef enum dxf_order_side_t:
        dxf_osd_undefined = 0,
        dxf_osd_buy = 1,
        dxf_osd_sell = 2

    # union _inner_oso:
    #     dxt.dxf_const_string_t market_maker,
    #     dxt.dxf_const_string_t spread_symbol


    ctypedef struct dxf_order_t:
        dxt.dxf_char_t source[DXF_RECORD_SUFFIX_SIZE],
        dxt.dxf_event_flags_t event_flags,
        dxt.dxf_long_t index,
        dxt.dxf_long_t time,
        dxt.dxf_int_t sequence,
        dxt.dxf_int_t time_nanos,
        dxf_order_action_t action,
        dxt.dxf_long_t action_time,
        dxt.dxf_long_t order_id,
        dxt.dxf_long_t aux_order_id,
        dxt.dxf_double_t price,
        dxt.dxf_double_t size,
        dxt.dxf_double_t executed_size,
        dxt.dxf_double_t count,
        dxt.dxf_long_t trade_id,
        dxt.dxf_double_t trade_price,
        dxt.dxf_double_t trade_size,
        dxt.dxf_char_t exchange_code,
        dxf_order_side_t side,
        dxf_order_scope_t scope,
        # _inner_oso # probably there should be some name (p58 of cython book)
        dxt.dxf_const_string_t market_maker,
        dxt.dxf_const_string_t spread_symbol

# /* Time And Sale ------------------------------------------------------------ */

    ctypedef enum dxf_tns_type_t:
        dxf_tnst_new = 0,
        dxf_tnst_correction = 1,
        dxf_tnst_cancel = 2


    ctypedef struct dxf_time_and_sale_t:
        dxt.dxf_event_flags_t event_flags,
        dxt.dxf_long_t index,
        dxt.dxf_long_t time,
        dxt.dxf_char_t exchange_code,
        dxt.dxf_double_t price,
        dxt.dxf_double_t size,
        dxt.dxf_double_t bid_price,
        dxt.dxf_double_t ask_price,
        dxt.dxf_const_string_t exchange_sale_conditions,
        dxt.dxf_int_t raw_flags,
        dxt.dxf_const_string_t buyer,
        dxt.dxf_const_string_t seller,
        dxf_order_side_t side,
        dxf_tns_type_t type,
        dxt.dxf_bool_t is_valid_tick,
        dxt.dxf_bool_t is_eth_trade,
        dxt.dxf_char_t trade_through_exempt,
        dxt.dxf_bool_t is_spread_leg,
        dxf_order_scope_t scope


# /* Candle ------------------------------------------------------------------- */
    ctypedef struct dxf_candle_t:
        dxt.dxf_event_flags_t event_flags,
        dxt.dxf_long_t index,
        dxt.dxf_long_t time,
        dxt.dxf_int_t sequence,
        dxt.dxf_double_t count,
        dxt.dxf_double_t open,
        dxt.dxf_double_t high,
        dxt.dxf_double_t low,
        dxt.dxf_double_t close,
        dxt.dxf_double_t volume,
        dxt.dxf_double_t vwap,
        dxt.dxf_double_t bid_volume,
        dxt.dxf_double_t ask_volume,
        dxt.dxf_double_t open_interest,
        dxt.dxf_double_t imp_volatility


# /* Greeks ------------------------------------------------------------------- */
    ctypedef struct dxf_greeks_t:
        dxt.dxf_event_flags_t event_flags,
        dxt.dxf_long_t index,
        dxt.dxf_long_t time,
        dxt.dxf_double_t price,
        dxt.dxf_double_t volatility,
        dxt.dxf_double_t delta,
        dxt.dxf_double_t gamma,
        dxt.dxf_double_t theta,
        dxt.dxf_double_t rho,
        dxt.dxf_double_t vega

# /* TheoPrice ---------------------------------------------------------------- */
# /* Event and record are the same */
    ctypedef rd.dx_theo_price_t dxf_theo_price_t

# /* Underlying --------------------------------------------------------------- */
    ctypedef struct dxf_underlying_t:
        dxt.dxf_double_t volatility,
        dxt.dxf_double_t front_volatility,
        dxt.dxf_double_t back_volatility,
        dxt.dxf_double_t call_volume,
        dxt.dxf_double_t put_volume,
        dxt.dxf_double_t option_volume,
        dxt.dxf_double_t put_call_ratio

    ctypedef dxf_underlying_t dxf_underlying

# /* Series ------------------------------------------------------------------- */
    ctypedef struct dxf_series_t:
        dxt.dxf_event_flags_t event_flags,
        dxt.dxf_long_t index,
        dxt.dxf_long_t time,
        dxt.dxf_int_t sequence,
        dxt.dxf_dayid_t expiration,
        dxt.dxf_double_t volatility,
        dxt.dxf_double_t call_volume,
        dxt.dxf_double_t put_volume,
        dxt.dxf_double_t option_volume,
        dxt.dxf_double_t put_call_ratio,
        dxt.dxf_double_t forward_price,
        dxt.dxf_double_t dividend,
        dxt.dxf_double_t interest


    ctypedef struct dxf_configuration_t:
        dxt.dxf_int_t version,
        dxt.dxf_string_t object


# /* -------------------------------------------------------------------------- */
# /*
#  *	Event data constants
#  */
# /* -------------------------------------------------------------------------- */

    # ctypedef static dxt.dxf_const_string_t DXF_ORDER_COMPOSITE_BID_STR = L"COMPOSITE_BID"
    # ctypedef static dxt.dxf_const_string_t DXF_ORDER_COMPOSITE_ASK_STR = L"COMPOSITE_ASK"

    # cdef static dxt.dxf_const_string_t DXF_ORDER_COMPOSITE_BID_STR = "COMPOSITE_BID"
    # cdef static dxt.dxf_const_string_t DXF_ORDER_COMPOSITE_ASK_STR = "COMPOSITE_ASK"

    cdef dxt.dxf_const_string_t DXF_ORDER_COMPOSITE_BID_STR = "COMPOSITE_BID"
    cdef dxt.dxf_const_string_t DXF_ORDER_COMPOSITE_ASK_STR = "COMPOSITE_ASK"

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

    ctypedef dxt.dxf_ulong_t dxf_time_int_field_t

    ctypedef struct dxf_event_params_t:
        dxt.dxf_event_flags_t flags,
        dxf_time_int_field_t time_int_field,
        dxt.dxf_ulong_t snapshot_key


# /* -------------------------------------------------------------------------- */
# /*
#  *	Event listener prototype
#
#  *  event type here is a one-bit mask, not an integer
#  *  from dx_eid_begin to dx_eid_count
#  */
# /* -------------------------------------------------------------------------- */


    ctypedef void (*dxf_event_listener_t) (int event_type, dxt.dxf_const_string_t symbol_name,
                                          const dxf_event_data_t* data, int data_count,
                                          void* user_data)

    ctypedef void (*dxf_event_listener_v2_t) (int event_type, dxt.dxf_const_string_t symbol_name,
                                          const dxf_event_data_t* data, int data_count,
                                          const dxf_event_params_t* event_params, void* user_data)

# /* -------------------------------------------------------------------------- */
# /*
#  *	Various event functions
#  */
# /* -------------------------------------------------------------------------- */
cdef extern from "<EventData.h>":
    cdef dxt.dxf_const_string_t dx_event_type_to_string (int event_type)
    cdef int dx_get_event_data_struct_size (int event_id)
    cdef dx_event_id_t dx_get_event_id_by_bitmask (int event_bitmask)

# /* -------------------------------------------------------------------------- */
# /*
#  *	Event subscription stuff
#  */
# /* -------------------------------------------------------------------------- */

    ctypedef enum dx_subscription_type_t:
        dx_st_begin = 0,

        dx_st_ticker = dx_st_begin,
        dx_st_stream,
        dx_st_history,

        # /* add new subscription types above this line */

        dx_st_count


    ctypedef struct dx_event_subscription_param_t:
        rd.dx_record_id_t record_id,
        dx_subscription_type_t subscription_type


    ctypedef struct dx_event_subscription_param_list_t:
        dx_event_subscription_param_t* elements,
        size_t size,
        size_t capacity


# /*
#  * Returns the list of subscription params. Fills records list according to event_id.
#  *
#  * You need to call dx_free(params.elements) to free resources.
#  */
    cdef size_t dx_get_event_subscription_params(dxt.dxf_connection_t connection, dx_order_source_array_ptr_t order_source, dx_event_id_t event_id,
                                        dxt.dxf_uint_t subscr_flags, dx_event_subscription_param_list_t* params)

# /* -------------------------------------------------------------------------- */
# /*
# *  Snapshot data structs
# */
# /* -------------------------------------------------------------------------- */
    #Not sure if it will go
    ctypedef struct dxf_snapshot_data_t:
        int event_type,
        dxt.dxf_string_t symbol,

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
    ctypedef struct dxf_price_level_element_t:
        dxt.dxf_double_t price
        dxt.dxf_double_t size
        dxt.dxf_long_t time



    ctypedef struct dxf_price_level_book_data_t:
        dxt.dxf_const_string_t symbol

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
    ctypedef void(*dxf_regional_quote_listener_t) (dxt.dxf_const_string_t symbol, const dxf_quote_t* quotes, int count, void* user_data)
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