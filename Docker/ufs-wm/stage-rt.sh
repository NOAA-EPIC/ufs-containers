#!/bin/bash
set -x

#DATADIR="home"
#for i in "$@"
#do
#case $i in
#    -d=*|--datadir=*)
#    DATADIR="${i#*=}"
#    ;;
#    -i=*|--container=*)
#    IMAGE="${i#*=}"
#    ;;
#   --default)
#   DEFAULT=YES
#   ;;
#    *)
            # unknown option
#    ;;
#esac
#done
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
#singularity exec -H $PWD $image cp -r /opt/ufs-weather-model .
##mkdir -p bin
cd ufs-weather-model/bin
ln -s ../container-scripts/build_container_executable.sh make
ln -s ../container-scripts/build_container_executable.sh cmake
ln -s ../container-scripts/run_container_executable.sh python
cd ../..
export line=`/bin/grep -n "cp ${PATHRT}" ufs-weather-model/tests/run_test.sh | /bin/grep fv3.exe | awk -F ":" '{print $1}'`
sed -i "${line}s/^/#/g"  $PWD/ufs-weather-model/tests/run_test.sh
sed -i "${line}a ln -s \$\{PATHRT\}\/..\/container-scripts/run_container_executable.sh fv3.exe"  $PWD/ufs-weather-model/tests/run_test.sh

# TODO: should we have a specific file, if we use the data locally?
#sed -i 's/srun/#srun/g' $PWD/ufs-weather-model/tests/fv3_conf/fv3_slurm.IN_singularity
#sed -i '/#srun/a mpiexec -n @[TASKS] ./fv3.exe' $PWD/ufs-weather-model/tests/fv3_conf/fv3_slurm.IN_singularity
sed -i "s|COMPILER|$compiler|g" $PWD/ufs-weather-model/tests-dev/test_cases/exp_conf/fv3_slurm.IN_singularity
sed -i "s|MPI|$mpi|g" $PWD/ufs-weather-model/tests-dev/test_cases/exp_conf/fv3_slurm.IN_singularity

sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/ufs-weather-model/container-scripts/ufswm.env
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh

SINGULARITY=`which singularity`
LOCDIR=`echo $PWD | awk -F "/" '{print $2}'`

#replace the paths in the script
sed -i "s|IMAGE|$image|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
sed -i "s|LOCDIR|$LOCDIR|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
sed -i "s|DATADIR|$DATADIR|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh
#sed -i "s|UFSPATH|$PWD/tests|g" *_executable.sh
sed -i "s|PATH_TO_SINGULARITY|$SINGULARITY|g" $PWD/ufs-weather-model/container-scripts/*_executable.sh

#for FILE in modulefiles/*intel.lua; do echo "prepend_path(\"PATH\", \"$PWD/bin\")" >> $FILE ; done
