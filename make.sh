#!/bin/bash

set -e

PACKAGE_DIR=$(rospack find ceres)
echo "### downloading and unpacking ceres to" $PACKAGE_DIR "###"


CERES_URL="https://ceres-solver.googlesource.com/ceres-solver"
CERES_PATH="ceres_src"
#CERES_TAG="a9f01baf28235b95696aedcbf918e9b1c3184fd6" #version 1.4
CERES_TAG=6bcb8d9c304a3b218f8788018dfdfe368bb7d60c #version 1.5
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
	cd $PACKAGE_DIR/$GFLAGS_PATH && ./configure --with-pic && make -j8 -l4 && cd $PACKAGE_DIR
fi

if [ ! -d "$PACKAGE_DIR/$GLOG_PATH" ]; then
	svn co $GLOG_URL $PACKAGE_DIR/$GLOG_PATH
	echo "### building Google log ###"
	cd $PACKAGE_DIR/$GLOG_PATH && ./configure --with-pic --with-gflags=$PACKAGE_DIR/$GFLAGS_PATH && make -j8 -l4 && cd $PACKAGE_DIR #I couldn't link ceres against a non PIC version
fi

if [ ! -d "$PACKAGE_DIR/$PROTOBUF_PATH" ]; then
	svn co $PROTOBUF_URL $PACKAGE_DIR/$PROTOBUF_PATH
	echo "### building Google Protocol Buffers ###"
	cd $PACKAGE_DIR/$PROTOBUF_PATH && ./autogen.sh && ./configure && make -j8 -l4 && cd $PACKAGE_DIR
#todo: this might need a make install... :(
fi

echo "### building Google ceres ###"

echo "### Patched ceres cmake ###"
#remove -Werror from cmake lists as clang outputs warnings for unused include paths
sed -i 's/-Werror/-Wall/g' $PACKAGE_DIR/$CERES_PATH/CMakeLists.txt

mkdir -p $PACKAGE_DIR/build && cd $PACKAGE_DIR/build

cmake -DGFLAGS_LIB=$PACKAGE_DIR/$GFLAGS_PATH -DGFLAGS_INCLUDE=$PACKAGE_DIR/$GFLAGS_PATH/src -DGFLAGS_LIB=$PACKAGE_DIR/$GFLAGS_PATH/.libs/libgflags.a -DGLOG_INCLUDE=$PACKAGE_DIR/$GLOG_PATH/src -DGLOG_LIB=$PACKAGE_DIR/$GLOG_PATH/.libs/libglog.a $PACKAGE_DIR/$CERES_PATH/ && make -j8 -l4 -I$PACKAGE_DIR/$GLOG_PATH/src

rm -rf $PACKAGE_DIR/bin
rm -rf $PACKAGE_DIR/lib

cp -R $PACKAGE_DIR/build/lib $PACKAGE_DIR/lib
cp -R $PACKAGE_DIR/build/bin $PACKAGE_DIR/bin

