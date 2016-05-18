from .version import version as __version__

# Delay importing extension modules till after they are built...
try:
    from .sxn import *
    from . import xdm

    # This SaxonProcessor object is used only to control creation and
    # destruction of the Saxon/C Java VM...
    _sp_init = SaxonProcessor(False, init=True)

except ImportError:
    pass
