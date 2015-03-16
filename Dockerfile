################################################
# Source build of the REDHAWK SDR framework for 
# raspbian wheezy.  Someone should really make
# armv7 packages but in the meantime, this 
# docker image should have the 1.10.2 release
# installed.
#
################################################

FROM resin/rpi-raspbian:wheezy
MAINTAINER Youssef Bagoulla <youssef.bagoulla@axiosengineering.com>

USER root
WORKDIR /redhawk-src

# Setup the environment variables required for build
ENV OSSIEHOME /usr/local/redhawk/core
ENV SDRROOT /var/redhawk/sdr
ENV PYTHONPATH $OSSIEHOME/lib/python:$PYTHONPATH
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-armhf
ENV PATH $OSSIEHOME/bin:$JAVA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH $OSSIEHOME/lib64:$OSSIEHOME/lib:$LD_LIBRARY_PATH

# Grab all the dependencies + wget, vim, & tar
# Note that we are using boost1.50 in place of the system default 1.49 due to a bug in the spinlock class for armv7 discussed here:
# https://svn.boost.org/trac/boost/ticket/5331
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential openmpi-bin libopenmpi-dev python2.7 python2.7-dev uuid uuid-dev openjdk-7-jdk libtool autotools-dev autoconf automake python-omniorb omnievents omniidl omniidl-python omniorb omniorb-idl omniorb-nameserver libcos4-dev libomnievents-dev libomniorb4-dev python-numpy python-omniorb liblog4cxx10-dev xsdcxx libboost1.50-dev libboost-system1.50-dev libboost-filesystem1.50-dev libboost-regex1.50-dev libboost-thread1.50-dev vim libxml2-utils python-jinja2 junit4 libcppunit-dev packagekit-gtk3-module wget tar

# Make OSSIEHOME and SDRROOT
RUN mkdir -p $OSSIEHOME
RUN mkdir -p $SDRROOT

# Grab and extract the sourcecode to be installed
RUN wget http://sourceforge.net/projects/redhawksdr/files/redhawk-source/1.10.2/redhawk-src-1.10.2-201502110808.tar.gz
RUN tar -xf redhawk-src-1.10.2-201502110808.tar.gz

# The top level build script requires user interaction so rather than using that we
# could go into each directory and run the build script there but it uses make -j
# and that eats too much memory for the poor pi.  So we are left to do it by hand.

# First the core framework
WORKDIR /redhawk-src/redhawk-src-1.10.2/redhawk/src
RUN ./reconf
RUN ./configure
RUN make 
RUN make install

# Then bulkio
WORKDIR /redhawk-src/redhawk-src-1.10.2/bulkioInterfaces
RUN ./reconf
RUN ./configure
RUN make 
RUN make install

# Then the GPP
WORKDIR /redhawk-src/redhawk-src-1.10.2/GPP/python
RUN ./reconf
RUN ./configure
RUN make install

# Then front end
WORKDIR /redhawk-src/redhawk-src-1.10.2/frontendInterfaces
RUN ./reconf
RUN ./configure
RUN make 
RUN make install

# Then burstio
WORKDIR /redhawk-src/redhawk-src-1.10.2/burstioInterfaces
RUN ./reconf
RUN ./configure
RUN make
RUN make install

# Clean up the build artifacts
RUN rm -rf /redhawk-src

# Now we just need to run nodeconfig
WORKDIR $SDRROOT/dev/devices/GPP/python
RUN ./nodeconfig.py --inplace --domainname=REDHAWK_DEV

# REDHAWK default install is x86 only, so we need to replace a few of the default files
# to set it up for the armv7l machine type
ADD DeviceManager.Linux.armv7l.prf.xml $SDRROOT/dev/mgr/DeviceManager.Linux.armv7l.prf.xml
ADD DeviceManager.spd.xml $SDRROOT/dev/mgr/DeviceManager.spd.xml
ADD DomainManager.spd.xml $SDRROOT/dom/mgr/DomainManager.spd.xml

