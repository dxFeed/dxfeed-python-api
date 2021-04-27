# /*
#  * The contents of this file are subject to the Mozilla Public License Version
#  * 1.1 (the "License"); you may not use this file except in compliance with
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

# /**
#  * @file
#  * @brief dxFeed C API functions declarations
#  */

# /**
#  * @defgroup functions Functions
#  * @brief DXFeed C API functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup functions-macros Defined macros
#  * @brief macros
#  */
# /**
#  * @ingroup functions
#  * @defgroup callback-types API Events' Callbacks
#  * @brief Event callbacks
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-event-listener-functions Listeners
#  * @brief API event listeners management functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-common Common functions
#  * @brief Common API functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-connection-functions Connections
#  * @brief Connection establishment/teardown functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-basic-subscription-functions Subscriptions
#  * @brief Subscription initiation/closing functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-symbol-subscription-functions Symbols
#  * @brief Symbol-related functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-orders Orders
#  * @brief Order-related functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-candle-attributes Candle symbol attributes
#  * @brief Candle attributes manipulation functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-snapshots Snapshots
#  * @brief Snapshot functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-price-level-book Price level books
#  * @brief Price level book functions
#  */
# /**
#  * @ingroup functions
#  * @defgroup c-api-regional-book Regional books
#  * @brief Regional book functions
#  */
# /**
# * @ingroup functions
# * @defgroup c-api-config Config
# * @brief Config functions
# */

#ifndef DXFEED_API_H_INCLUDED
#define DXFEED_API_H_INCLUDED

#include "DXTypes.h"
from dxfeed.core.pxd_include.DXTypes cimport *
#include "EventData.h"
from dxfeed.core.pxd_include.EventData cimport *

# /* -------------------------------------------------------------------------- */
# /*
#  *	DXFeed API function return value codes
#  */
# /* -------------------------------------------------------------------------- */

# /**
#  * @ingroup  functions-macros
#  * @brief Successful API call
#  * @details The value is returned on successful API call
#  */
#define DXF_SUCCESS 1
DEF DXF_SUCCESS = 1
cdef int DXF_SUCCESS = 1
# /**
#  * @ingroup functions-macros
#  * @brief Failed API call
#  * @details The value is returned on failed API call
#  */
#define DXF_FAILURE 0
DEF DXF_FAILURE = 0

# /* -------------------------------------------------------------------------- */
# /*
#  *	DXFeed API generic types
#  */
# /* -------------------------------------------------------------------------- */
cdef extern from "DXFeed.h":
    # /**
    #  * @ingroup callback-types
    #  *
    #  * @brief Connection termination notification callback type
    #  *
    #  * @details Called whenever connection to dxFeed servers terminates
    #  */
    ctypedef void (*dxf_conn_termination_notifier_t) (dxf_connection_t connection, void* user_data)
    
    # /**
    # * @ingroup callback-types
    # *
    # * @brief Connection Status notification callback type
    # *
    # * @details Called whenever connection status to dxFeed servers changes
    # */
    ctypedef void (*dxf_conn_status_notifier_t) (dxf_connection_t connection,
                                                dxf_connection_status_t old_status,
                                                dxf_connection_status_t new_status,
                                                void* user_data)
    
    # /**
    # * @ingroup callback-types
    # *
    # * @brief The callback type of a connection incoming heartbeat notification
    # *
    # * @details Called when a server heartbeat arrives and contains non empty payload
    # *
    # * Parameters:
    # *  - connection      - The connection handle
    # *  - server_millis   - The server time in milliseconds (from the incoming heartbeat payload)
    # *  - server_lag_mark - The server's messages composing lag time in microseconds (from the incoming heartbeat payload)
    # *  - connection_rtt  - The calculated connection RTT in microseconds
    # *  - user_data       - The user data passed to dxf_set_on_server_heartbeat_notifier
    # *
    # *  An example of implementation:
    # *
    # *  ```c
    # *  void on_server_heartbeat_notifier(dxf_connection_t connection, dxf_long_t server_millis, dxf_int_t server_lag_mark,
    # *      dxf_int_t connection_rtt, void* user_data)
    # *  {
    # *      fwprintf(stderr, L"\n##### Server time (UTC) = %" PRId64 " ms, Server lag = %d us, RTT = %d us #####\n",
    # *          server_millis, server_lag_mark, connection_rtt);
    # *  }
    # *  ```
    # */
    ctypedef void (*dxf_conn_on_server_heartbeat_notifier_t)(dxf_connection_t connection, dxf_long_t server_millis,
                                                            dxf_int_t server_lag_mark, dxf_int_t connection_rtt,
                                                            void* user_data)
    
    # /* the low level callback types, required in case some thread-specific initialization must be performed
    #    on the client side on the thread creation/destruction */
    # /**
    # * @ingroup callback-types
    # *
    # * @brief The low level callback type, required in case some thread-specific initialization must be performed
    # *        on the client side on the thread creation/destruction
    # *
    # * @details Called whenever connection thread is being created
    # */
    ctypedef int (*dxf_socket_thread_creation_notifier_t) (dxf_connection_t connection, void* user_data)
    
    # /**
    # * @ingroup callback-types
    # *
    # * @brief The low level callback type, required in case some thread-specific initialization must be performed
    # *        on the client side on the thread creation/destruction
    # *
    # * @details Called whenever connection thread is being terminated
    # */
    ctypedef void (*dxf_socket_thread_destruction_notifier_t) (dxf_connection_t connection, void* user_data)
    
    # /* -------------------------------------------------------------------------- */
    # /*
    # *	DXFeed C API functions
     
    # *  All functions return DXF_SUCCESS on success and DXF_FAILURE if some error
    # *  has occurred. Use 'dxf_get_last_error' to retrieve the error code
    # *  and description.
    # */
    # /* -------------------------------------------------------------------------- */
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Creates connection with the specified parameters.
    # *
    # * @details
    # *
    # * @param[in] address              Connection string
    # *                                   - the single address: ```host:port``` or just ```host```
    # *                                   - address with credentials: ```host:port[username=xxx,password=yyy]```
    # *                                   - multiple addresses: ```(host1:port1)(host2)(host3:port3[username=xxx,password=yyy])```
    # *                                   - the data from file: ```/path/to/file``` on *nix and ```drive:\path\to\file```
    # *                                     on Windows
    # * @param[in] notifier             The callback to inform the client side that the connection has stumbled upon and
    # *                                 error and will go reconnecting
    # * @param[in] conn_status_notifier The callback to inform the client side that the connection status has changed
    # * @param[in] stcn                 The callback for informing the client side about the socket thread creation;
    # *                                 may be set to NULL if no specific action is required to perform on the client side
    # *                                 on a new thread creation
    # * @param[in] stdn                 The callback for informing the client side about the socket thread destruction;
    # *                                 may be set to NULL if no specific action is required to perform on the client side
    # *                                 on a thread destruction
    # * @param[in] user_data            The user defined value passed to the termination notifier callback along with the
    # *                                 connection handle; may be set to whatever value
    # * @param[out] connection          The handle of the created connection
    # *
    # * @return DXF_SUCCESS on successful connection establishment or DXF_FAILURE on error.
    # *         Created connection is returned via OUT parameter ```connection```.
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure.
    # */
    ERRORCODE dxf_create_connection(const char* address, dxf_conn_termination_notifier_t notifier,
                                    dxf_conn_status_notifier_t conn_status_notifier,
                                    dxf_socket_thread_creation_notifier_t stcn,
                                    dxf_socket_thread_destruction_notifier_t stdn, void* user_data,
                                    dxf_connection_t* connection)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Creates connection with the specified parameters and basic authorization.
    # *
    # * @details
    # *
    # * @param[in] address              Connection string
    # *                                   - the single address: ```host:port``` or just ```host```
    # *                                   - address with credentials: ```host:port[username=xxx,password=yyy]```
    # *                                   - multiple addresses: ```(host1:port1)(host2)(host3:port3[username=xxx,password=yyy])```
    # *                                   - the data from file: ```/path/to/file``` on *nix and ```drive:\path\to\file```
    # *                                     on Windows
    # * @param[in] user                 The user name;
    # * @param[in] password             The user password;
    # * @param[in] notifier             The callback to inform the client side that the connection has stumbled upon and
    # *                                 error and will go reconnecting
    # * @param[in] conn_status_notifier The callback to inform the client side that the connection status has changed
    # * @param[in] stcn                 The callback for informing the client side about the socket thread creation;
    # *                                 may be set to NULL if no specific action is required to perform on the client side
    # *                                 on a new thread creation
    # * @param[in] stdn                 The callback for informing the client side about the socket thread destruction;
    # *                                 may be set to NULL if no specific action is required to perform on the client side
    # *                                 on a thread destruction;
    # * @param[in] user_data            The user defined value passed to the termination notifier callback along with the
    # *                                 connection handle; may be set to whatever value;
    # * @param[out] connection          The handle of the created connection.
    # *
    # * @return {@link DXF_SUCCESS} on successful connection establishment or {@link DXF_FAILURE} on error;
    # *         created connection is returned via OUT parameter *connection*;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure.
    # *
    # * @warning The user and password data from argument have a higher priority than address credentials.
    # */
    ERRORCODE dxf_create_connection_auth_basic(const char* address, const char* user, const char* password,
                                               dxf_conn_termination_notifier_t notifier,
                                               dxf_conn_status_notifier_t conn_status_notifier,
                                               dxf_socket_thread_creation_notifier_t stcn,
                                               dxf_socket_thread_destruction_notifier_t stdn, void* user_data,
                                               dxf_connection_t* connection)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Creates connection with the specified parameters and token authorization.
    # *
    # * @details
    # *
    # * @param[in] address              Connection string
    # *                                   - the single address: "host:port" or just "host"
    # *                                   - address with credentials: "host:port[username=xxx,password=yyy]"
    # *                                   - multiple addresses: "(host1:port1)(host2)(host3:port3[username=xxx,password=yyy])"
    # *                                   - the data from file: "/path/to/file" on *nix and "drive:\path\to\file" on Windows
    # * @param[in] token                The authorization token;
    # * @param[in] notifier             The callback to inform the client side that the connection has stumbled upon and
    # *                                 error and will go reconnecting
    # * @param[in] conn_status_notifier The callback to inform the client side that the connection status has changed
    # * @param[in] stcn                 The callback for informing the client side about the socket thread creation;
    # *                                 may be set to NULL if no specific action is required to perform on the client side
    # *                                 on a new thread creation
    # * @param[in] stdn                 The callback for informing the client side about the socket thread destruction;
    # *                                 may be set to NULL if no specific action is required to perform on the client side
    # *                                 on a thread destruction;
    # * @param[in] user_data            The user defined value passed to the termination notifier callback along with the
    # *                                 connection handle; may be set to whatever value;
    # * @param[out] connection          The handle of the created connection.
    # *
    # * @return {@link DXF_SUCCESS} on successful connection establishment or {@link DXF_FAILURE} on error;
    # *         created connection is returned via OUT parameter *connection*;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure.
    # *
    # * @warning The token data from argument have a higher priority than address credentials
    # */
    ERRORCODE dxf_create_connection_auth_bearer(const char* address,
                                                           const char* token,
                                                           dxf_conn_termination_notifier_t notifier,
                                                           dxf_conn_status_notifier_t conn_status_notifier,
                                                           dxf_socket_thread_creation_notifier_t stcn,
                                                           dxf_socket_thread_destruction_notifier_t stdn,
                                                           void* user_data,
                                                           dxf_connection_t* connection)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Creates connection with the specified parameters and custom described authorization.
    # *
    # * @details
    # *
    # * @param[in] address              Connection string
    # *                                   - the single address: ```host:port``` or just ```host```
    # *                                   - address with credentials: ```host:port[username=xxx,password=yyy]```
    # *                                   - multiple addresses: ```(host1:port1)(host2)(host3:port3[username=xxx,password=yyy])```
    # *                                   - the data from file: ```/path/to/file``` on *nix and ```drive:\path\to\file```
    # *                                     on Windows
    # * @param[in] authscheme           The authorization scheme
    # * @param[in] authdata             The authorization data
    # * @param[in] notifier             The callback to inform the client side that the connection has stumbled upon and
    # *                                 error and will go reconnecting
    # * @param[in] conn_status_notifier The callback to inform the client side that the connection status has changed
    # * @param[in] stcn                 The callback for informing the client side about the socket thread creation;
    #                                    may be set to NULL if no specific action is required to perform on the client side
    #                                    on a new thread creation
    # * @param[in] stdn                 The callback for informing the client side about the socket thread destruction;
    #                                    may be set to NULL if no specific action is required to perform on the client side
    #                                    on a thread destruction;
    # * @param[in] user_data            The user defined value passed to the termination notifier callback along with the
    # *                                 connection handle; may be set to whatever value;
    # * @param[out] connection          The handle of the created connection.
    # *
    # * @return {@link DXF_SUCCESS} on successful connection establishment or {@link DXF_FAILURE} on error;
    # *         created connection is returned via OUT parameter *connection*;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure.
    # *
    # * @warning The authscheme and authdata from argument have a higher priority than address credentials.
    # */
    ERRORCODE dxf_create_connection_auth_custom(const char* address,
                                                           const char* authscheme,
                                                           const char* authdata,
                                                           dxf_conn_termination_notifier_t notifier,
                                                           dxf_conn_status_notifier_t conn_status_notifier,
                                                           dxf_socket_thread_creation_notifier_t stcn,
                                                           dxf_socket_thread_destruction_notifier_t stdn,
                                                           void* user_data,
                                                           dxf_connection_t* connection)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Sets a server heartbeat notifier's callback to the connection.
    # *
    # * @details This notifier will be invoked when the new heartbeat arrives from a server and contains non empty payload
    # *
    # * @param[in] connection  The handle of a previously created connection
    # * @param[in] notifier    The notifier callback function pointer
    # * @param[in] user_data   The data to be passed to the callback function
    # *
    # * @return {@link DXF_SUCCESS} on successful set of the heartbeat notifier's or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_set_on_server_heartbeat_notifier(dxf_connection_t connection,
                                                              dxf_conn_on_server_heartbeat_notifier_t notifier,
                                                              void* user_data)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Closes a connection
    # *
    # * @details
    # *
    # * @param[in] connection A handle of a previously created connection
    # *
    # * @return {@link DXF_SUCCESS} on successful connection closure or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure.
    # */
    ERRORCODE dxf_close_connection (dxf_connection_t connection)
    
    # /**
    # * @ingroup c-api-basic-subscription-functions
    # *
    # * @brief Creates a subscription with the specified parameters.
    # *
    # * @details
    # *
    # * @param[in] connection    A handle of a previously created connection which the subscription will be using
    # * @param[in] event_types   A bitmask of the subscription event types. See {@link dx_event_id_t} and
    # *                          {@link DX_EVENT_BIT_MASK} for information on how to create an event type bitmask
    # * @param[out] subscription A handle of the created subscription
    # *
    # * @return {@link DXF_SUCCESS} on successful subscription creation or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         a handle to newly created subscription is returned via ```subscription``` out parameter
    # */
    ERRORCODE dxf_create_subscription (dxf_connection_t connection, int event_types,
                                                  dxf_subscription_t* subscription)
    
    # /**
    # * @ingroup c-api-basic-subscription-functions
    # *
    # * @brief Creates a subscription with the specified parameters and the subscription flags.
    # *
    # * @details
    # *
    # * @param[in] connection    A handle of a previously created connection which the subscription will be using
    # * @param[in] event_types   A bitmask of the subscription event types. See {@link dx_event_id_t} and
    # *                          {@link DX_EVENT_BIT_MASK} for information on how to create an event type bitmask
    # * @param[in] subscr_flags  A bitmask of the subscription event flags. See {@link dx_event_subscr_flag}
    # * @param[out] subscription A handle of the created subscription
    # *
    # * @return {@link DXF_SUCCESS} on successful subscription creation or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         a handle to newly created subscription is returned via ```subscription``` out parameter
    # */
    ERRORCODE dxf_create_subscription_with_flags(dxf_connection_t connection, int event_types,
                                                            dx_event_subscr_flag subscr_flags,
                                                            dxf_subscription_t* subscription)
    
    # /**
    # * @ingroup c-api-basic-subscription-functions
    # *
    # * @brief Creates a timed subscription with the specified parameters.
    # *
    # * @details
    # *
    # * @param[in] connection    A handle of a previously created connection which the subscription will be using
    # * @param[in] event_types   A bitmask of the subscription event types. See {@link dx_event_id_t} and
    # *                          {@link DX_EVENT_BIT_MASK} for information on how to create an event type bitmask
    # * @param[in] time          UTC time in the past (unix time in milliseconds)
    # * @param[out] subscription A handle of the created subscription
    # *
    # * @return {@link DXF_SUCCESS} on successful subscription creation or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         a handle to newly created subscription is returned via ```subscription``` out parameter
    # */
    ERRORCODE dxf_create_subscription_timed(dxf_connection_t connection, int event_types, 
                                                       dxf_long_t time,
                                                       dxf_subscription_t* subscription)
    
    # /**
    # * @ingroup c-api-basic-subscription-functions
    # *
    # * @brief Creates a timed subscription with the specified parameters and the subscription flags.
    # *
    # * @details
    # *
    # * @param[in] connection    A handle of a previously created connection which the subscription will be using
    # * @param[in] event_types   A bitmask of the subscription event types. See {@link dx_event_id_t} and
    # *                          {@link DX_EVENT_BIT_MASK} for information on how to create an event type bitmask
    # * @param[in] time          UTC time in the past (unix time in milliseconds)
    # * @param[in] subscr_flags  A bitmask of the subscription event flags. See {@link dx_event_subscr_flag}
    # * @param[out] subscription A handle of the created subscription
    # *
    # * @return {@link DXF_SUCCESS} on successful subscription creation or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         a handle to newly created subscription is returned via ```subscription``` out parameter
    # */
    ERRORCODE dxf_create_subscription_timed_with_flags(dxf_connection_t connection, int event_types,
                                                                  dxf_long_t time, dx_event_subscr_flag subscr_flags,
                                                                  dxf_subscription_t* subscription)
    
    # /**
    # * @ingroup c-api-basic-subscription-functions
    # *
    # * @brief Closes a subscription.
    # *
    # * @details All the data associated with it will be disposed. As a side-effect, API error is reset.
    # *
    # * @param[in] subscription A handle of the subscription to close
    # *
    # * @return {@link DXF_SUCCESS} on successful subscription closure or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_close_subscription (dxf_subscription_t subscription)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Adds a single symbol to the subscription.
    # *
    # * @details A wildcard symbol "*" will replace all symbols: there will be an unsubscription from messages on all
    # *          current symbols and a subscription to "*". The subscription type will be changed to dx_st_stream.
    # *          If there is already a subscription to "*", then nothing will happen
    # *
    # * @param[in] subscription A handle of the subscription to which a symbol is added
    # * @param[in] symbol       The symbol to add
    # *
    # * @return {@link DXF_SUCCESS} if the operation succeed or {@link DXF_FAILURE} if the operation fails. The error code
    # * can be obtained using the function {@link dxf_get_last_error}
    # */
    ERRORCODE dxf_add_symbol (dxf_subscription_t subscription, dxf_const_string_t symbol)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Adds several symbols to the subscription.
    # *
    # * @details No error occurs if the symbol is attempted to add for the second time.
    # *          Empty symbols will be ignored. First met the "*" symbol (wildcard) will overwrite all other symbols:
    # *          there will be an unsubscription from messages on all current symbols and a subscription to "*". The
    # *          subscription type will be changed to dx_st_stream. If there is already a subscription to "*",
    # *          then nothing will happen.
    # *
    # * @param[in] subscription A handle of the subscription to which the symbols are added
    # * @param[in] symbols      The symbols to add
    # * @param[in] symbol_count A number of symbols
    # *
    # * @return {@link DXF_SUCCESS} if the operation succeed or {@link DXF_FAILURE} if the operation fails. The error code
    # * can be obtained using the function {@link dxf_get_last_error}
    # */
    ERRORCODE dxf_add_symbols (dxf_subscription_t subscription, dxf_const_string_t* symbols, int symbol_count)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Adds a candle symbol to the subscription.
    # *
    # * @details
    # *
    # * @param subscription      A handle of the subscription to which a symbol is added
    # * @param candle_attributes Pointer to the candle struct
    # *
    # * @return {@link DXF_SUCCESS} on successful symbol addition or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_add_candle_symbol(dxf_subscription_t subscription, dxf_candle_attributes_t candle_attributes)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Remove a candle symbol from the subscription.
    # *
    # * @details
    # *
    # * @param[in] subscription       a handle of the subscription from symbol will be removed
    # * @param[in] candle_attributes  pointer to the candle structure
    # *
    # * @return  {@link DXF_SUCCESS} on successful symbol removal or {@link DXF_FAILURE} on error;
    # *          {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_remove_candle_symbol(dxf_subscription_t subscription, dxf_candle_attributes_t candle_attributes)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Removes a single symbol from the subscription.
    # *
    # * @details A wildcard symbol "*" will remove all symbols: there will be an unsubscription from messages on all current
    # *          symbols. If there is already a subscription to "*" and the @a symbol to remove is not a "*", then nothing
    # *          will happen.
    # *
    # * @param[in] subscription A handle of the subscription from which a symbol is removed
    # * @param[in] symbol       The symbol to remove
    # *
    # * @return {@link DXF_SUCCESS} if the operation succeed or {@link DXF_FAILURE} if the operation fails. The error code
    # *         can be obtained using the function {@link dxf_get_last_error}
    # */
    ERRORCODE dxf_remove_symbol (dxf_subscription_t subscription, dxf_const_string_t symbol)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Removes several symbols from the subscription.
    # *
    # * @details No error occurs if it's attempted to remove symbols that weren't added beforehand. First met the "*" symbol
    # *          (wildcard) will remove all symbols: there will be an unsubscription from messages on all current symbols.
    # *          If there is already a subscription to "*" and the @a symbols to remove are not contain a "*", then nothing
    # *          will happen.
    # *
    # * @param[in] subscription A handle of the subscription from which symbols are removed
    # * @param[in] symbols      The symbols to remove
    # * @param[in] symbol_count A number of symbols
    # *
    # * @return {@link DXF_SUCCESS} if the operation succeed or {@link DXF_FAILURE} if the operation fails. The error code
    # *         can be obtained using the function {@link dxf_get_last_error}
    # */
    ERRORCODE dxf_remove_symbols (dxf_subscription_t subscription, dxf_const_string_t* symbols, int symbol_count)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Retrieves the list of symbols currently added to the subscription.
    # *
    # * @details The memory for the resulting list is allocated internally, so no actions to free it are required.
    # *          The symbol name buffer is guaranteed to be valid until either the subscription symbol list is changed or
    # *          a new call of this function is performed.
    # *
    # * @param[in] subscription  A handle of the subscriptions whose symbols are to retrieve
    # * @param[out] symbols      A pointer to the string array object to which the symbol list is to be stored
    # * @param[out] symbol_count A pointer to the variable to which the symbol count is to be stored
    # *
    # * @return {@link DXF_SUCCESS} on successful symbols retrieval or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_get_symbols (dxf_subscription_t subscription, dxf_const_string_t** symbols, int* symbol_count)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Sets the symbols for the subscription.
    # *
    # * @details The difference between this function and {@link dxf_add_symbols} is that all the previously added symbols
    # *          that do not belong to the symbol list passed to this function will be removed.
    # *
    # * @param[in] subscription A handle of the subscription whose symbols are to be set
    # * @param[in] symbols      The symbol list to set
    # * @param[in] symbol_count The symbol count
    # *
    # * @return {@link DXF_SUCCESS} if the operation succeed or {@link DXF_FAILURE} if the operation fails. The error code
    # *         can be obtained using the function {@link dxf_get_last_error}
    # */
    ERRORCODE dxf_set_symbols (dxf_subscription_t subscription, dxf_const_string_t* symbols, int symbol_count)
    
    # /**
    # * @ingroup c-api-symbol-subscription-functions
    # *
    # * @brief Removes all the symbols from the subscription.
    # *
    # * @details
    # *
    # * @param[in] subscription A handle of the subscription whose symbols are to be cleared
    # *
    # * @return {@link DXF_SUCCESS} if the operation succeed or {@link DXF_FAILURE} if the operation fails. The error code
    # *         can be obtained using the function {@link dxf_get_last_error}
    # */
    ERRORCODE dxf_clear_symbols (dxf_subscription_t subscription)
    
    # /**
    # * @ingroup c-api-event-listener-functions
    # *
    # * @brief Attaches a listener callback to the subscription.
    # *
    # * @details This callback will be invoked when the new event data for the subscription symbols arrives.
    # *          No error occurs if it's attempted to attach the same listener twice or more.
    
    # * @param[in] subscription   A handle of the subscription to which a listener is to be attached
    # * @param[in] event_listener A listener callback function pointer
    # * @param[in] user_data      Data to be passed to the callback function
    # *
    # * @return {@link DXF_SUCCESS} on successful event listener attachment or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_attach_event_listener (dxf_subscription_t subscription, dxf_event_listener_t event_listener,
                                                    void* user_data)
    
    # /**
    # * @ingroup c-api-event-listener-functions
    # *
    # * @brief Detaches a listener from the subscription.
    # *
    # * @details No error occurs if it's attempted to detach a listener which wasn't previously attached.
    # *
    # * @param[in] subscription   A handle of the subscription from which a listener is to be detached
    # * @param[in] event_listener A listener callback function pointer
    # *
    # * @return {@link DXF_SUCCESS} on successful event listener detachment or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_detach_event_listener (dxf_subscription_t subscription, dxf_event_listener_t event_listener)
    
    # /**
    # * @ingroup c-api-event-listener-functions
    # *
    # * @brief Attaches a extended listener callback to the subscription.
    # *
    # * @details This callback will be invoked when the new event data for the subscription symbols arrives.
    # *          No error occurs if it's attempted to attach the same listener twice or more.
    # *          This listener differs with extend number of callback parameters.
    # *
    # * @param[in] subscription   A handle of the subscription to which a listener is to be attached
    # * @param[in] event_listener A listener callback function pointer
    # * @param[in] user_data      Data to be passed to the callback function; if there isn't user data pass NULL
    # *
    # * @return {@link DXF_SUCCESS} on successful event listener attachment or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_attach_event_listener_v2(dxf_subscription_t subscription, 
                                                      dxf_event_listener_v2_t event_listener,
                                                      void* user_data)
    
    # /**
    # * @ingroup c-api-event-listener-functions
    # *
    # * @brief Detaches a extended listener from the subscription.
    # *
    # * @details No error occurs if it's attempted to detach a listener which wasn't previously attached.
    # *
    # * @param[in] subscription   A handle of the subscription from which a listener is to be detached
    # * @param[in] event_listener A listener callback function pointer
    # *
    # * @return {@link DXF_SUCCESS} on successful event listener detachment or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_detach_event_listener_v2(dxf_subscription_t subscription, 
                                                      dxf_event_listener_v2_t event_listener)
    
    # /**
    # * @ingroup c-api-event-listener-functions
    # *
    # * @brief Retrieves the subscription event types.
    # *
    # * @details
    # *
    # * @param[in] subscription A handle of the subscription whose event types are to be retrieved
    # * @param[out] event_types A pointer to the variable to which the subscription event types bitmask is to be stored
    # *
    # * @return {@link DXF_SUCCESS} on successful event types retrieval or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_get_subscription_event_types (dxf_subscription_t subscription, int* event_types)
    
    # /**
    # * @ingroup c-api-event-listener-functions
    # *
    # * @brief Retrieves the last event data of the specified symbol and type for the connection.
    # *
    # * @details
    # *
    # * @param[in] connection  A handle of the connection whose data is to be retrieved
    # * @param[in] event_type  An event type bitmask defining a single event type
    # * @param[in] symbol      A symbol name
    # * @param[out] event_data A pointer to the variable to which the last data buffer pointer is stored; if there was no
    # *                        data for this connection/event type/symbol, NULL will be stored
    # *
    # * @return {@link DXF_SUCCESS} on successful event retrieval or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_get_last_event (dxf_connection_t connection, int event_type, dxf_const_string_t symbol,
                                             dxf_event_data_t* event_data)
    # /**
    # * @ingroup c-api-common
    # *
    # * @brief Retrieves the last error info.
    # *
    # *
    # * @details The error is stored on per-thread basis. If the connection termination notifier callback was invoked, then
    # *          to retrieve the connection's error code call this function right from the callback function.
    # *          If an error occurred within the error storage subsystem itself, the function will return DXF_FAILURE.
    # *
    # * @param[out] error_code  A pointer to the variable where the error code is to be stored
    # * @param[out] error_descr A pointer to the variable where the human-friendly error description is to be stored;
    # *                         may be NULL if the text representation of error is not required
    # * @return {@link DXF_SUCCESS} on successful error retrieval or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         @a error_code and @a error_descr are returned as output parameters of this function
    # */
    ERRORCODE dxf_get_last_error (int* error_code, dxf_const_string_t* error_descr)
    
    # /**
    # * @ingroup c-api-common
    # *
    # * @brief Initializes the internal logger.
    # *
    # * @details Various actions and events, including the errors, are being logged
    # *          throughout the library. They may be stored into the file.
    # *
    # * @param[in] file_name          A full path to the file where the log is to be stored
    # * @param[in] rewrite_file       A flag defining the file open mode; if it's nonzero then the log file will be rewritten
    # * @param[in] show_timezone_info A flag defining the time display option in the log file; if it's nonzero then
    # *                               the time will be displayed with the timezone suffix
    # * @param[in] verbose            A flag defining the logging mode; if it's nonzero then the verbose logging will be
    # *                               enabled
    # *
    # * @return {@link DXF_SUCCESS} on successful logger initialization or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_initialize_logger(const char* file_name, int rewrite_file, int show_timezone_info, int verbose)
    
    # /**
    # * @ingroup c-api-common
    # *
    # * @brief Initializes the internal logger with data transfer logging.
    # *
    # * @details Various actions and events, including the errors, are being logged
    # *          throughout the library. They may be stored into the file.
    # *
    # * @param[in] file_name          A full path to the file where the log is to be stored
    # * @param[in] rewrite_file       A flag defining the file open mode; if it's nonzero then the log file will be rewritten
    # * @param[in] show_timezone_info A flag defining the time display option in the log file; if it's nonzero then
    # *                               the time will be displayed with the timezone suffix
    # * @param[in] verbose            A flag defining the logging mode; if it's nonzero then the verbose logging will be
    # *                               enabled
    # * @param[in] log_data_transfer  A flag defining the logging mode; if it's nonzero then the data transfer (portions of
    # *                               received and sent data) logging will be enabled
    # *
    # * @return {@link DXF_SUCCESS} on successful logger initialization or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_initialize_logger_v2(const char* file_name, int rewrite_file, int show_timezone_info, int verbose, int log_data_transfer)
    
    # /**
    # * @ingroup c-api-orders
    # *
    # * @brief Clear current sources and add new one to subscription
    # *
    # * @details
    # *
    # * @warning You must configure order source before {@link dxf_add_symbols}/{@link dxf_add_symbol} call
    # *
    # * @param[in] subscription A handle of the subscription where source will be changed
    # * @param[in] source       Source of order to set, 4 symbols maximum length
    # *
    # * @return {@link DXF_SUCCESS} on order source setup or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_set_order_source(dxf_subscription_t subscription, const char* source)
    
    # /**
    # * @ingroup c-api-orders
    # *
    # * @brief Add a new source to subscription
    # *
    # * @details
    # *
    # * @warning You must configure order source before {@link dxf_add_symbols}/{@link dxf_add_symbol} call
    # *
    # * @param[in] subscription A handle of the subscription where source will be changed
    # * @param[in] source       Source of order event to add, 4 symbols maximum length
    # *
    # * @return {@link DXF_SUCCESS} if order has been successfully added or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_add_order_source(dxf_subscription_t subscription, const char* source)
    
    # /**
    # * @ingroup c-api-candle-attributes
    # *
    # * @brief API that allows user to create candle symbol attributes
    # *
    # * @details
    # *
    # * @param[in] base_symbol        The symbols to add
    # * @param[in] exchange_code      Exchange attribute of this symbol
    # * @param[in] period_value       Aggregation period value of this symbol
    # * @param[in] period_type        Aggregation period type of this symbol
    # * @param[in] price              Price ("price" key) type attribute of this symbol. The dxf_candle_price_attribute_t
    # *                               enum defines possible values with dxf_cpa_last being default. For legacy
    # *                               backwards-compatibility purposes, most of the price values cannot be abbreviated, so a
    # *                               one-minute candle of "EUR/USD" bid price shall be specified with
    # *                               ```EUR/USD{=m,price=bid}``` candle symbol string. However, the dxf_cpa_settlement can
    # *                               be abbreviated to "s", so a daily candle on "/ES" futures settlement prices can be
    # *                               specified with ```/ES{=d,price=s}``` string.
    # * @param[in] session            Session ("tho" key) attribute of this symbol. "tho" key with a value of "true"
    # *                               corresponds to session set to dxf_csa_regular which limits the candle to trading hours
    # *                               only, so a 133 tick candles on "GOOG" base symbol collected over trading hours only
    # *                               can be specified with ```GOOG{=133t,tho=true}``` string. Note, that the default daily
    # *                               candles for US equities are special for historical reasons and correspond to the way
    # *                               US equity exchange report their daily summary data. The volume the US equity default
    # *                               daily candle corresponds to the total daily traded volume, while open, high, low,
    # *                               and close correspond to the regular trading hours only.
    # * @param[in] alignment          Alignment ("a" key) attribute of this symbol. The dxf_candle_alignment_attribute_t
    # *                               enum defines possible values with dxf_caa_midnight being default. The alignment
    # *                               values can be abbreviated to the first letter. So, a 1 hour candle on a symbol "AAPL"
    # *                               that starts at the regular trading session at 9:30 am ET can be specified with
    # *                               ```AAPL{=h,a=s,tho=true}```. Contrast that to the ```AAPL{=h,tho=true}``` candle that
    # *                               is aligned at midnight and thus starts at 9:00 am.
    # * @param[in] price_level        Price level ("pl" key) attribute of this symbol. The candle price level defines
    # *                               additional axis to split candles within particular price corridor in addition to
    # *                               candle period attribute with the default value NAN. So a one-minute candles of "AAPL"
    # *                               with price level 0.1 shall be specified with ```AAPL{=m,pl=0.1}```.
    # * @param[out] candle_attributes Pointer to the configured candle attributes struct
    # *
    # * \return {@link DXF_SUCCESS} if candle attributes have been created successfully or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         *candle_attributes* are returned via output parameter
    # */
    ERRORCODE dxf_create_candle_symbol_attributes(dxf_const_string_t base_symbol,
                                                             dxf_char_t exchange_code,
                                                             dxf_double_t period_value,
                                                             dxf_candle_type_period_attribute_t period_type,
                                                             dxf_candle_price_attribute_t price,
                                                             dxf_candle_session_attribute_t session,
                                                             dxf_candle_alignment_attribute_t alignment,
                                                             dxf_double_t price_level,
                                                             dxf_candle_attributes_t* candle_attributes)
    
    # /**
    # * @ingroup c-api-candle-attributes
    # *
    # * @brief Free memory allocated by dxf_initialize_candle_symbol_attributes(...) function
    # *
    # * @details
    # *
    # * @param[in] candle_attributes Pointer to the candle attributes struct
    # */
    ERRORCODE dxf_delete_candle_symbol_attributes(dxf_candle_attributes_t candle_attributes)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Creates snapshot with the specified parameters.
    # *
    # * @details
    # *          For Order or Candle events (dx_eid_order or dx_eid_candle) please use
    # *          short form of this function: dxf_create_order_snapshot or dxf_create_candle_snapshot respectively.
    # *
    # *          For order events (event_id is 'dx_eid_order')
    # *          If source is NULL string subscription on Order event will be performed. You can specify order
    # *          source for Order event by passing suffix: "BYX", "BZX", "DEA", "DEX", "ISE", "IST", "NTV" etc.
    # *          If source is equal to "AGGREGATE_BID" or "AGGREGATE_ASK" subscription on MarketMaker event will
    # *          be performed. For other events source parameter does not matter.
    # *
    # * @param[in] connection A handle of a previously created connection which the subscription will be using
    # * @param[in] event_id   Single event id. Next events is supported: dxf_eid_order, dxf_eid_candle,
    # *                       dx_eid_spread_order, dx_eid_time_and_sale, dx_eid_greeks, dx_eid_series.
    # * @param[in] symbol     The symbol to add.
    # * @param[in] source     Order source for Order, which can be one of following: "NTV", "ntv", "NFX", "ESPD", "XNFI",
    # *                       "ICE", "ISE", "DEA", "DEX", "BYX", "BZX", "BATE", "CHIX", "CEUX", "BXTR", "IST", "BI20",
    # *                       "ABE", "FAIR", "GLBX", "glbx", "ERIS", "XEUR", "xeur", "CFE", "C2OX", "SMFE".
    # *                       For MarketMaker subscription use "AGGREGATE_BID" or "AGGREGATE_ASK" keyword.
    # * @param[in] time       Time in the past (unix time in milliseconds).
    # * @param[out] snapshot  A handle of the created snapshot
    # *
    # * @return {@link DXF_SUCCESS} if snapshot has been successfully created or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         newly created snapshot is return via *snapshot* output parameter
    # */
    ERRORCODE dxf_create_snapshot(dxf_connection_t connection, dx_event_id_t event_id,
                                             dxf_const_string_t symbol, const char* source, 
                                             dxf_long_t time, dxf_snapshot_t* snapshot)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Creates Order snapshot with the specified parameters.
    # *
    # * @details If source is NULL string subscription on Order event will be performed. You can specify order
    # *          source for Order event by passing suffix: "BYX", "BZX", "DEA", "DEX", "ISE", "IST", "NTV" etc.
    # *          If source is equal to "AGGREGATE_BID" or "AGGREGATE_ASK" subscription on MarketMaker event will
    # *          be performed.
    # *
    # * @param[in] connection A handle of a previously created connection which the subscription will be using
    # * @param[in] symbol     The symbol to add
    # * @param[in] source     Order source for Order, which can be one of following: "NTV", "ntv", "NFX", "ESPD", "XNFI",
    # *                       "ICE", "ISE", "DEA", "DEX", "BYX", "BZX", "BATE", "CHIX", "CEUX", "BXTR", "IST", "BI20",
    # *                       "ABE", "FAIR", "GLBX", "glbx", "ERIS", "XEUR", "xeur", "CFE", "C2OX", "SMFE".
    # *                       For MarketMaker subscription use "AGGREGATE_BID" or "AGGREGATE_ASK" keyword.
    # * @param[in] time       Time in the past (unix time in milliseconds)
    # * @param[out] snapshot  A handle of the created snapshot
    # *
    # * @return {@link DXF_SUCCESS} if order snapshot has been successfully created or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         newly created snapshot is return via *snapshot* output parameter
    # */
    ERRORCODE dxf_create_order_snapshot(dxf_connection_t connection, 
                                                   dxf_const_string_t symbol, const char* source,
                                                   dxf_long_t time, dxf_snapshot_t* snapshot)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Creates Candle snapshot with the specified parameters.
    # *
    # * @details
    # *
    # * @param[in] connection        A handle of a previously created connection which the subscription will be using
    # * @param[in] candle_attributes Object specified symbol attributes of candle
    # * @param[in] time              Time in the past (unix time in milliseconds)
    # * @param[out] snapshot         A handle of the created snapshot
    # *
    # * @return {@link DXF_SUCCESS} if candle snapshot has been successfully created or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         newly created snapshot is return via *snapshot* output parameter
    # */
    ERRORCODE dxf_create_candle_snapshot(dxf_connection_t connection, 
                                                    dxf_candle_attributes_t candle_attributes, 
                                                    dxf_long_t time, dxf_snapshot_t* snapshot)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Closes a snapshot.
    # *
    # * @details All the data associated with it will be freed.
    # *
    # * @param[in] snapshot A handle of the snapshot to close
    # *
    # * @return {@link DXF_SUCCESS} if snapshot has been closed successfully or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_close_snapshot(dxf_snapshot_t snapshot)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Attaches a listener callback to the snapshot.
    # *
    # * @details This callback will be invoked when the new snapshot arrives or existing updates.
    # *          No error occurs if it's attempted to attach the same listener twice or more.
    # *
    # * @param[in] snapshot          A handle of the snapshot to which a listener is to be attached
    # * @param[in] snapshot_listener A listener callback function pointer
    # * @param[in] user_data         Data to be passed to the callback function
    # *
    # * @return {@link DXF_SUCCESS} if snapshot listener has been successfully attached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_attach_snapshot_listener(dxf_snapshot_t snapshot, 
                                                      dxf_snapshot_listener_t snapshot_listener,
                                                      void* user_data)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Detaches a listener from the snapshot.
    # *
    # * @details No error occurs if it's attempted to detach a listener which wasn't previously attached.
    # *
    # * @param[in] snapshot          A handle of the snapshot to which a listener is to be detached
    # * @param[in] snapshot_listener A listener callback function pointer
    # *
    # * @return {@link DXF_SUCCESS} if snapshot listener has been successfully detached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_detach_snapshot_listener(dxf_snapshot_t snapshot, 
                                                      dxf_snapshot_listener_t snapshot_listener)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Attaches an incremental listener callback to the snapshot.
    # *
    # * @details This callback will be invoked when the new snapshot arrives or existing updates.
    # *          No error occurs if it's attempted to attach the same listener twice or more.
    # *
    # * @param[in] snapshot          A handle of the snapshot to which a listener is to be attached
    # * @param[in] snapshot_listener A listener callback function pointer
    # * @param[in] user_data         Data to be passed to the callback function
    # *
    # * @return {@link DXF_SUCCESS} if listener has been successfully attached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_attach_snapshot_inc_listener(dxf_snapshot_t snapshot, 
                                                      dxf_snapshot_inc_listener_t snapshot_listener,
                                                      void* user_data)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Detaches a listener from the snapshot.
    # *
    # * @details No error occurs if it's attempted to detach a listener which wasn't previously attached.
    # *
    # * @param[in] snapshot          A handle of the snapshot to which a listener is to be detached
    # * @param[in] snapshot_listener A listener callback function pointer
    # *
    # * @return {@link DXF_SUCCESS} if snapshot listener has been successfully detached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_detach_snapshot_inc_listener(dxf_snapshot_t snapshot, 
                                                      dxf_snapshot_inc_listener_t snapshot_listener)
    
    # /**
    # * @ingroup c-api-snapshots
    # *
    # * @brief Retrieves the symbol currently added to the snapshot subscription.
    # *
    # * @details The memory for the resulting symbol is allocated internally, so no actions to free it are required.
    # *
    # * @param[in] snapshot A handle of the snapshot to which a listener is to be detached
    # * @param[out] symbol  A pointer to the string object to which the symbol is to be stored
    # *
    # * @return {@link DXF_SUCCESS} if snapshot symbol has been successfully received or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         *symbol* itself is returned via out parameter
    # */
    ERRORCODE dxf_get_snapshot_symbol(dxf_snapshot_t snapshot, dxf_string_t* symbol)
    
    # /**
    # * @ingroup c-api-price-level-book
    # *
    # * @brief Creates Price Level book with the specified parameters.
    # *
    # * @details
    # *
    # * @param[in] connection A handle of a previously created connection which the subscription will be using
    # * @param[in] symbol     The symbol to use
    # * @param[in] sources    Order sources for Order, NULL-terminated list. Each element can be one of following:
    # *                       "NTV", "ntv", "NFX", "ESPD", "XNFI", "ICE", "ISE", "DEA", "DEX", "BYX", "BZX", "BATE", "CHIX",
    # *                       "CEUX", "BXTR", "IST", "BI20", "ABE", "FAIR", "GLBX", "glbx", "ERIS", "XEUR", "xeur", "CFE",
    # *                       "C2OX", "SMFE"
    # * @param[out] book      A handle of the created price level book
    # *
    # * @return {@link DXF_SUCCESS} if price level book has been successfully created or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         *price level book* itself is returned via out parameter
    # */
    ERRORCODE dxf_create_price_level_book(dxf_connection_t connection, 
                                                     dxf_const_string_t symbol, const char** sources,
                                                     dxf_price_level_book_t* book)
    
    # /**
    # * @ingroup c-api-price-level-book
    # *
    # * @brief Closes a price level book.
    # *
    # * @details All the data associated with it will be freed.
    # *
    # * @param book A handle of the price level book to close
    # *
    # * @return {@link DXF_SUCCESS} if price level book has been successfully closed or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_close_price_level_book(dxf_price_level_book_t book)
    
    # /**
    # * @ingroup c-api-price-level-book
    # *
    # * @brief Attaches a listener callback to the price level book.
    # *
    # * @details This callback will be invoked when price levels change.
    # *          No error occurs if it's attempted to attach the same listener twice or more.
    # *
    # * @param[in] book          A handle of the book to which a listener is to be detached
    # * @param[in] book_listener A listener callback function pointer
    # * @param[in] user_data     Data to be passed to the callback function
    # *
    # * @return {@link DXF_SUCCESS} if listener has been successfully attached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_attach_price_level_book_listener(dxf_price_level_book_t book, 
                                                              dxf_price_level_book_listener_t book_listener,
                                                              void* user_data)
    
    # /**
    # * @ingroup c-api-price-level-book
    # *
    # * @brief Detaches a listener from the snapshot.
    # *
    # * @details No error occurs if it's attempted to detach a listener which wasn't previously attached.
    # *
    # * @param[in] book          A handle of the book to which a listener is to be detached
    # * @param[in] book_listener A listener callback function pointer
    # *
    # * @return {@link DXF_SUCCESS} if listener has been successfully detached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_detach_price_level_book_listener(dxf_price_level_book_t book, 
                                                   dxf_price_level_book_listener_t book_listener)
    
    # /**
    # * @ingroup c-api-regional-book
    # *
    # * @brief Creates Regional book with the specified parameters.
    # *
    # * @details Regional book is like Price Level Book but uses regional data instead of full depth order book.
    # *
    # * @param[in] connection A handle of a previously created connection which the subscription will be using
    # * @param[in] symbol     The symbol to use
    # * @param[out] book      A handle of the created regional book
    # *
    # * @return {@link DXF_SUCCESS} if regional book has been successfully created or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         *regional book* itself is returned via out parameter
    # */
    ERRORCODE dxf_create_regional_book(dxf_connection_t connection, 
                                                  dxf_const_string_t symbol,
                                                  dxf_regional_book_t* book)
    
    # /**
    # * @ingroup c-api-regional-book
    # *
    # * @brief Closes a regional book.
    # *
    # * @details All the data associated with it will be freed.
    # *
    # * @param[in] book A handle of the price level book to close
    # *
    # * @return {@link DXF_SUCCESS} if regional book has been successfully closed or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_close_regional_book(dxf_regional_book_t book)
    
    # /**
    # * @ingroup c-api-regional-book
    # *
    # * @brief Attaches a listener callback to regional book.
    # *
    # * @details This callback will be invoked when price levels created from regional data change.
    # *
    # * @param[in] book          A handle of the book to which a listener is to be detached
    # * @param[in] book_listener A listener callback function pointer
    # * @param[in] user_data     Data to be passed to the callback function
    # *
    # * @return {@link DXF_SUCCESS} if listener has been successfully attached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_attach_regional_book_listener(dxf_regional_book_t book, 
                                                           dxf_price_level_book_listener_t book_listener,
                                                           void* user_data)
    
    # /**
    # * @ingroup c-api-regional-book
    # *
    # * @brief Detaches a listener from the regional book.
    # *
    # * @details No error occurs if it's attempted to detach a listener which wasn't previously attached.
    # *
    # * @param book          A handle of the book to which a listener is to be detached
    # * @param book_listener A listener callback function pointer
    # *
    # * @return {@link DXF_SUCCESS} if listener has been successfully detached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_detach_regional_book_listener(dxf_regional_book_t book, 
                                                           dxf_price_level_book_listener_t book_listener)
    
    # /**
    # * @ingroup c-api-regional-book
    # *
    # * @brief Attaches a listener callback to regional book.
    # *
    # * @details This callback will be invoked when new regional quotes are received.
    # *
    # * @param[in] book      A handle of the book to which a listener is to be detached
    # * @param[in] listener  A listener callback function pointer
    # * @param[in] user_data Data to be passed to the callback function
    # *
    # * @return {@link DXF_SUCCESS} if listener has been successfully attached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_attach_regional_book_listener_v2(dxf_regional_book_t book,
                                                              dxf_regional_quote_listener_t listener,
                                                              void* user_data)
    
    # /**
    # * @ingroup c-api-regional-book
    # *
    # * @brief Detaches a listener from the regional book.
    # *
    # * @details No error occurs if it's attempted to detach a listener which wasn't previously attached.
    # *
    # * @param[in] book     A handle of the book to which a listener is to be detached
    # * @param[in] listener A listener callback function pointer
    # *
    # * @return {@link DXF_SUCCESS} if listener has been successfully detached or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_detach_regional_book_listener_v2(dxf_regional_book_t book,
                                                              dxf_regional_quote_listener_t listener)
    
    # /**
    # * @ingroup c-api-common
    # *
    # * @brief Add dumping of incoming traffic into specific file
    # *
    # * @details
    # *
    # * @param[in] connection    A handle of a previously created connection which the subscription will be using
    # * @param[in] raw_file_name Raw data file name
    # *
    # */
    ERRORCODE dxf_write_raw_data(dxf_connection_t connection, const char* raw_file_name)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Retrieves the array of key-value pairs (properties) for specified connection.
    # *
    # * @details The memory for the resulting array is allocated during execution of the function
    # *          and SHOULD be free by caller with dxf_free_connection_properties_snapshot
    # *          function. So done because connection properties can be changed during reconnection.
    # *          Returned array is a snapshot of properties at the moment of the call.
    # *
    # * @param[in] connection  A handle of a previously created connection
    # * @param[out] properties Address of pointer to store address of key-value pairs array
    # * @param[out] count      Address of variable to store length of key-value pairs array
    # *
    # * @return {@link DXF_SUCCESS} if connection properties have been successfully received or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         *properties* are returned via output parameter
    # */
    ERRORCODE dxf_get_connection_properties_snapshot(dxf_connection_t connection,
                                                                dxf_property_item_t** properties,
                                                                int* count)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Frees memory allocated during {@link dxf_get_connection_properties_snapshot} function execution
    # *
    # * @details
    # *
    # * @param[in] properties Pointer to the key-value pairs array
    # * @param[in] count      Length of key-value pairs array
    # *
    # * @return {@link DXF_SUCCESS} if memory has been successfully freed or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # */
    ERRORCODE dxf_free_connection_properties_snapshot(dxf_property_item_t* properties, int count)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Retrieves the null-terminated string with current connected address in format ```<host>:<port>```.
    # *
    # * @details If (*address) points to NULL then connection is not connected (reconnection, no valid addresses,
    # *          closed connection and others). The memory for the resulting string is allocated during execution
    # *          of the function and SHOULD be free by caller with call of dxf_free function. So done because inner
    # *          string with connected address can be free during reconnection.
    # *
    # * @param[in] connection A handle of a previously created connection
    # * @param[out] address   Address of pointer to store address of the null-terminated string with current connected address
    # *
    # * @return {@link DXF_SUCCESS} if address has been successfully received or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         *address* itself is returned via out parameter
    # */
    ERRORCODE dxf_get_current_connected_address(dxf_connection_t connection, char** address)
    
    # /**
    # * @ingroup c-api-connection-functions
    # *
    # * @brief Retrieves the current connection status
    # *
    # * @details
    # *
    # * @param[in] connection A handle of a previously created connection
    # * @param[out] status    Connection status
    # *
    # * @return {@link DXF_SUCCESS} if connection status has been successfully received or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure;
    # *         *status* itself is returned via out parameter
    # */
    ERRORCODE dxf_get_current_connection_status(dxf_connection_t connection, dxf_connection_status_t* status)
    
    # /**
    # * @ingroup c-api-common
    # *
    # * @brief Frees memory allocated in API functions from this module
    # *
    # * @param[in] pointer Pointer to memory allocated earlier in some API function from this module
    # */
    ERRORCODE dxf_free(void* pointer)
    
    # /**
    # * @ingroup c-api-common
    # *
    # * @brief Returns a dxf_const_string_t name of the dxf_order_action_t enum value
    # *
    # * @details Don't free the pointer returned by this function
    # *
    # * @param[in] action Order action
    # */
    dxf_const_string_t dxf_get_order_action_wstring_name(dxf_order_action_t action)
    
    # /**
    # * @ingroup c-api-common
    # *
    # * @brief Returns a name of the dxf_order_action_t enum value
    # *
    # * @details Don't free the pointer returned by this function
    # *
    # * @param[in] action Order action
    # */
    const char* dxf_get_order_action_string_name(dxf_order_action_t action)
    
    # /**
    # * @ingroup c-api-config
    # *
    # * @brief Initializes the C-API configuration and loads a config (in TOML format) from a wide string (dxf_const_string_t)
    # * For the successful application of the configuration, this function must be called before creating any connection
    # *
    # * @details The config file sample: [Sample](https://github.com/dxFeed/dxfeed-c-api/dxfeed-api-config.sample.toml)
    # *
    # * The TOML format specification: https://toml.io/en/v1.0.0-rc.2
    # *
    # * Example #1:
    # * ```c
    # * dxf_load_config_from_wstring(
    # *     L"network.heartbeatPeriod = 10\n"
    # *     L"network.heartbeatTimeout = 120\n"
    # * );
    # * ```
    # *
    # * Example #2:
    # * ```c
    # * dxf_load_config_from_wstring(
    # *     L"[network]\n"
    # *     L"heartbeatPeriod = 10\n"
    # *     L"heartbeatTimeout = 120\n"
    # * );
    # * ```
    # *
    # * @param[in] config The config (in TOML format) string
    # *
    # * @return {@link DXF_SUCCESS} if configuration has been successfully loaded or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure
    # */
    ERRORCODE dxf_load_config_from_wstring(dxf_const_string_t config)
    
    # /**
    # * @ingroup c-api-config
    # *
    # * @brief Initializes the C-API configuration and loads a config (in TOML format) from a string
    # * For the successful application of the configuration, this function must be called before creating any connection
    # *
    # * @details The config file sample: [Sample](https://github.com/dxFeed/dxfeed-c-api/dxfeed-api-config.sample.toml)
    # *
    # * The TOML format specification: https://toml.io/en/v1.0.0-rc.2
    # *
    # * Example #1:
    # * ```c
    # * dxf_load_config_from_string(
    # *     "network.heartbeatPeriod = 10\n"
    # *     "network.heartbeatTimeout = 120\n"
    # * );
    # * ```
    # *
    # * Example #2:
    # * ```c
    # * dxf_load_config_from_string(
    # *     "[network]\n"
    # *     "heartbeatPeriod = 10\n"
    # *     "heartbeatTimeout = 120\n"
    # * );
    # * ```
    # *
    # * @param[in] config The config (in TOML format) string
    # *
    # * @return {@link DXF_SUCCESS} if configuration has been successfully loaded or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure
    # */
    ERRORCODE dxf_load_config_from_string(const char* config)
    
    # /**
    # * @ingroup c-api-config
    # *
    # * @brief Initializes the C-API configuration and loads a config (in TOML format) from a file
    # * For the successful application of the configuration, this function must be called before creating any connection
    # *
    # * @details The config file sample: [Sample](https://github.com/dxFeed/dxfeed-c-api/dxfeed-api-config.sample.toml)
    # *
    # * The TOML format specification: https://toml.io/en/v1.0.0-rc.2
    # *
    # * Example #1:
    # * ```c
    # * dxf_load_config_from_file("./dxfeed-api-config.toml");
    # * ```
    # *
    # * Example #2:
    # * ```c
    # * dxf_load_config_from_file("C:\\dxFeedApp\\dxfeed-api-config.toml");
    # * ```
    # *
    # * @param[in] file_name The config (in TOML format) file name
    # *
    # * @return {@link DXF_SUCCESS} if configuration has been successfully loaded or {@link DXF_FAILURE} on error;
    # *         {@link dxf_get_last_error} can be used to retrieve the error code and description in case of failure
    # */
    ERRORCODE dxf_load_config_from_file(const char* file_name)
    
    #endif /* DXFEED_API_H_INCLUDED */
