"""Define extension types for MyException, SaxonApiException, and
SaxonProcessor."""
from libcpp.string cimport string
cimport cython


@cython.final       # not subclassable
@cython.internal    # not in the module dict
cdef class MyException:
    """MyException extension type"""

    cdef cpp.MyException e

    property errorCode:
        def __get__(self):
            cdef string ec
            ec = self.e.errorCode
            if ec.length() == 0:
                return None
            else:
                return ec

    property errorMessage:
        def __get__(self):
            cdef string em
            m = self.e.errorMessage
            if em.length() == 0:
                return None
            else:
                return em

    property linenumber:
        def __get__(self):
            return self.e.linenumber

    property isType:
        def __get__(self):
            return <bint>self.e.isType

    property isStatic:
        def __get__(self):
            return <bint>self.e.isStatic

    property isGlobal:
        def __get__(self):
            return <bint>self.e.isGlobal


@cython.final       # not subclassable
@cython.internal    # not in the module dict
cdef class SaxonApiException:
    """Saxon API Exception extension type."""

    cdef cpp.SaxonApiException *thisptr

    def __cinit__(self):
        self.thisptr = NULL

    def __dealloc__(self):
        if self.thisptr != NULL:
            del self.thisptr

    def __copy__(self):
        cdef SaxonApiException e
        e = SaxonApiException()
        e.thisptr = new cpp.SaxonApiException(self.thisptr[0])
        return e

    def clear(self):
        self.thisptr.clear()

    property count:
        def __get__(self):
            return self.thisptr.count()

    def __getitem__(self, int i):
        cdef MyException mye
        mye =  MyException()
        mye.e = self.thisptr.getException(i)
        return mye


cdef class SaxonProcessor:
    """SaxonProcessor extension type."""

    def __cinit__(self, what=None):
        cdef char *conf_file

        if isinstance(what, bytes):
            conf_file = what
            self.thisptr = new cpp.SaxonProcessor(conf_file)
        elif isinstance(what, bool):
            self.thisptr = new cpp.SaxonProcessor(<bint>what)
        # elif what is None:
        #     self.thisptr = new cpp.SaxonProcessor()
        else:
            raise TypeError('SaxonProcessor cannot be initialized with: %s'
                            % what)

    def __dealloc__(self):
        self.thisptr.release()

    property exceptionOccurred:
        def __get__(self):
            return <bint>self.thisptr.exceptionOccurred()

    def exceptionClear(self):
        self.thisptr.exceptionClear()

    def getException(self):
        cdef SaxonApiException e
        e = SaxonApiException()
        e.thisptr = self.thisptr.getException()
        return e

    def setcwd(self, char* cwd):
        self.thisptr.setcwd(cwd)

    property resourcesDirectory:
        def __get__(self):
            return self.thisptr.getResourcesDirectory()

        def __set__(self, char* dir):
            self.thisptr.setResourcesDirectory(dir)

    def setConfigurationProperty(self, char* name, char* value):
        self.thisptr.setConfigurationProperty(name, value)

    def clearConfigurationProperties(self):
        self.thisptr.clearConfigurationProperties()

    def version(self):
        return self.thisptr.version()
