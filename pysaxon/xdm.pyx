from libcpp.string cimport string
from .sxn cimport SaxonProcessor

# Constants
VALUE = cpp.XDM_VALUE
ITEM = cpp.XDM_ITEM
NODE = cpp.XDM_NODE
ATOMIC_VALUE = cpp.XDM_ATOMIC_VALUE
FUNCTION_ITEM = cpp.XDM_FUNCTION_ITEM

DOCUMENT = cpp.DOCUMENT
ELEMENT = cpp.ELEMENT
ATTRIBUTE = cpp.ATTRIBUTE
TEXT = cpp.TEXT
COMMENT = cpp.COMMENT
PROCESSING_INSTRUCTION = cpp.PROCESSING_INSTRUCTION
NAMESPACE = cpp.NAMESPACE
UNKNOWN = cpp.UNKNOWN


cdef class Value:
    """XdmValue extension type."""

    # def __cinit__(self, SaxonProcessor p=None):
    #     cdef cpp.SaxonProcessor *ptr
    #     self._size = 0
    #     self._cntr = 0
    #     if p is None:
    #         self.thisptr = new cpp.XdmValue()
    #     else:
    #         ptr = p.thisptr
    #         self.thisptr = new cpp.XdmValue(ptr)

    def __cinit__(self):
        self.thisptr = NULL

    def __dealloc__(self):
        if self.thisptr != NULL:
            self.thisptr.releaseXdmValue()
            del self.thisptr

    property type:
        def __get__(self):
            return <cpp.XDM_TYPE>self.thisptr.getType()

    property processor:
        """Set SaxonProcessor for this Value object."""
        def __set__(self, SaxonProcessor p not None):
            self.thisptr.setProcessor(p.thisptr)

    property size:
        def __get__(self):
            return self.thisptr.size()

    def getHead(self):
        """Get the first item in the sequence.

        None is returned when the sequence is empty.
        """
        cdef cpp.XdmItem *iptr
        cdef Item i
        iptr = self.thisptr.getHead()
        if iptr == NULL:
            return None
        else:
            i = Item()
            i.thisptr = iptr
            return i

    def itemAt(self, int n):
        cdef Item it = Item()
        cdef int size = self.size
        if n > size:
            raise ValueError('There are only %d items' % size)
        it.thisptr = self.thisptr.itemAt(n)
        return it

    def checkFailures(self):
        cdef char *temp
        temp = <char*>self.thisptr.checkFailures()
        if temp == NULL:
            return None
        else:
            return temp

    def __iter__(self):
        """Iterator to support XdmValue.itemAt() functionality."""
        self._size = self.thisptr.size()
        self._cntr = 0
        return self

    def __next__(self):
        """Get the value's items sequentially from the first one."""
        if self._cntr >= self._size:
            raise StopIteration
        cdef Item it
        it = Item()
        it.thisptr = self.thisptr.itemAt(self._cntr)
        self._cntr += 1
        return it


cdef class Item:
    """XdmItem extension type."""

    def __cinit__(self):
        # self.thisptr = new cpp.XdmItem()
        self.thisptr = NULL

    def __dealloc__(self):
        if self.thisptr != NULL:
            del self.thisptr

    property type:
        def __get__(self):
            return <cpp.XDM_TYPE>self.thisptr.getType()

    property isAtomic:
        def __get__(self):
            return <bint>self.thisptr.isAtomic()

    property size:
        def __get__(self):
            return <int>self.thisptr.size()

    def getHead(self):
        """Get the first item in the sequence.

        None is returned when the sequence is empty.
        """
        cdef cpp.XdmItem *iptr
        cdef Item i
        iptr = self.thisptr.getHead()
        if iptr == NULL:
            return None
        else:
            i = Item()
            i.thisptr = iptr
            return i

    def __iter__(self):
        """Iterator to support XdmItem.itemAt() functionality."""
        self._size = self.thisptr.size()
        self._cntr = 0
        return self

    def __next__(self):
        """Get the n'th item in the value's sequence, counting from zero."""
        if self._cntr >= self._size:
            raise StopIteration
        cdef Item it
        it = Item()
        it.thisptr = self.thisptr.itemAt(self._cntr)
        self._cntr += 1
        return it

    def getStringValue(self, SaxonProcessor proc not None):
        """Get string value or None."""
        cdef char *temp
        temp = <char*>self.thisptr.getStringValue(proc.thisptr)
        if temp == NULL:
            return None
        else:
            temp


cdef class AtomicValue:
    """XdmAtomicValue extension type."""

    def __cinit__(self, AtomicValue av=None):
        if av is None:
            self.thisptr = new cpp.XdmAtomicValue()
        else:
            self.thisptr = new cpp.XdmAtomicValue(av.thisptr[0])

    def __dealloc__(self):
        del self.thisptr

    property type:
        def __get__(self):
            return <cpp.XDM_TYPE>self.thisptr.getType()

        def __set__(self, string ty):
            self.thisptr.setType(ty)

    property isAtomic:
        def __get__(self):
            return <bint>self.thisptr.isAtomic()


cdef class Node:
    """XdmNode extension type."""

    def __cinit__(self):
        self.thisptr = NULL

    def __dealloc__(self):
        if self.thisptr:
            del self.thisptr

    property isAtomic:
        def __get__(self):
            return <bint>self.thisptr.isAtomic()

    property type:
        """Type (XDM_TYPE value) of the node."""
        def __get__(self):
            return <cpp.XDM_TYPE>self.thisptr.getType()

    property kind:
        """Node's kind (XDM_NODE_KIND) as an all-lowercase string."""
        def __get__(self):
            cdef str kind
            cdef cpp.XDM_NODE_KIND nk
            nk = self.thisptr.getNodeKind()
            if nk == cpp.DOCUMENT:
                kind = 'document'
            elif nk == cpp.ELEMENT:
                kind = 'element'
            elif nk == cpp.ATTRIBUTE:
                kind = 'attribute'
            elif nk == cpp.TEXT:
                kind = 'text'
            elif nk == cpp.COMMENT:
                kind = 'comment'
            elif nk == cpp.PROCESSING_INSTRUCTION:
                kind = 'processing_instruction'
            elif nk == cpp.NAMESPACE:
                kind = 'namespace'
            elif nk == cpp.UNKNOWN:
                kind = 'unknown'
            else:
                raise ValueError('Unknown node kind: %d' % nk)
            return kind

    property name:
        """Get the name of the node, as a string in the form of a EQName.

        In the case of unnamed nodes (for example, text and comment nodes)
        return None.
        """
        def __get__(self):
            cdef char *temp
            temp = <char*>self.thisptr.getNodeName()
            if temp == NULL:
                return None
            else:
                temp

    property baseuri:
        """Get node's base URI or None."""
        def __get__(self):
            cdef char *temp
            temp = <char*>self.thisptr.getBaseUri()
            if temp == NULL:
                return None
            else:
                temp

    # Causes ImportError due to missing symbol.
    # property value:
    #     """Get node's value as an Value() (XdmValue) object or None."""
    #     def __get__(self):
    #         cdef Value val
    #         cdef cpp.XdmValue *vptr
    #         vptr = self.thisptr.getTypedValue()
    #         if vptr == NULL:
    #             return None
    #         else:
    #             val = Value()
    #             val.thisptr = vptr
    #             return val

    property parent:
        """Get node's parent node."""
        def __get__(self):
            cdef Node n = Node()
            n.thisptr = self.thisptr.getParent()
            return n

    def getAttributeValue(self, char *name):
        """Get attribute's value as a bytes object or None."""
        cdef char *temp
        temp = <char*>self.thisptr.getAttributeValue(name)
        if temp == NULL:
            return None
        else:
            temp

    property attribute_count:
        """Get the number of the node's attributes."""
        def __get__(self):
            return <int>self.thisptr.getAttributeCount()

    property children_count:
        """Get the number of the node's children."""
        def __get__(self):
            return <int>self.thisptr.getChildCount()

    property attributes:
        """Get node's attributes as a list of Node objects."""
        def __get__(self):
            cdef list nodes = []
            cdef cpp.XdmNode **n
            cdef int count, i
            cdef Node node

            count = self.thisptr.getAttributeCount()
            if count > 0:
                n = self.thisptr.getAttributeNodes()
                for i in range(count):
                    node = Node()
                    node.thisptr = n[i]
                    nodes.append(node)

            return nodes

    property children:
        """Get node's children as a list of Node objects."""
        def __get__(self):
            cdef list nodes = []
            cdef cpp.XdmNode **n
            cdef int count, i
            cdef Node node

            count = self.thisptr.getChildCount()
            if count > 0:
                n = self.thisptr.getChildren()
                for i in range(count):
                    node = Node()
                    node.thisptr = n[i]
                    nodes.append(node)

            return nodes
