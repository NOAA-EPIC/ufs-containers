help([[
The GNU Compiler Collection 13.3.1 includes front ends for C, C++, Fortran,
as well as libraries for these languages, build on Rocky 9 system.
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("compiler")

conflict(pkgName)
conflict("intel,pgi,lahey,nag")

local mpath = "/opt/modulefiles"
prepend_path("MODULEPATH", mpath)

local base = "/opt/rh/gcc-toolset-13/root/usr"

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib64"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib64"))

prepend_path("INCLUDE",  pathJoin(base,"include"))
prepend_path("CPATH",  pathJoin(base,"include"))
prepend_path("CMAKE_PREFIX_PATH",base)
prepend_path("MANPATH",  pathJoin(base,"share","man"))

setenv("CC", "gcc")
setenv("CXX", "g++")
setenv("FC", "gfortran")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: GNU Compiler Family")

