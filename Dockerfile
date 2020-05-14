# PONZU
# build lime kernel module and volatilty profiles from lime and dwarfDump source.
# change the FROM line to a different OS release if required
# also change the COPY centos-el6-vault.repo line as necessary
#
# [build ponzu]
# docker build -t ponzu:el7 .
#
# [run ponzu]
# docker run --rm -v /YourPath/rpms/:/rpms/ ponzu:el7 3.10.0-123.1.2
#
# I keep the rpms out of the ponzu directory to keep the build process compact
# [optional]
# mkdir /YourPath/rpms
# cp kernel-${KVER}*.rpm /YourPath/rpms
# cp kernel-devel-${KVER}*.rpm /YourPath/rpms
# cp kernel-firmware-${KVER}*.rpm /YourPath/rpms
#
# If you're doing el5 or el7, change the release value below and change the OSVER in build-volatility.sh

FROM centos:centos7

LABEL maintainer Dannen Harris version 3.0

RUN mkdir /lime-module /rpms

# x86_64 only
RUN echo "exclude=*.i386 *.i586 *.i686" >> /etc/yum.conf
RUN yum -y -q -e 0 install autoconf \
 automake \
 gcc \
 gcc-c++ \
 make \
 patch \
 patchutils \
 dracut \
 dracut-kernel \
 elfutils \
 elfutils-devel \
 elfutils-libelf \
 elfutils-libelf-devel \
 git \
 kbd \
 kbd-misc \
 grubby \
 zip \
 zlip && \
 yum -y clean all
WORKDIR /
RUN git clone git://git.code.sf.net/p/libdwarf/code && \
 cd /code && \
 /bin/bash scripts/FIX-CONFIGURE-TIMES && \
 ./configure && \
 make > /tmp/log-file 2>&1  && \
 cp -p /code/dwarfdump/dwarfdump /bin/dwarfdump && \
 cd / && \
 rm -rf /code
RUN git clone https://github.com/504ensicsLabs/LiME.git
RUN git clone https://github.com/volatilityfoundation/volatility.git

COPY centos-el7-vault.repo /etc/yum.repos.d
#RUN yum -y -q -e 0 update
COPY build-volatility.el7.sh /build-volatility.sh

ENTRYPOINT ["/build-volatility.sh"]
