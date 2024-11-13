#!/bin/bash
#set -x
export img=IMAGE
export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
#export SINGULARITYENV_APPEND_PATH=UFSPATH
cmd=$(basename "$0")
arg="$@"
if [[ $cmd == "python" ]]; then
    echo "$2" > tmp_arg_file.py
    arg=tmp_arg_file.py
    #cat $arg
else
    arg="$@"
fi
echo running: PATH_TO_SINGULARITY exec --env-file SINGULARITY_WORKING_DIR/ufs-weather-model/container-scripts/ufswm.env -B /LOCDIR:/LOCDIR "${img}" $cmd $arg
PATH_TO_SINGULARITY exec --env-file SINGULARITY_WORKING_DIR/ufs-weather-model/container-scripts/ufswm.env -B /LOCDIR:/LOCDIR -B /DATADIR "${img}" $cmd $arg

