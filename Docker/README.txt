This is a series of Dockerfile recipes for building ubuntu20.04-based containers with intel compilers and MPI.
The Dockerfile.ubuntu20.04-base will build a base container with ubuntu20.04 and some extra tools that are 
needed by many UFS applications.
The Dockerfile.ubuntu20.04-spack will use the ubuntu20.04 base image to start and then install spack-stack.
Using spack-stack this recipe will then install intel oneapi compilers and MPI and use them to build
the ufs-srw-public-v2 template of the spack stack
The Dockerfile.ubuntu20.04-intel22-ufs-srwapp uses the ubuntu20.04-stack container as a base and then builds
the ufs-srweather-app on top of it. It contains a script that can be used to stage the SRW for use on 
Tier 1 platforms.

