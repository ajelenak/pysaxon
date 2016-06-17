"""Declare MyException, SaxonApiException, and SaxonProcessor."""
from libcpp.string cimport string
from libcpp.map cimport map
from libc.string cimport const_char


cdef extern from "SaxonProcessor.h":
    ctypedef struct MyException:
        string errorCode
        string errorMessage
        int linenumber
        bint isType
        bint isStatic
        bint isGlobal

    cdef cppclass SaxonApiException:
        SaxonApiException() except +
        SaxonApiException(const SaxonApiException &ex) except +
        void clear() except +
        int count() except +
        MyException getException(int i) except +

    cdef cppclass SaxonProcessor:
        SaxonProcessor() except +
        SaxonProcessor(const_char *configFile) except +
        SaxonProcessor(bint l) except +
        int exceptionOccurred() except +
        void exceptionClear() except +
        SaxonApiException* getException() except +
        void release() except +
        void setcwd(const_char *cwd) except +
        void setResourcesDirectory(const_char *dir) except +
        const_char* getResourcesDirectory() except +
        void setConfigurationProperty(const_char * name, const_char * value) except +
        void clearConfigurationProperties() except +
        const_char* version() except +
        XPathProcessor* newXPathProcessor() except +
        XsltProcessor* newXsltProcessor() except +
        SchemaValidator* newSchemaValidator() except +
        XdmNode* parseXmlFromString(const_char* source) except +
        XdmNode* parseXmlFromFile(const_char* source) except +
        XdmNode* parseXmlFromUri(const_char* source) except +
        const_char * getStringValue(XdmItem * item) except +

cdef extern from "XdmValue.h":
    ctypedef enum XDM_TYPE:
        XDM_VALUE = 1,
        XDM_ITEM = 2,
        XDM_NODE = 3,
        XDM_ATOMIC_VALUE = 4,
        XDM_FUNCTION_ITEM = 5

cdef extern from "XdmItem.h":
    cdef cppclass XdmItem:
        XdmItem() except +
        int isAtomic() except +
        const_char* getStringValue(SaxonProcessor *proc) except +
        XdmItem* getHead() except +
        XdmItem* itemAt(int n) except +
        int size() except +
        XDM_TYPE getType() except +

cdef extern from "XdmValue.h":
    cdef cppclass XdmValue:
        XdmValue() except +
        XdmValue(SaxonProcessor *p) except +
        XdmValue* addXdmValueWithType(const_char *tStr, const_char *val) except +
        void addXdmItem(XdmItem *val) except +
        void releaseXdmValue() except +
        XdmItem* getHead() except +
        XdmItem* itemAt(int n) except +
        int size() except +
        int getRefCount() except +
        void incrementRefCount() except +
        void decrementRefCount() except +
        void setProcessor(SaxonProcessor *p) except +
        const_char* checkFailures() except +
        XDM_TYPE getType() except +

cdef extern from "XdmNode.h":
    ctypedef enum XDM_NODE_KIND:
        DOCUMENT = 9,
        ELEMENT = 1,
        ATTRIBUTE = 2,
        TEXT = 3,
        COMMENT = 8,
        PROCESSING_INSTRUCTION = 7,
        NAMESPACE = 13,
        UNKNOWN = 0

    cdef cppclass XdmNode:
        int isAtomic() except +
        XDM_NODE_KIND getNodeKind() except +
        const_char* getNodeName() except +
        const_char* getBaseUri() except +
        XdmValue* getTypedValue() except +
        XdmNode* getParent() except +
        const_char* getAttributeValue(const_char *str) except +
        int getAttributeCount() except +
        XdmNode** getAttributeNodes() except +
        XdmNode** getChildren() except +
        int getChildCount() except +
        XDM_TYPE getType() except +

cdef extern from "XdmAtomicValue.h":
    cdef cppclass XdmAtomicValue:
        XdmAtomicValue() except +
        XdmAtomicValue(const XdmAtomicValue &d) except +
        string getPrimitiveTypeName() except +
        int getBooleanValue() except +
        double getDoubleValue() except +
        const_char* getStringValue() except +
        long getLongValue() except +
        void setType(string ty) except +
        int isAtomic()
        XDM_TYPE getType() except +

cdef extern from "XPathProcessor.h":
    cdef cppclass XPathProcessor:
        XPathProcessor() except +
        XPathProcessor(SaxonProcessor* proc, string cwd) except +
        void setBaseURI(const_char *uriStr) except +
        XdmValue* evaluate(const_char *xpathStr) except +
        XdmItem* evaluateSingle(const_char *xpathStr) except +
        void setContextItem(XdmItem *item) except +
        void setcwd(const_char* cwd) except +
        void setContextFile(const_char *filename) except +
        bint effectiveBooleanValue(const_char *xpathStr) except +
        void setParameter(const_char *name, XdmValue *value) except +
        bint removeParameter(const_char *name) except +
        void setProperty(const_char *name, const_char *value) except +
        void declareNamespace(const_char *prefix, const_char *uri) except +
        map[string,XdmValue*]& getParameters() except +
        map[string,string]& getProperties() except +
        void clearParameters(bint deleteValues) except +
        void clearProperties() except +
        bint exceptionOccurred() except +
        void exceptionClear() except +
        int exceptionCount() except +
        const_char* getErrorMessage(int i) except +
        const_char* getErrorCode(int i) except +
        const_char* checkException() except +

cdef extern from "XsltProcessor.h":
    cdef cppclass XsltProcessor:
        XsltProcessor() except +
        XsltProcessor(SaxonProcessor* proc, string cwd) except +
        void setcwd(const_char* cwd) except +
        void setSourceFromXdmValue(XdmItem *value) except +
        void setSourceFromFile(const_char *filename) except +
        void setOutputFile(const_char *outfile) except +
        void setParameter(const_char *name, XdmValue *value) except +
        XdmValue* getParameter(const_char *name) except +
        bint removeParameter(const_char *name) except +
        void setProperty(const_char* name, const_char* value) except +
        const_char* getProperty(const_char* name) except +
        map[string,XdmValue*]& getParameters() except +
        map[string,string]& getProperties() except +
        void clearParameters(bint deleteValues) except +
        void clearProperties() except +
        XdmValue* getXslMessages() except +
        void transformFileToFile(const_char* sourcefile, const_char* stylesheetfile, const_char* outputfile) except +
        const_char* transformFileToString(const_char* sourcefile, const_char* stylesheetfile) except +
        XdmValue* transformFileToValue(const_char* sourcefile, const_char* stylesheetfile)
        void compileFromFile(const_char *stylesheet)
        void compileFromString(const_char *stylesheet)
        void compileFromXdmNode(XdmNode *node)
        void releaseStylesheet()
        const_char* transformToString()
        XdmValue* transformToValue()
        void transformToFile()
        bint exceptionOccurred()
        const_char* checkException()
        void exceptionClear()
        int exceptionCount()
        const_char* getErrorMessage(int i)
        const_char* getErrorCode(int i)
        SaxonProcessor* getSaxonProcessor()

cdef extern from "SchemaValidator.h":
    cdef cppclass SchemaValidator:
        pass
