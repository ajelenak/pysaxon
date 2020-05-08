"""Tests for SaxonProcessor extension type."""
import os
import pytest
import pysaxon
from pysaxon import nodekind


@pytest.fixture(scope='module')
def sxnproc():
    sp = pysaxon.PySaxonProcessor(license=False)
    yield sp
    sp.release()


@pytest.fixture
def fresh_saxproc():
    return pysaxon.PySaxonProcessor(license=False)


@pytest.fixture
def tmp_file(tmp_path):
    """Provide a temp file with ``name`` and ``content`` for use in tests."""
    created_files = list()

    def _make_file(name='pysaxon.tmp', content=''):
        f = tmp_path / name
        f.write_text(content)
        created_files.append(f)
        return f

    yield _make_file
    for f in created_files:
        os.remove(str(f))


def test_create_bool():
    """Create SaxonProcessor object with a boolean argument"""
    sp1 = pysaxon.PySaxonProcessor(license=True)
    sp2 = pysaxon.PySaxonProcessor(license=False)
    assert isinstance(sp1, pysaxon.PySaxonProcessor)
    assert isinstance(sp2, pysaxon.PySaxonProcessor)


def test_create_config(tmp_file):
    """Create SaxonProcessor object with a configuration file argument"""
    conf_xml = """\
    <configuration xmlns="http://saxon.sf.net/ns/configuration" edition="HE">
    <global
        allowExternalFunctions="true"
        allowMultiThreading="true"
        allowOldJavaUriFormat="false"
        collationUriResolver="net.sf.saxon.lib.StandardCollationURIResolver"
        collectionUriResolver="net.sf.saxon.lib.StandardCollectionURIResolver"
        compileWithTracing="false"
        defaultCollation="http://www.w3.org/2005/xpath-functions/collation/codepoint"
        defaultCollection="file:///e:/temp"
        dtdValidation="false"
        dtdValidationRecoverable="true"
        errorListener="net.sf.saxon.StandardErrorListener"
        expandAttributeDefaults="true"
        lazyConstructionMode="false"
        lineNumbering="true"
        optimizationLevel="10"
        preEvaluateDocFunction="false"
        preferJaxpParser="true"
        recognizeUriQueryParameters="true"
        schemaValidation="strict"
        serializerFactory=""
        sourceParser=""
        sourceResolver=""
        stripWhitespace="all"
        styleParser=""
        timing="false"
        traceExternalFunctions="true"
        traceListener="net.sf.saxon.trace.XSLTTraceListener"
        traceOptimizerDecisions="false"
        treeModel="tinyTreeCondensed"
        uriResolver="net.sf.saxon.StandardURIResolver"
        usePiDisableOutputEscaping="false"
        useTypedValueCache="true"
        validationComments="false"
        validationWarnings="true"
        versionOfXml="1.0"
        xInclude="false"
    />

    <xslt
        initialMode=""
        initialTemplate=""
        messageReceiver=""
        outputUriResolver=""
        recoveryPolicy="recoverWithWarnings"
        schemaAware="false"
        staticErrorListener=""
        staticUriResolver=""
        styleParser=""
        version="2.1"
        versionWarning="false">
        <extensionElement namespace="http://saxon.sf.net/sql"
            factory="net.sf.saxon.option.sql.SQLElementFactory"/>
    </xslt>

    <xquery
        allowUpdate="true"
        constructionMode="preserve"
        defaultElementNamespace=""
        defaultFunctionNamespace="http://www.w3.org/2005/xpath-functions"
        emptyLeast="true"
        inheritNamespaces="true"
        moduleUriResolver="net.sf.saxon.query.StandardModuleURIResolver"
        preserveBoundarySpace="false"
        preserveNamespaces="true"
        requiredContextItemType="document-node()"
        schemaAware="false"
        staticErrorListener=""
        version="1.1"
        />

    <xsd
        occurrenceLimits="100,250"
        schemaUriResolver="com.saxonica.sdoc.StandardSchemaResolver"
        useXsiSchemaLocation="false"
        version="1.1"
    />

    <serialization
        method="xml"
        indent="yes"
        saxon:indent-spaces="8"
        xmlns:saxon="http://saxon.sf.net/"/>

    <localizations defaultLanguage="en" defaultCountry="US">
        <localization lang="da" class="net.sf.saxon.option.local.Numberer_da"/>
        <localization lang="de" class="net.sf.saxon.option.local.Numberer_de"/>
    </localizations>

    <resources>
        <externalObjectModel>net.sf.saxon.option.xom.XOMObjectModel</externalObjectModel>
        <extensionFunction>s9apitest.TestIntegrationFunctions$SqrtFunction</extensionFunction>
        <schemaDocument>file:///c:/MyJava/samples/data/books.xsd</schemaDocument>
        <schemaComponentModel/>
    </resources>

    <collations>
        <collation uri="http://www.w3.org/2005/xpath-functions/collation/codepoint"
                    class="net.sf.saxon.sort.CodepointCollator"/>
        <collation uri="http://www.microsoft.com/collation/caseblind"
                    class="net.sf.saxon.sort.CodepointCollator"/>
        <collation uri="http://example.com/french" lang="fr" ignore-case="yes"/>
    </collations>
    </configuration>
    """
    with tmp_file('conf.xml', conf_xml) as f:
        sp = pysaxon.PySaxonProcessor(config_file=str(f))
        assert isinstance(sp, pysaxon.PySaxonProcessor)


def test_create_procs(fresh_saxproc):
    """Create XPathProcessor, XsltProcessor, Xslt30Processor from SaxonProcessor objects"""
    xp = fresh_saxproc.new_xpath_processor()
    xsl = fresh_saxproc.new_xslt_processor()
    xsl30 = fresh_saxproc.new_xslt30_processor()
    assert isinstance(xp, pysaxon.PyXPathProcessor)
    assert isinstance(xsl, pysaxon.PyXsltProcessor)
    assert isinstance(xsl30, pysaxon.PyXslt30Processor)


def test_version(sxnproc):
    """SaxonProcessor version string content"""
    ver = sxnproc.version
    assert ver.startswith('Saxon/C')
    assert ver.endswith('from Saxonica')


def test_xpath_proc(fresh_saxproc, tmp_file):
    xp = fresh_saxproc.new_xpath_processor()
    xml = """\
<out>
    <person>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    with tmp_file('cat.xml', xml) as xml_file:
        xp.set_context(file_name=str(xml_file))
        assert xp.effective_boolean_value('count(//person) = 3')
        assert not xp.effective_boolean_value("/out/person/text() = 'text'")


def test_atomic_values(fresh_saxproc):
    value = fresh_saxproc.make_double_value(3.5)
    boolVal = value.boolean_value
    assert boolVal == True
    assert value.string_value == '3.5'
    assert value.double_value == 3.5
    assert value.integer_value == 3
    prim_value = value.primitive_type_name
    assert prim_value == 'Q{http://www.w3.org/2001/XMLSchema}double'


def test_node_list(fresh_saxproc):
    xml = """\
<out>
    <person att1='value1' att2='value2'>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    node = fresh_saxproc.parse_xml(xml_text=xml)
    outNode = node.children[0]
    children = outNode.children
    person_data = str(children)
    assert '<person att1' in person_data


def parse_xml_file(fresh_saxproc, tmp_file):
    xml = """\
<out>
    <person>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    with tmp_file('cat.xml', xml) as f:
        node = fresh_saxproc.parse_xml(xml_file_name=str(f))
    outNode = node.children[0]
    assert outNode.name == 'out'


def test_node(fresh_saxproc):
    xml = """\
<out>
    <person att1='value1' att2='value2'>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    node = fresh_saxproc.parse_xml(xml_text=xml)
    assert node.node_kind == 9
    assert node.size == 1
    outNode = node.children[0]
    assert outNode.name == 'out'
    assert outNode.node_kind == nodekind.ELEMENT
    children = outNode.children
    attrs = children[1].attributes
    assert len(attrs) == 2
    assert children[1].get_attribute_value('att2') == 'value2'
    assert 'value2' in attrs[1].string_value


def test_evaluate(fresh_saxproc):
    xml = """\
<out>
    <person att1='value1' att2='value2'>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    xp = fresh_saxproc.new_xpath_processor()
    node = fresh_saxproc.parse_xml(xml_text=xml)
    assert isinstance(node, pysaxon.PyXdmNode)
    xp.set_context(xdm_item=node)
    value = xp.evaluate('//person')
    assert isinstance(value, pysaxon.PyXdmValue)
    assert value.size == 3


def test_single(fresh_saxproc):
    xml = """\
<out>
    <person>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    xp = fresh_saxproc.new_xpath_processor()
    node = fresh_saxproc.parse_xml(xml_text=xml)
    assert isinstance(node, pysaxon.PyXdmNode)
    xp.set_context(xdm_item=node)
    item = xp.evaluate_single('//person[1]')
    assert isinstance(item, pysaxon.PyXdmItem)
    assert item.size == 1
    assert not item.is_atomic
    assert str(item) == '<person>text1</person>'


def test_declare_variable_value(fresh_saxproc):
    xdm_string_value = fresh_saxproc.make_string_value('This is a test.')
    xpath_processor = fresh_saxproc.new_xpath_processor()
    xpath_processor.set_parameter('s1', xdm_string_value)
    result = xpath_processor.evaluate('$s1')
    assert result is not None
    assert'test.' in result.head.string_value


def test_schema_aware(fresh_saxproc):
    assert not fresh_saxproc.is_schema_aware


def test_validator2(fresh_saxproc):
    fresh_saxproc.set_cwd('.')
    fresh_saxproc.set_configuration_property("xsdversion", "1.1")
    val = None
    try:
        val = fresh_saxproc.new_schema_validator()
    except Exception as e:
        pytest.xfail('Processor is not licensed for schema processing')
    assert val is not None
    print(type(val))
    print(val.exception_occurred())
    invalid_xml = "<?xml version='1.0'?><request><a/><!--comment--></request>"
    sch1 = "<xs:schema xmlns:xs='http://www.w3.org/2001/XMLSchema' elementFormDefault='qualified' attributeFormDefault='unqualified'><xs:element name='request'><xs:complexType><xs:sequence><xs:element name='a' type='xs:string'/><xs:element name='b' type='xs:string'/></xs:sequence><xs:assert test='count(child::node()) = 3'/></xs:complexType></xs:element></xs:schema>"
    input_ = fresh_saxproc.parse_xml(xml_text=invalid_xml)
    assert input_ is not None
    print(type(input_))
    val.set_source_node(input_)
    val.register_schema(xsd_text=sch1)
    val.validate()
    assert val.exception_occurred() is False


def test_validator3(fresh_saxproc):
    fresh_saxproc.set_configuration_property("xsdversion", "1.1")
    val = None
    try:
        val = fresh_saxproc.new_schema_validator()
    except Exception as e:
        pytest.xfail('Processor is not licensed for schema processing')
    val.register_schema(xsd_file="family-ext.xsd")
    val.register_schema(xsd_file="family.xsd")
    val.validate(file_name="family.xml")
    nodea = val.validation_report
    assert val.exception_occurred() is False
    assert nodea is None


def test_xslt_processor():
    sp = pysaxon.PySaxonProcessor()
    xsltproc = sp.new_xslt_processor()
    xml = """\
<out>
    <person>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    node_ = sp.parse_xml(xml_text=xml)
    xsltproc.set_source(xdm_node=node_)
    xsltproc.compile_stylesheet(stylesheet_text="""\
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="values" select="(2,3,4)" />
    <xsl:output method="xml" indent="yes" />
    <xsl:template match="*">
        <output>
            <xsl:value-of select="//person[1]" />
            <xsl:for-each select="$values">
                <out>
                    <xsl:value-of select=". * 3" />
                </out>
            </xsl:for-each>
        </output>
    </xsl:template>
</xsl:stylesheet>
""")
    output2 = xsltproc.transform_to_string()
    assert 'text1' in output2


def test_result_document(sxnproc):
    xsl = """\
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="a">
        <c>d</c>
    </xsl:template>
    <xsl:template match="whatever">
        <xsl:result-document href="out.xml">
            <e>f</e>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
"""
    trans = sxnproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text=xsl)
    in_put = sxnproc.parse_xml(xml_text="<a>b</a>")
    trans.set_initial_match_selection(xdm_value=in_put)
    xdm_value = trans.apply_templates_returning_value()
    assert xdm_value.size == 1


def test_apply_templates_to_xdm(sxnproc):
    source = """\
<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:xs='http://www.w3.org/2001/XMLSchema' version='3.0'>
    <xsl:template match='*'>
        <xsl:param name='a' as='xs:double'/>
        <xsl:param name='b' as='xs:float'/>
        <xsl:sequence select='., $a + $b'/>
    </xsl:template>
</xsl:stylesheet>
"""
    trans = sxnproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text=source)
    trans.set_property("!omit-xml-declaration", "yes")
    param_arr = {"a": sxnproc.make_integer_value(12),
                 "b": sxnproc.make_integer_value(5)}
    trans.set_initial_template_parameters(False, param_arr)
    trans.set_result_as_raw_value(True)
    in_put = sxnproc.parse_xml(xml_text="<e/>")
    trans.set_initial_match_selection(xdm_value=in_put)
    result = trans.apply_templates_returning_value()
    assert result is not None
    assert result.size == 2
    first = result.item_at(0)
    assert not first.is_atomic
    assert "e" in first.get_node_value().name
    second = result.item_at(1)
    assert second.is_atomic
    assert second.get_atomic_value().double_value == 17.0


def test_xslt(sxnproc):
    xsltproc = sxnproc.new_xslt_processor()
    document = sxnproc.parse_xml(xml_text="""\
<out>
    <person>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
""")
    xsltproc.set_source(xdm_node=document)
    xsltproc.compile_stylesheet(stylesheet_text="""\
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="values" select="(2,3,4)" />
    <xsl:output method="xml" indent="yes" />
    <xsl:template match="*">
        <output>
            <xsl:value-of select="//person[1]" />
            <xsl:for-each select="$values">
                <out>
                    <xsl:value-of select=". * 3" />
                </out>
            </xsl:for-each>
        </output>
    </xsl:template>
</xsl:stylesheet>
""")
    output2 = xsltproc.transform_to_string()
    assert output2.startswith('<?xml version="1.0" encoding="UTF-8"?>\n<output>text1<out>6</out')


def test_null_stylesheet(fresh_saxproc):
    trans = fresh_saxproc.new_xslt30_processor()
    result = trans.apply_templates_returning_string()
    assert result is None


def test_xdm_destination(fresh_saxproc):
    trans = fresh_saxproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="""\
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template name="go">
        <a />
    </xsl:template>
</xsl:stylesheet>
""")
    root = trans.call_template_returning_value("go")
    assert root is not None
    assert root.head is not None
    assert not root.head.is_atomic
    node = root.head
    assert node is not None
    assert isinstance(node, pysaxon.PyXdmNode)
    assert node.node_kind == 9


def test_xdm_destination_with_item_separator(fresh_saxproc):
    trans = fresh_saxproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="""\
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template name="go">
        <xsl:comment>A</xsl:comment>
        <out />
        <xsl:comment>Z</xsl:comment>
    </xsl:template>
    <xsl:output method="xml" item-separator="§" />
</xsl:stylesheet>
""")
    root = trans.call_template_returning_value("go")
    node = root
    assert str(node) == '<!--A-->§<out/>§<!--Z-->'
    assert node.node_kind == 9


def test_pipeline(fresh_saxproc):
    stage1 = fresh_saxproc.new_xslt30_processor()
    xsl = """\
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <a>
            <xsl:copy-of select="." />
        </a>
    </xsl:template>
</xsl:stylesheet>
"""
    xml = "<z/>"
    stage1.compile_stylesheet(stylesheet_text=xsl)
    in_ = fresh_saxproc.parse_xml(xml_text=xml)
    assert in_ is not None

    stage2 = fresh_saxproc.new_xslt30_processor()
    stage2.compile_stylesheet(stylesheet_text=xsl)
    stage3 = fresh_saxproc.new_xslt30_processor()
    stage3.compile_stylesheet(stylesheet_text=xsl)
    stage4 = fresh_saxproc.new_xslt30_processor()
    stage4.compile_stylesheet(stylesheet_text=xsl)
    stage5 = fresh_saxproc.new_xslt30_processor()
    stage5.compile_stylesheet(stylesheet_text=xsl)

    stage1.set_property("!omit-xml-declaration", "yes")
    stage1.set_property("!indent", "no")
    stage1.set_initial_match_selection(xdm_value=in_)
    d1 = stage1.apply_templates_returning_value()
    assert d1 is not None

    stage2.set_property("!omit-xml-declaration", "yes")
    stage2.set_property("!indent", "no")
    stage2.set_initial_match_selection(xdm_value=d1)
    d2 = stage2.apply_templates_returning_value()
    assert d2 is not None

    stage3.set_property("!omit-xml-declaration", "yes")
    stage3.set_property("!indent", "no")
    stage3.set_initial_match_selection(xdm_value=d2)
    d3 = stage3.apply_templates_returning_value()
    assert d3 is not None

    stage4.set_property("!omit-xml-declaration", "yes")
    stage4.set_property("!indent", "no")
    stage4.set_initial_match_selection(xdm_value=d3)
    d4 = stage4.apply_templates_returning_value()
    assert d3 is not None

    stage5.set_property("!indent", "no")
    stage5.set_property("!omit-xml-declaration", "yes")
    stage5.set_initial_match_selection(xdm_value=d4)
    sw = stage5.apply_templates_returning_string()
    assert sw is not None
    assert "<a><a><a><a><a><z/></a></a></a></a></a>" in sw


def test_pipeline_short(fresh_saxproc):
    xsl = """\
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <a>
            <xsl:copy-of select="." />
        </a>
    </xsl:template>
</xsl:stylesheet>
"""
    xml = "<z/>"
    stage1 = fresh_saxproc.new_xslt30_processor()
    stage2 = fresh_saxproc.new_xslt30_processor()
    stage1.compile_stylesheet(stylesheet_text=xsl)
    stage2.compile_stylesheet(stylesheet_text=xsl)
    stage1.set_property("!omit-xml-declaration", "yes")
    stage2.set_property("!omit-xml-declaration", "yes")
    in_ = fresh_saxproc.parse_xml(xml_text=xml)
    assert in_ is not None
    stage1.set_initial_match_selection(xdm_value=in_)
    out = stage1.apply_templates_returning_value()
    assert out is not None
    stage2.set_initial_match_selection(xdm_value=out)
    sw = stage2.apply_templates_returning_string()
    assert "<a><a><z/></a></a>" in sw


def test_xslt_parameter(fresh_saxproc, tmp_file):
    input_ = fresh_saxproc.parse_xml(xml_text="""\
<out>
    <person>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
""")
    value1 = fresh_saxproc.make_integer_value(10)
    trans = fresh_saxproc.new_xslt_processor()
    trans.set_parameter("numParam", value1)
    assert value1 is not None
    trans.set_source(xdm_node=input_)
    xsl = """\
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="numParam" select="2" />
    <xsl:output method="xml" indent="yes" />
    <xsl:template match="*">
        <output>
            <xsl:for-each select="person">
                <out>
                    <xsl:value-of select="." />
                </out>
            </xsl:for-each>
            <out>
                <xsl:value-of select="$numParam*2" />
            </out>
        </output>
        <xsl:message>Testing message1</xsl:message>
        <xsl:message>Testing message2</xsl:message>
    </xsl:template>
    <xsl:template name="custom">
        <out>text1</out>
    </xsl:template>
</xsl:stylesheet>
"""
    with tmp_file('test.xsl', xsl) as f:
        output_ = trans.transform_to_string(stylesheet_file=str(f))
    assert '<out>20</out>' in output_


def test_context_not_root(fresh_saxproc):
    node = fresh_saxproc.parse_xml(xml_text="<doc><e>text</e></doc>")
    trans = fresh_saxproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="""\
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:variable name="x" select="." />
    <xsl:template match="/">errorA</xsl:template>
    <xsl:template match="e">
        [
        <xsl:value-of select="name($x)" />
        ]
    </xsl:template>
</xsl:stylesheet>
""")
    assert node is not None
    assert isinstance(node, pysaxon.PyXdmNode)
    assert len(node.children) > 0
    eNode = node.children[0].children[0]
    assert eNode is not None
    trans.set_global_context_item(xdm_item=node)
    trans.set_initial_match_selection(xdm_value=eNode)
    result = trans.apply_templates_returning_string()
    assert result is not None
    assert "[" in result


def test_resolve_uri(fresh_saxproc):
    trans = fresh_saxproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="""\
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:err="http://www.w3.org/2005/xqt-errors">
    <xsl:template name="go">
        <xsl:try>
            <xsl:variable name="uri" as="xs:anyURI" select= "resolve-uri('notice trailing space /out.xml')" />
            <xsl:message select="$uri" />
            <xsl:result-document href="{$uri}">
                <out />
            </xsl:result-document>
            <xsl:catch>
                <xsl:sequence select= "'\$err:code: ' || $err:code  || ', $err:description: ' || $err:description" />
            </xsl:catch>
        </xsl:try>
    </xsl:template>
</xsl:stylesheet>
""")
    value = trans.call_template_returning_value("go")
    assert value is not None
    item = value.head
    assert "code" in item.string_value


def test_call_function(fresh_saxproc):
    source = """\
<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://localhost/" version="3.0">
    <xsl:function name="f:add" visibility="public">
        <xsl:param name="a" />
        <xsl:param name="b" />
        <xsl:sequence select="$a + $b" />
    </xsl:function>
</xsl:stylesheet>
"""
    trans = fresh_saxproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text=source)
    param_arr = [fresh_saxproc.make_integer_value(2),
                fresh_saxproc.make_integer_value(3)]
    v = trans.call_function_returning_value("{http://localhost/}add", param_arr)
    assert isinstance(v.head, pysaxon.PyXdmItem)
    assert v.head.is_atomic
    assert v.head.get_atomic_value().integer_value == 5
    trans.clear_parameters()


def test_call_function_arg_conversion(fresh_saxproc):
    trans = fresh_saxproc.new_xslt30_processor()
    source = """\
<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://localhost/" version="3.0">
    <xsl:function name="f:add" visibility="public">
        <xsl:param name="a" />
        <xsl:param name="b" />
        <xsl:sequence select="$a + $b" />
    </xsl:function>
</xsl:stylesheet>
"""
    trans.compile_stylesheet(stylesheet_text=source)
    v = trans.call_function_returning_value(
        "{http://localhost/}add",
        [fresh_saxproc.make_integer_value(2),
         fresh_saxproc.make_integer_value(3)])
    assert isinstance(v.head, pysaxon.PyXdmItem)
    assert v.head.is_atomic
    assert v.head.get_atomic_value().double_value == 5.0e0


def test_xquery(fresh_saxproc, tmp_file):
    query_proc = fresh_saxproc.new_xquery_processor()
    query_proc.clear_properties()
    query_proc.clear_parameters()
    cat = """\
<out>
    <person>text1</person>
    <person>text2</person>
    <person>text3</person>
</out>
"""
    with tmp_file('cat.xml', cat) as xml_file, \
         tmp_file('catOutput.xml') as cat_out:
        query_proc.set_property("s", str(xml_file))
        query_proc.set_property("qs", "<out>{count(/out/person)}</out>")
        result = query_proc.run_query_to_string()
        assert result is not None
        query_proc.run_query_to_file(output_file_name=str(cat_out))
        node = fresh_saxproc.parse_xml(xml_file_name=str(cat_out))
        xp = fresh_saxproc.new_xpath_processor()
        xp.set_context(xdm_item=node)
        assert xp.effective_boolean_value("/out/text()=3")
