cmake_minimum_required(VERSION 2.8.3)
project(ceres)

find_package(catkin_simple REQUIRED)
catkin_simple()

include_directories(${Eigen_INCLUDE_DIRS})

include(ExternalProject)

set(VERSION 1.8.0)

set(CERES_URL https://ceres-solver.googlesource.com/ceres-solver)
set(CERES_TAG 4d52ef5457ccc23fe04f75b0f4451ebb1e852a27) #version 1.8

# The configure step fails at catkin_package() if this directory
# doesn't exist yet. Create it at configure time!
file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include)

ExternalProject_Add(ceres_src
  #DEPENDS dependency_hack  # This is broken, so we hope that suitesparse is build by the time ceres searches for it.
  DOWNLOAD_COMMAND ""
  CONFIGURE_COMMAND cp ${PROJECT_SOURCE_DIR}/make.sh ./
  BUILD_COMMAND sh make.sh ${CATKIN_DEVEL_PREFIX} ${suitesparse_DEVEL_PREFIX}/include/suitesparse ${suitesparse_DEVEL_PREFIX}/lib
  INSTALL_COMMAND ""
)

# HACK, HACK, HACK. Force cmake to first build the catkin dep suitesparse before
# building the external lib.
cs_add_library(dependency_hack src/dependency_hack.cc)
target_link_libraries(dependency_hack ${catkin_LIBRARIES})
add_dependencies(dependency_hack ${catkin_EXPORTED_TARGETS} ceres_src)


cs_install()

cs_export(CFG_EXTRAS ${PROJECT_SOURCE_DIR}/cmake/ceres-extras.cmake.in)
