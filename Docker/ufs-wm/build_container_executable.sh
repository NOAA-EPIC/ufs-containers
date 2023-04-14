#!/bin/bash
#set -x
export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
export SINGULARITYENV_APPEND_PATH=$PWD/tests
cmd=$(basename "$0")
arg="$@"
echo running: singularity exec "${img}" $cmd $arg
SINGULARITY exec -e -B /LOCDIR -B /DATADIR "${img}" $cmd $arg

