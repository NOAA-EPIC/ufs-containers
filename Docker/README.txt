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

To build the container series--



