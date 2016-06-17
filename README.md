# PySaxon

Python interface to the Saxon/C Home Edition XML document processor library.

**Note: The code is still in the very early stage of development. The API is not stable and can change after each commit.**

## Installation

The standard Python method is supported:

    $ python setup.py install

Requirements:

* Python 3 (support for Python 2 not yet verified)
* Saxon/C Home Edition library (currently only available for Linux)
* Python packages:
    * six
    * Cython
    * pytest (for testing only)

## For Developers

Those interested in contributing to this project should consider using the Docker image with all the requirements already installed and the Saxon/C Home Edition library properly configured. Since the library is only available for Linux using this image will both ensure the consistency of the development environment as well as allow Mac and Windows users to work on their computers.

Here are the steps to set up the development environment:

1. Change to a directory which will be used as the repository's base, let's call it ``SOME_DIRECTORY``.

1. Clone the PySaxon repository:
```
$ git clone https://github.com/ajelenak/pysaxon.git
```
There should be a ``pysaxon`` directory in ``SOME_DIRECTORY``.

1. [Install](https://docs.docker.com/engine/installation/) and start Docker.

1. Pull the Docker image:
```
$ docker pull ajelenak/pysaxon
```

1. Start the image (create a Docker container):
```
$ docker run -it -v SOME_DIRECTORY:/opt/pysaxon ajelenak/pysaxon
```
If all the above steps were successful, the running Docker container should have the PySaxon repository available at ``/opt/pysaxon``.

1. Change directory to ``/opt/pysaxon``.

1. Build the PySaxon package:
```
$ python setup.py develop
```

1. [Optional] Run the tests:
```
$ python setup.py test
```
