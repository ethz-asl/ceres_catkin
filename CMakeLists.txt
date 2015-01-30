cmake_minimum_required(VERSION 2.8.3)
project(ceres_catkin)

find_package(catkin_simple REQUIRED)
catkin_simple()

include_directories(${Eigen_INCLUDE_DIRS})

include(ExternalProject)

set(VERSION 1.9.0)
set(CERES_TAG 7c57de5080c9f5a4f067e2d20b5f33bad5b1ade6) #version 1.9

# The configure step fails at catkin_package() if this directory
# doesn't exist yet. Create it at configure time!
file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include)

# Patch away the linking to the gomp OpenMP implementation, in case we use the Intel OpenMP implementation and Clang.
if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	set(GOMP_PATCH "")
else (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	set(GOMP_PATCH "--dry-run")
endif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

ExternalProject_Add(ceres_src
  GIT_REPOSITORY https://ceres-solver.googlesource.com/ceres-solver
  GIT_TAG ${CERES_TAG}
  UPDATE_COMMAND ""
  PATCH_COMMAND cd ../ceres_src/ && patch -N CMakeLists.txt ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.patch && patch ${GOMP_PATCH} -N internal/ceres/CMakeLists.txt ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists_internal.patch && patch -N include/ceres/internal/numeric_diff.h ${CMAKE_CURRENT_SOURCE_DIR}/numeric_diff.patch
  CONFIGURE_COMMAND cmake -DCMAKE_CXX_FLAGS=-fPIC -DGFLAGS=ON 
    -DGFLAGS_LIBRARY=${gflags_catkin_LIBRARIES}
    -DGFLAGS_INCLUDE_DIR=${gflags_catkin_INCLUDE_DIR}
    -DGLOG_INCLUDE_DIR=${glog_catkin_INCLUDE_DIR}
    -DGLOG_LIBRARY=${glog_catkin_LIBRARIES}
    -DCMAKE_INSTALL_PREFIX=${CATKIN_DEVEL_PREFIX} -DBUILD_SHARED_LIBS=ON 
    -DBUILD_DOCUMENTATION=OFF -DCMAKE_VERBOSE_MAKEFILE=ON
    -DSUITESPARSE_INCLUDE_DIR_HINTS=${CATKIN_DEVEL_PREFIX}/include/suitesparse 
    -DSUITESPARSE_LIBRARY_DIR_HINTS=${CATKIN_DEVEL_PREFIX}/lib ../ceres_src
	-DCMAKE_BUILD_TYPE:STRING=Release
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
  BUILD_COMMAND make -j8
  INSTALL_COMMAND make install -j8
)
add_dependencies(ceres_src glog_catkin gflags_catkin suitesparse)

cs_add_library(${PROJECT_NAME} src/dependency_tracker.cc)
add_dependencies(${PROJECT_NAME} ceres_src)
target_link_libraries(${PROJECT_NAME}
  ${CATKIN_DEVEL_PREFIX}/lib/libceres${CMAKE_SHARED_LIBRARY_SUFFIX})

cs_install()

cs_export(INCLUDE_DIRS ${CATKIN_DEVEL_PREFIX}/include
          CFG_EXTRAS ceres-extras.cmake)
