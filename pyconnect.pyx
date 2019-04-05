cdef extern from "lib/dxfeed-c-api/include/DXTypes.h":
    ctypedef int ERRORCODE
    ctypedef void* dxf_subscription_t
    ctypedef void* dxf_connection_t
    ctypedef void* dxf_candle_attributes_t
    ctypedef void* dxf_snapshot_t
    ctypedef void* dxf_price_level_book_t
    ctypedef void* dxf_regional_book_t

    ctypedef enum dxf_connection_status_t:
        dxf_cs_not_connected = 0,
        dxf_cs_connected,
        dxf_cs_login_required,
        dxf_cs_authorized

cdef extern from "lib/dxfeed-c-api/include/DXFeed.h":
    ctypedef int (*dxf_socket_thread_creation_notifier_t) (dxf_connection_t connection, void* user_data)
    ctypedef void (*dxf_socket_thread_destruction_notifier_t) (dxf_connection_t connection, void* user_data)
    ctypedef void (*dxf_conn_termination_notifier_t) (dxf_connection_t connection, void* user_data)
    ctypedef void (*dxf_conn_status_notifier_t) (dxf_connection_t connection,
                                                dxf_connection_status_t old_status,
                                                dxf_connection_status_t new_status,
                                                void* user_data)

    ERRORCODE dxf_create_connection(const char* address,
                                        const char* authscheme,
                                        const char* authdata,
                                        dxf_conn_termination_notifier_t notifier,
                                        dxf_conn_status_notifier_t conn_status_notifier,
                                        dxf_socket_thread_creation_notifier_t stcn,
                                        dxf_socket_thread_destruction_notifier_t stdn,
                                        void* user_data,
                                        dxf_connection_t* connection)

def pyconnect():
    return dxf_create_connection("demo.dxfeed.com:7300", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)