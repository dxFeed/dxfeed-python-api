cdef extern from "lib/dxfeed-c-api/include/DXTypes.h":
    ctypedef int ERRORCODE
    ctypedef void* dxf_connection_t

cdef extern from "lib/dxfeed-c-api/include/DXFeed.h":
    ERRORCODE dxf_close_connection (dxf_connection_t connection)

def pydisconnect():
    dxf_close_connection(NULL)