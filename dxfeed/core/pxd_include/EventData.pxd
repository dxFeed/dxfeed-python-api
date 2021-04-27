# /*
#  * The contents of this file are subject to the Mozilla Public License Version
#  * 1.1 (the "License"), you may not use this file except in compliance with
#  * the License. You may obtain a copy of the License at
#  * http://www.mozilla.org/MPL/
#  *
#  * Software distributed under the License is distributed on an "AS IS" basis,
#  * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
#  * for the specific language governing rights and limitations under the
#  * License.
#  *
#  * The Initial Developer of the Original Code is Devexperts LLC.
#  * Portions created by the Initial Developer are Copyright (C) 2010
#  * the Initial Developer. All Rights Reserved.
#  *
#  * Contributor(s):
#  *
#  */

# /*
#  *  Here we have the data structures passed along with symbol events
#  */

# /**
#  * @file
#  * @brief dxFeed C API event data structures declarations
#  */

# /**
#  * @defgroup event-data-structures Event data structures
#  * @brief DxFeed C API event data structures declarations
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-order-spread-order Order & Spread Order
#  * @brief Order & Spread Order
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-trade-trade-eth Trade & Trade ETH
#  * @brief Trade & Trade ETH
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-quote Quote
#  * @brief Quote
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-summary Summary
#  * @brief Summary
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-profile Profile
#  * @brief Profile
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-tns Time & Sale
#  * @brief Time & Sale
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-candle Candle
#  * @brief Candle
#  */

# /**
#  * @ingroup event-data-structures-candle
#  * @defgroup event-data-structures-candle-attr Candle Attributes
#  * @brief Candle Attributes
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-greeks Greeks
#  * @brief Greeks
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-theo-price TheoPrice
#  * @brief TheoPrice
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-underlying Underlying
#  * @brief Underlying
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-series Series
#  * @brief Series
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-configuration Configuration
#  * @brief Configuration
#  */

# /**
#  * @ingroup event-data-structures
#  * @defgroup event-data-structures-event-subscription-stuff Event Subscription Stuff
#  * @brief Event Subscription Stuff
#  */


#ifndef EVENT_DATA_H_INCLUDED
#define EVENT_DATA_H_INCLUDED

# for wchar convertion
from dxfeed.core.utils.helpers cimport dxf_const_string_t_from_unicode

#include <limits.h>
from libc.limits cimport *
#include <math.h>
from libc.math cimport *

#include "DXTypes.h"
from dxfeed.core.pxd_include.DXTypes cimport *
#include "RecordData.h"
from dxfeed.core.pxd_include.RecordData cimport *

#ifndef OUT
#    ifndef DOXYGEN_SHOULD_SKIP_THIS
#        define OUT
#    endif    // DOXYGEN_SHOULD_SKIP_THIS
#endif        /* OUT */
DEF OUT = ''
# /**
#  * @addtogroup event-data-structures-order-spread-order
#  * @{s
#  */

# /**
#  * Action enum for the Full Order Book (FOB) Orders. Action describes business meaning of the dxf_order_t event:
#  * whether order was added or replaced, partially or fully executed, etc.
#  */
ctypedef enum dxf_order_action_t:
    # /**
    #  * Default enum value for orders that do not support "Full Order Book" and for backward compatibility -
    #  * action must be derived from other dxf_order_t fields.
    #  *
    #  * All Full Order Book related fields for this action will be empty.
    #  *
    #  * Integer value = 0
    #  */
    dxf_oa_undefined = 0,

    # /**
    #  * New Order is added to Order Book.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always present
    #  * - \ref dxf_order_t.aux_order_id - ID of the order replaced by this new order - if available.
    #  * - Trade fields will be empty
    #  *
    #  * Integer value = 1
    #  */
    dxf_oa_new = 1,

    # /**
    #  * Order is modified and price-time-priority is not maintained (i.e. order has re-entered Order Book).
    #  * Order symbol and \ref dxf_order_t.side will remain the same.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always present
    #  * - Trade fields will be empty
    #  *
    #  * Integer value = 2
    #  */
    dxf_oa_replace = 2,

    # /**
    #  * Order is modified without changing its price-time-priority (usually due to partial cancel by user).
    #  * Order's \ref dxf_order_t.size will contain new updated size.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always present
    #  * - Trade fields will be empty
    #  *
    #  * Integer value = 3
    #  */
    dxf_oa_modify = 3,

    # /**
    #  * Order is fully canceled and removed from Order Book.
    #  * Order's \ref dxf_order_t.size will be equal to 0.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always present
    #  * - \ref dxf_order_t.aux_order_id - ID of the new order replacing this order - if available.
    #  * - Trade fields will be empty
    #  *
    #  * Integer value = 4
    #  */
    dxf_oa_delete = 4,

    # /**
    #  * Size is changed (usually reduced) due to partial order execution.
    #  * Order's \ref dxf_order_t.size will be updated to show current outstanding size.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always present
    #  * - \ref dxf_order_t.aux_order_id - aggressor order ID, if available
    #  * - \ref dxf_order_t.trade_id - if available
    #  * - \ref dxf_order_t.trade_size and \ref dxf_order_t.trade_price - contain size and price of this execution
    #  *
    #  * Integer value = 5
    #  */
    dxf_oa_partial = 5,

    # /**
    #  * Order is fully executed and removed from Order Book.
    #  * Order's \ref dxf_order_t.size will be equals to 0.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always present
    #  * - \ref dxf_order_t.aux_order_id - aggressor order ID, if available
    #  * - \ref dxf_order_t.trade_id - if available
    #  * - \ref dxf_order_t.trade_size and \ref dxf_order_t.trade_price - contain size and price of this execution - always present
    #  *
    #  * Integer value = 6
    #  */
    dxf_oa_execute = 6,

    # /**
    #  * Non-Book Trade - this Trade not refers to any entry in Order Book.
    #  * Order's \ref dxf_order_t.size and \ref dxf_order_t.price will be equals to 0.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always empty
    #  * - \ref dxf_order_t.trade_id - if available
    #  * - \ref dxf_order_t.trade_size and \ref dxf_order_t.trade_price - contain size and price of this trade - always present
    #  *
    #  * Integer value = 7
    #  */
    dxf_oa_trade = 7,

    # /**
    #  * Prior Trade/Order Execution bust.
    #  * Order's \ref dxf_order_t.size and \ref dxf_order_t.price will be equals to 0.
    #  *
    #  * Full Order Book fields:
    #  * - \ref dxf_order_t.order_id - always empty
    #  * - \ref dxf_order_t.trade_id - always present
    #  * - \ref dxf_order_t.trade_size and \ref dxf_order_t.trade_price - always empty
    #  *
    #  * Integer value = 8
    #  */
    dxf_oa_bust = 8,

    dxf_oa_last = dxf_oa_bust
cdef dxf_order_action_t dxf_order_action_t

# static DX_MAYBE_UNUSED dxf_const_string_t DXF_ORDER_AGGREGATE_BID_STR = L"AGGREGATE_BID",
# static DX_MAYBE_UNUSED dxf_const_string_t DXF_ORDER_AGGREGATE_ASK_STR = L"AGGREGATE_ASK",
cdef dxf_const_string_t DXF_ORDER_AGGREGATE_BID_STR = dxf_const_string_t_from_unicode("AGGREGATE_BID")
cdef dxf_const_string_t DXF_ORDER_AGGREGATE_ASK_STR = dxf_const_string_t_from_unicode("AGGREGATE_ASK")

#/// Scope of an order.
ctypedef enum dxf_order_scope_t:
    # /// Represents best bid or best offer for the whole market. Integer value = 0
    dxf_osc_composite = 0,
    # /// Represents best bid or best offer for a given exchange code. Integer value = 1
    dxf_osc_regional = 1,
    # /// Represents aggregate information for a given price level or best bid or best offer for a given market maker.
    # /// Integer value = 2
    dxf_osc_aggregate = 2,
    # /// Represents individual order on the market. Integer value = 3
    dxf_osc_order = 3
cdef dxf_order_scope_t dxf_order_scope_t

# /// The length of record suffix including the terminating null character
#define DXF_RECORD_SUFFIX_SIZE 5
DEF DXF_RECORD_SUFFIX_SIZE = 5

# /// Side of an order or a trade.
ctypedef enum dxf_order_side_t:
    # /// Side is undefined, unknown or inapplicable. Integer value = 0
    dxf_osd_undefined = 0,
    # /// Buy side (bid). Integer value = 1
    dxf_osd_buy = 1,
    # /// Sell side (ask or offer). Integer value = 2
    dxf_osd_sell = 2
cdef dxf_order_side_t dxf_order_side_t

# /// Order
ctypedef struct dxf_order_t:
    # /// Source of this order
    dxf_char_t source[DXF_RECORD_SUFFIX_SIZE],

    # /// Transactional event flags.
    dxf_event_flags_t event_flags,

    # /// Unique per-symbol index of this order.
    dxf_long_t index,

    # /// Time of this order. Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    dxf_long_t time,

    # /// Sequence number of this order to distinguish orders that have the same #time.
    dxf_int_t sequence,

    # /// Microseconds and nanoseconds part of time of this order.
    dxf_int_t time_nanos,

    # /// Order action if available, otherwise - dxf_oa_undefined. This field is a part of the FOB ("Full Order Book") support.
    dxf_order_action_t action,

    # /// Time of the last \ref dxf_order.action if available, otherwise - 0. This field is a part of the FOB ("Full Order Book") support.
    dxf_long_t action_time,

    # /**
    #  * Contains order ID if available, otherwise - 0. Some actions dxf_oa_trade, dxf_oa_bust have no order since they are not related
    #  * to any order in Order book.
    #  *
    #  * This field is a part of the FOB ("Full Order Book") support.
    #  */
    dxf_long_t order_id,

    # /**
    #  * Contains auxiliary order ID if available, otherwise - 0:
    #  * - in dxf_oa_new - ID of the order replaced by this new order
    #  * - in dxf_oa_delete - ID of the order that replaces this deleted order
    #  * - in dxf_oa_partial - ID of the aggressor order
    #  * - in dxf_oa_execute - ID of the aggressor order
    #  *
    #  * This field is a part of the FOB ("Full Order Book") support.
    #  */
    dxf_long_t aux_order_id,

    # /// Price of this order.
    dxf_double_t price,

    # /// Size of this order
    dxf_int_t size,

    # /// Number of individual orders in this aggregate order.
    dxf_int_t count,

    # /**
    #  * Contains trade (order execution) ID for events containing trade-related action if available, otherwise - 0.
    #  *
    #  * This field is a part of the FOB ("Full Order Book") support.
    #  */
    dxf_long_t trade_id,

    # /**
    #  * Contains trade price for events containing trade-related action.
    #  *
    #  * This field is a part of the FOB ("Full Order Book") support.
    #  */
    dxf_double_t trade_price,

    # /**
    #  * Contains trade size for events containing trade-related action.
    #  *
    #  * This field is a part of the FOB ("Full Order Book") support.
    #  */
    dxf_double_t trade_size,

    # /// Exchange code of this order
    dxf_char_t exchange_code,

    # /// Side of this order
    dxf_order_side_t side,

    # /// Scope of this order
    dxf_order_scope_t scope,

    # /// Market maker of this order or spread symbol of this spread order
    # union {
    dxf_const_string_t market_maker,
    dxf_const_string_t spread_symbol,
    # },
cdef dxf_order_t dxf_order_t

# ///@}

# /**
#  * @addtogroup event-data-structures-trade-trade-eth
#  * @{
#  */

# /// Direction of the price movement. For example tick direction for last trade price.
ctypedef enum dxf_direction_t:
    # /// Direction is undefined, unknown or inapplicable. Integer value = 0
    dxf_dir_undefined = 0,
    # /// Current price is lower than previous price. Integer value = 1
    dxf_dir_down = 1,
    # /// Current price is the same as previous price and is lower than the last known price of different value. Integer
    # /// value = 2
    dxf_dir_zero_down = 2,
    # /// Current price is equal to the only known price value suitable for price direction computation. Integer value = 3
    dxf_dir_zero = 3,
    # /// Current price is the same as previous price and is higher than the last known price of different value. Integer
    # /// value = 4
    dxf_dir_zero_up = 4,
    # /// Current price is higher than previous price. Integer value = 5
    dxf_dir_up = 5
cdef dxf_direction_t dxf_direction_t

# /**
#  * Trade event is a snapshot of the price and size of the last trade during regular trading hours and an overall day
#  * volume and day turnover. It represents the most recent information that is available about the regular last trade on
#  * the market at any given moment of time.
#  */
ctypedef struct dxf_trade_t:
    # /// Time of the last trade.
    dxf_long_t time,
    # /// Sequence number of the last trade to distinguish trades that have the same #time.
    dxf_int_t sequence,
    # /// Microseconds and nanoseconds part of time of the last trade
    dxf_int_t time_nanos,
    # /// Exchange code of the last trade
    dxf_char_t exchange_code,
    # /// Price of the last trade
    dxf_double_t price,
    # /// Size of the last trade as integer number (rounded toward zero)
    dxf_int_t size,

    # /**
    #  * Trend indicator – in which direction price is moving. The values are: Up (Tick = 1), Down (Tick = 2),
    #  * and Undefined (Tick = 0).
    #  * Should be used if #direction is Undefined (#dxf_dir_undefined = 0).
    #  *
    #  * This field is absent in TradeETH
    #  */
    dxf_int_t tick,
    # /**
    #  * Change of the last trade.
    #  * Value equals price minus dxf_summary_t#prev_day_close_price
    #  */
    dxf_double_t change,
    # /// Identifier of the day that this `trade` or `trade_eth` represents. Identifier of the day is the number of days passed since
    # /// January 1, 1970.
    dxf_dayid_t day_id,
    # /// Total volume traded for a day
    dxf_double_t day_volume,
    # /// Total turnover traded for a day
    dxf_double_t day_turnover,
    # /**
    #  * This field contains several individual flags encoded as an integer number the following way:
    #  *
    #  * |31...4|  3 |  2 |  1 |  0 |
    #  * |------|----|----|----|----|
    #  * |      |  Direction |||ETH |
    #  *
    #  * 1. Tick Direction (#dxf_direction_t)
    #  * 2. ETH (extendedTradingHours) - flag that determines current trading session: extended or regular (0 - regular
    #  *    trading hours, 1 - extended trading hours).
    #  */
    dxf_int_t raw_flags,
    # /// Tick direction of the last trade
    dxf_direction_t direction,
    # /// Last trade was in extended trading hours
    dxf_bool_t is_eth,
    # /**
    #  * Last trade scope.
    #  *
    #  * Possible values: #dxf_osc_composite (Trade events) , #dxf_osc_regional (Trade& events)
    #  */
    dxf_order_scope_t scope,

cdef dxf_trade_t dxf_trade_t

# /// TradeETH
ctypedef dxf_trade_t dxf_trade_eth_t

# ///@}

# /**
#  * @addtogroup event-data-structures-quote
#  * @{
#  */

# /**
#  * @brief Quote.
#  *
#  * @details Quote event is a snapshot of the best bid and ask prices, and other fields that change with each quote. It
#  * represents the most recent information that is available about the best quote on the market at any given moment of
#  * time.
#  */
ctypedef struct dxf_quote_t:
    # /// Time of the last bid or ask change
    dxf_long_t time,
    # /// Sequence number of this quote to distinguish quotes that have the same #time.
    dxf_int_t sequence,
    # /// Microseconds and nanoseconds part of time of the last bid or ask change
    dxf_int_t time_nanos,
    # /// Time of the last bid change
    dxf_long_t bid_time,
    # /// Bid exchange code
    dxf_char_t bid_exchange_code,
    # /// Bid price
    dxf_double_t bid_price,
    # /// Bid size
    dxf_int_t bid_size,
    # /// Time of the last ask change
    dxf_long_t ask_time,
    # /// Ask exchange code
    dxf_char_t ask_exchange_code,
    # /// Ask price
    dxf_double_t ask_price,
    # /// Ask size
    dxf_int_t ask_size,
    # /**
    #  * Scope of this quote.
    #  *
    #  * Possible values: #dxf_osc_composite (Quote events) , #dxf_osc_regional (Quote& events)
    #  */
    dxf_order_scope_t scope,
cdef dxf_quote_t dxf_quote_t

# ///@}

# /**
#  * @addtogroup event-data-structures-summary
#  * @{
#  */

# /// Type of the price value.
ctypedef enum dxf_price_type_t:
    # /// Regular price. Integer value = 0.
    dxf_pt_regular = 0,
    # /// Indicative price (derived via math formula). Integer value = 1.
    dxf_pt_indicative = 1,
    # /// Preliminary price (preliminary settlement price), usually posted prior to dxf_pt_final price. Integer value = 2.
    dxf_pt_preliminary = 2,
    # /// Final price (final settlement price). Integer value = 3.
    dxf_pt_final = 3
cdef dxf_price_type_t dxf_price_type_t

# /**
#  * @brief Summary
#  *
#  * @details Summary information snapshot about the trading session including session highs, lows, etc. It represents
#  * the most recent information that is available about the trading session in the market at any given moment of time.
#  */
ctypedef struct dxf_summary_t:
    # /// Identifier of the day that this summary represents. Identifier of the day is the number of days passed since
    # /// January 1, 1970.
    dxf_dayid_t day_id,
    # /// The first (open) price for the day.
    dxf_double_t day_open_price,
    # /// The maximal (high) price for the day
    dxf_double_t day_high_price,
    # /// The minimal (low) price for the day
    dxf_double_t day_low_price,
    # /// The last (close) price for the day
    dxf_double_t day_close_price,
    # /// Identifier of the previous day that this summary represents. Identifier of the day is the number of days passed
    # /// since January 1, 1970.
    dxf_dayid_t prev_day_id,
    # /// The last (close) price for the previous day
    dxf_double_t prev_day_close_price,
    # /// Total volume traded for the previous day
    dxf_double_t prev_day_volume,
    # /// Open interest of the symbol as the number of open contracts
    dxf_int_t open_interest,
    # /**
    #  * This field contains several individual flags encoded as an integer number the following way:
    #  *
    #  * |31...4|  3 |  2 |  1 |  0  |
    #  * |------|----|----|----|-----|
    #  * |      |  Close ||PrevClose||
    #  *
    #  * 1. Close (dayClosePriceType) - parameter that shows if the closing price is final #dxf_price_type_t
    #  * 2. PrevClose (prevDayClosePriceType) - parameter that shows if the closing price of the previous day is final
    #  * #dxf_price_type_t
    #  */
    dxf_int_t raw_flags,
    # /// Exchange code
    dxf_char_t exchange_code,
    # /// The price type of the last (close) price for the day
    dxf_price_type_t day_close_price_type,
    # /// The price type of the last (close) price for the previous day
    dxf_price_type_t prev_day_close_price_type,
    # /**
    #  * Scope of this summary.
    #  *
    #  * Possible values: #dxf_osc_composite (Summary events) , #dxf_osc_regional (Summary& events)
    #  */
    dxf_order_scope_t scope,
cdef dxf_summary_t dxf_summary

# ///@}

# /**
#  * @addtogroup event-data-structures-profile
#  * @{
#  */

# /// Trading status of an instrument.
ctypedef enum dxf_trading_status_t:
    # /// Trading status is undefined, unknown or inapplicable. Integer value = 0.
    dxf_ts_undefined = 0,
    # /// Trading is halted. Integer value = 1.
    dxf_ts_halted = 1,
    # /// Trading is active. Integer value = 2.
    dxf_ts_active = 2
cdef dxf_trading_status_t dxf_trading_status

# /// Short sale restriction on an instrument.
ctypedef enum dxf_short_sale_restriction_t:
    # /// Short sale restriction is undefined, unknown or inapplicable. Integer value = 0.
    dxf_ssr_undefined = 0,
    # /// Short sale restriction is active. Integer value = 1.
    dxf_ssr_active = 1,
    # /// Short sale restriction is inactive. Integer value = 2.
    dxf_ssr_inactive = 2
cdef dxf_short_sale_restriction_t dxf_short_sale_restriction

# /**
#  * @brief Profile
#  *
#  * @details Profile information snapshot that contains security instrument description. It represents the most recent
#  * information that is available about the traded security on the market at any given moment of time.
#  */
ctypedef struct dxf_profile_t:
    # /// The correlation coefficient of the instrument to the S&P500 index (calculated, or received from other data providers)
    dxf_double_t beta,
    # /// Earnings per share (the company’s profits divided by the number of shares). The value comes directly from the annual quarterly accounting reports of companies. Available generally for stocks
    dxf_double_t eps,
    # /// Frequency of cash dividends payments per year (calculated)
    dxf_int_t div_freq,
    # /// The amount of the last paid dividend
    dxf_double_t exd_div_amount,
    # /// Date of the last dividend payment
    dxf_dayid_t exd_div_date,
    # /// Maximal (high) price in last 52 weeks
    dxf_double_t high_52_week_price,
    # /// Minimal (low) price in last 52 weeks
    dxf_double_t low_52_week_price,
    # /// Shares outstanding. In general, this is the total number of shares issued by this company (only for stocks)
    dxf_double_t shares,
    # /// The number of shares outstanding that are available to the public for trade. This field always has NaN value.
    dxf_double_t free_float,
    # /// Maximal (high) allowed price
    dxf_double_t high_limit_price,
    # /// Minimal (low) allowed price
    dxf_double_t low_limit_price,
    # /// Starting time of the trading halt interval
    dxf_long_t halt_start_time,
    # /// Ending time of the trading halt interval
    dxf_long_t halt_end_time,
    # /**
    #  * This field contains several individual flags encoded as an integer number the following way:
    #  *
    #  * |31...4|  3 |  2 |  1 |  0 |
    #  * |------|----|----|----|----|
    #  * |      |   SSR  || Status ||
    #  *
    #  * 1. SSR (shortSaleRestriction) - special mode of protection against "shorting the market", this field
    #  *    is optional. #dxf_short_sale_restriction_t
    #  * 2. Status (tradingStatus) - the state of the instrument. #dxf_trading_status_t
    #  */
    dxf_int_t raw_flags,
    # /// Description of the security instrument
    dxf_const_string_t description,
    # /// Description of the reason that trading was halted
    dxf_const_string_t status_reason,
    # /// Trading status of the security instrument
    dxf_trading_status_t trading_status,
    # /// Short sale restriction of the security instrument
    dxf_short_sale_restriction_t ssr,
cdef dxf_profile_t dxf_profile

# ///@}

# /**
#  * @addtogroup event-data-structures-tns
#  * @{
#  */

# /// Type of a time and sale event.
ctypedef enum dxf_tns_type_t:
    # /// Represents new time and sale event. Integer value = 0.
    dxf_tnst_new = 0,
    # /// Represents correction time and sale event. Integer value = 1.
    dxf_tnst_correction = 1,
    # /// Represents cancel time and sale event. Integer value = 2.
    dxf_tnst_cancel = 2
cdef dxf_tns_type_t dxf_tns_type

# /// Time & sale
ctypedef struct dxf_time_and_sale_t:
    # /// Transactional event flags. See: #dxf_event_flag
    dxf_event_flags_t event_flags,
    # /// Unique per-symbol index of this time and sale event
    dxf_long_t index,
    # /// Timestamp of the original event
    dxf_long_t time,
    # /// Exchange code of this time and sale event
    dxf_char_t exchange_code,
    # /// Price of this time and sale event
    dxf_double_t price,
    # /// Size of this time and sale event as integer number
    dxf_int_t size,
    # /// The current bid price on the market when this time and sale event had occurred
    dxf_double_t bid_price,
    # /// The current ask price on the market when this time and sale event had occurred
    dxf_double_t ask_price,
    # /// Sale conditions provided for this event by data feed. [TimeAndSale Sale Conditions](https://kb.dxfeed.com/display/DS/TimeAndSale+Sale+Conditions)
    dxf_const_string_t exchange_sale_conditions,
    # /**
    #  * This field contains several individual flags encoded as an integer number the following way:
    #  *
    #  * |31...16|15...8|  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |
    #  * |-------|------|----|----|----|----|----|----|----|----|
    #  * |       |TTE   |    |   Side || SL | ETH| VT |  Type  ||
    #  *
    #  * 1. TradeThroughExempt (TTE) - is a transaction concluded by exempting from compliance with some rule. The value
    #  *    is encoded by the letter.
    #  * 2. Side (aggressorSide) - initiator of the trade. #dxf_order_side_t
    #  * 3. SL (spreadLeg) - an indication of whether this transaction is a part of a multi-leg order (0 - single order,
    #  *    1 - multi-leg order).
    #  * 4. ETH (extendedTradingHours) - whether the transaction is completed during extended trading hours (0 - regular
    #  *    trading hours, 1 - extended trading hours).
    #  * 5. VT (validTick) - our normalized SaleCondition flag (1 - the tick is valid and must be drawn on the chart
    #  *    service, 0 - this is most likely not a transaction and does not need to be displayed).
    #  * 6. Type - type of event. #dxf_tns_type_t
    #  */
    dxf_int_t raw_flags,
    # /// Buyer of this time and sale event
    dxf_const_string_t buyer,
    # /// Seller of this time and sale event
    dxf_const_string_t seller,
    # /// Aggressor side of this time and sale event
    dxf_order_side_t side,
    # /// Type of this time and sale event
    dxf_tns_type_t type,
    # /// Whether this event represents a valid intraday tick
    dxf_bool_t is_valid_tick,
    # /// Whether this event represents an extended trading hours sale
    dxf_bool_t is_eth_trade,
    # /// TradeThroughExempt flag of this time and sale event
    dxf_char_t trade_through_exempt,
    # /// Whether this event represents a spread leg
    dxf_bool_t is_spread_leg,
    # /**
    #  * Scope of this TimeAndSale.
    #  *
    #  * Possible values: #dxf_osc_composite (TimeAndSale events) , #dxf_osc_regional (TimeAndSale& events)
    #  */
    dxf_order_scope_t scope,
cdef dxf_time_and_sale_t dxf_time_and_sale

# ///@}

# /**
#  * @addtogroup event-data-structures-candle
#  * @{
#  */

# /**
#  * @brief Candle
#  *
#  * @details Candle event with open, high, low, close prices and other information for a specific period. Candles are
#  * build with a specified CandlePeriod (#dxf_candle_type_period_attribute_t + value) using a specified
#  * CandlePrice type (#dxf_candle_price_attribute_t) with a data taken from the specified CandleExchange (A-Z) from the
#  * specified CandleSession (#dxf_candle_session_attribute) with further details of aggregation provided by
#  * CandleAlignment (#dxf_candle_alignment_attribute)
#  */
ctypedef struct dxf_candle_t:
    # /// Transactional event flags
    dxf_event_flags_t event_flags,
    # /// Unique per-symbol index of this candle
    dxf_long_t index,
    # /// Timestamp of this candle in milliseconds
    dxf_long_t time,
    # /// Sequence number of this candle, distinguishes candles with same #time
    dxf_int_t sequence,
    # /// Total number of original trade (or quote) events in this candle
    dxf_double_t count,
    # /// The first (open) price of this candle
    dxf_double_t open,
    # /// The maximal (high) price of this candle
    dxf_double_t high,
    # /// The minimal (low) price of this candle
    dxf_double_t low,
    # /// The last (close) price of this candle
    dxf_double_t close,
    # /// Total volume in this candle
    dxf_double_t volume,
    # /// Volume-weighted average price (VWAP) in this candle
    dxf_double_t vwap,
    # /// Bid volume in this candle
    dxf_double_t bid_volume,
    # /// Ask volume in this candle
    dxf_double_t ask_volume,
    # /// Open interest
    dxf_int_t open_interest,
    # /// Implied volatility
    dxf_double_t imp_volatility,

# ///@}

# /**
#  * @addtogroup event-data-structures-greeks
#  * @{
#  */

# /**
#  * @brief Greeks
#  * @details Greeks event is a snapshot of the option price, Black-Scholes volatility and greeks. It represents the
#  * most recent information that is available about the corresponding values on the market at any given moment of time.
#  */
ctypedef struct dxf_greeks_t:
    # /// Transactional event flags
    dxf_event_flags_t event_flags,
    # /// Unique per-symbol index of this event
    dxf_long_t index,
    # /// Timestamp of this event in milliseconds
    dxf_long_t time,
    # /// Option market price
    dxf_double_t price,
    # /// Black-Scholes implied volatility of the option
    dxf_double_t volatility,
    # /// Option delta
    dxf_double_t delta,
    # /// Option gamma
    dxf_double_t gamma,
    # /// Option theta
    dxf_double_t theta,
    # /// Option rho
    dxf_double_t rho,
    # /// Option vega
    dxf_double_t vega,
cdef dxf_greeks_t dxf_greeks

# ///@}

# /**
#  * @addtogroup event-data-structures-theo-price
#  * @{
#  */

# /// Theo price. Event and record are the same
ctypedef dx_theo_price_t dxf_theo_price_t

# ///@}

# /**
#  * @addtogroup event-data-structures-underlying
#  * @{
#  */

# /**
#  * @brief Underlying
#  *
#  * @details Underlying event is a snapshot of computed values that are available for an option underlying symbol based
#  * on the option prices on the market. It represents the most recent information that is available about the
#  * corresponding values on the market at any given moment of time.
#  */
ctypedef struct dxf_underlying_t:
    # /// 30-day implied volatility for this underlying based on VIX methodology
    dxf_double_t volatility,
    # /// Front month implied volatility for this underlying based on VIX methodology,
    dxf_double_t front_volatility,
    # /// Back month implied volatility for this underlying based on VIX methodology
    dxf_double_t back_volatility,
    # /// Call options traded volume for a day
    dxf_double_t call_volume,
    # /// Put options traded volume for a day
    dxf_double_t put_volume,
    # /// Options traded volume for a day
    dxf_double_t option_volume,
    # /// Ratio of put options traded volume to call options traded volume for a day
    dxf_double_t put_call_ratio,
cdef dxf_underlying_t dxf_underlying

# ///@}

# /**
#  * @addtogroup event-data-structures-series
#  * @{
#  */

# /**
#  * @brief Series
#  *
#  * @details Series event is a snapshot of computed values that are available for all option series for a given
#  * underlying symbol based on the option prices on the market. It represents the most recent information that is
#  * available about the corresponding values on the market at any given moment of time.
#  */
ctypedef struct dxf_series_t:
    # /// Transactional event flags
    dxf_event_flags_t event_flags,
    # /// Unique per-symbol index of this series
    dxf_long_t index,
    # /// Time of this series
    dxf_long_t time,
    # /// Sequence number of this series, distinguishes candles with same #times
    dxf_int_t sequence,
    # /// Day id of expiration
    dxf_dayid_t expiration,
    # /// Implied volatility index for this series based on VIX methodology
    dxf_double_t volatility,
    # /// Call options traded volume for a day
    dxf_double_t call_volume,
    # /// Put options traded volume for a day
    dxf_double_t put_volume,
    # /// Options traded volume for a day
    dxf_double_t option_volume,
    # /// Ratio of put options traded volume to call options traded volume for a day
    dxf_double_t put_call_ratio,
    # /// Implied forward price for this option series
    dxf_double_t forward_price,
    # /// Implied simple dividend return of the corresponding option series
    dxf_double_t dividend,
    # /// Implied simple interest return of the corresponding option series
    dxf_double_t interest,
cdef dxf_series_t dxf_series

# ///@}

# /**
#  * @addtogroup event-data-structures-configuration
#  * @{
#  */

# /// Configuration event with application-specific attachment
ctypedef struct dxf_configuration_t:
    # /// Version
    dxf_int_t version,
    # /// Attachment
    dxf_string_t object,
cdef dxf_configuration_t dxf_configuration

# ///@}

# /**
#  * @addtogroup event-data-structures-candle-attr
#  * @{
#  */

# /* -------------------------------------------------------------------------- */
# /*
#  *    Event candle attributes
#  */
# /* -------------------------------------------------------------------------- */

# /// Composite "exchange code" of a candle, i.e. empty string
#define DXF_CANDLE_EXCHANGE_CODE_COMPOSITE_ATTRIBUTE L'\0'
DEF DXF_CANDLE_EXCHANGE_CODE_COMPOSITE_ATTRIBUTE = '\0'
# /// Default exchange code of a candle, i.e. empty string
#define DXF_CANDLE_EXCHANGE_CODE_ATTRIBUTE_DEFAULT     DXF_CANDLE_EXCHANGE_CODE_COMPOSITE_ATTRIBUTE
DEF DXF_CANDLE_EXCHANGE_CODE_ATTRIBUTE_DEFAULT = DXF_CANDLE_EXCHANGE_CODE_COMPOSITE_ATTRIBUTE
# /// Default period attribute value of a candle (1.0)
#define DXF_CANDLE_PERIOD_VALUE_ATTRIBUTE_DEFAULT     1.0
DEF DXF_CANDLE_PERIOD_VALUE_ATTRIBUTE_DEFAULT = 1.0
# /// Default price level attribute value of a candle (NaN)
#define DXF_CANDLE_PRICE_LEVEL_ATTRIBUTE_DEFAULT     (NAN)
DEF DXF_CANDLE_PRICE_LEVEL_ATTRIBUTE_DEFAULT = ''

# /// Candle price attribute. Defines price that is used to build the candles. `price=<value>`
ctypedef enum dxf_candle_price_attribute_t:
    # /// Last trading price. `price=last`
    dxf_cpa_last,
    # /// Quote bid price. `price=bid`
    dxf_cpa_bid,
    # /// Quote ask price. `price=ask`
    dxf_cpa_ask,
    # /// Market price defined as average between quote bid and ask prices. `price=mark`
    dxf_cpa_mark,
    # /// Official settlement price that is defined by exchange or last trading price otherwise. `price=s`
    dxf_cpa_settlement,

    dxf_cpa_count,

    # /// Default price attribute value. `price=last`
    dxf_cpa_default = dxf_cpa_last
cdef dxf_candle_price_attribute_t dxf_candle_price_attribute

# /// Candle session attribute. Defines trading that is used to build the candles. `tho=<value>`
ctypedef enum dxf_candle_session_attribute_t:
    # /// `tho=false`
    dxf_csa_any,
    # /// `tho=true`
    dxf_csa_regular,

    dxf_csa_count,

    # /// `tho=false`
    dxf_csa_default = dxf_csa_any
cdef dxf_candle_session_attribute_t dxf_candle_session_attribute

# /// Candle type period attribute. Defines type of aggregation period of the candles `=<amount><type>`,
# /// Where <amount> - double value
ctypedef enum dxf_candle_type_period_attribute_t:
    # /// Ticks. `=<amount>t`
    dxf_ctpa_tick,
    # /// Seconds. `=<amount>s`
    dxf_ctpa_second,
    # /// Minutes. `=<amount>m`
    dxf_ctpa_minute,
    # /// Hours. `=<amount>h`
    dxf_ctpa_hour,
    # /// Days. `=<amount>d`
    dxf_ctpa_day,
    # /// Weeks. `=<amount>w`
    dxf_ctpa_week,
    # /// Months. `=<amount>mo`
    dxf_ctpa_month,
    # /// Option expirations. `=<amount>o`
    dxf_ctpa_optexp,
    # /// Years. `=<amount>y`
    dxf_ctpa_year,
    # /// Volume of trades. `=<amount>v`
    dxf_ctpa_volume,

    # /**
    #  * Certain price change, calculated according to the following rules:
    #  * 1. high(n) - low(n) = price range
    #  * 2. close(n) = high(n) or close(n) = low(n)
    #  * 3. open(n+1) = close(n)
    #  *
    #  * where n is the number of the bar.
    #  *
    #  * `=<amount>p`
    #  */
    dxf_ctpa_price,

    # /**
    #  * Certain price change, calculated according to the following rules:
    #  * 1. high(n) - low(n) = price range
    #  * 2. close(n) = high(n) or close(n) = low(n)
    #  * 3. open(n+1) = close(n) + tick size, if close(n) = high(n)
    #  * 4. open(n+1) = close(n) - tick size, if close(n) = low(n)
    #  *
    #  * where n is the number of the bar.
    #  *
    #  * `=<amount>pm`
    #  */
    dxf_ctpa_price_momentum,
    # /**
    #  * Certain price change, calculated according to the following rules:
    #  * 1. high(n+1) - high(n) = price range or low(n) - low(n+1) = price range
    #  * 2. close(n) = high(n) or close(n) = low(n)
    #  * 3. open(n+1) = high(n), if high(n+1) - high(n) = price range
    #  * 4. open(n+1) = low(n), if low(n) - low(n+1) = price range
    #  *
    #  * where n is the number of the bar.
    #  *
    #  * `=<amount>pr`
    #  */
    dxf_ctpa_price_renko,

    dxf_ctpa_count,

    # /// Default type period attribute. `=<amount>t`
    dxf_ctpa_default = dxf_ctpa_tick
cdef dxf_candle_type_period_attribute_t dxf_candle_type_period_attribute

# /// Candle alignment attribute. Defines how candle are aligned with respect to time. `a=<value>`
ctypedef enum dxf_candle_alignment_attribute_t:
    # /// Align candles on midnight. `a=m`
    dxf_caa_midnight,
    # /// Align candles on session. `a=s`
    dxf_caa_session,

    dxf_caa_count,

    # /// Default alignment attribute value. `a=m`
    dxf_caa_default = dxf_caa_midnight
cdef dxf_candle_alignment_attribute_t dxf_candle_alignment_attribute

# /// @}

# /**
#  * @addtogroup event-data-structures-event-subscription-stuff
#  * @{
#  */

# /* -------------------------------------------------------------------------- */
# // Event subscription stuff
# /* -------------------------------------------------------------------------- */

# /// Event flag. [EventFlags description](https://kb.dxfeed.com/display/DS/QD+Model+of+Market+Events#QDModelofMarketEvents-EventFlagsfield)
ctypedef enum dxf_event_flag:
    # /// (0x01) TX_PENDING indicates a pending transactional update. When TX_PENDING is 1, it means that an ongoing transaction
    # /// update, that spans multiple events, is in process
    dxf_ef_tx_pending = 0x01,
    # /// (0x02) REMOVE_EVENT indicates that the event with the corresponding index has to be removed
    dxf_ef_remove_event = 0x02,
    # /// (0x04) SNAPSHOT_BEGIN indicates when the loading of a snapshot starts. Snapshot load starts on new subscription and
    # /// the first indexed event that arrives for each exchange code (in the case of a regional record) on a new
    # /// subscription may have SNAPSHOT_BEGIN set to true. It means that an ongoing snapshot consisting of multiple
    # /// events is incoming
    dxf_ef_snapshot_begin = 0x04,
    # /// (0x08) SNAPSHOT_END or (0x10) SNAPSHOT_SNIP indicates the end of a snapshot. The difference between SNAPSHOT_END and
    # /// SNAPSHOT_SNIP is the following: SNAPSHOT_END indicates that the data source sent all the data pertaining to
    # /// the subscription for the corresponding indexed event, while SNAPSHOT_SNIP indicates that some limit on the
    # /// amount of data was reached and while there still might be more data available, it will not be provided
    # /// @{
    dxf_ef_snapshot_end = 0x08,
    dxf_ef_snapshot_snip = 0x10,
    # /// @}

    dxf_ef_remove_symbol = 0x20
# Verify this
cdef dxf_event_flag dxf_event_flag_t

# /// Event data
ctypedef void* dxf_event_data_t
ctypedef const void* dxf_const_event_data_t

ctypedef dxf_ulong_t dxf_time_int_field_t

# /// Event params
ctypedef struct dxf_event_params_t:
    dxf_event_flags_t flags,
    dxf_time_int_field_t time_int_field,
    dxf_ulong_t snapshot_key,
# Verify this
cdef dxf_event_params_t dxf_event_params

# /* -------------------------------------------------------------------------- */
# /*
#  *    Event listener prototype
#
#  *  event type here is a one-bit mask, not an integer
#  *  from dx_eid_begin to dx_eid_count
#  */
# /* -------------------------------------------------------------------------- */

# /**
#  * Event listener prototype
#  *
#  * Parameters:
#  * - event_type - Event type bit mask constructed from dx_event_id_t enum fields. See macro: \ref DXF_ET_TRADE, \ref DXF_ET_QUOTE ... \ref DXF_ET_CONFIGURATION
#  * - symbol_name - Event symbol (AAPL, IBM, etc)
#  * - data - Pointer to event data (should be casted to some specific event data structure, i.e. dxf_order_t, dxf_trade_t ...)
#  * - data_count **[deprecated]** - The number of events. Always equals to 1. **[Will be removed in 8.0.0 version]**
#  * - user_data - The user data passed to \ref dxf_attach_event_listener
#  *
#  *  An example of implementation:
#  *
#  *  ```c
#  *
#  *  void print_timestamp(dxf_long_t timestamp) {
 # *      wchar_t timefmt[80],
 # *
 # *      struct tm* timeinfo,
 # *      time_t tmpint = (time_t)(timestamp / 1000),
 # *      timeinfo = localtime(&tmpint),
 # *
 # *      wcsftime(timefmt, 80, L"%Y%m%d-%H%M%S", timeinfo),
 # *      wprintf(L"%ls", timefmt),
 # *  }
 # *
 # *  void listener(int event_type, dxf_const_string_t symbol_name, const dxf_event_data_t* data, int data_count,
 # *      void* user_data) {
 # *  {
 # *      wprintf(L"%ls{symbol=%ls, ", dx_event_type_to_string(event_type), symbol_name),
 # *
 # *      if (event_type == DXF_ET_QUOTE) {
 # *          dxf_quote_t* q = (dxf_quote_t*)data,
 # *
 # *          wprintf(L"bidTime="),
 # *          print_timestamp(q->bid_time),
 # *          wprintf(L" bidExchangeCode=%c, bidPrice=%f, bidSize=%i, ", q->bid_exchange_code, q->bid_price, q->bid_size),
 # *          wprintf(L"askTime="),
 # *          print_timestamp(q->ask_time),
 # *          wprintf(L" askExchangeCode=%c, askPrice=%f, askSize=%i, scope=%d}\n", q->ask_exchange_code, q->ask_price,
 # *                  q->ask_size, (int)q->scope),
 # *      }
 # *  }
 # *  ```
 # */
ctypedef void (*dxf_event_listener_t)(int event_type, dxf_const_string_t symbol_name, const dxf_event_data_t* data,
                                      int data_count, void* user_data)

# /**
#  * Event listener prototype v. 2
#  *
#  * Parameters:
#  * - event_type - Event type bit mask constructed from dx_event_id_t enum fields. See macro: \ref DXF_ET_TRADE, \ref DXF_ET_QUOTE ... \ref DXF_ET_CONFIGURATION
#  * - symbol_name - Event symbol (AAPL, IBM, etc)
#  * - data - Pointer to event data (should be casted to some specific event data structure, i.e. dxf_order_t, dxf_trade_t ...)
#  * - data_count **[deprecated]** - The number of events. Always equals to 1. **[Will be removed in 8.0.0 version]**
#  * - event_params - Some event parameters: event flags, snapshot key and time stored in 4 high or low bytes
#  * - user_data - The user data passed to \ref dxf_attach_event_listener_v2
#  */
ctypedef void (*dxf_event_listener_v2_t)(int event_type, dxf_const_string_t symbol_name, const dxf_event_data_t* data,
                                         int data_count, const dxf_event_params_t* event_params, void* user_data)

# /**
#  * @brief Event ID
#  */
ctypedef enum dx_event_id_t:
    dx_eid_begin = 0u,
    # /// Trade event ID
    dx_eid_trade = dx_eid_begin,
    # /// Quote event ID
    dx_eid_quote,
    # /// Summary event ID
    dx_eid_summary,
    # /// Profile event ID
    dx_eid_profile,
    # /// Order event ID
    dx_eid_order,
    # /// T&S event ID
    dx_eid_time_and_sale,
    # /// Candle event ID
    dx_eid_candle,
    # /// TradeETH event ID
    dx_eid_trade_eth,
    # /// Spread Order event ID
    dx_eid_spread_order,
    # /// Greeks event ID
    dx_eid_greeks,
    # /// Theo Price event ID
    dx_eid_theo_price,
    # /// Underlying event ID
    dx_eid_underlying,
    # /// Series event ID
    dx_eid_series,
    # /// Configuration event ID
    dx_eid_configuration,

    # /* add new event id above this line */

    dx_eid_count,
    dx_eid_invalid
cdef dx_event_id_t dx_event_id

# Verify this
# /// Trade event
#define DXF_ET_TRADE (1u << (unsigned)dx_eid_trade)
cdef DXF_ET_TRADE = 1u << <unsigned>dx_eid_trade
# /// Quote event
#define DXF_ET_QUOTE (1u << (unsigned)dx_eid_quote)
cdef DXF_ET_QUOTE = 1u << <unsigned>dx_eid_quote
# /// Summary event
#define DXF_ET_SUMMARY (1u << (unsigned)dx_eid_summary)
cdef DXF_ET_SUMMARY = 1u << <unsigned>dx_eid_summary
# /// Profile event
#define DXF_ET_PROFILE (1u << (unsigned)dx_eid_profile)
cdef DXF_ET_PROFILE = 1u << <unsigned>dx_eid_profile
# /// Order event
#define DXF_ET_ORDER (1u << (unsigned)dx_eid_order)
cdef DXF_ET_ORDER = 1u << <unsigned>dx_eid_order
# /// Time & sale event
#define DXF_ET_TIME_AND_SALE (1u << (unsigned)dx_eid_time_and_sale)
cdef DXF_ET_TIME_AND_SALE = 1u << <unsigned>dx_eid_time_and_sale
# /// Candle event
#define DXF_ET_CANDLE (1u << (unsigned)dx_eid_candle)
cdef DXF_ET_CANDLE = 1u << <unsigned>dx_eid_candle
# /// Trade eth event
#define DXF_ET_TRADE_ETH (1u << (unsigned)dx_eid_trade_eth)
cdef DXF_ET_TRADE_ETH = 1u << <unsigned>dx_eid_trade_eth
# /// Spread order event
#define DXF_ET_SPREAD_ORDER (1u << (unsigned)dx_eid_spread_order)
cdef DXF_ET_SPREAD_ORDER = 1u << <unsigned>dx_eid_spread_order
# /// Greeks event
#define DXF_ET_GREEKS (1u << (unsigned)dx_eid_greeks)
cdef DXF_ET_GREEKS = 1u << <unsigned>dx_eid_greeks
# /// Theo price event
#define DXF_ET_THEO_PRICE (1u << (unsigned)dx_eid_theo_price)
cdef DXF_ET_THEO_PRICE = 1u << <unsigned>dx_eid_theo_price
# /// Underlying event
#define DXF_ET_UNDERLYING (1u << (unsigned)dx_eid_underlying)
cdef DXF_ET_UNDERLYING = 1u << <unsigned>dx_eid_underlying
# /// Series event
#define DXF_ET_SERIES (1u << (unsigned)dx_eid_series)
cdef DXF_ET_SERIES = 1u << <unsigned>dx_eid_series
# /// Configuration event
#define DXF_ET_CONFIGURATION (1u << (unsigned)dx_eid_configuration)
cdef DXF_ET_CONFIGURATION = 1u << <unsigned>dx_eid_configuration
#define DXF_ET_UNUSED         (~((1u << (unsigned)dx_eid_count) - 1u))
cdef DXF_ET_UNUSED = 1u << <unsigned>dx_eid_count
DXF_ET_UNUSED = DXF_ET_UNUSED - 1u
DXF_ET_UNUSED = ~DXF_ET_UNUSED

# /// Event bit-mask
#define DX_EVENT_BIT_MASK(event_id) (1u << (unsigned)event_id)
# cdef DX_EVENT_BIT_MASK[event_id] = 1u << <unsigned>event_id

# /// @}

# /**
#  * @ingroup event-data-structures-event-subscription-stuff
#  *
#  * @brief Event Subscription flags
#  */
ctypedef enum dx_event_subscr_flag:
    # /// (0x0) Used for default subscription
    dx_esf_default = 0x0u,
    # /// (0x1) Used for subscribing on one record only in case of snapshots
    dx_esf_single_record = 0x1u,
    # /// (0x2) Used with #dx_esf_single_record flag and for #dx_eid_order (Order) event
    dx_esf_sr_market_maker_order = 0x2u,
    # /// (0x4) Used for time series subscription
    dx_esf_time_series = 0x4u,
    # /// (0x8) Used for regional quotes
    dx_esf_quotes_regional = 0x8u,
    # /// (0x10) Used for wildcard ("*") subscription
    dx_esf_wildcard = 0x10u,
    # /// (0x20) Used for forcing subscription to ticker data
    dx_esf_force_ticker = 0x20u,
    # /// (0x40) Used for forcing subscription to stream data
    dx_esf_force_stream = 0x40u,
    # /// (0x80) Used for forcing subscription to history data
    dx_esf_force_history = 0x80u,

    dx_esf_force_enum_unsigned = UINT_MAX
# Verify this
cdef dx_event_subscr_flag dx_event_subscr_flag_t

# /// Suffix
ctypedef struct dx_suffix_t:
    dxf_char_t suffix[DXF_RECORD_SUFFIX_SIZE],
cdef dx_suffix_t dx_suffix

# /// Order source array
ctypedef struct dx_order_source_array_t:
    dx_suffix_t* elements,
    size_t size,
    size_t capacity,
#Verify this
cdef dx_order_source_array_t dx_order_source_array

# /// Pointer to an order source array
ctypedef dx_order_source_array_t* dx_order_source_array_ptr_t

# /// Subscription type
ctypedef enum dx_subscription_type_t:
    dx_st_begin = 0,

    # /**
    #  * @brief TICKER subscription type
    #  *
    #  * @details Delivery of latest actual value, queued older events could be conflated to conserve bandwidth and
    #  * resources.
    #  *
    #  * Example: Values of the latest bid/ask and last sale prices for IBM
    #  */
    dx_st_ticker = dx_st_begin,

    # /**
    #  * @brief STREAM subscription type
    #  *
    #  * @details All events are delivered in order.
    #  *
    #  * Example: Incoming tape of all trades for IBM
    #  */
    dx_st_stream,

    # /**
    #  * @brief HISTORY subscription type
    #  *
    #  * @details Request data history - values for certain records (groups of elements) which have arrived into QDS and
    #  * have special timestamp value fitting into period requested by consumer.
    #  *
    #  * Example: Charting: daily bars for IBM from Sep 1st till Sep 10th 2011
    #  */
    dx_st_history,

    # /* add new subscription types above this line */

    dx_st_count
# Verify this
cdef dx_subscription_type_t dx_subscription_type

# /// Event subscription param
ctypedef struct dx_event_subscription_param_t:
    dx_record_id_t record_id,
    dx_subscription_type_t subscription_type,
cdef dx_event_subscription_param_t dx_event_subscription_param

# /// Event subscription param list
ctypedef struct dx_event_subscription_param_list_t:
    dx_event_subscription_param_t* elements,
    size_t size,
    size_t capacity,
cdef dx_event_subscription_param_list_t dx_event_subscription_param_list

# /**
#  * @ingroup c-api-basic-subscription-functions
#  *
#  * @brief Returns the list of subscription params. Fills records list according to event_id.
#  *
#  * @param[in]  connection    Connection handle
#  * @param[in]  order_source  Order source
#  * @param[in]  event_id      Event id
#  * @param[in]  subscr_flags  Subscription flags
#  * @param[out] params        Subscription params
#  *
#  * @warning You need to call dx_free(params.elements) to free resources.
#  */
cdef size_t dx_get_event_subscription_params(dxf_connection_t connection, dx_order_source_array_ptr_t order_source,
                                             dx_event_id_t event_id, dx_event_subscr_flag subscr_flags,
                                             dx_event_subscription_param_list_t* params)

# /* -------------------------------------------------------------------------- */
# /*
#  *  Snapshot data structs
#  */
# /* -------------------------------------------------------------------------- */

# /// Snapshot
# ctypedef struct dxf_snapshot_data {
#     int event_type,
#     dxf_string_t symbol,
#
#     size_t records_count,
#     const dxf_event_data_t* records,
# } dxf_snapshot_data_t, *dxf_snapshot_data_ptr_t,
ctypedef struct dxf_snapshot_data_t:
    int event_type,
    dxf_string_t symbol,

    size_t records_count,
    const dxf_event_data_t* records,
cdef dxf_snapshot_data_t dxf_snapshot_data
ctypedef dxf_snapshot_data_t *dxf_snapshot_data_ptr_t



# /* -------------------------------------------------------------------------- */
# /**
#  * @ingroup c-api-snapshots
#  *
#  * @brief Snapshot listener prototype
#  *
#  * @param[in] snapshot_data Pointer to the received snapshot data
#  * @param[in] user_data     Pointer to user struct, use NULL by default
#  */
# /* -------------------------------------------------------------------------- */
ctypedef void (*dxf_snapshot_listener_t)(const dxf_snapshot_data_ptr_t snapshot_data, void* user_data)

# /* -------------------------------------------------------------------------- */
#define DXF_IS_CANDLE_REMOVAL(c)        (((c)->event_flags & dxf_ef_remove_event) != 0)
#define DXF_IS_ORDER_REMOVAL(o)            ((((o)->event_flags & dxf_ef_remove_event) != 0) || ((o)->size == 0))
#define DXF_IS_SPREAD_ORDER_REMOVAL(o)    ((((o)->event_flags & dxf_ef_remove_event) != 0) || ((o)->size == 0))
#define DXF_IS_TIME_AND_SALE_REMOVAL(t) (((t)->event_flags & dxf_ef_remove_event) != 0)
#define DXF_IS_GREEKS_REMOVAL(g)        (((g)->event_flags & dxf_ef_remove_event) != 0)
#define DXF_IS_SERIES_REMOVAL(s)        (((s)->event_flags & dxf_ef_remove_event) != 0)
# /**
#  *  @brief Incremental Snapshot listener prototype
#
#  *  @param[in] snapshot_data Pointer to the received snapshot data
#  *  @param[in] new_snapshot  Flag, is this call with new snapshot or incremental update.
#  *  @param[in] user_data     Pointer to user struct, use NULL by default
#  */
ctypedef void (*dxf_snapshot_inc_listener_t)(const dxf_snapshot_data_ptr_t snapshot_data, int new_snapshot,
                                             void* user_data)

# /* -------------------------------------------------------------------------- */
# /*
#  *  Price Level data structs
#  */
# /* -------------------------------------------------------------------------- */
# /// Price level element
ctypedef struct dxf_price_level_element_t:
    dxf_double_t price,
    dxf_long_t size,
    dxf_long_t time,
cdef dxf_price_level_element_t dxf_price_level_element

# /// Price level book data
# ctypedef struct dxf_price_level_book_data {
#     dxf_const_string_t symbol,
#
#     size_t bids_count,
#     const dxf_price_level_element_t* bids,
#
#     size_t asks_count,
#     const dxf_price_level_element_t* asks,
# } dxf_price_level_book_data_t, *dxf_price_level_book_data_ptr_t,

ctypedef struct dxf_price_level_book_data_t:
    dxf_const_string_t symbol,

    size_t bids_count,
    const dxf_price_level_element_t* bids,

    size_t asks_count,
    const dxf_price_level_element_t* asks,
cdef dxf_price_level_book_data_t dxf_price_level_book_data
ctypedef dxf_price_level_book_data_t *dxf_price_level_book_data_ptr_t

# /**
#  * @ingroup c-api-price-level-book
#  *
#  * @brief Price Level listener prototype
#  *
#  *  @param[in] book      Pointer to the received price book data.
#  *                       bids and asks are sorted by price,
#  *                       best bid (with largest price) and best ask
#  *                       (with smallest price) are first elements
#  *                       of corresponding arrays.
#  *  @param[in] user_data Pointer to user struct, use NULL by default
#  */
ctypedef void (*dxf_price_level_book_listener_t)(const dxf_price_level_book_data_ptr_t book, void* user_data)

# /**
#  * @ingroup c-api-regional-book
#  *
#  * @brief Regional quote listener prototype
#  *
#  * @param[in] quote     Pointer to the received regional quote
#  * @param[in] user_data Pointer to user struct, use NULL by default
#  */
ctypedef void (*dxf_regional_quote_listener_t)(dxf_const_string_t symbol, const dxf_quote_t* quotes, int count,
                                               void* user_data)

# /* -------------------------------------------------------------------------- */
# // Event data navigation functions
# /* -------------------------------------------------------------------------- */

#ifdef __cplusplus
# extern "C"
# cdef extern from "C":
#endif
    # /**
    #  * @ingroup c-api-event-listener-functions
    #  *
    #  * @brief  Get event data item from event data
    #  *
    #  * @param event_mask Event mask
    #  * @param data       Event data
    #  * @param index      Event data item index
    #  * @return Event data item
    #  */
    # dxf_const_event_data_t
cdef dx_get_event_data_item(int event_mask, dxf_const_event_data_t data, size_t index)

# /* -------------------------------------------------------------------------- */
# // Various event functions
# /* -------------------------------------------------------------------------- */

# /**
#  * @ingroup c-api-event-listener-functions
#  *
#  * @brief Converts event type code to its string representation
#  *
#  * @param event_type Event type code
#  *
#  * @return String representation of event type
#  */
# DXFEED_API dxf_const_string_t dx_event_type_to_string(int event_type)
cdef dxf_const_string_t dx_event_type_to_string(int event_type)

# /**
#  * @ingroup c-api-event-listener-functions
#  *
#  * @brief Get event data structure size for given event id
#  *
#  * @param event_id Event id
#  *
#  * @return Data structure size
#  */
cdef int dx_get_event_data_struct_size(int event_id)

# /**
#  * @ingroup c-api-event-listener-functions
#  *
#  * @brief Get event id by event bitmask
#  *
#  * @param event_bitmask Event bitmask
#  *
#  * @return Event id
#  */
cdef dx_event_id_t dx_get_event_id_by_bitmask(int event_bitmask)

#endif /* EVENT_DATA_H_INCLUDED */