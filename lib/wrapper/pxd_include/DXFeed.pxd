include "DXTypes.pxd"

# /* -------------------------------------------------------------------------- */
# /*
#  *	DXFeed API generic types
#  */
# /* -------------------------------------------------------------------------- */

cdef extern from "DXFeed.h":
    ctypedef void (*dxf_conn_termination_notifier_t) (dxf_connection_t connection, void* user_data)
    ctypedef void (*dxf_conn_status_notifier_t) (dxf_connection_t connection,
                                                dxf_connection_status_t old_status,
                                                dxf_connection_status_t new_status,
                                                void* user_data)

# /* the low level callback types, required in case some thread-specific initialization must be performed
#    on the client side on the thread creation/destruction */

    ctypedef int (*dxf_socket_thread_creation_notifier_t) (dxf_connection_t connection, void* user_data)
    ctypedef void (*dxf_socket_thread_destruction_notifier_t) (dxf_connection_t connection, void* user_data)



    # Functions
 #    /*
 # *	Creates connection with the specified parameters.
 #
 # *  address - the single address: "host:port" or just "host"
 # *            address with credentials: "host:port[username=xxx,password=yyy]"
 # *            multiple addresses: "(host1:port1)(host2)(host3:port3[username=xxx,password=yyy])"
 # *            the data from file: "/path/to/file" on *nix and "drive:\path\to\file" on Windows
 # *  notifier - the callback to inform the client side that the connection has stumbled upon and error and will go reconnecting
 # *  conn_status_notifier - the callback to inform the client side that the connection status has changed
 # *  stcn - the callback for informing the client side about the socket thread creation;
 #           may be set to NULL if no specific action is required to perform on the client side on a new thread creation
 # *  shdn - the callback for informing the client side about the socket thread destruction;
 #           may be set to NULL if no specific action is required to perform on the client side on a thread destruction
 # *  user_data - the user defined value passed to the termination notifier callback along with the connection handle; may be set
 #                to whatever value
 # *  OUT connection - the handle of the created connection
 # */
    ERRORCODE dxf_create_connection (const char* address,
                                            dxf_conn_termination_notifier_t notifier,
                                            dxf_conn_status_notifier_t conn_status_notifier,
                                            dxf_socket_thread_creation_notifier_t stcn,
                                            dxf_socket_thread_destruction_notifier_t stdn,
                                            void* user_data,
                                        dxf_connection_t* connection)

# /*
#  *	Closes a connection.
#
#  *  connection - a handle of a previously created connection
#  */
    ERRORCODE dxf_close_connection (dxf_connection_t connection)

# /*
#  *	Creates a subscription with the specified parameters.
#
#  *  connection - a handle of a previously created connection which the subscription will be using
#  *  event_types - a bitmask of the subscription event types. See 'dx_event_id_t' and 'DX_EVENT_BIT_MASK'
#  *                for information on how to create an event type bitmask
#  *  OUT subscription - a handle of the created subscription
#  */
    ERRORCODE dxf_create_subscription (dxf_connection_t connection, int event_types,
                                       dxf_subscription_t* subscription)