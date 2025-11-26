help([[
This module loads libraries for running the UFS SRW App with 
a singularity container
]])

whatis([===[Loads libraries needed for building the UFS SRW App in singularity container ]===])

--prepend_path("MODULEPATH","/opt/hpc-modules/modulefiles/stack")

load("COMPILERMOD")
load("MPIMOD")

setenv("CMAKE_C_COMPILER","mpiicc")
setenv("CMAKE_CXX_COMPILER","mpicxx")
setenv("CMAKE_Fortran_COMPILER","mpif90")
setenv("CMAKE_Platform","singularity.gnu")

