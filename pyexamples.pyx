cdef extern from "lib/dxfeed-c-api/tests/ConnectionTest/ConnectionTest.c":
    int main ()

def runsampletest():
    return main()