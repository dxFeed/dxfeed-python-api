from abc cimport foo

ctypedef int (*function_type)(int  a, int b)

cdef int lam(function_type func, int c, int d):
    return func(c,d)

print(lam(add, 5, 6))
