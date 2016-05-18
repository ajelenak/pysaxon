# Dockerfile for PySaxon development work
FROM python:latest

MAINTAINER Aleksandar Jelenak "aleksandar dot jelenak at gmail dot com"

USER root

#
# Java commands below borrowed from:
# https://github.com/docker-library/openjdk/blob/89851f0abc3a83cfad5248102f379d6a0bd3951a/8-jdk/Dockerfile
#

RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV JAVA_VERSION 8u72
ENV JAVA_DEBIAN_VERSION 8u72-b15-1~bpo8+1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
        ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
    && rm -rf /var/lib/apt/lists/* \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

#
# End of borrowed Java commands
#

# Invalidate Docker's image cache by changing the value so all subsequent
# commands will run
ENV DOCKERFILE_LAST_UPDATED 2016-03-25

# Install required Python modules
RUN pip3 install --upgrade pip \
    && pip3 install cython pytest six jupyter-console

# Install the Saxon/C HE library. The install file must first be downloaded from
# http://www.saxonica.com/saxon-c/index.xml#download and unzipped.
COPY libsaxon-HEC-setup64-v1.0.1 /opt/
RUN mkdir /opt/saxon-HEC-v1.0.1 \
    && printf "/opt/saxon-HEC-v1.0.1\n" | /opt/libsaxon-HEC-setup64-v1.0.1 \
    && rm /opt/libsaxon-HEC-setup64-v1.0.1 \
    && ln -s /opt/saxon-HEC-v1.0.1/libsaxonhec.so /usr/lib/ \
    && ln -s /opt/saxon-HEC-v1.0.1/rt /usr/lib/rt \
    && ln -s /opt/saxon-HEC-v1.0.1/saxon-data /usr/lib
ENV LD_LIBRARY_PATH=/opt/saxon-HEC-v1.0.1/rt/lib/amd64:$LD_LIBRARY_PATH

# Make a volume for pysaxon dev environment
RUN mkdir -p /opt/pysaxon
VOLUME /opt/pysaxon

# Point to Saxon/C installation directory
ENV SAXONC_HOME=/opt/saxon-HEC-v1.0.1

CMD ["/bin/bash"]
