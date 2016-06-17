from libcpp.string cimport string
from libc.string cimport const_char
from libc.stdio cimport printf
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


cdef void print_ptr(char *msg, void *ptr):
    printf('%s = %p\n', msg, ptr)


cdef object make_item(cpp.XdmItem *ptr, char *when_null):
    """make_item(XdmItem *ptr, char *when_null)

    Wrap a XdmItem* pointer as xdm.Item object.

    If the XdmItem* pointer is NULL then depending on the ``when_null``
    parameter either a None is returned (when_null='or None') or a ValueError
    exception is raised (when_null='or error').
    """
    cdef Item i
    if ptr is NULL:
        if when_null == b'or None':
            return None
        else:
            raise ValueError("xdm.Item object's pointer is NULL")
    else:
        i = Item()
        i.thisptr = <cpp.XdmValue*>ptr
        return i


cdef object make_node(cpp.XdmNode *ptr, char *when_null):
    """make_node(XdmNode *ptr, char *when_null)

    Wrap a XdmNode* pointer as xdm.Node object.

    If the XdmNode* pointer is NULL then depending on the ``when_null``
    paramter either a None is returned (when_null='or None') or a ValueError
    exception is raised (when_null='or error').
    """
    cdef Node n
    if ptr is NULL:
        if when_null == b'or None':
            return None
        else:
            raise ValueError("xdm.Node object's pointer is NULL")
    else:
        n = Node()
        n.thisptr = <cpp.XdmValue*>ptr
        return n


cdef class Value:
    """XdmValue extension type."""

    def __cinit__(self):
        if type(self) == AtomicValue:
            return
        self.thisptr = NULL
        self._size = 0
        self._cntr = 0

    def __dealloc__(self):
        if self.thisptr is not NULL:
            self.thisptr.releaseXdmValue()
            del self.thisptr
            self.thisptr = NULL

    property type:
        def __get__(self):
            return <cpp.XDM_TYPE>self.thisptr.getType()

    property processor:
        """Set SaxonProcessor for this xdm.Value object."""
        def __set__(self, SaxonProcessor p not None):
            if p.thisptr is NULL:
                raise ValueError('SaxonProcessor object is NULL')
            self.thisptr.setProcessor(p.thisptr)

    property size:
        def __get__(self):
            return self.thisptr.size()

    def getHead(self):
        """Get the first item in the sequence.

        None is returned when the sequence is empty.
        """
        cdef cpp.XdmItem *iptr
        iptr = self.thisptr.getHead()
        return make_item(iptr, b'or None')

    def itemAt(self, int n):
        """Get the n'th item in the value, counting from zero.

        If n is less than zero, or greater than or equal to the number of items
        in the value, then raise a ValueError exception.
        """
        cdef cpp.XdmItem *iptr = NULL
        cdef int size = self.size
        if not (0 <= n < size):
            raise ValueError('Item at %d out of range' % n)
        iptr = self.thisptr.itemAt(n)
        return make_item(iptr, b'or error')

    def checkFailures(self):
        cdef const_char *temp
        temp = (<cpp.XdmValue*>self.thisptr).checkFailures()
        if temp == NULL:
            return b''
        else:
            return <bytes>temp

    def __iter__(self):
        """Iterator to support XdmValue.itemAt() functionality."""
        self._size = self.size
        self._cntr = 0
        return self

    def __next__(self):
        """Get the value's items sequentially from the first one."""
        if self._cntr >= self._size:
            raise StopIteration
        cdef cpp.XdmItem *iptr = NULL
        iptr = self.thisptr.itemAt(self._cntr)
        self._cntr += 1
        return make_item(iptr, b'or error')


cdef class Item(Value):
    """XdmItem extension type."""

    def __dealloc__(self):
        cdef cpp.XdmItem *ptr
        if self.thisptr is not NULL:
            ptr = <cpp.XdmItem*>self.thisptr
            del ptr
            self.thisptr = NULL

    property type:
        def __get__(self):
            return <cpp.XDM_TYPE>(<cpp.XdmItem*>self.thisptr).getType()

    property isAtomic:
        def __get__(self):
            return <bint>(<cpp.XdmItem*>self.thisptr).isAtomic()

    property size:
        def __get__(self):
            cdef cpp.XdmItem *ptr = <cpp.XdmItem*>self.thisptr
            return ptr.size()

    def itemAt(self, int n):
        """Get the n'th item in the value, counting from zero.

        If n is less than zero, or greater than or equal to the number of items
        in the value, then raise a ValueError exception.
        """
        cdef cpp.XdmItem *iptr = NULL
        cdef int size = self.size
        if not (0 <= n < size):
            raise ValueError('Item at %d out of range' % n)
        iptr = (<cpp.XdmItem*>self.thisptr).itemAt(n)
        return make_item(iptr, b'or error')

    def getStringValue(self, SaxonProcessor proc not None):
        """Get item's string value or None."""
        cdef const_char *temp
        temp = (<cpp.XdmItem*>self.thisptr).getStringValue(proc.thisptr)
        if temp is NULL:
            return None
        else:
            return temp

    def __iter__(self):
        """Iterator to support XdmItem.itemAt() functionality."""
        self._size = self.size
        self._cntr = 0
        return self

    def __next__(self):
        """Get the n'th item in the value's sequence, counting from zero."""
        if self._cntr >= self._size:
            raise StopIteration
        cdef cpp.XdmItem *iptr = NULL
        iptr = (<cpp.XdmItem*>self.thisptr).itemAt(self._cntr)
        self._cntr += 1
        return make_item(iptr, b'or error')


cdef class AtomicValue(Item):
    """XdmAtomicValue extension type."""

    def __cinit__(self, AtomicValue av=None):
        cdef cpp.XdmAtomicValue *avptr = NULL
        if av is None:
            avptr = new cpp.XdmAtomicValue()
        else:
            avptr = new cpp.XdmAtomicValue((<cpp.XdmAtomicValue*>av.thisptr)[0])

        if avptr is NULL:
            raise ValueError("xdm.AtomicValue object's pointer is NULL")
        else:
            self.thisptr = <cpp.XdmValue*>avptr
            self._size = 0
            self._cntr = 0

    def __dealloc__(self):
        cdef cpp.XdmAtomicValue *ptr
        if self.thisptr is not NULL:
            ptr = <cpp.XdmAtomicValue*>self.thisptr
            del ptr
            self.thisptr = NULL

    property type:
        def __get__(self):
            return <cpp.XDM_TYPE>(<cpp.XdmAtomicValue*>self.thisptr).getType()

        def __set__(self, string ty):
            (<cpp.XdmAtomicValue*>self.thisptr).setType(ty)

    property isAtomic:
        def __get__(self):
            return <bint>(<cpp.XdmAtomicValue*>self.thisptr).isAtomic()


cdef class Node(Item):
    """XdmNode extension type."""

    def __dealloc__(self):
        cdef cpp.XdmNode *ptr
        if self.thisptr is not NULL:
            ptr = <cpp.XdmNode*>self.thisptr
            del ptr
            self.thisptr = NULL

    property isAtomic:
        def __get__(self):
            return <bint>(<cpp.XdmNode*>self.thisptr).isAtomic()

    property type:
        """Type (XDM_TYPE value) of the node."""
        def __get__(self):
            return <cpp.XDM_TYPE>(<cpp.XdmNode*>self.thisptr).getType()

    property kind:
        """Node's kind (XDM_NODE_KIND) as an all-lowercase string."""
        def __get__(self):
            cdef str kind
            cdef cpp.XDM_NODE_KIND nk
            nk = (<cpp.XdmNode*>self.thisptr).getNodeKind()
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
                kind = 'processing-instruction'
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
            cdef const_char *temp
            temp = (<cpp.XdmNode*>self.thisptr).getNodeName()
            if temp == NULL:
                return None
            else:
                temp

    property baseuri:
        """Get node's base URI or None."""
        def __get__(self):
            cdef const_char *temp
            temp = (<cpp.XdmNode*>self.thisptr).getBaseUri()
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
    #         vptr = (<cpp.XdmNode*>self.thisptr).getTypedValue()
    #         if vptr == NULL:
    #             return None
    #         else:
    #             val = Value()
    #             val.thisptr = vptr
    #             return val

    property parent:
        """Get node's parent node."""
        def __get__(self):
            cdef cpp.XdmNode *nptr = NULL
            nptr = (<cpp.XdmNode*>self.thisptr).getParent()
            return make_node(nptr, b'or None')

    def getAttributeValue(self, char *name):
        """Get attribute's value as a bytes object or None."""
        cdef const_char *temp
        temp = (<cpp.XdmNode*>self.thisptr).getAttributeValue(name)
        if temp == NULL:
            return None
        else:
            temp

    property attribute_count:
        """Get the number of the node's attributes."""
        def __get__(self):
            return (<cpp.XdmNode*>self.thisptr).getAttributeCount()

    property children_count:
        """Get the number of the node's children."""
        def __get__(self):
            return (<cpp.XdmNode*>self.thisptr).getChildCount()

    property attributes:
        """Get node's attributes as a list of Node objects."""
        def __get__(self):
            cdef list nodes = []
            cdef cpp.XdmNode **n
            cdef int count, i

            count = (<cpp.XdmNode*>self.thisptr).getAttributeCount()
            if count > 0:
                n = (<cpp.XdmNode*>self.thisptr).getAttributeNodes()
                for i in range(count):
                    nodes.append(make_node(n[i], b'or error'))

            return nodes

    property children:
        """Get node's children as a list of Node objects."""
        def __get__(self):
            cdef list nodes = []
            cdef cpp.XdmNode **n
            cdef int count, i

            count = (<cpp.XdmNode*>self.thisptr).getChildCount()
            if count > 0:
                n = (<cpp.XdmNode*>self.thisptr).getChildren()
                for i in range(count):
                    nodes.append(make_node(n[i], b'or error'))

            return nodes
