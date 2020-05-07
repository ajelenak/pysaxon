"""PySaxon setup script"""
import os
from pathlib import Path
from distutils.command.build_ext import build_ext
from distutils.command.build import build
from setuptools import setup, Extension
from Cython.Build import cythonize
from pysaxon import __version__ as VERSION


def extensions(saxon_top_dir):
    """List of Cython implementation files (without file extension)"""
    top_path = Path(saxon_top_dir)
    if not top_path.is_dir():
        raise OSError(top_path.resolve(), ': Not a directory')

    # Compiler settings...
    settings = {
        'include_dirs': [str(top_path.joinpath('Saxon.C.API')),
                         str(top_path.joinpath('Saxon.C.API', 'jni')),
                         str(top_path.joinpath('Saxon.C.API', 'jni', 'unix'))],
    }

    # Additional Saxon source files required...
    addl_src = ['SaxonProcessor.cpp',
                'SaxonCGlue.c',
                'SaxonCXPath.c',
                'XdmValue.cpp',
                'XdmItem.cpp',
                'XdmNode.cpp',
                'XdmAtomicValue.cpp',
                'XsltProcessor.cpp',
                'Xslt30Processor.cpp',
                'XQueryProcessor.cpp',
                'XPathProcessor.cpp',
                'SchemaValidator.cpp']
    for n, src in enumerate(addl_src):
        src_file = top_path.joinpath('Saxon.C.API', src)
        if not src_file.is_file():
            raise OSError('"%s" file not found' % str(addl_src[n]))
        addl_src[n] = str(src_file)

    exts = list()
    modules = ['saxonc']
    for m in modules:
        pyx_src = top_path.joinpath('Saxon.C.API', 'python-saxon', m + '.pyx')
        exts.append(Extension('pysaxon.' + m, [str(pyx_src)] + addl_src,
                              language='c++', **settings))

    return exts

class PySaxonBuild(build):
    """Custom build_py command that takes command-line arguments"""

    description = 'PySaxon custom build_py command'

    user_options = build.user_options
    user_options.extend([('saxon-install=', None, 'Saxon C install folder')])

    def initialize_options(self):
        """Initialize command-line options"""
        build.initialize_options(self)
        self.saxon_install = os.environ.get('SAXONC_HOME')

    def finalize_options(self):
        """Check custom command-line options"""
        build.finalize_options(self)
        if self.saxon_install is None:
            raise ValueError('Missing Saxon C install folder')

    def run(self):
        """Build PySaxon package"""
        sax_api = Path(self.saxon_install).joinpath('Saxon.C.API').resolve()
        if not sax_api.is_dir():
            raise OSError(
                '{}: Not a folder or does not exist'.format(str(sax_api)))
        build.run(self)


class BuildSaxonExt(build_ext):
    """Custom build_ext command"""

    description = 'Build Python extension module for Saxon C library'

    def run(self):
        """Build Saxon extension module"""
        bld = self.distribution.get_command_obj('build')
        self.extensions = cythonize(extensions(bld.saxon_install))
        build_ext.run(self)


setup(
    name='PySaxon',
    version=VERSION,
    description=('Python package for the Saxon-HE/C XML document processor'),
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
    ext_modules=[Extension('pysaxon.foo', ['foo.c'])],  # Force build to run build_ext
    python_requires='>=3.6',
    setup_requires=['Cython>=0.25'],
    tests_require=['pytest'],
    zip_safe=False,
    cmdclass={'build': PySaxonBuild,
              'build_ext': BuildSaxonExt}
)
