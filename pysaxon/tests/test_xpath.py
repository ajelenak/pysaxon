"""Tests for XPathProcessor extension type"""
import pysaxon


def test_single(sxnproc, xpathproc):
    xml = b"""\
    <out>
        <person>text1</person>
        <person>text2</person>
        <person>text3</person>
    </out>
    """
    node = sxnproc.parseXmlFromString(xml)
    assert isinstance(node, pysaxon.xdm.Node)
    xpathproc.setContextItem(node)
    item = xpathproc.evaluate_single(b'//person[1]')
    assert isinstance(item, pysaxon.xdm.Item)
    assert item.size == 1
    assert not item.isAtomic
    assert item.getStringValue(sxnproc) == b'<person>text1</person>'
