help([[
An open source Message Passing Interface implementation v.4.1.6
built with gnu/13.3.1 compilers, for C, C++, Fortran and slurm support with pmi, pmi2
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

whatis([[Configure options :  --prefix=/opt/openmpi/4.1.6 --enable-mpi-fortran=all --with-slurm=/opt/slurm --with-pmi=/opt/slurm --with-pmi-libdir=/opt/slurm/lib  --with-pmix   --with-libevent=internal --with-hwloc=internal --enable-mpi-thread-multiple  --enable-shared --enable-static --with-gnu-ld --enable-mpirun-prefix-by-default CC=/opt/rh/gcc-toolset-13/root/usr/bin/gcc CFLAGS=" -fPIC" CXX=/opt/rh/gcc-toolset-13/root/usr/bin/g++  CXXFLAGS="  -fPIC" FC=/opt/rh/gcc-toolset-13/root/usr/bin/gfortran  FCFLAGS="-fallow-argument-mismatch -fallow-invalid-boz -fPIC"]])
family("mpi")

conflict(pkgName)
conflict("mpich","impi")

local gnu = pathJoin("gnu","13.3.1")
prepend_path("MODULEPATH", "/opt/modulefiles")
load(gnu)
prereq(gnu)


local base = pathJoin("/opt","openmpi/4.1.6")

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LD_LIBRARY_PATH", "/opt/slurm/lib")
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LIBRARY_PATH", "/opt/slurm/lib")
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", "/opt/slurm/lib")
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("CPATH", "/opt/slurm/include")
prepend_path("INCLUDE", pathJoin(base,"include"))
prepend_path("CMAKE_PREFIX_PATH",base)
prepend_path("MANPATH", pathJoin(base,"share","man"))
prepend_path("PKG_CONFIG_PATH",pathJoin(base,"lib/pkgconfig"))
setenv("MPI_ROOT", base)

-- Enable FindMPI.cmake to automatically find and configure OpenMPI
setenv("MPI_HOME", base)
setenv("MPI_Fortran_COMPILER", pathJoin(base,"bin/mpif90"))
setenv("MPI_C_COMPILER", pathJoin(base,"bin/mpicc"))
setenv("MPI_CXX_COMPILER", pathJoin(base,"bin/mpic++"))

