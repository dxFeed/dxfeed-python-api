cdef extern from "lib/dxfeed-c-api/tests/ConnectionTest/ConnectionTest.c":
    int main (int argc, char* argv[])

def runsampletest():
    return main(2, [''])