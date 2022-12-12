#!/bin/bash
set -x

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
PYTHONPATH=`which python | head -n 1 | xargs dirname`
SINGULARITY=`which singularity`

#change the RUN cmds to mpirun
sed -i "/RUN_CMD_UTILS/c\  RUN_CMD_UTILS:  mpirun -n \$nprocs" ufs-srweather-app/ush/machine/${MACHINE}.yaml
sed -i "/RUN_CMD_FCST/c\  RUN_CMD_FCST:  mpirun -n \$\{PE_MEMBER01\}" ufs-srweather-app/ush/machine/${MACHINE}.yaml
sed -i "/RUN_CMD_POST/c\  RUN_CMD_POST:  mpirun -n \$nprocs" ufs-srweather-app/ush/machine/${MACHINE}.yaml
sed -i 's/rgn_/rgnl_/g' ufs-srweather-app/scripts/exregional_make_grid.sh 
cp ufs-srweather-app/container-scripts/srw.sh-template srw.sh
echo $IMAGE
echo $BINDDIR
LOCDIR=`echo $PWD | awk -F "/" '{print $2}'`
sed -i "s|IMAGE|$IMAGE|g" srw.sh
sed -i "s|BINDDIR|$BINDDIR|g" srw.sh
sed -i "s|LOCDIR|$LOCDIR|g" srw.sh
sed -i "s|PATH_TO_SINGULARITY|$SINGULARITY|g" srw.sh
sed -i "2 i export PATH=$PYTHONPATH:\$PATH" ufs-srweather-app/scripts/exregional_* 

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

cd ..
cp -r bin exec
cd ..

cp ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua ufs-srweather-app/modulefiles/build_${MACHINE}_intel.lua
sed -i "/rocoto/a load(\"${COMPILER}\")\nload(\"${MPI}\")" ufs-srweather-app/modulefiles/build_${MACHINE}_intel.lua
sed -i "/rocoto/a load(\"${COMPILER}\")\nload(\"${MPI}\")" ufs-srweather-app/modulefiles/wflow_${MACHINE}.lua

rm ufs-srweather-app/modulefiles/tasks/${MACHINE}/* 
sed -i "2 i export PATH=/${PWD}/ufs-srweather-app/bin:/${PWD}/ufs-srweather-app/exec:\$PATH" $PWD/ufs-srweather-app/ush/load_modules_run_task.sh

