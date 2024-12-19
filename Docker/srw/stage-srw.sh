#!/bin/bash
#set -x

Help()
{
    # Display Help
    echo "This script sets up the SRW App to run on supported systems."
    echo
    echo "Syntax: ./setup_container.sh [-h|-c=<compiler>|-m=<mpi>|-i=<container>|-p=<platform>]"
    echo "options:"
    echo "-h     Prints out help function."
    echo "-c     Compiler and version that is to be used outside of the container in <compiler>/<version> format. Example intel/2022.1.2"
    echo "-i     Full path to the SRW container."
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
if [ -z "$compiler" ] || [ -z "$image" ] || [ -z "$mpi" ] || [ -z "$platform" ] ; then 
    echo "Missing -c <compiler> or -i <image> or -m <mpi> or -p <platform> argument(s)! Please add missing argument(s)."
    exit 1
fi

# Copy out SRW App repo
echo "Copying out SRW App repo from container"
singularity exec -H $PWD ${image} cp -r /opt/ufs-srweather-app .

# Move and modify build yaml
echo "Move and modify build yaml"
cp $PWD/ufs-srweather-app/build/build_settings.yaml $PWD/ufs-srweather-app/exec
sed -i "s|Machine:|Machine:         ${platform}|g" $PWD/ufs-srweather-app/exec/build_settings.yaml

# Get the name of the root directory where data is staged, and host rocoto and singularity
echo "Setup srw.sh script"
BINDDIR=`grep -Ri TEST_EXTRN_MDL_SOURCE_BASEDIR ufs-srweather-app/ush/machine/${platform}.yaml | awk -F ": " '{print $2}' | awk -F '/' '{print $2}'`
#PYTHONPATH=`which python3 | head -n 1 | xargs dirname`
SINGULARITY=`which singularity`
#ROCOTODIR=`which rocotorun | awk -F '/' '{print "/"$2}'`

# Create srw script and sub paths
cp ufs-srweather-app/container-scripts/srw.sh-template srw.sh
LOCDIR=`echo $PWD | awk -F "/" '{print $2}'`
sed -i "s|IMAGE|$image|g" srw.sh
sed -i "s|BINDDIR|$BINDDIR|g" srw.sh
sed -i "s|LOCDIR|$LOCDIR|g" srw.sh
#sed -i "s|ROCOTODIR|$ROCOTODIR|g" srw.sh
sed -i "s|PATH_TO_SINGULARITY|$SINGULARITY|g" srw.sh
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" srw.sh

#sed -i "2 i export PATH=$PYTHONPATH:\$PATH" ufs-srweather-app/scripts/exregional_* 
#test python install for required packages and install them if they are missing
#$PWD/ufs-srweather-app/container-scripts/test_python.sh

# Create a new module file that only uses the user's compiler and mpi
echo "Create build modulefile for container"
mv $PWD/ufs-srweather-app/modulefiles/build_${platform}_intel.lua $PWD/ufs-srweather-app/modulefiles/build_${platform}_intel.lua-original
echo "load(\"$compiler\")" > $PWD/ufs-srweather-app/modulefiles/build_${platform}_intel.lua
echo "load(\"$mpi\")" >> $PWD/ufs-srweather-app/modulefiles/build_${platform}_intel.lua
# These paths are being removed on Gaea, so add them in build modulefile
echo "prepend_path(\"PATH\", \"$PWD/ufs-srweather-app/conda/envs/srw_app/bin\")" >> $PWD/ufs-srweather-app/modulefiles/build_${platform}_intel.lua
echo "prepend_path(\"PATH\", \"$PWD/ufs-srweather-app/exec\")" >> $PWD/ufs-srweather-app/modulefiles/build_${platform}_intel.lua

# Set python to the python built by the SRW App
echo "Create python modulefile"
mv $PWD/ufs-srweather-app/modulefiles/python_srw.lua $PWD/ufs-srweather-app/modulefiles/python_srw.lua-original
echo "prepend_path(\"PATH\", \"$PWD/ufs-srweather-app/conda/envs/srw_app/bin\")" > $PWD/ufs-srweather-app/modulefiles/python_srw.lua
echo "prepend_path(\"PATH\", \"$PWD/ufs-srweather-app/exec\")" >> $PWD/ufs-srweather-app/modulefiles/python_srw.lua
rm ufs-srweather-app/modulefiles/tasks/${platform}/*

# Update conda paths and create conda loc file
echo "Configure conda"
sed -i "s|/opt|$PWD|g" $PWD/ufs-srweather-app/conda/envs/srw_app/bin/uw
sed -i "s|/opt|$PWD|g" $PWD/ufs-srweather-app/conda/etc/profile.d/conda.sh
sed -i "s|/opt|$PWD|g" $PWD/ufs-srweather-app/conda/bin/conda
echo "$PWD/ufs-srweather-app/conda" > $PWD/ufs-srweather-app/conda_loc

# Update srw.env file
echo "Update srw env file"
sed -i "s|SINGULARITY_WORKING_DIR|$PWD|g" $PWD/ufs-srweather-app/container-scripts/srw.env
#cp $PWD/ufs-srweather-app/container-scripts/build_singularity_intel.lua $PWD/ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua
#sed -i "s|COMPILERMOD|$COMPILER|g" $PWD/ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua
#sed -i "s|MPIMOD|$MPI|g" $PWD/ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua
#use the same module for all tasks
#cp ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua ufs-srweather-app/modulefiles/build_${MACHINE}_intel.lua
#remove any extra modules
#rm ufs-srweather-app/modulefiles/tasks/${MACHINE}/* 

# Update RUN cmds to mpiexec
echo "Update run cmds" 
if [ $platform == "gaea" ] ; then
    sed -i 's|srun|srun --mpi=pmi2|g' $PWD/ufs-srweather-app/ush/machine/${platform}.yaml
else
    sed -i "/RUN_CMD_UTILS/c\  RUN_CMD_UTILS:  mpiexec -np \$nprocs" $PWD/ufs-srweather-app/ush/machine/${platform}.yaml
    sed -i "/RUN_CMD_FCST/c\  RUN_CMD_FCST:  mpiexec -np \$\{PE_MEMBER01\}" $PWD/ufs-srweather-app/ush/machine/${platform}.yaml
    sed -i "/RUN_CMD_POST/c\  RUN_CMD_POST:  mpiexec -np \$nprocs" $PWD/ufs-srweather-app/ush/machine/${platform}.yaml
fi

# Create links to the srw.sh script in ufs-srweather-app/exec dir
echo "Create links to srw.sh script"
cd ufs-srweather-app/exec
ln -s ../../srw.sh chgres_cube
ln -s ../../srw.sh cpld_gridgen
ln -s ../../srw.sh emcsfc_ice_blend
ln -s ../../srw.sh emcsfc_snow2mdl
ln -s ../../srw.sh filter_topo
ln -s ../../srw.sh fregrid
ln -s ../../srw.sh fvcom_to_FV3
ln -s ../../srw.sh global_cycle
ln -s ../../srw.sh global_equiv_resol
ln -s ../../srw.sh inland
ln -s ../../srw.sh lakefrac
ln -s ../../srw.sh lst
ln -s ../../srw.sh make_hgrid
ln -s ../../srw.sh make_solo_mosaic
ln -s ../../srw.sh ncdump
ln -s ../../srw.sh orog
ln -s ../../srw.sh orog_gsl
ln -s ../../srw.sh regional_esg_grid
ln -s ../../srw.sh sfc_climo_gen
ln -s ../../srw.sh shave
ln -s ../../srw.sh ufs_model
ln -s ../../srw.sh upp.x
ln -s ../../srw.sh vcoord_gen

#cd ..

#make sure we have the path to our executable scripts at the head of our PATH variable
#sed -i "2 i export PATH=${PYTHONPATH}:/${PWD}/ufs-srweather-app/exec:\$PATH" $PWD/ufs-srweather-app/ush/load_modules_run_task.sh
#Remove the --cpus-per-task section of the submit script, since it breaks with singularity for some reason
#sed -i 's/--cpus-per-task {fcst_threads}//g' $PWD/ufs-srweather-app/ush/generate_FV3LAM_wflow.py
