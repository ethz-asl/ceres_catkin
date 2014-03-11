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
	echo "### Building Google flags ###"
	cd $PACKAGE_DIR/$GFLAGS_PATH && ./configure --with-pic && make -j8 && cd $PACKAGE_DIR
fi

if [ ! -d "$PACKAGE_DIR/$GLOG_PATH" ]; then
	svn co $GLOG_URL $PACKAGE_DIR/$GLOG_PATH
	echo "### Building Google log ###"
	cd $PACKAGE_DIR/$GLOG_PATH && ./configure --with-pic --with-gflags=$PACKAGE_DIR/$GFLAGS_PATH && \
           make -j8 && cd $PACKAGE_DIR
fi

if [ ! -d "$PACKAGE_DIR/$PROTOBUF_PATH" ]; then
	svn co $PROTOBUF_URL $PACKAGE_DIR/$PROTOBUF_PATH
	echo "### Building Google Protocol Buffers ###"
	cd $PACKAGE_DIR/$PROTOBUF_PATH && ./autogen.sh && ./configure && make -j8 && cd $PACKAGE_DIR
fi

echo "### Building Google ceres ###"

echo "### Patching ceres cmake ###"
# Remove -Werror from cmake lists as clang outputs warnings for unused include paths.
sed -i 's/-Werror/-Wall/g' $PACKAGE_DIR/$CERES_PATH/CMakeLists.txt
# Add gflags to linker list for ceres.
sed -i 's/SET(CERES_LIBRARY_DEPENDENCIES ${GLOG_LIBRARIES})/SET(CERES_LIBRARY_DEPENDENCIES ${GLOG_LIBRARIES} ${GFLAGS_LIBRARIES})/g' $PACKAGE_DIR/$CERES_PATH/internal/ceres/CMakeLists.txt

mkdir -p $PACKAGE_DIR/build && cd $PACKAGE_DIR/build

cmake -DCMAKE_CXX_FLAGS=-fPIC -DGFLAGS=ON -DGFLAGS_LIBRARY=$PACKAGE_DIR/$GFLAGS_PATH/.libs/libgflags.a \
      -DGFLAGS_INCLUDE_DIR=$PACKAGE_DIR/$GFLAGS_PATH/src/ -DGLOG_INCLUDE_DIR=$PACKAGE_DIR/$GLOG_PATH/src/ \
      -DGLOG_LIBRARY=$PACKAGE_DIR/$GLOG_PATH/.libs/libglog.a -DCMAKE_INSTALL_PREFIX=$INSTALL_SPACE \
      -DBUILD_SHARED_LIBS=ON -DBUILD_DOCUMENTATION=OFF -DCMAKE_VERBOSE_MAKEFILE=ON \
      $PACKAGE_DIR/$CERES_PATH/ && make -j8


