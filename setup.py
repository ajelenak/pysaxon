from __future__ import print_function, unicode_literals
import os
import sys
import os.path as osp
from functools import reduce
from setuptools import setup, Extension  # , Command
from setuptools.command.test import test
from Cython.Build import cythonize
from pysaxon import __version__ as VERSION


def localpath(*args):
    """Generate absolute path from arguments in ``args`` using this file as the
    reference.
    """
    return osp.abspath(reduce(osp.join, (osp.dirname(__file__),) + args))


def extensions():
    # List of Cython implementation files (without file extension)...
    modules = ['sxn', 'xdm']

    # Get home directories for Java and Saxon/C...
    saxonhome = os.environ.get('SAXONC_HOME')
    javahome = os.environ.get('JAVA_HOME')
    if not all((saxonhome, javahome)):
        raise ValueError('SAXONC_HOME and/or JAVA_HOME not set')

    # Compiler settings...
    settings = {
        'libraries': ['saxonhec'],
        'include_dirs': [osp.join(saxonhome, 'Saxon.C.API'),
                         osp.join(javahome, 'include')],
        'library_dirs': [saxonhome, '/usr/lib']
    }
    if sys.platform.startswith('linux'):
        settings['include_dirs'].append(osp.join(javahome, 'include', 'linux'))
    else:
        raise NotImplemented(sys.platform, 'not supported yet')

    # See: http://stackoverflow.com/q/19123623
    if os.name != 'nt':
        settings['runtime_library_dirs'] = settings['library_dirs']

    # Additional source files required...
    addl_src = ['SaxonCGlue.c', 'SaxonCXPath.c', 'XdmValue.cpp',
                'XdmItem.cpp', 'XdmNode.cpp', 'XdmAtomicValue.cpp',
                'SaxonProcessor.cpp', 'XsltProcessor.cpp',
                'XQueryProcessor.cpp', 'XPathProcessor.cpp',
                'SchemaValidator.cpp']
    for n in range(len(addl_src)):
        addl_src[n] = osp.join(saxonhome, 'Saxon.C.API', addl_src[n])
        if not osp.isfile(addl_src[n]):
            raise IOError('"%s" file not found' % addl_src[n])

    exts = list()
    for m in modules:
        pyx_src = localpath('pysaxon', m + '.pyx')
        exts.append(Extension('pysaxon.' + m, [pyx_src] + addl_src,
                              language='c++', **settings))

    return cythonize(exts)


class sxn_test(test):
    """Custom setuptools test command using py.test."""
    description = 'Options for py.test command'
    user_options = [('pytest-opts=', 'a', 'Options to pass to py.test')]

    def initialize_options(self):
        self.pytest_opts = []

    def finalize_options(self):
        pass

    def run(self):
        import pytest
        import _pytest.main

        # Customize messages for pytest exit codes...
        msg = {_pytest.main.EXIT_OK: 'OK',
               _pytest.main.EXIT_TESTSFAILED: 'Tests failed',
               _pytest.main.EXIT_INTERRUPTED: 'Interrupted',
               _pytest.main.EXIT_INTERNALERROR: 'Internal error',
               _pytest.main.EXIT_USAGEERROR: 'Usage error',
               _pytest.main.EXIT_NOTESTSCOLLECTED: 'No tests collected'}

        bldobj = self.distribution.get_command_obj('build')
        bldobj.run()
        exitcode = pytest.main(self.pytest_opts)
        print(msg[exitcode])
        sys.exit(exitcode)


setup(
    name='PySaxon',
    version=VERSION,
    description=('Python interface to the Saxon-HE/C XML document processor '
                 'C++ library'),
    # long_description='',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'Intended Audience :: Information Technology',
        'Intended Audience :: Science/Research',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Text Processing :: Markup :: XML'],
    author='Aleksandar Jelenak',
    author_email='aleksandar dot jelenak at gmail dot com',
    maintainer='Aleksandar Jelenak',
    maintainer_email='aleksandar dot jelenak at gmail dot com',
    # url = '',
    # download_url = '',
    packages=['pysaxon'],
    # package_data = package_data,
    ext_modules=extensions(),
    install_requires=['six'],
    setup_requires=['Cython>=0.20', 'six'],
    tests_require=['pytest', 'six'],
    cmdclass={'test': sxn_test},
    zip_safe=False
)
