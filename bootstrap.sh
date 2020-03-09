#!/bin/bash

# Print commands and exit on errors
set -xe

# Update VM box
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y \
               -o Dpkg::Options::="--force-confdef" \
               -o Dpkg::Options::="--force-confold" \
               upgrade

# Install P4C dependencies
apt-get install -y --no-install-recommends --fix-missing \
        automake \
        bison \
        cmake \
        flex \
        g++ \
        git \
        libboost-dev \
        libboost-graph-dev \
        libboost-iostreams-dev \
        libfl-dev \
        libgc-dev \
        libgmp-dev \
        libtool \
        llvm \
        pkg-config \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        tcpdump

pip3 install \
     scapy \
     ipaddr \
     ply

#Get the number of cores to speed up the compilation process
NUM_CORES=`grep -c ^processor /proc/cpuinfo`

# Set compilation directory to /opt
cd /opt

# Install protobuf - v3.6.1 as that's recommended by P4C
PROTOBUF_COMMIT="v3.6.1"

git clone https://github.com/google/protobuf.git
cd protobuf
git checkout ${PROTOBUF_COMMIT}
export CFLAGS="-Os"
export CXXFLAGS="-Os"
export LDFLAGS="-Wl,-s"
./autogen.sh
./configure --prefix=/usr
make -j${NUM_CORES}
make install
ldconfig
unset CFLAGS CXXFLAGS LDFLAGS
# Force install python module
cd python
sudo python3 setup.py install
cd ../..

# Now install the P4C compiler - use the master branch as it is not versioned
git clone --recursive https://github.com/p4lang/p4c
mkdir -p p4c/build
cd p4c/build
cmake ..
# P4C compilations is RAM hungry so only use one thread
make -j1
make install
ldconfig
cd ../..
