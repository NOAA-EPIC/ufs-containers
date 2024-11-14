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

##singularity exec -H $PWD $IMAGE cp /opt/ufs-weather-model/container-scripts/run_container_executable.sh .
echo "Copying out ufs-weather-model repo from the container"
singularity exec -H $PWD $image cp -r /opt/ufs-weather-model .
##mkdir -p bin
cd ufs-weather-model/bin
ln -s ../container-scripts/build_container_executable.sh make
ln -s ../container-scripts/build_container_executable.sh cmake
ln -s ../container-scripts/run_container_executable.sh python
cd ../..

# Set the script to run exe in the container
echo "Set run_test.sh to use exe in the container"
export line=`/bin/grep -n "cp ${PATHRT}" ufs-weather-model/tests/run_test.sh | /bin/grep fv3.exe | awk -F ":" '{print $1}'`
sed -i "${line}s/^/#/g"  $PWD/ufs-weather-model/tests/run_test.sh
sed -i "${line}a ln -s \$\{PATHRT\}\/..\/container-scripts/run_container_executable.sh fv3_\$\{COMPILE_ID\}.exe"  $PWD/ufs-weather-model/tests/run_test.sh

# Update files with compiler and mpi info
#sed -i 's/srun/#srun/g' $PWD/ufs-weather-model/tests/fv3_conf/fv3_slurm.IN_singularity
#sed -i '/#srun/a mpiexec -n @[TASKS] ./fv3.exe' $PWD/ufs-weather-model/tests/fv3_conf/fv3_slurm.IN_singularity
echo "Updating compiler and mpi in fv3_slurm.IN_singularity"
sed -i "s|USER_COMPILER|$compiler|g" $PWD/ufs-weather-model/tests-dev/test_cases/exp_conf/fv3_slurm.IN_singularity
sed -i "s|USER_MPI|$mpi|g" $PWD/ufs-weather-model/tests-dev/test_cases/exp_conf/fv3_slurm.IN_singularity

# Create ufs_singularity.intel lua file
echo "Creating ufs_singularity.intel.lua"
echo "load(\"$compiler\")" > $PWD/ufs-weather-model/modulefiles/ufs_singularity.intel.lua
echo "load(\"$mpi\")" >> $PWD/ufs-weather-model/modulefiles/ufs_singularity.intel.lua

# Trick ufs_test.sh file
echo "Tricking ufs_test.sh file"
sed -i "174 i export MACHINE_ID=singularity" $PWD/ufs-weather-model/tests-dev/ufs_test.sh
sed -i "s|s4 )|s4 singularity )|g" $PWD/ufs-weather-model/tests-dev/ufs_test.sh

# Replace with host paths 
echo "Updating various files with host paths"
SINGULARITY=`which singularity`
LOCDIR=`echo $PWD | awk -F "/" '{print $2}'`

sed -i "s|IMAGE|$image|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
sed -i "s|LOCDIR|$LOCDIR|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
sed -i "s|DATADIR|$DATADIR|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
#sed -i "s|UFSPATH|$PWD/tests|g" *_executable.sh
sed -i "s|PATH_TO_SINGULARITY|$SINGULARITY|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/ufs-weather-model/container-scripts/ufswm.env
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/ufs-weather-model/tests-dev/machine_config/machine_singularity.config
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/ufs-weather-model/tests-dev/baseline_setup.yaml

#for FILE in modulefiles/*intel.lua; do echo "prepend_path(\"PATH\", \"$PWD/bin\")" >> $FILE ; done
