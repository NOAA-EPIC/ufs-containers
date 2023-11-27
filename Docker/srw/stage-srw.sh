#!/bin/bash
#set -x

for i in "$@"
do
case $i in
    -c=*|--compiler=*)
    COMPILER="${i#*=}"
    ;;
    -m=*|--mpi=*)
    MPI="${i#*=}"
    ;;
    -i=*|--container=*)
    IMAGE="${i#*=}"
    ;;
    -p=*|--machine=*)
    MACHINE="${i#*=}"
    ;;
#   --default)
#   DEFAULT=YES
#   ;;
    *)
            # unknown option
    ;;
esac
done
singularity exec -H $PWD ${IMAGE} cp -r /opt/ufs-srweather-app .

#get the name of the root directory where data is staged
BINDDIR=`grep -Ri TEST_EXTRN_MDL_SOURCE_BASEDIR ufs-srweather-app/ush/machine/${MACHINE}.yaml | awk -F ": " '{print $2}' | awk -F '/' '{print $2}'`
#get the path to python, rocoto and singularity on the host
PYTHONPATH=`which python3 | head -n 1 | xargs dirname`
SINGULARITY=`which singularity`
ROCOTODIR=`which rocotorun | awk -F '/' '{print "/"$2}'`

#copy the template to use as the srw script
cp ufs-srweather-app/container-scripts/srw.sh-template srw.sh
#replace the paths in the script
LOCDIR=`echo $PWD | awk -F "/" '{print $2}'`
sed -i "s|IMAGE|$IMAGE|g" srw.sh
sed -i "s|BINDDIR|$BINDDIR|g" srw.sh
sed -i "s|LOCDIR|$LOCDIR|g" srw.sh
sed -i "s|ROCOTODIR|$ROCOTODIR|g" srw.sh
sed -i "s|PATH_TO_SINGULARITY|$SINGULARITY|g" srw.sh
sed -i "2 i export PATH=$PYTHONPATH:\$PATH" ufs-srweather-app/scripts/exregional_* 

#test python install for required packages and install them if they are missing
$PWD/ufs-srweather-app/container-scripts/test_python.sh

#create a new module file to use that has only the compiler and mpi loaded
cp $PWD/ufs-srweather-app/container-scripts/build_singularity_intel.lua $PWD/ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua
sed -i "s|COMPILERMOD|$COMPILER|g" $PWD/ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua
sed -i "s|MPIMOD|$MPI|g" $PWD/ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua
#use the same module for all tasks
cp ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua ufs-srweather-app/modulefiles/build_${MACHINE}_intel.lua
#remove any extra modules
rm ufs-srweather-app/modulefiles/tasks/${MACHINE}/* 

#make modifications for Hercules and Orion
if [[ ${MACHINE} =~  "orion" ]] || [[ ${MACHINE} =~  "hercules" ]] ; then

    #add python path to jobs scripts
    sed -i "2 i export PATH=$PYTHONPATH:\$PATH" ufs-srweather-app/jobs/JREGIONAL_*

    #change the RUN cmds to mpiexec needed for using singularity
    sed -i "/RUN_CMD_UTILS/c\  RUN_CMD_UTILS:  mpiexec -n \$nprocs" ufs-srweather-app/ush/machine/${MACHINE}.yaml
    sed -i "/RUN_CMD_FCST/c\  RUN_CMD_FCST:  mpiexec -n \$\{PE_MEMBER01\}" ufs-srweather-app/ush/machine/${MACHINE}.yaml
    sed -i "/RUN_CMD_POST/c\  RUN_CMD_POST:  mpiexec -n \$nprocs" ufs-srweather-app/ush/machine/${MACHINE}.yaml

    #load nco path so make_grid task can find ncdump
    sed -i '12 i load("nco")' ufs-srweather-app/modulefiles/build_${MACHINE}_intel.lua

    #update wall time for make_sfc task only for Hercules
    [[ ${MACHINE} =~  "hercules" ]] && sed -i "s|walltime: 00:20:00|walltime: 00:50:00|g" ufs-srweather-app/parm/wflow/prep.yaml

    #update nodes and processors for run_post task
    sed -i "s|nnodes: 2|nnodes: 4|g" ufs-srweather-app/parm/wflow/post.yaml
    sed -i "s|ppn: 24|ppn: 12|g" ufs-srweather-app/parm/wflow/post.yaml
fi

#create links to the srw.sh script in ufs-srweather-app/bin dir
cd ufs-srweather-app/bin
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

#cd back to the working dir
cd ..
cp -r bin exec
cd ..

#Link ush dir to working dir so the workflow tools can find it
ln -s ufs-srweather-app/ush .

#make sure we have the path to our executable scripts at the head of our PATH variable
sed -i "2 i export PATH=${PYTHONPATH}:/${PWD}/ufs-srweather-app/exec:\$PATH" $PWD/ufs-srweather-app/ush/load_modules_run_task.sh
#Remove the --cpus-per-task section of the submit script, since it breaks with singularity for some reason
sed -i 's/--cpus-per-task {fcst_threads}//g' $PWD/ufs-srweather-app/ush/generate_FV3LAM_wflow.py
