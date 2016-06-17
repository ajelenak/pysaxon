cimport cpp


cdef class Value:
    cdef cpp.XdmValue *thisptr
    cdef int _size, _cntr


cdef class Item(Value):
    pass


cdef class Node(Item):
    pass


cdef class AtomicValue(Item):
    pass


cdef object make_item(cpp.XdmItem *ptr, char* when_null)
cdef object make_node(cpp.XdmNode *ptr, char* when_null)
cdef void print_ptr(char *msg, void *ptr)
