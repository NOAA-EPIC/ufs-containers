# UFS App Containerization: Docker and Singularity

This repository provides the collections of Docker and Singularity build recipes that can be applied for the ufs srw and mrw applicationshpc-stack and ufs-srw Docker container images are built in the git workflow and pushed to the Docker HubAvailable Docker containers include:

* docker://noaaepic/ubuntu20.04-gnu9.3

* docker://noaaepic/ubuntu20.04-gnu9.3-hpc-stack

* docker://noaaepic/ubuntu20.04-gnu9.3-ufs-srwapp

* docker://noaaepic/ubuntu20.04-gnu9.3-ufs-mrwapp

The Dockerfile recipes and associated files in Docker/srw are designed to build the SRW application in three steps. The application is 
build upon the Intel OneAPI compilers and MPI implementations and then a spack-stack environment based on the specifications required
for the UFS-SRW. The script "build-srw-containers.sh" will build and push all three Docker images to docker hub and is designed to 
be run as root or the docker user. The script takes one argument, which is the name of the branch of the SRW to build. The final docker 
image contains a template and a script called "stage-srw.sh" which is located in /opt/ufs-srweather-app/container-scripts. That script
can be run on any supported Tier-1 platform to "unpack" the container and create a copy of the ufs-srweather-app on the host file
system that can be run/tested with Rocoto.

Docker directory tree:

```
├── Docker/
│   ├── Dockerfile.ubuntu20.04-gnu9.3
│   ├── Dockerfile.ubuntu20.04-hpc-intel
│   ├── README.txt
│   ├── srw/
│       ├── build-srw-containers.sh
│       ├── Dockerfile.ubuntu20.04-base-intel
│       ├── Dockerfile.ubuntu20.04-intel-spack
│       ├── Dockerfile.ubuntu20.04-intel-srwapp
│       ├── gen-specs.sh
│       ├── modules.yaml
│       ├── srw.sh-template
│       ├── srw.specs
│       ├── stage-srw-develop.sh
│       ├── third-party-programs.txt
│       └── ubuntu-intel.tar.gz
├── Jenkinsfile
├── README.md
└── utils
    ├── ChangeLog
    ├── rt-cheyenne_gnu.sh
    ├── rt-cheyenne_intel.sh
    └── rt-orion_intel.sh

```
