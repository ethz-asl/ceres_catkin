cmake_minimum_required(VERSION 2.8.3)
project(ceres)

set(CMAKE_BUILD_TYPE Release)

find_package(catkin REQUIRED COMPONENTS suitesparse)

include(ExternalProject)

set(VERSION 1.8.0)

catkin_package(
    DEPENDS ${catkin_EXPORTED_TARGETS}
    CATKIN_DEPENDS suitesparse
    INCLUDE_DIRS 
    LIBRARIES ceres
)

# HACK, HACK, HACK. Force cmake to first build the catkin dep suitesparse before
# building the external lib.
add_library(dependency_hack src/dependency_hack.cc)
target_link_libraries(dependency_hack ${catkin_LIBRARIES})
#add_dependencies(dependency_hack ${catkin_EXPORTED_TARGETS})

set(CERES_URL https://ceres-solver.googlesource.com/ceres-solver)
set(CERES_TAG 4d52ef5457ccc23fe04f75b0f4451ebb1e852a27) #version 1.8

ExternalProject_Add(ceres_src
  DOWNLOAD_COMMAND ""
  CONFIGURE_COMMAND cp ${PROJECT_SOURCE_DIR}/make.sh ./
  BUILD_COMMAND sh make.sh ${CATKIN_DEVEL_PREFIX}
  INSTALL_COMMAND cd build && make -j8 -l8 install
)

install(DIRECTORY include
  DESTINATION ${CATKIN_GLOBAL_INCLUDE_DESTINATION}
)
install(DIRECTORY lib
  DESTINATION ${CATKIN_GLOBAL_LIB_DESTINATION}
)
install(DIRECTORY share
  DESTINATION ${CATKIN_GLOBAL_SHARE_DESTINATION}
)

