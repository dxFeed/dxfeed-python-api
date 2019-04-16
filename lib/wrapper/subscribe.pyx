from pxd_include.DXFeed cimport *

cdef dxf_connection_t connection
cdef dxf_subscription_t subscription

def pysubscribe():
    print('subscribing')
    dxf_create_subscription(connection, 1, &subscription)
    print('suscribed')