import time

cdef extern from "DXTypes.h":
    ctypedef int ERRORCODE
    ctypedef void* dxf_subscription_t
    ctypedef void* dxf_connection_t
    ctypedef void* dxf_candle_attributes_t
    ctypedef void* dxf_snapshot_t
    ctypedef void* dxf_price_level_book_t
    ctypedef void* dxf_regional_book_t

    enum dxf_connection_status_t:
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

    ERRORCODE dxf_create_connection (const char* address,
                                            dxf_conn_termination_notifier_t notifier,
                                            dxf_conn_status_notifier_t conn_status_notifier,
                                            dxf_socket_thread_creation_notifier_t stcn,
                                            dxf_socket_thread_destruction_notifier_t stdn,
                                            void* user_data,
                                        dxf_connection_t* connection)

    ERRORCODE dxf_close_connection (dxf_connection_t connection)



# cpdef pyconnect(connection):
#     return dxf_create_connection("demo.dxfeed.com:7300", NULL, NULL, NULL, NULL, NULL, NULL, NULL, dereference(connection))
#
# cpdef pydisconnect(connection):
#     dxf_close_connection(dereference(connection))

# cpdef con_discon():
#     cdef dxf_connection_t connection
#     # global connection
#     # cdef const char dxfeed_host = "demo.dxfeed.com:7300"
#     # print("Connecting to host %s...\n", dxfeed_host)
#     print('connecting')
#     dxf_create_connection("demo.dxfeed.com:7300", NULL, NULL, NULL, NULL, NULL, &connection)
#
#     # pyconnect(connection)
#     print('connected')
#
#     time.sleep(5)
#     print('disconnecting')
#     # pydisconnect(connection)
#     dxf_close_connection(connection)
#     print('disconnected')

cdef dxf_connection_t connection

def pyconnect():
    print('connecting1')
    dxf_create_connection("demo.dxfeed.com:7300", NULL, NULL, NULL, NULL, NULL, &connection)
    print('connected')

def pydisconnect():
    print('disconnecting')
    dxf_close_connection(connection)
    print('disconnected')

def test():
    pyconnect()
    pydisconnect()