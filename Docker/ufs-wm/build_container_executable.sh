#!/bin/bash
#set -x
export img=IMAGE
export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
export SINGULARITYENV_APPEND_PATH=UFSPATH
cmd=$(basename "$0")
arg="$@"
echo running: singularity exec "${img}" $cmd $arg
PATH_TO_SINGULARITY exec -e -B /LOCDIR -B /DATADIR "${img}" $cmd $arg

