from pxd_include.DXFeed cimport *
from pxd_include.DXTypes cimport *

cdef dxf_connection_t connection

def pyconnect():
    print('connecting')
    dxf_create_connection("demo.dxfeed.com:7300", NULL, NULL, NULL, NULL, NULL, &connection)
    print('connected')

def pydisconnect():
    print('disconnecting')
    dxf_close_connection(connection)
    print('disconnected')