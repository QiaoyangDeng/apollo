#!/usr/bin/env bash

###############################################################################
# Copyright 2018 The Apollo Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

# Fail on first error.
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# http://caffe.berkeleyvision.org/install_apt.html
# apt-get -y update && \
#    apt-get -y install \
#    caffe-cuda && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

#Note(storypku): Build Caffe from source
apt-get -y update && \
    apt-get -y install \
    libleveldb-dev \
    libsnappy-dev \
    libopencv-dev \
    libhdf5-serial-dev \
    libboost-all-dev \
    liblmdb-dev \
    libatlas-base-dev \
    libopenblas-dev \

# And...
# protobuf/gflags/glog

## packages not used in building
# libflann-dev \
# libopenni-dev \
# libqhull-dev \
# mpi-default-dev
# libvtk6-dev
# libvtk6-qt-dev

# BLAS: install ATLAS by sudo apt-get install libatlas-base-dev or install
# OpenBLAS by sudo apt-get install libopenblas-dev or MKL for better CPU performance.

. /tmp/installers/installer_base.sh

VERSION="1.0"
PKG_NAME="caffe-1.0.tar.gz"
CHECKSUM="71d3c9eb8a183150f965a465824d01fe82826c22505f7aa314f700ace03fa77f"
DOWNLOAD_LINK="https://github.com/BVLC/caffe/archive/1.0.tar.gz"

download_if_not_cached "${PKG_NAME}" "${CHECKSUM}" "${DOWNLOAD_LINK}"

tar xzf "${PKG_NAME}"

MY_DEST_DIR=/usr/local/caffe

#TODO(storypku): More GPU arch support (sm_61 on my GTX 1070)
# And...        -DUSE_NCCL=ON
pushd caffe-${VERSION}
    mkdir build && cd build
    cmake .. \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_python=OFF \
        -DBUILD_docs=OFF \
        -DCMAKE_INSTALL_PREFIX=${MY_DEST_DIR}
    make -j$(nproc)
    make install
popd

rm -rf "${MY_DEST_DIR}/{bin,python}"

# Clean up.
rm -rf ${PKG_NAME} caffe-${VERSION}
apt-get clean && rm -rf /var/lib/apt/lists/*
