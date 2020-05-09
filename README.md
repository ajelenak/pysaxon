# PySaxon

Python interface for the Saxon/C Home Edition XML document processor library.

This version wraps up Saxonica's Cython extension module into a conventionally installable Python package. The PySaxon package started with its own Cython code when it was created in 2016. A never-resolved segmentation fault in one of the tests cooled off enthusiasm for further development.

Fast forward to 2020... Saxonica now provides a Cython extension module while their Saxon/C library has further matured. However, this extension module is available only as source code and distributed in a way that prevents its installation with the usual Python toolset. This is what the current version of PySaxon does. The Saxonica's extension module is available as `pysaxon.saxonc` module. There are currently now plans to provide a more Pythonic API in PySaxon.

## Installation

Requirements:

* Python 3.6 or later
* Cython 0.25 or later
* pytest
* C++ compiler
* Saxon/C Home Edition library (http://www.saxonica.com/saxon-c/index.xml)

[Download](http://www.saxonica.com/download/c.xml) the Saxon-HE/C package for your computer and carefully follow its installation [instructions](http://www.saxonica.com/saxon-c/documentation/index.html#!starting/installing). The Saxon/C code expects the Saxon library (`libsaxon`) and its accompanying dependencies to be placed in specific system locations so special user privileges may be needed.

[Download](https://github.com/ajelenak/pysaxon/releases) the latest PySaxon release and unpack the archive file. Run this command in the folder where the `setup.py` is:
```shell
$ SAXONC_HOME=<SAXON/C install folder> python setup.py install
```
The installation can be verified by running the tests from the same folder as the previous command:
```shell
$ pytest
```
