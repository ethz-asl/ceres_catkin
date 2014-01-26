ceres
=====

This repository contains ros-package files and a download/make script to checkout and build ceres and its dependencies.
In order to use the ceres covariance computation, you must use an -fPIC version of suitesparse. Check out Jérôme's build with
```
sudo add-apt-repository ppa:jmaye/ethz
sudo apt-get update
sudo apt-get install libsuitesparse-dev
```

### UBUNTU 13.04
same as above except for the last step
```
sudo aptitude install libsuitesparse-dev=1:3.4.0-2ubuntu5~raring
```
do NOT accept the first solution aptitude will propose to you!
take the second solution
