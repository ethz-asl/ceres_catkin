#!/bin/bash

set -e

INSTALL_SPACE=$1

PACKAGE_DIR=$(pwd)
cd $PACKAGE_DIR
echo "### Downloading and unpacking ceres to " $PACKAGE_DIR "###"
echo "### Install to " $INSTALL_SPACE "###"


CERES_URL="https://ceres-solver.googlesource.com/ceres-solver"
CERES_PATH="ceres_src"
CERES_TAG=4d52ef5457ccc23fe04f75b0f4451ebb1e852a27 #version 1.8
GLOG_URL="http://google-glog.googlecode.com/svn/trunk/ "
GLOG_PATH="dependencies/glog"
GFLAGS_URL="http://gflags.googlecode.com/svn/trunk/"
GFLAGS_PATH="dependencies/gflags"
PROTOBUF_URL="http://protobuf.googlecode.com/svn/trunk/"
PROTOBUF_PATH="dependencies/protobuf"

#create directory for deps
mkdir -p $PACKAGE_DIR/dependencies

#clone or update the sources
if [ ! -d "$PACKAGE_DIR/$CERES_PATH" ]; then
	git clone $CERES_URL $PACKAGE_DIR/$CERES_PATH/
	cd $PACKAGE_DIR/$CERES_PATH/ && git checkout $CERES_TAG && cd $PACKAGE_DIR 
else
	cd $PACKAGE_DIR/$CERES_PATH/ && git fetch && cd $PACKAGE_DIR
	cd $PACKAGE_DIR/$CERES_PATH/ && git checkout $CERES_TAG && cd $PACKAGE_DIR 
fi

if [ ! -d "$PACKAGE_DIR/$GFLAGS_PATH" ]; then
	svn co $GFLAGS_URL $PACKAGE_DIR/$GFLAGS_PATH
	echo "### building Google flags ###"
	cd $PACKAGE_DIR/$GFLAGS_PATH && ./configure --with-pic && make -j8 && cd $PACKAGE_DIR
fi

if [ ! -d "$PACKAGE_DIR/$GLOG_PATH" ]; then
	svn co $GLOG_URL $PACKAGE_DIR/$GLOG_PATH
	echo "### building Google log ###"
	cd $PACKAGE_DIR/$GLOG_PATH && ./configure --with-pic --with-gflags=$PACKAGE_DIR/$GFLAGS_PATH && \
           make -j8 && cd $PACKAGE_DIR #I couldn't link ceres against a non PIC version
fi

if [ ! -d "$PACKAGE_DIR/$PROTOBUF_PATH" ]; then
	svn co $PROTOBUF_URL $PACKAGE_DIR/$PROTOBUF_PATH
	echo "### building Google Protocol Buffers ###"
	cd $PACKAGE_DIR/$PROTOBUF_PATH && ./autogen.sh && ./configure && make -j8 && cd $PACKAGE_DIR
#todo: this might need a make install... :(
fi

echo "### building Google ceres ###"

echo "### Patched ceres cmake ###"
#remove -Werror from cmake lists as clang outputs warnings for unused include paths
sed -i 's/-Werror/-Wall/g' $PACKAGE_DIR/$CERES_PATH/CMakeLists.txt

mkdir -p $PACKAGE_DIR/build && cd $PACKAGE_DIR/build

cmake -DCMAKE_CXX_FLAGS=-fPIC -DGFLAGS=ON -DGFLAGS_LIBRARY_DIR_HINTS=$PACKAGE_DIR/$GFLAGS_PATH/ \
      -DGFLAGS_INCLUDE_DIR=$PACKAGE_DIR/$GFLAGS_PATH/src -DGLOG_INCLUDE_DIR=$PACKAGE_DIR/$GLOG_PATH/src \
      -DGLOG_LIBRARY_DIR_HINTS=$PACKAGE_DIR/$GLOG_PATH/ -DCMAKE_INSTALL_PREFIX=$INSTALL_SPACE \
      -DBUILD_SHARED_LIBS=ON -DBUILD_DOCUMENTATION=OFF -DCMAKE_VERBOSE_MAKEFILE=ON -DMINIGLOG=ON \
      $PACKAGE_DIR/$CERES_PATH/ && make -j8


