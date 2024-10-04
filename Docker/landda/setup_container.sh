#!/bin/bash
#set -x


Help()
{
    # Display Help
    echo "This script sets up the Land DA workflow to run on unsupported systems."
    echo
    echo "Syntax: ./setup_container.sh [-h|-c=<compiler>|-m=<mpi>|-i=<container>|-p=<platform>]"
    echo "options:"
    echo "-h     Prints out help function."
    echo "-c     Compiler and version that is to be used outside of the container in <compiler>/<version> format. Example intel/2022.1.2"
    echo "-i     Full path to the land DA container."
    echo "-m     MPI and version that is to be used outside of the container in <MPI>/<version> format. Example impi/2022.1.2"
    echo "-p     Name of platform you are running on. "
}


while getopts "h:c:i:m:p:" flag;
do 
    case "${flag}" in 
	h) Help
           exit ;;
        c) compiler="${OPTARG#=}" ;;
        i) image="${OPTARG#=}" ;;
        m) mpi="${OPTARG#=}";;
	p) platform="${OPTARG#=}" ;;
        \?) echo "Invalid option. Exiting!"
            exit 1 ;;
    esac
done

# Check for required arguments
if [ -z "$compiler" ] || [ -z "$image" ] || [ -z "$mpi" ] ; then 
    echo "Missing -c <compiler> or -i <image> or -m <mpi> argument(s)! Please add missing argument(s)."
    exit 1
fi

# Copy land-DA_workflow from container
echo "Copying out land-DA_workflow from container"
singularity exec -H $PWD $image cp -r /opt/land-DA_workflow .

# Get Land DA data
echo "Checking if LANDDA_INPUTS variable exists and copying to land-DA_workflow"
if [ -d $LANDDA_INPUTS/NaturalEarth ]; then
    echo "Land DA data exists copying it over"
    cp -r $LANDDA_INPUTS/* $PWD/land-DA_workflow/fix/
fi

# Update jobs and scripts files to work with container
echo "Updating jobs and scripts files"
sed -i 's|setpdy.sh|${EXEClandda}/setpdy.sh|g' $PWD/land-DA_workflow/jobs/*
sed -i 's|err_chk|${EXEClandda}/err_chk|g' $PWD/land-DA_workflow/jobs/*
sed -i '2 i export NDATE=${HOMElandda}/exec/ndate' $PWD/land-DA_workflow/jobs/*

sed -i 's|. prep_step|${EXEClandda}/prep_step|g' $PWD/land-DA_workflow/scripts/*
sed -i 's|err_chk|${EXEClandda}/err_chk|g' $PWD/land-DA_workflow/scripts/*
sed -i 's|JEDI_EXECDIR=${JEDI_INSTALL}/build/bin|JEDI_EXECDIR=${EXEClandda}|g' $PWD/land-DA_workflow/scripts/exlandda_analysis.sh

sed -i "s|COMPILER|$compiler|g" $PWD/land-DA_workflow/modulefiles/tasks/singularity/*
sed -i "s|MPI|$mpi|g" $PWD/land-DA_workflow/modulefiles/tasks/singularity/*

sed -i "s|PWD|$PWD|g" $PWD/land-DA_workflow/ush/hofx_analysis_stats.py

# Setup run scripts
echo "Updating run scripts"
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/land-DA_workflow/parm/land_analysis_singularity.yaml
cp $PWD/land-DA_workflow/parm/land_analysis_singularity.yaml $PWD/land-DA_workflow/parm/land_analysis.yaml

sed -i "s|IMAGE|$image|g" $PWD/land-DA_workflow/parm/run_container_executable.sh

# Sync conda with platform
echo "Setup conda"
sed -i "s|/opt|$PWD|g" $PWD/land-DA_workflow/sorc/conda/etc/profile.d/conda.sh
sed -i "s|/opt|$PWD|g" $PWD/land-DA_workflow/sorc/conda/bin/conda
sed -i "s|/opt|$PWD|g" $PWD/land-DA_workflow/sorc/conda/envs/land_da/bin/uw

echo "$PWD/land-DA_workflow/sorc/conda" > $PWD/land-DA_workflow/parm/conda_loc

# Append Python path to analysis and plot scripts
sed -i "2 i export PATH=$PWD/land-DA_workflow/sorc/conda/envs/land_da/bin:\$PATH" $PWD/land-DA_workflow/scripts/exlandda_analysis.sh 
sed -i "2 i export PATH=$PWD/land-DA_workflow/sorc/conda/envs/land_da/bin:\$PATH" $PWD/land-DA_workflow/scripts/exlandda_plot_stats.sh

# Get JEDI Data
echo "Getting the jedi test data from container"
mkdir -p $PWD/jedi-bundle/fv3-jedi/test
singularity exec -H $PWD $image cp -r /opt/jedi-bundle/fv3-jedi/test/Data $PWD/jedi-bundle/fv3-jedi/test/

# Create links
echo "Creating links for exe"
cd land-DA_workflow/exec
ln -s ../parm/run_container_executable.sh apply_incr.exe
ln -s ../parm/run_container_executable.sh err_chk
ln -s ../parm/run_container_executable.sh fv3jedi_letkf.x
ln -s ../parm/run_container_executable.sh ndate
ln -s ../parm/run_container_executable.sh prep_step
ln -s ../parm/run_container_executable.sh python
ln -s ../parm/run_container_executable.sh setpdy.sh
ln -s ../parm/run_container_executable.sh tile2tile_converter.exe
ln -s ../parm/run_container_executable.sh ufs_model

cd ../singularity/bin
ln -s ../../parm/build_container_executable.sh ecbuild
ln -s ../../parm/build_container_executable.sh make
ln -s ../../parm/build_container_executable.sh cmake
ln -s ../../parm/build_container_executable.sh ctest

echo "Done"
