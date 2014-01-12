#!/bin/bash

set -e

PACKAGE_DIR=$(rospack find ceres)
echo "### downloading and unpacking ceres to" $PACKAGE_DIR "###"


CERES_URL="https://ceres-solver.googlesource.com/ceres-solver"
CERES_PATH="ceres_src"
#CERES_TAG="a9f01baf28235b95696aedcbf918e9b1c3184fd6" #version 1.4
#CERES_TAG=6bcb8d9c304a3b218f8788018dfdfe368bb7d60c #version 1.5
#CERES_TAG=01fb8a3133b74112900361af4b7195118c0c9c9e #version 1.6rc2
#CERES_TAG=f3e1267aa1f00e4a5b35d30de2d18b9aff7b2c05 # june 4th 2013
#CERES_TAG=e948986669c83f7c2c4df0ae7a26440b3789ec7d #version 1.7
#CERES_TAG=468a23f2111e3fea45c900082e644a45dae743b7 #version 1.7 with fixed parameter removal bug
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
      -DGLOG_LIBRARY_DIR_HINTS=$PACKAGE_DIR/$GLOG_PATH/ $PACKAGE_DIR/$CERES_PATH/ && \
      make -j8

rm -rf $PACKAGE_DIR/bin
rm -rf $PACKAGE_DIR/lib

cp -R $PACKAGE_DIR/build/lib $PACKAGE_DIR/lib
cp -R $PACKAGE_DIR/build/bin $PACKAGE_DIR/bin

