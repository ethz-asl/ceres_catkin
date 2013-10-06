ceres
=====

This repository contains ros-package files and a download/make script to checkout and build version 1.7 of ceres and its dependencies.
In order to use the ceres covariance computation, you must use an -fPIC version of suitesparse. Check out sudo Jérôme's build with
```
add-apt-repository ppa:jmaye/ethz
sudo apt-get update
sudo apt-get install libsuitesparse-dev
```
