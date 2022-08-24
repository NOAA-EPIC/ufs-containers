#!/bin/bash

#Usage: ./spack_setup.sh --site NAME_OF_WORKING_MACHINE --template NAME_OF_PRECONFIGURED_SPACK_TEMPLATE
# use spack stack create env -h to see list of available sites and templates
# https://spack-stack.readthedocs.io/en/latest/Quickstart.html#create-local-environment

export SITE=$1
export TEMPLATE=$2
export NAME=${TEMPLATE}.${MACHINE}

git clone --recursive https://github.com/NOAA-EMC/spack-stack.git
cd spack-stack

if [[ ${SITE} == orion ]] ; then
    module purge
    module use /work/noaa/da/role-da/spack-stack/modulefiles
    module load miniconda/3.9.7
    module load git
elif [[ ${SITE} == cheyenne ]] ; then
    module purge
    module unuse /glade/u/apps/ch/modulefiles/default/compilers
    export MODULEPATH_ROOT=/glade/work/jedipara/cheyenne/spack-stack/modulefiles
    module use /glade/work/jedipara/cheyenne/spack-stack/modulefiles/compilers
    module load python/3.7.9
elif [[ ${SITE} =~ noaa- ]] ; then
    # NOAA Parallel Works
    module unuse /opt/cray/craype/default/modulefiles
    module unuse opt/cray/modulefiles
    export PATH="${PATH}:/contrib/spack-stack/apps/utils/bin"
    module use /contrib/spack-stack/modulefiles/core
    module load miniconda/3.9.7
elif [[ ${SITE} == hera ]] ; then
    module purge
    module use /scratch1/NCEPDEV/jcsda/jedipara/spack-stack/modulefiles
    module load miniconda/3.9.12
else
    # Jet, ...
    echo "SITE=${SITE} not yet supported. Please visit https://spack-stack.readthedocs.io/en/latest/Platforms.html#pre-configured-sites."
fi

source ./setup.sh

echo "Creating spack-stack ${TEMPLATE} environment."
spack stack create env --site ${SITE} --template ${TEMPLATE} --name ${NAME}

echo "Activating spack-stack ${NAME} environment."
spack env activate ./envs/${NAME}

echo "Concretizing ${NAME} spack-stack environment."
spack concretize 2>&1 | tee concretize.log

echo "Installing ${NAME} spack-stack environment."
spack install 2>&1 | tee install.log

yes "y" 2>/dev/null | spack module lmod refresh

spack stack setup-meta-modules
