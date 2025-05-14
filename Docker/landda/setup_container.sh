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
echo "Checking if LANDDA_INPUTS variable exists and linking to land-DA_workflow"
if [ -d $LANDDA_INPUTS/NaturalEarth ]; then
    echo "Land DA data exists, creating links"
    ln -nsf $LANDDA_INPUTS/* $PWD/land-DA_workflow/fix
fi

# Update scripts and module files to work with container
echo "Updating scripts files"
sed -i 's|. prep_step|${EXEClandda}/prep_step|g' $PWD/land-DA_workflow/scripts/*
sed -i 's|JEDI_EXECDIR=${JEDI_PATH}/build/bin|JEDI_EXECDIR=${EXEClandda}|g' $PWD/land-DA_workflow/scripts/exlandda_analysis.sh
# Call python wrapper for prep and plot scripts
sed -i 's|${USHlandda}|python ${USHlandda}|g' $PWD/land-DA_workflow/scripts/exlandda_prep_data.sh
sed -i 's|${USHlandda}|python ${USHlandda}|g' $PWD/land-DA_workflow/scripts/exlandda_plot_stats.sh
sed -i 's|${USHlandda}/plot_comp_sfc_data.py|${HOMElandda}/exec/python ${USHlandda}/plot_comp_sfc_data.py|g' $PWD/land-DA_workflow/scripts/exlandda_analysis.sh

echo "Updating singularity modulefiles"
sed -i "s|COMPILER|$compiler|g" $PWD/land-DA_workflow/modulefiles/tasks/singularity/*
sed -i "s|MPI|$mpi|g" $PWD/land-DA_workflow/modulefiles/tasks/singularity/*
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/land-DA_workflow/modulefiles/tasks/singularity/*
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/land-DA_workflow/modulefiles/wflow_singularity.lua

# Setup run related scripts
echo "Updating run related scripts"
sed -i "s|IMAGE|$image|g" $PWD/land-DA_workflow/parm/run_container_executable.sh
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/land-DA_workflow/parm/setup_wflow_env.py
sed -i "s|conda list|#conda list|g" $PWD/land-DA_workflow/parm/task_load_modules_run_jjob.sh
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/land-DA_workflow/parm/run_container_executable.sh

# Sync conda with platform
echo "Setup conda"
sed -i "s|/opt|$PWD|g" $PWD/land-DA_workflow/sorc/conda/etc/profile.d/conda.sh
sed -i "s|/opt|$PWD|g" $PWD/land-DA_workflow/sorc/conda/bin/conda
sed -i "s|/opt|$PWD|g" $PWD/land-DA_workflow/sorc/conda/envs/land_da/bin/uw
echo "$PWD/land-DA_workflow/sorc/conda" > $PWD/land-DA_workflow/parm/conda_loc

# Get JEDI Data
echo "Getting the jedi test data from container"
mkdir -p $PWD/jedi-bundle/fv3-jedi/test
singularity exec -H $PWD $image cp -r /opt/jedi-bundle/fv3-jedi/test/Data $PWD/jedi-bundle/fv3-jedi/test/

# Check if it is using mpich (i.e. gaea)
#if [[ $mpi =~ cray-mpich/ ]]; then
#    sed -i 's|which mpiexec|which srun|g' $PWD/land-DA_workflow/scripts/exlandda_*
#    sed -i 's|${RUN_CMD} -n ${NPROCS_FORECAST}|${RUN_CMD} -n ${NPROCS_FORECAST} --mpi=pmi2|g' $PWD/land-DA_workflow/scripts/exlandda_forecast.sh
#    sed -i 's|${RUN_CMD} -n ${NPROCS_ANALYSIS}|${RUN_CMD} -n ${NPROCS_ANALYSIS} --mpi=pmi2|g' $PWD/land-DA_workflow/scripts/exlandda_analysis.sh
#    sed -i '30 i module reset' $PWD/land-DA_workflow/parm/task_load_modules_run_jjob.sh
#    sed -i 's|`which singularity`|"/usr/bin/singularity"|g' $PWD/land-DA_workflow/parm/run_container_executable.sh
#fi

# Update experiment variables (fcst length and max procs)
echo "Update experiment variables"
sed -i "477s|00:30:00|01:00:00|g" $PWD/land-DA_workflow/parm/templates/template.land_analysis.yaml
sed -i "324s|40|64|g" $PWD/land-DA_workflow/parm/setup_wflow_env.py 

# Create links
echo "Creating links for exe"
cd land-DA_workflow/exec
ln -s ../parm/run_container_executable.sh apply_incr.exe
ln -s ../parm/run_container_executable.sh calcfIMS.exe
ln -s ../parm/run_container_executable.sh chgres_cube
ln -s ../parm/run_container_executable.sh err_chk
ln -s ../parm/run_container_executable.sh fv3jedi_letkf.x
ln -s ../parm/run_container_executable.sh fv3jedi_var.x
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
