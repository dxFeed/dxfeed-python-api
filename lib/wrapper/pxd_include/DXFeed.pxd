from .DXTypes cimport *
# from EventData cimport *

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
    ERRORCODE dxf_create_connection (const char* address,
                                            dxf_conn_termination_notifier_t notifier,
                                            dxf_conn_status_notifier_t conn_status_notifier,
                                            dxf_socket_thread_creation_notifier_t stcn,
                                            dxf_socket_thread_destruction_notifier_t stdn,
                                            void* user_data,
                                        dxf_connection_t* connection)

    ERRORCODE dxf_close_connection (dxf_connection_t connection)