#!/bin/bash

echo "### Patching ceres cmake ###"
# Remove -Werror from cmake lists as clang outputs warnings for unused include paths.
sed -i.bu 's/-Werror/-Wall/g' CMakeLists.txt
# Add gflags to linker list for ceres.
sed -i.bu 's/SET(CERES_LIBRARY_DEPENDENCIES ${GLOG_LIBRARIES})/SET(CERES_LIBRARY_DEPENDENCIES ${GLOG_LIBRARIES} ${GFLAGS_LIBRARIES})/g' internal/ceres/CMakeLists.txt

