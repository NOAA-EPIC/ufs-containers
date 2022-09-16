This is a series of Dockerfile recipes for building ubuntu20.04-based containers with intel compilers and MPI.
The Dockerfile.ubuntu20.04-base-intel will build a base container with ubuntu20.04 and some extra tools that are 
needed by many UFS applications. It then installs spack-stack and build/installs the intel oneapi compilers
and MPI implementation.

The Dockerfile.ubuntu20.04-intel-spack-ufswm will use the ubuntu20.04 base image to start and then install 
the environment required to build the UFS WM head of develop (as of 9/15/22). The final step of this recipe
loads all the modules in the container and then dumps them into a file called "locenvs" which the build 
script copies out to use in building the final container. 

The Dockerfile.ubuntu20.04-intel-ufswm uses the ubuntu20.04-intel-spack-ufswm container as a base and then builds
the ufs-weather-model on top of it. As the final step of the build script, the environment variables listed
in locenvs are set as the environment of the docker container. These environment variables are then carried
on into singularity containers build from the docker image and ensure that all the modules and the ufs_model
itself are in the default paths/ld_library_path when shelling into or executing the singularity container. 

To build the docker container series locally--

sudo ./build-ufswm-containers.sh BRANCH-NAME

This command will build the base container, the spack container with all required libraries and then
finally the final container with the ufs-weather-model built inside and paths set for execution.

To create a singularity container from the locally build docker container for use on HPC systems, use

singularity build ubuntu20.04-intel-ufswm-BRANCH-NAME.img  docker-daemon://noaaepic/ubuntu20.04-intel-ufswm:BRANCH-NAME

Alternatively, use the container that EPIC has pushed to docker hub

singularity build ubuntu20.04-intel-ufswm-develop.img  docker://noaaepic/ubuntu20.04-intel-ufswm:develop

Running the weather model

The magic trick that makes this all work is contained in the executable.sh-template script that is part of this
repository. It looks like this--

#!/bin/bash
set -x
export SINGULARITYENV_FI_PROVIDER=tcp
export SINGULARITY_SHELL=/bin/bash
dir="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
img="IMAGE"
cmd=$(basename "$0")
arg="$@"
echo running: singularity exec "${dir}/${img}" $cmd $arg
PATH_TO_SINGULARITY exec -B /BINDDIR:/BINDDIR -B /LOCDIR:/LOCDIR "${dir}/${img}" $cmd $arg

This template should be copied to a file called executable.sh (pick any name you like) and the following
placeholders should be replaced with specifics of your container and system--

IMAGE=name of singularity container that exists in the same directory as the executable.sh file
PATH_TO_SINGULARITY=The full path to the singularity installation on your platform 
BINDIR=the root directory of your experiment (e.g. scratch1, lustre, lfs4, etc)
LOCDIR=any other directory you want bound and available to read/write from within the container

Quite a few directories have been created within the container already, but if there is none that match
your system, you will have to expand the container to a writable sandbox and add the desired mount 
point. 

When the specifics have been added to the executable.sh script, the last step is to create a soft link
from it to your experiment directory called "ufs_model". 

In your experiment directory, run this command--

ln -s path-to-/executable.sh ./ufs_model 

The magic here is that the exectuble.sh script knows what the link is called and uses that name as 
the executable to run inside the container. As long as that name is in the container path, it will
run the executable seamlessly. So, you can also create a soft link to executable.sh called "which" 
and when you run ./which ufs_model, it will report where it found ufs_model inside the container. 

Once the soft link of ufs_model is made, it can be run directly with 

mpiexec -n MPI_TASKS ./ufs_model


