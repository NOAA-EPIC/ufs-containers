#!/bin/bash

source /usr/share/lmod/lmod/init/bash
source /opt/spack-stack/setup.sh
export PATH=$PATH:/opt/dist/usr/local/bin
module use /opt/spack-stack/envs/ufs-srw.intel/install/modulefiles/Core
module load stack-intel
module load stack-intel-oneapi-mpi/2021.6.0
module load netcdf-c netcdf-fortran libpng jasper
module load sp zlib hdf5 netcdf-c netcdf-fortran parallelio esmf fms bacio crtm g2 g2tmpl ip w3nco upp gftl-shared yafyaml mapl gfsio landsfcutil nemsio nemsiogfs sfcio sigio w3emc wgrib2
cmake -DCMAKE_INSTALL_PREFIX=/opt/ufs-srweather-app ..
make -j 8

