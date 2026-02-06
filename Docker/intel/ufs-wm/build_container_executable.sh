#!/bin/bash
#set -x
export img=IMAGE
export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
#export SINGULARITYENV_APPEND_PATH=UFSPATH
cmd=$(basename "$0")
arg="$@"
echo running: PATH_TO_SINGULARITY exec --env-file SINGULARITY_WORKING_DIR/ufs-weather-model/container-scripts/ufswm.env -e -B /LOCDIR:/LOCDIR "${img}" $cmd $arg 
PATH_TO_SINGULARITY exec --env-file SINGULARITY_WORKING_DIR/ufs-weather-model/container-scripts/ufswm.env -e -B /LOCDIR:/LOCDIR "${img}" $cmd $arg

