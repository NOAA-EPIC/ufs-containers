#!/bin/bash
set -x

fileList=$@

script_dir=$(dirname "$0")
cp $script_dir/run_modularized_executable.sh $PWD
#replace CONTAINERENV_ with SINGULARITY/APPTAINER
if [[ -z $(env | grep APPTAINER) ]]; then 
   sed -i 's/CONTAINERENV_/SINGULARITYENV_/g' $PWD/run_modularized_executable.sh
else 
   sed -i 's/SINGULARITYENV_/APPTAINERENV_/g' $PWD/run_modularized_executable.sh
fi
#replace the paths in the script
sed -i "s|IMAGE|$SINGULARITY_CONTAINER|g" $PWD/run_modularized_executable.sh
nbinds=`echo $SINGULARITY_BIND | awk -F "," '{print NF }'`
bindstring=" "
for (( i = 1; i <= $nbinds; i++ )); do binddir=`echo $SINGULARITY_BIND | cut -d "," -f $i` && bindstring="${bindstring} -B ${binddir}" ; done
echo $bindstring
sed -i "s|BINDDIRS|$bindstring|g" $PWD/run_modularized_executable.sh
sed -i "s|FI_PATH|$FI_PROVIDER_PATH|g" $PWD/run_modularized_executable.sh

for file in $fileList
do
  fullfile=$(readlink -m $file)
  pathdir=$(dirname $fullfile)
  basefile=$(basename "$fullfile")
  dot="/."
  cp $fullfile $fullfile.orig
  mv $fullfile $pathdir$dot$basefile
  cp $PWD/run_modularized_executable.sh $fullfile
  echo "fullfile is $fullfile"
  echo $pathdir
 
  EXEC_PATH="$pathdir:$PATH"
  sed -i "s|EXEC_PATH|$EXEC_PATH|g" $fullfile
  sed -i "s|BASEFILE|HOMEgfs/\.$basefile|g" $fullfile
  chmod +x $fullfile
done

rm $PWD/run_modularized_executable.sh
