cmake_minimum_required(VERSION 2.8.3)
project(ceres)

set(CMAKE_BUILD_TYPE Release)

find_package(catkin REQUIRED)

include(ExternalProject)

set(VERSION 1.8.0)

catkin_package(
    DEPENDS
    CATKIN_DEPENDS suitesparse
    INCLUDE_DIRS include
    LIBRARIES ceres_wrap
)

set(CERES_URL https://ceres-solver.googlesource.com/ceres-solver)
set(CERES_TAG 4d52ef5457ccc23fe04f75b0f4451ebb1e852a27) #version 1.8

ExternalProject_Add(ceres_src
  DOWNLOAD_COMMAND ""
  CONFIGURE_COMMAND pwd && cp ${PROJECT_SOURCE_DIR}/make.sh ./
  BUILD_COMMAND pwd && sh make.sh ${CATKIN_DEVEL_PREFIX}
  INSTALL_COMMAND cd build && make -j8 -l8 install
)

add_library(ceres_wrap src/wrap_lib.cc)
target_link_libraries(ceres_wrap )
add_dependencies(ceres_wrap ceres_src)

install(DIRECTORY include
  DESTINATION ${CATKIN_GLOBAL_INCLUDE_DESTINATION}
)
install(DIRECTORY lib
  DESTINATION ${CATKIN_GLOBAL_LIB_DESTINATION}
)
install(DIRECTORY share
  DESTINATION ${CATKIN_GLOBAL_SHARE_DESTINATION}
)

