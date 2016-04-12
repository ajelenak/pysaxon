from __future__ import print_function, unicode_literals
import os
import sys
import os.path as osp
# import json
from functools import reduce
# from datetime import datetime as dt
from setuptools import setup, Extension  # ,Command
# from setuptools.command.build_ext import build_ext
# from distutils.command.build import build
from Cython.Build import cythonize
from pysaxon import __version__ as VERSION


def localpath(*args):
    """Generate absolute path from arguments in ``args`` using this file as the
    reference.
    """
    return osp.abspath(reduce(osp.join, (osp.dirname(__file__),) + args))


# class configure(Command):
#     """Configure build options for PySaxon."""
#     _conf_file = localpath('config.json')
#     description = 'Configure pysaxon build options'
#     user_options = [('saxonhome=', 's', 'Saxon HE/C install directory'),
#                     ('javahome=', 'j', 'Java home directory')]

#     def initialize_options(self):
#         # Remove the old configuration file...
#         try:
#             os.unlink(self._conf_file)
#         except Exception:
#             pass

#         self.saxonhome = os.environ.get('SAXONC_HOME')
#         self.javahome = os.environ.get('JAVA_HOME')

#     def finalize_options(self):
#         for n, e in enumerate((self.saxonhome, self.javahome)):
#             if e:
#                 if not osp.isdir(e):
#                     raise ValueError('%s is not a directory' % e)
#             else:
#                 raise ValueError('%s unknown' % configure.user_options[n])

#     def run(self):
#         # Determine location of the Saxon library file...
#         check_lib = list()
#         libsaxon = 'libsaxonhec.so'
#         if self.saxonhome is None:
#             raise ValueError('What is Saxon HE/C install directory?')

#         # Look for libsaxon file in these directories...
#         if os.name != 'posix':
#             raise NotImplementedError(
#                 'Non-POSIX operating systems not supported yet')

#         # Create expected library file paths to check...
#         dirs = ['/usr/lib', self.saxonhome]
#         for d in dirs:
#             check_lib.append(osp.join(d, libsaxon))

#         # Verify one of the options where the libsaxon file is...
#         for l in check_lib:
#             if osp.isfile(l):
#                 break
#         else:
#             raise ValueError('%s file not found in %s' % (libsaxon, check_lib))

#         # Save configuration in the config.json file...
#         conf = {'last_run': dt.utcnow().timestamp(),
#                 'saxon_home': self.saxonhome,
#                 'java_home': self.javahome}
#         with open(self._conf_file, 'w') as f:
#             print('Saving configuration in file "%s"' % f.name)
#             json.dump(conf, f)

#         print('Summary of PySaxon configuration')
#         print('    Saxon home is: %s' % self.saxonhome)
#         print('    Java home is: %s' % self.javahome)


# class sxn_build_ext(build_ext):
#     """Custom build command incorporating cythonization, compilation and
#     linking.
#     """
#     def run(self):
#         # List of Cython implementation files (without file extension)...
#         modules = ['sxn']

#         # Get home directories for Java and Saxon/C...
#         config = self.distribution.get_command_obj('configure')
#         config.run()

#         # Compiler settings...
#         settings = {
#             'libraries': ['saxonhec'],
#             'include_dirs': [osp.join(config.saxonhome, 'Saxon.C.API'),
#                              osp.join(config.javahome, 'include')],
#             'library_dirs': [config.saxonhome, '/usr/lib']
#         }
#         if sys.platform.startswith('linux'):
#             settings['include_dirs'].append(
#                 osp.join(config.javahome, 'include', 'linux'))
#         else:
#             raise NotImplemented(sys.platform, 'not supported yet')

#         # See: http://stackoverflow.com/q/19123623
#         if os.name != 'nt':
#             settings['runtime_library_dirs'] = settings['library_dirs']

#         # Additional source files required...
#         addl_src = ['SaxonCGlue.c', 'SaxonCXPath.c', 'XdmValue.cpp',
#                     'XdmItem.cpp', 'XdmNode.cpp', 'XdmAtomicValue.cpp',
#                     'SaxonProcessor.cpp', 'XsltProcessor.cpp',
#                     'XQueryProcessor.cpp', 'XPathProcessor.cpp',
#                     'SchemaValidator.cpp']
#         for n in range(len(addl_src)):
#             addl_src[n] = osp.join(config.saxonhome, 'Saxon.C.API',
#                                    addl_src[n])
#             if not osp.isfile(addl_src[n]):
#                 raise IOError('"%s" file not found' % addl_src[n])

#         extensions = list()
#         for m in modules:
#             pyx_src = localpath('pysaxon', m+'.pyx')
#             extensions.append(Extension('pysaxon.'+m, [pyx_src]+addl_src,
#                                         **settings))

#         # Do the build...
#         build_ext.run(self)


# class sxn_build(build):
#     """Simple class to ensure "setup.py build_ext" command is triggered.

#     For some reason with "setup.py build" does not run the build_ext
#     command.
#     """
#     def run(self):
#         self.run_command('build_ext')
#         build.run(self)


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
        pyx_src = localpath('pysaxon', m+'.pyx')
        exts.append(Extension('pysaxon.'+m, [pyx_src]+addl_src, language='c++',
                              **settings))

    return cythonize(exts)


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
    setup_requires=['Cython>=0.20',
                    'nose'],
    # cmdclass={'configure': configure,
    #           'build_ext': sxn_build_ext,
    #           'build': sxn_build}
)
