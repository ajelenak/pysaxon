"""Declare MyException, SaxonApiException, and SaxonProcessor."""
from libcpp.string cimport string
from libcpp.map cimport map

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
        SaxonProcessor(const char *configFile) except +
        SaxonProcessor(int l) except +
        int exceptionOccurred() except +
        void exceptionClear() except +
        SaxonApiException* getException() except +
        void release() except +
        void setcwd(const char *cwd) except +
        void setResourcesDirectory(const char *dir) except +
        const char* getResourcesDirectory() except +
        void setConfigurationProperty(const char * name, const char * value) except +
        void clearConfigurationProperties() except +
        const char* version() except +
        XPathProcessor* newXPathProcessor() except +
        XsltProcessor* newXsltProcessor() except +
        SchemaValidator* newSchemaValidator() except +
        XdmNode* parseXmlFromString(const char* source) except +
        XdmNode* parseXmlFromFile(const char* source) except +
        XdmNode* parseXmlFromUri(const char* source) except +

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
        const char* getStringValue(SaxonProcessor *proc) except +
        XdmItem* getHead() except +
        XdmItem* itemAt(int n) except +
        int size() except +
        XDM_TYPE getType() except +

cdef extern from "XdmValue.h":
    cdef cppclass XdmValue:
        XdmValue() except +
        XdmValue(SaxonProcessor *p) except +
        XdmValue* addXdmValueWithType(const char *tStr, const char *val) except +
        void addXdmItem(XdmItem *val) except +
        void releaseXdmValue() except +
        XdmItem* getHead() except +
        XdmItem* itemAt(int n) except +
        int size() except +
        int getRefCount() except +
        void incrementRefCount() except +
        void decrementRefCount() except +
        void setProcessor(SaxonProcessor *p) except +
        const char* checkFailures() except +
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
        const char* getNodeName() except +
        const char* getBaseUri() except +
        XdmValue* getTypedValue() except +
        XdmNode* getParent() except +
        const char* getAttributeValue(const char *str) except +
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
        const char* getStringValue() except +
        long getLongValue() except +
        void setType(string ty) except +
        int isAtomic()
        XDM_TYPE getType() except +

cdef extern from "XPathProcessor.h":
    cdef cppclass XPathProcessor:
        XPathProcessor() except +
        XPathProcessor(SaxonProcessor* proc, string cwd) except +
        void setBaseURI(const char *uriStr) except +
        XdmValue* evaluate(const char *xpathStr) except +
        XdmItem* evaluateSingle(const char *xpathStr) except +
        void setContextItem(XdmItem *item) except +
        void setcwd(const char* cwd) except +
        void setContextFile(const char *filename) except +
        bint effectiveBooleanValue(const char *xpathStr) except +
        void setParameter(const char *name, XdmValue *value) except +
        bint removeParameter(const char *name) except +
        void setProperty(const char *name, const char *value) except +
        void declareNamespace(const char *prefix, const char *uri) except +
        map[string,XdmValue*]& getParameters() except +
        map[string,string]& getProperties() except +
        void clearParameters(bint deleteValues) except +
        void clearProperties() except +
        bint exceptionOccurred() except +
        void exceptionClear() except +
        int exceptionCount() except +
        const char* getErrorMessage(int i) except +
        const char* getErrorCode(int i) except +
        const char* checkException() except +

cdef extern from "XsltProcessor.h":
    cdef cppclass XsltProcessor:
        XsltProcessor() except +
        XsltProcessor(SaxonProcessor* proc, string cwd) except +
        void setcwd(const char* cwd) except +
        void setSourceFromXdmValue(XdmItem *value) except +
        void setSourceFromFile(const char *filename) except +
        void setOutputFile(const char *outfile) except +
        void setParameter(const char *name, XdmValue *value) except +
        XdmValue* getParameter(const char *name) except +
        bint removeParameter(const char *name) except +
        void setProperty(const char* name, const char* value) except +
        const char* getProperty(const char* name) except +
        map[string,XdmValue*]& getParameters() except +
        map[string,string]& getProperties() except +
        void clearParameters(bint deleteValues) except +
        void clearProperties() except +
        XdmValue* getXslMessages() except +
        void transformFileToFile(const char* sourcefile, const char* stylesheetfile, const char* outputfile) except +
        const char* transformFileToString(const char* sourcefile, const char* stylesheetfile) except +
        XdmValue* transformFileToValue(const char* sourcefile, const char* stylesheetfile)
        void compileFromFile(const char *stylesheet)
        void compileFromString(const char *stylesheet)
        void compileFromXdmNode(XdmNode *node)
        void releaseStylesheet()
        const char* transformToString()
        XdmValue* transformToValue()
        void transformToFile()
        bint exceptionOccurred()
        const char* checkException()
        void exceptionClear()
        int exceptionCount()
        const char* getErrorMessage(int i)
        const char* getErrorCode(int i)
        SaxonProcessor* getSaxonProcessor()

cdef extern from "SchemaValidator.h":
    cdef cppclass SchemaValidator:
        pass
