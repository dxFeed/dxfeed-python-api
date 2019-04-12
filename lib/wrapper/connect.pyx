include "pxd_include/DXFeed.pxd"

cdef dxf_connection_t connection

def pyconnect():
    print('connecting2')
    dxf_create_connection("demo.dxfeed.com:7300", NULL, NULL, NULL, NULL, NULL, &connection)
    # print('connected')

def pydisconnect():
    print('disconnecting')
    dxf_close_connection(connection)
    print('disconnected')