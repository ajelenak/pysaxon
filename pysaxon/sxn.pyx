"""Define extension types for MyException, SaxonApiException, and
SaxonProcessor."""
from libcpp.string cimport string
cimport cython
cimport decls


@cython.final       # not subclassable
@cython.internal    # not in the module dict
cdef class MyException:
    """MyException extension type"""

    cdef decls.MyException e

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

    property is_type:
        def __get__(self):
            return <bint>self.e.isType

    property is_static:
        def __get__(self):
            return <bint>self.e.isStatic

    property is_global:
        def __get__(self):
            return <bint>self.e.isGlobal


@cython.final       # not subclassable
@cython.internal    # not in the module dict
cdef class SaxonApiException:
    """Saxon API Exception extension type."""

    cdef decls.SaxonApiException *thisptr

    def __cinit__(self):
        self.thisptr = NULL

    def __dealloc__(self):
        if self.thisptr != NULL:
            del self.thisptr

    def __copy__(self):
        cdef SaxonApiException e
        e = SaxonApiException()
        e.thisptr = new decls.SaxonApiException(self.thisptr[0])
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

    cdef decls.SaxonProcessor *thisptr

    def __cinit__(self, what=None):
        cdef char *conf_file

        if isinstance(what, bytes):
            conf_file = what
            self.thisptr = new decls.SaxonProcessor(conf_file)
        elif isinstance(what, bool):
            self.thisptr = new decls.SaxonProcessor(<bint>what)
        elif what is None:
            self.thisptr = new decls.SaxonProcessor()
        else:
            raise TypeError('SaxonProcessor cannot be initialized with: %s'
                            % what)

    def __dealloc__(self):
        self.thisptr.release()
        del self.thisptr

    property exception:
        def __get__(self):
            return <bint>self.thisptr.exceptionOccurred()

    def exception_clear(self):
        self.thisptr.exceptionClear()

    def get_exception(self):
        cdef SaxonApiException e
        e = SaxonApiException()
        e.thisptr = self.thisptr.getException()
        return e

    def set_cwd(self, char* cwd):
        self.thisptr.setcwd(cwd)

    property resources_directory:
        def __get__(self):
            return self.thisptr.getResourcesDirectory()

        def __set__(self, char* dir):
            self.thisptr.setResourcesDirectory(dir)

    def set_configuration_property(self, char* name, char* value):
        self.thisptr.setConfigurationProperty(name, value)

    def clear_configuration_property(self):
        self.thisptr.clearConfigurationProperties()

    def version(self):
        return self.thisptr.version()
