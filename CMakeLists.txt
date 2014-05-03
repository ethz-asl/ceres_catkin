cmake_minimum_required(VERSION 2.8.3)
project(ceres_catkin)

find_package(catkin_simple REQUIRED)
catkin_simple()

include_directories(${Eigen_INCLUDE_DIRS})

include(ExternalProject)

set(VERSION 1.8.0)
set(CERES_TAG 4d52ef5457ccc23fe04f75b0f4451ebb1e852a27) #version 1.8

# The configure step fails at catkin_package() if this directory
# doesn't exist yet. Create it at configure time!
file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include)

ExternalProject_Add(protobuf
  SVN_REPOSITORY http://protobuf.googlecode.com/svn/trunk/
  CONFIGURE_COMMAND cd ../protobuf && ./autogen.sh && ./configure --with-pic --prefix=${CATKIN_DEVEL_PREFIX}
  BUILD_COMMAND cd ../protobuf && make -j8
  INSTALL_COMMAND cd ../protobuf && make install -j8
)

ExternalProject_Add(gflags
  SVN_REPOSITORY http://gflags.googlecode.com/svn/trunk/
  CONFIGURE_COMMAND cd ../gflags && ./autogen.sh && ./configure --with-pic GFLAGS_NAMESPACE=gflags --prefix=${CATKIN_DEVEL_PREFIX}
  BUILD_COMMAND cd ../gflags && make -j8
  INSTALL_COMMAND cd ../gflags && make install -j8
)

ExternalProject_Add(glog
  DEPENDS gflags
  SVN_REPOSITORY http://google-glog.googlecode.com/svn/trunk/
  CONFIGURE_COMMAND cd ../glog && ./configure --with-pic --with-gflags=${CATKIN_DEVEL_PREFIX} --prefix=${CATKIN_DEVEL_PREFIX}
  BUILD_COMMAND cd ../glog && make -j8
  INSTALL_COMMAND cd ../glog && make install -j8
)

ExternalProject_Add(ceres_src
  DEPENDS gflags glog protobuf
  GIT_REPOSITORY https://ceres-solver.googlesource.com/ceres-solver
  GIT_TAG ${CERES_TAG}
  PATCH_COMMAND cd ../ceres_src && ${PROJECT_SOURCE_DIR}/patch.sh
  CONFIGURE_COMMAND cmake -DCMAKE_CXX_FLAGS=-fPIC -DGFLAGS=ON -DGFLAGS_LIBRARY=${CATKIN_DEVEL_PREFIX}/lib/libgflags.a -DGFLAGS_INCLUDE_DIR=${CATKIN_DEVEL_PREFIX}/include/ -DGLOG_INCLUDE_DIR=${CATKIN_DEVEL_PREFIX}/include -DGLOG_LIBRARY=${CATKIN_DEVEL_PREFIX}/lib/libglog.a -DCMAKE_INSTALL_PREFIX=${CATKIN_DEVEL_PREFIX} -DBUILD_SHARED_LIBS=ON -DBUILD_DOCUMENTATION=OFF -DCMAKE_VERBOSE_MAKEFILE=ON -DSUITESPARSE_INCLUDE_DIR_HINTS=${CATKIN_DEVEL_PREFIX}/include/suitesparse -DSUITESPARSE_LIBRARY_DIR_HINTS=${CATKIN_DEVEL_PREFIX} ../ceres_src
  BUILD_COMMAND make -j8
  INSTALL_COMMAND make install -j8
)

add_library(ceres STATIC IMPORTED)
set_property(TARGET ceres PROPERTY IMPORTED_LOCATION ${CATKIN_DEVEL_PREFIX}/lib/libceres.so)
cs_add_library(dependency_hack src/dependency_hack.cc)
add_dependencies(dependency_hack ceres)
target_link_libraries(dependency_hack ceres)

cs_install()

cs_export(INCLUDE_DIRS ${CATKIN_DEVEL_PREFIX}/include)
