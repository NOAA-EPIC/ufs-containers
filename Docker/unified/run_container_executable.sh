#!/bin/bash

export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
img="$EPICCONTAINERS/ubuntu20.04-intel-spack-landda.img"
cmd=$(basename "$0")
arg="$@"
echo running: singularity exec "${img}" $cmd $arg
singularity exec "${img}" $cmd $arg

