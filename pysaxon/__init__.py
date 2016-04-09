from .version import version as __version__

# Delay importing extension modules till after they are built...
try:
    from . import sxn
except ImportError:
    pass
