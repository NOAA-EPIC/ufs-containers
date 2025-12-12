This folder contains the files needed to build the GNU based spack-stack container.

Build process
--------------
The Dockerfile.rockylinux9-gnu13.3.1-wm-srw is used to build the GNU based spack-stack container (rocky9-ss192-gcc13.sif). 
Its corresponding Docker image can be found in the noaaepic docker hub (https://hub.docker.com/r/noaaepic/rocky9-gcc13.3.1-wm/tags) under the v1.9.2-srw tag.

Loading the spack-stack env
----------------------------
 1. Users need to shell into the container.
        # top-dir is the first directory in the containers full path
        singularity shell -B /<top-dir> rocky9-ss192-gcc13.sif
 2. The ufs-wm and srw spack-stack envs can be loaded by doing the following:
        source /opt/spack-stack/spack-stack-1.9.2/.bashenv
Notes
------
 - The spack-stack contains the ufs-weather-model-env spack-stack env plus the packages needed to build the SRW App.
 - There are two environmental files (ufs-wm.env and srw.env) that correspond to the envs that is needed 
   to build and/or run the executables in the container. These files are found under the /opt/spack-stack/spack-stack-1.9.2 directory.
