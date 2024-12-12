help([[
This module loads libraries for running the UFS SRW App with 
a singularity container
]])

whatis([===[Loads libraries needed for building the UFS SRW App in singularity container ]===])

load("srw_common")

setenv("CFLAGS","-diag-disable=10448")
setenv("FFLAGS","-diag-disable=10448")

prepend_path("PATH","/opt/intel/oneapi/compiler/2024.0/bin:/opt/intel/oneapi/compiler/2023.2.3/linux/bin/intel64")

setenv("CC", "mpiicc")
setenv("CXX", "mpiicpc")
setenv("FC", "mpiifort")
