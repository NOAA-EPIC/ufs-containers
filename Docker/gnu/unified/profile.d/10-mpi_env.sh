# Avoid re-sourcing
[ -n "$MPI_ENV_SOURCED" ] && return
export MPI_ENV_SOURCED=1

#####################################
# PATH and binary search path
#####################################

export PATH=/opt/openmpi/4.1.6/bin:/opt/rh/gcc-toolset-13/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

#####################################
# Library paths for runtime + compile
#####################################

export LD_LIBRARY_PATH=/opt/slurm/lib:/opt/openmpi/4.1.6/lib:/opt/rh/gcc-toolset-13/root/usr/lib64:/opt/rh/gcc-toolset-13/root/usr/lib:${LD_LIBRARY_PATH}
export LIBRARY_PATH=/opt/slurm/lib:/opt/openmpi/4.1.6/lib:/opt/rh/gcc-toolset-13/root/usr/lib64:/opt/rh/gcc-toolset-13/root/usr/lib:${LIBRARY_PATH}

#####################################
# Headers for compile-time inclusion
#####################################

export CPATH=/opt/slurm/include:/opt/openmpi/4.1.6/include:/opt/rh/gcc-toolset-13/root/usr/include:${CPATH}

#####################################
# Module system variables (if you use modules)
#####################################

# You already override MODULEPATH in /etc/profile.d/01-modulepath.sh
# Here we only ensure MODULESHOME is correct.

export MODULESHOME=/usr/share/lmod/lmod

