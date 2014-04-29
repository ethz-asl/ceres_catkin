cmake_minimum_required(VERSION 2.8.3)
project(ceres)

set(CMAKE_BUILD_TYPE Release)

find_package(catkin REQUIRED COMPONENTS suitesparse)

include(ExternalProject)

set(VERSION 1.8.0)

# HACK, HACK, HACK. Force cmake to first build the catkin dep suitesparse before
# building the external lib.
add_library(dependency_hack src/dependency_hack.cc)
target_link_libraries(dependency_hack ${catkin_LIBRARIES})
add_dependencies(dependency_hack ${catkin_EXPORTED_TARGETS})

set(CERES_URL https://ceres-solver.googlesource.com/ceres-solver)
set(CERES_TAG 4d52ef5457ccc23fe04f75b0f4451ebb1e852a27) #version 1.8

find_package(suitesparse REQUIRED)

ExternalProject_Add(ceres_src
  #DEPENDS dependency_hack  # This is broken, so we hope that suitesparse is build by the time ceres searches for it.
  DOWNLOAD_COMMAND ""
  CONFIGURE_COMMAND cp ${PROJECT_SOURCE_DIR}/make.sh ./
  BUILD_COMMAND sh make.sh ${CATKIN_DEVEL_PREFIX} ${suitesparse_DEVEL_PREFIX}/include/suitesparse ${suitesparse_DEVEL_PREFIX}/lib
  INSTALL_COMMAND ""
)

catkin_package(
    DEPENDS ${catkin_EXPORTED_TARGETS} ceres_src eigen
    CATKIN_DEPENDS suitesparse
    INCLUDE_DIRS ${CATKIN_DEVEL_PREFIX}/include
    LIBRARIES ceres
)