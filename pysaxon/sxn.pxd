cimport cpp

cdef class SaxonProcessor:
    cdef cpp.SaxonProcessor *thisptr

cdef class XPathProcessor:
    cdef cpp.XPathProcessor *thisptr

cdef class XsltProcessor:
    cdef cpp.XsltProcessor *thisptr
