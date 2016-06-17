"""Tests for SaxonProcessor extension type."""

import os
from tempfile import mkstemp
import pytest
import six
from pysaxon import *


def test_create_bool():
    """Create SaxonProcessor object with a boolean argument"""
    sp1 = SaxonProcessor(True)
    sp2 = SaxonProcessor(False)
    assert isinstance(sp1, SaxonProcessor)
    assert isinstance(sp2, SaxonProcessor)


@pytest.mark.skip('Error: SaxonDll.processor is NULL in constructor(configFile)')
def test_create_config():
    """Create SaxonProcessor object with a configuration file argument"""
    conf_xml = b"""\
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
    try:
        fd, fname = mkstemp(suffix='.xml')
        os.write(fd, conf_xml)
        os.close(fd)
        if not os.path.exists(fname):
            raise IOError('%s does not exist' % fname)

        with open(fname, 'r') as f:
            print(f.read())

        sp = SaxonProcessor(fname.encode('utf-8'))
        assert isinstance(sp, SaxonProcessor)
    finally:
        os.unlink(fname)


def test_create_procs():
    """Create XPathProcessor, XsltProcessor from SaxonProcessor object"""
    sp = SaxonProcessor()
    xp = sp.newXPathProcessor()
    xsl = sp.newXsltProcessor()
    assert isinstance(xp, XPathProcessor)
    assert isinstance(xsl, XsltProcessor)


def test_create_init():
    """Only one init SaxonProcessor object can exist"""
    with pytest.raises(RuntimeError):
        SaxonProcessor(init=True)


def test_version():
    """SaxonProcessor version string content"""
    sp = SaxonProcessor()
    ver = sp.version
    assert isinstance(ver, six.binary_type)
    assert ver.startswith(b'Saxon-HE')
    assert ver.endswith(b'from Saxonica')
