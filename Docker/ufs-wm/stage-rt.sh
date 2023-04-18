#!/bin/bash
set -x

DATADIR="home"
for i in "$@"
do
case $i in
    -d=*|--datadir=*)
    DATADIR="${i#*=}"
    ;;
    -i=*|--container=*)
    IMAGE="${i#*=}"
    ;;
#   --default)
#   DEFAULT=YES
#   ;;
    *)
            # unknown option
    ;;
esac
done

singularity exec -H $PWD $IMAGE cp /opt/ufs-weather-model/container-scripts/run_container_executable.sh .
singularity exec -H $PWD $IMAGE cp /opt/ufs-weather-model/container-scripts/build_container_executable.sh .
mkdir -p bin
cd bin
ln -s ../build_container_executable.sh make
ln -s ../build_container_executable.sh cmake
cd ..
export line=`/bin/grep -n "cp ${PATHRT}" tests/run_test.sh | /bin/grep fv3.exe | awk -F ":" '{print $1}'`
sed -i "${line}s/^/#/g" tests/run_test.sh
sed -i "${line}a ln -s \$\{PATHRT\}\/..\/run_container_executable.sh fv3_\$\{COMPILE_NR\}.exe" tests/run_test.sh
sed -i 's/srun/#srun/g' tests/fv3_conf/fv3_slurm.IN*
sed -i '/#srun/a mpiexec -n @[TASKS] ./fv3_${COMPILE_NR}.exe' tests/fv3_conf/fv3_slurm.IN*

SINGULARITY=`which singularity`
LOCDIR=`echo $PWD | awk -F "/" '{print $2}'`

#replace the paths in the script
sed -i "s|IMAGE|$IMAGE|g" *_executable.sh
sed -i "s|LOCDIR|$LOCDIR|g" *_executable.sh
sed -i "s|DATADIR|$DATADIR|g" *_executable.sh
sed -i "s|UFSPATH|$PWD/tests|g" *_executable.sh
sed -i "s|PATH_TO_SINGULARITY|$SINGULARITY|g" *_executable.sh

for FILE in modulefiles/*intel.lua; do echo "prepend_path(\"PATH\", \"$PWD/bin\")" >> $FILE ; done
