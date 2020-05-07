"""Versioning module for pysaxon."""
from .version import VERSION as __version__
try:
    from .saxonc import *
except ModuleNotFoundError:
    pass
