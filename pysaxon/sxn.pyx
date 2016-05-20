"""Define extension types for MyException, SaxonApiException, and
SaxonProcessor."""
from libcpp.string cimport string
from libcpp.map cimport map
cimport cython
from .xdm cimport Value, Item, Node


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


# Global boolean flag indicating whether Saxon/C Java VM has started...
cdef int _init = 0


cdef class SaxonProcessor:
    """SaxonProcessor extension type."""

    def __cinit__(self, what=None, init=False):
        cdef char *conf_file
        global _init

        if isinstance(what, bytes):
            conf_file = what
            self.thisptr = new cpp.SaxonProcessor(conf_file)
        else:
            self.thisptr = new cpp.SaxonProcessor(<bint>bool(what))

        if not (init or _init):
            raise RuntimeError(
                'SaxonProcessor "init" object with never created')
        elif init and _init:
            raise RuntimeError('Only one "init" SaxonProcessor object allowed')
        if init:
            _init = 1
            self._init = 1
        else:
            self._init = 0

    def __dealloc__(self):
        global _init
        if self._init == 1:
            self.thisptr.release()
        del self.thisptr

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

    property version:
        """Get the Saxon version."""
        def __get__(self):
            return self.thisptr.version()

    def parseXmlFromString(self, char *xml):
        """Parse a lexical representation of the source document and return it
        as a Node object.
        """
        cdef Node n = Node()
        n.thisptr = self.thisptr.parseXmlFromString(xml)
        return n

    def parseXmlFromFile(self, char *xmlfile):
        """Parse a source document file and return it as a Node object."""
        cdef Node n = Node()
        n.thisptr = self.thisptr.parseXmlFromFile(xmlfile)
        return n

    def parseXmlFromUri(self, char *uri):
        """Parse a source document available by URI and return it as a Node
        object."""
        cdef Node n = Node()
        n.thisptr = self.thisptr.parseXmlFromUri(uri)
        return n

    def newXPathProcessor(self):
        """Create an XPathProcessor.

        An XPathProcessor is used to compile XPath expressions.
        """
        cdef XPathProcessor xp = XPathProcessor(raw=True)
        xp.thisptr = self.thisptr.newXPathProcessor()
        return xp

    def newXsltProcessor(self):
        """Create an XsltProcessor.

        An XsltProcessor is used to compile XSLT stylesheets.
        """
        cdef XsltProcessor xsl = XsltProcessor()
        xsl.thisptr = self.thisptr.newXsltProcessor()
        return xsl


cdef class XPathProcessor:
    """XPathProcessor extension type."""

    def __cinit__(self, SaxonProcessor proc=None, bytes cwd=b'',
                  bint raw=False):
        cdef string temp
        if raw:
            self.thisptr = NULL
        else:
            if proc is None:
                self.thisptr = new cpp.XPathProcessor()
            else:
                temp = cwd
                self.thisptr = new cpp.XPathProcessor(proc.thisptr, temp)

    def __dealloc__(self):
        if self.thisptr:
            del self.thisptr

    def setcwd(self, char *cwd):
        """Set the current working directory to ``cwd``."""
        self.thisptr.setcwd(cwd)

    def setBaseURI(self, char *uri):
        """Set the static base URI for XPath expressions compiled using this
        XPath processor.

        The base URI is part of the static context, and is used to resolve any
        relative URIs appearing within an XPath expression. If no static base
        URI is supplied then the current working directory is used.
        """
        self.thisptr.setBaseURI(uri)

    def declareNamespace(self, char *prefix, char *uri):
        """Declare a namespace binding as part of the static context for XPath
        expressions.

        :arg char* prefix: The namespace prefix. If the value is a zero-length
            string, this method sets the default namespace for elements and
            types.
        :arg char* uri: The namespace URI. It is possible to specify a zero-
            length string to "undeclare" a namespace; in this case the prefix
            will not be available for use, except in the case where the prefix
            is also a zero length string, in which case the absence of a prefix
            implies that the name is in no namespace.
        """
        self.thisptr.declareNamespace(prefix, uri)

    def evaluate(self, char *xpath):
        """Compile and evaluate an XPath expression.

        Return xdm.Value object.
        """
        cdef Value val = Value()
        val.thisptr = self.thisptr.evaluate(xpath)
        return val

    def evaluate_single(self, char *xpath):
        """Compile and evaluate an XPath expression. The result is expected to
        be a single xdm.Item.
        """
        cdef Item it = Item()
        it.thisptr = self.thisptr.evaluateSingle(xpath)

    def evaluate_bool(self, char *xpath):
        """Evaluate the XPath expression, returning the effective boolean value
        of the result.
        """
        return <bint>self.thisptr.effectiveBooleanValue(xpath)

    def setContextItem(self, Item it):
        self.thisptr.setContextItem(it.thisptr)

    def setContextFile(self, char *filename):
        """Set the context item from file."""
        self.thisptr.setContextFile(filename)

    def setParameter(self, char *name, Value val):
        """Set a parameter value used in the query."""
        self.thisptr.setParameter(name, val.thisptr)

    def removeParameter(self, char *name):
        """Remove a parameter named ``name``."""
        return <bint>self.thisptr.removeParameter(name)

    property parameters:
        def __get__(self):
            """Get all parameters as a dictionary of names (string) and
            xdm.Value objects.
            """
            cdef params = {}
            cdef map[string, cpp.XdmValue*] m
            cdef Value v
            m = self.thisptr.getParameters()
            for it in m:
                v = Value()
                v.thisptr = it.second
                params[it.first] = v
            return params

        def __del__(self):
            """Clear parameter values set."""
            self.thisptr.clearParameters(<bint>1)

    def setProperty(self, char *name, char *value):
        """Set a property specific to the processor in use.

        :arg char* name: Property's name.
        :arg char* value: Property's value.
        """
        self.thisptr.setProperty(name, value)

    property properties:
        def __get__(self):
            """Get all properties as a dictionary."""
            return self.thisptr.getProperties()

        def __del__(self):
            """Clear property values set."""
            self.thisptr.clearProperties()

    def exceptionOccurred(self):
        """Check for pending exceptions without creating a local reference to
        the exception object.
        """
        return <bint>self.thisptr.exceptionOccurred()

    property exceptions:
        def __get__(self):
            """Get exception error messages and their codes as a list of
            MyException objects or None.
            """
            cdef MyException mye
            cdef list errors = []
            cdef int count, i

            if not self.thisptr.exceptionOccurred():
                return None

            count = self.thisptr.exceptionCount()
            if count == 0:
                return None

            for i in range(count):
                mye = MyException()
                mye.e.errorCode.assign(self.thisptr.getErrorCode(i))
                mye.e.errorMessage.assign(self.thisptr.getErrorMessage(i))
                mye.e.linenumber = -1
                mye.e.isType = 1
                mye.e.isGlobal = 1
                mye.e.isStatic = 1
                errors.append(mye)

            return errors

        def __del__(self):
            """Clear any exception thrown."""
            self.thisptr.exceptionClear()


cdef class XsltProcessor:
    """XsltProcessor extension type."""

    def __cinit__(self):
        self.thisptr = NULL

    def __dealloc__(self):
        if self.thisptr:
            self.thisptr.releaseStylesheet()
            del self.thisptr

    def setcwd(self, char *cwd):
        """Set the current working directory to ``cwd``."""
        self.thisptr.setcwd(cwd)

    property parameters:
        def __get__(self):
            """Get all parameters as a dictionary of names (string) and
            xdm.Value objects.
            """
            cdef params = {}
            cdef map[string, cpp.XdmValue*] m
            cdef Value v
            m = self.thisptr.getParameters()
            for it in m:
                v = Value()
                v.thisptr = it.second
                params[it.first] = v
            return params

        def __del__(self):
            """Clear parameter values set."""
            self.thisptr.clearParameters(<bint>1)

    property properties:
        def __get__(self):
            """Get all properties as a dictionary."""
            return self.thisptr.getProperties()

        def __del__(self):
            """Clear property values set."""
            self.thisptr.clearProperties()

    def setSourceFromXdmValue(self, Item val):
        """Set the source document from a xdm.Item object for the
        transformation."""
        self.thisptr.setSourceFromXdmValue(val.thisptr)

    def setSourceFromFile(self, char *filename):
        """Set the source from file for the transformation."""
        self.thisptr.setSourceFromFile(filename)

    def setOutputFile(self, char *filename):
        """Set the output file of where the transformation result is sent."""
        self.thisptr.setOutputFile(filename)

    property xslMessages:
        def __get__(self):
            """Get the messages written using the ``xsl:message`` instruction
            as an xdm.Value object.
            """
            cdef Value v = Value()
            v.thisptr = self.thisptr.getXslMessages()
            return v

    def transformFileToFile(self, char* source, char *out, xslt=None):
        """Perform a one shot transformation from a file to a file.

        :arg bytes source: Source document file name.
        :arg bytes out: File name where to store the transformation's result.
        :arg bytes xslt: XSLT file name. If None, the most recently compiled
            stylesheet is used.
        """
        cdef char *xslt_c = NULL
        if xslt is not None:
            xslt_c = xslt
        self.thisptr.transformFileToFile(source, xslt_c, out)

    def transformFileToString(self, char *source, xslt=None):
        """Perform a one shot transformation from a file to a string.

        :arg bytes source: Source document file name.
        :arg bytes xslt: XSLT file name. If None, the most recently compiled
            stylesheet is used.
        """
        cdef char *xslt_c = NULL
        if xslt is not None:
            xslt_c = xslt
        return self.thisptr.transformFileToString(source, xslt_c)

    def transformFileToValue(self, char *source, xslt=None):
        """Perform a one shot transformation from a file to an xdm.Value.

        :arg bytes source: Source document file name.
        :arg bytes xslt: XSLT file name. If None, the most recently compiled
            stylesheet is used.
        """
        cdef char *xslt_c = NULL
        cdef Value v = Value()
        if xslt is not None:
            xslt_c = xslt
        v.thisptr = self.thisptr.transformFileToValue(source, xslt_c)
        return v

    def compileFromFile(self, char *xslt):
        """Compile a stylesheet stored in a file.

        :arg bytes xslt: XSLT file name.
        """
        self.thisptr.compileFromFile(xslt)

    def compileFromString(self, char *xslt):
        """Compile a stylesheet stored in a string.

        :arg bytes xslt: XSLT content.
        """
        self.thisptr.compileFromString(xslt)

    def compileFromXdmNode(self, Node n not None):
        """Compile a stylesheet stored in an xdm.Node."""
        self.thisptr.compileFromXdmNode(n.thisptr)

    def transformToString(self):
        """Perform the transformation based upon what has been cached and
        return the result as a bytes object.
        """
        return self.thisptr.transformToString()

    def transformToValue(self):
        """Perform the transformation based upon what has been cached and
        return the result as an xdm.Value object.
        """
        cdef Value v = Value()
        v.thisptr = self.thisptr.transformToValue()
        return v

    def transformToFile(self):
        """Perform the transformation based upon what has been cached and
        return the result in a file.
        """
        self.thisptr.transformToFile()

    def exceptionOccurred(self):
        """Check for pending exceptions without creating a local reference to
        the exception object.
        """
        return <bint>self.thisptr.exceptionOccurred()

    property exceptions:
        def __get__(self):
            """Get exception error messages and their codes as a list of
            MyException objects or None.
            """
            cdef MyException mye
            cdef list errors = []
            cdef int count, i

            if not self.thisptr.exceptionOccurred():
                return None

            count = self.thisptr.exceptionCount()
            if count == 0:
                return None

            for i in range(count):
                mye = MyException()
                mye.e.errorCode.assign(self.thisptr.getErrorCode(i))
                mye.e.errorMessage.assign(self.thisptr.getErrorMessage(i))
                mye.e.linenumber = -1
                mye.e.isType = 1
                mye.e.isGlobal = 1
                mye.e.isStatic = 1
                errors.append(mye)

            return errors

        def __del__(self):
            """Clear any exception thrown."""
            self.thisptr.exceptionClear()
