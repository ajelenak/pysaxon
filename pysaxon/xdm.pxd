cimport cpp

cdef class Item:
    cdef cpp.XdmItem *thisptr
    cdef int _size, _cntr

cdef class Value:
    cdef cpp.XdmValue *thisptr
    cdef int _size, _cntr

cdef class Node:
    cdef cpp.XdmNode *thisptr

cdef class AtomicValue:
    cdef cpp.XdmAtomicValue *thisptr
