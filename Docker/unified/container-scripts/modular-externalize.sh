#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "g     Print the GPL license notification."
   echo "h     Print this Help."
   echo "v     Verbose mode."
   echo "V     Print software version and exit."
   echo
}

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################
################################################################################
# Process the input options. Add options as needed.                            #
################################################################################
# Get the options
while getopts ":he" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      e) # external directory to hold externalized executables
         exec_dir=$2
         echo "Will create external executable in $exec_dir"
   esac
done
shift $(($OPTIND ))
fileList=$@

mkdir -p $exec_dir
script_dir=$(dirname "$0")
cp $script_dir/run_modularized_executable.sh $exec_dir
#replace CONTAINERENV_ with SINGULARITY/APPTAINER
if [[ -z $(env | grep APPTAINER) ]]; then 
   sed -i 's/CONTAINERENV_/SINGULARITYENV_/g' $exec_dir/run_modularized_executable.sh
else 
   sed -i 's/CONTAINERENV_/APPTAINERENV_/g' $exec_dir/run_modularized_executable.sh
fi
#replace the paths in the script
sed -i "s|IMAGE|$SINGULARITY_CONTAINER|g" $exec_dir/run_modularized_executable.sh
nbinds=`echo $SINGULARITY_BIND | awk -F "," '{print NF }'`
bindstring=" "
for (( i = 1; i <= $nbinds; i++ )); do binddir=`echo $SINGULARITY_BIND | cut -d "," -f $i` && bindstring="${bindstring} -B ${binddir}" ; done
echo $bindstring
sed -i "s|BINDDIRS|$bindstring|g" $exec_dir/run_modularized_executable.sh
sed -i "s|FI_PATH|$FI_PROVIDER_PATH|g" $exec_dir/run_modularized_executable.sh

for file in $fileList
do
  fullfile=$(readlink -m $file)
  basefile=$(basename "$fullfile")
  cp $exec_dir/run_modularized_executable.sh $exec_dir/$basefile
  pathdir=$(dirname $fullfile)
  echo "fullfile is $fullfile"
  echo $pathdir
 
  EXEC_PATH="$pathdir:$PATH"
  sed -i "s|EXEC_PATH|$EXEC_PATH|g" $exec_dir/$basefile
  sed -i "s|BASEFILE|$basefile|g" $exec_dir/$basefile
done

chmod +x $exec_dir/*
rm $exec_dir/run_modularized_executable.sh
