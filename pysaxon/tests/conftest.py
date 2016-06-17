import pytest
import pysaxon


@pytest.fixture
def sxnproc():
    return pysaxon.SaxonProcessor()


@pytest.fixture
def xpathproc(sxnproc):
    return sxnproc.newXPathProcessor()
