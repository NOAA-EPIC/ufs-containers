#!/bin/bash

set -x
export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
export SINGULARITYENV_APPEND_PATH=/opt/fv3-bundle/build/bin
CONTAINERLOC=${EPICCONTAINERS:-${HOME}}
img=${img:-'${CONTAINERLOC}/ubuntu20.04-intel-spack-landda.img'}
#img=${CONTAINERLOC}/ubuntu20.04-intel-spack-landda.img
cmd=$(basename "$0")
arg="$@"
echo running: singularity exec $img $cmd $arg
singularity exec $img $cmd $arg

