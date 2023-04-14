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
#singularity exec -H $PWD ${IMAGE} tar xvfz /opt/files.tar.gz 
tar xvfz files.tar.gz

SINGULARITY=`which singularity`
LOCDIR=`echo $PWD | awk -F "/" '{print $2}'`

#replace the paths in the script
sed -i "s|IMAGE|$IMAGE|g" *_executable.sh
sed -i "s|LOCDIR|$LOCDIR|g" *_executable.sh
sed -i "s|DATADIR|$DATADIR|g" *_executable.sh
sed -i "s|UFSPATH|$PWD/tests|g" *_executable.sh
sed -i "s|PATH_TO_SINGULARITY|$SINGULARITY|g" *_executable.sh

for FILE in modulefiles/*intel.lua; do echo "prepend_path(\"PATH\", \"$PWD/bin\")" >> $FILE ; done
