#!/bin/bash
#set -x
export img=IMAGE
export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
cmd=$(basename "$0")
if [[ $cmd == "python3" ]]; then
    echo "$2" > tmp_arg_file.py
    arg=tmp_arg_file.py
    #cat $arg
else
    arg="$@"
fi
echo running: PATH_TO_SINGULARITY exec --env-file SINGULARITY_WORKING_DIR/ufs-weather-model/container-scripts/ufs-wm.env -e -B /LOCDIR:/LOCDIR "${img}" $cmd $arg 
PATH_TO_SINGULARITY exec --env-file SINGULARITY_WORKING_DIR/ufs-weather-model/container-scripts/ufs-wm.env -e -B /LOCDIR:/LOCDIR "${img}" $cmd $arg
