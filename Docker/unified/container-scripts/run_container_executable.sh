#!/bin/bash
#set -x
export img=IMAGE
export CONTAINERENV_FI_PROVIDER=tcp
export CONTAINERENV_FI_PROVIDER_PATH=FI_PATH
export SINGULARITY_SHELL=/bin/bash
export CONTAINERENV_PATH=EXEC_PATH
export CONTAINERENV_LD_LIBRARY_PATH=LDLIB_PATH
export CONTAINERENV_LIBRARY_PATH=LIB_PATH
export CONTAINERENV_ESMFMKFILE=ESMF_MK
#cmd=$(basename "$0")
cmd=BASEFILE
arg="$@"
echo running: singularity exec "${img}" $cmd $arg
singularity exec BINDDIRS "${img}" $cmd $arg

