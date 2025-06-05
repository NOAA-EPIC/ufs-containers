#!/bin/bash
#set -x
export img=IMAGE
export CONTAINERENV_FI_PROVIDER=tcp
export CONTAINERENV_FI_PROVIDER_PATH=FI_PATH
export SINGULARITY_SHELL=/bin/bash
cmd=BASEFILE
arg="$@"
echo running: singularity exec "${img}" $cmd $arg
singularity exec BINDDIRS "${img}" $cmd $arg

