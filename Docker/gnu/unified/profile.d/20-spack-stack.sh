# Avoid re-sourcing
[ -n "$SPACK_STACK_ENV_SOURCED" ] && return
export SPACK_STACK_ENV_SOURCED=1

#####################################
# Environmental variables set after loading the 
# modulefiles needed for running UFS-SRW-App and UFS-WeatherModel:
# jasper libpng netcdf-c netcdf-fortran parallelio esmf fms bacio crtm g2 g2tmpl ip sp w3emc gftl-shared mapl nemsio sfcio sigio w3nco wrf-io wgrib2 scotch
# It could also be accomplished as following:
# source /usr/share/lmod/lmod/init/bash
# module use /opt/modulefiles
# module use  /opt/spack-stack/spack-stack-1.9.2/envs/ufs-wm-env/install/modulefiles/Core/
# module load stack-gcc
# module load stack-openmpi
# module load module load jasper libpng netcdf-c netcdf-fortran parallelio esmf fms bacio crtm g2 g2tmpl ip sp w3emc gftl-shared mapl nemsio sfcio sigio w3nco wrf-io wgrib2 scotch
#
# NOTE: the env can also be loaded by running: source /opt/spack-stack/spack-stack-1.9.2/.bashenv
#
#####################################
# PATH and binary search path
#####################################

export PATH=IMPORT_PATH:${PATH}

export LD_LIBRARY_PATH=IMPORT_LD_LIBRARY_PATH:${LD_LIBRARY_PATH}

export LIBRARY_PATH=IMPORT_LIBRARY_PATH:${LIBRARY_PATH}

#####################################
# Headers for compile-time inclusion
#####################################

export CPATH=IMPORT_CPATH:${CPATH}
