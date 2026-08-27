This folder contains the files needed to run the UFS weather model with the GNU based spack-stack container.

Build process
--------------
The Dockerfile.rockylinux9-gnu13.3.1-wm is used to build the UFS WM container (rocky9-gcc13.3.1-ss192-wm.sif). 
Its corresponding Docker image can be found in the noaaepic docker hub (https://hub.docker.com/r/noaaepic/rocky9-gcc13.3.1-wm/tags) under the wm-srw192-dev tag.

Updating ufs-weather-model repo
--------------------------------
If a user finds the ufs-weather-model repo is out of date, then they need to do the following to sync it up with the GNU container.
  1. In the same directory as the GNU container, clone a fresh ufs-weather-model repo.
         git clone --recursive https://github.com/ufs-community/ufs-weather-model.git
  2. In this same directory, clone the ufs-containers repo to get the files related to the container.
         git clone -b feature/unified-1.9.2 https://github.com/NOAA-EPIC/ufs-containers.git
  3. Prep the ufs-weather-model for the container by running the following commands:
         mkdir -p ufs-weather-model/bin
         mkdir -p ufs-weather-model/container-scripts
         # if you didn't copy stage-rt.sh from the container
         cp ufs-containers/Docker/gnu/ufs-wm/stage-rt.sh .
         cp ufs-containers/Docker/gnu/ufs-wm/run_container_executable.sh ufs-weather-model/container-scripts
         cp ufs-containers/Docker/gnu/ufs-wm/build_container_executable.sh ufs-weather-model/container-scripts
         cp ufs-containers/Docker/gnu/ufs-wm/default_vars.sh ufs-weather-model/tests
         cp ufs-containers/Docker/gnu/ufs-wm/rt.sh ufs-weather-model/tests
         cp ufs-containers/Docker/gnu/ufs-wm/fv3_slurm.IN_singularity ufs-weather-model/tests/fv3_conf/
         cp ufs-containers/Docker/gnu/ufs-wm/compile_slurm.IN_singularity ufs-weather-model/tests/fv3_conf/
         # top-dir is the first directory in the containers full path
         singularity exec -B /<top-dir> rocky9-gcc13.3.1-ss192-wm.sif cp /opt/spack-stack/spack-stack-1.9.2/ufs-wm.env ufs-weather-model/container-scripts
  4. Now the new ufs-weather-model repo is all set to run with the container. Run the set up script.
         # where gnu/version and mpi/version are your systems gnu and mpi modules. 
         # example: gnu/version = gnu/13.2.0 & mpi/version = openmpi/4.1.6 
         ./stage-rt.sh -c=gnu/version -m=openmpi/version -i=/full/path/to/rocky9-gcc13.3.1-ss192-wm.sif

Running RTs with the GNU based spack-stack container
-----------------------------------------------------
Once the ufs-weather-model repo has been configured with the stage-rt.sh script, then the user can run RTs by doing the following:
  1. Update rocoto and DISKNM path under the singularity section (line 1011) of the rt.sh file.
  2. Update ufs-weather-model/tests/bl_date.conf, if need be.
  3. Run a single RT as you normally would without the container:
         cd ufs-weather-model/test
         # account_name is the name of the account to run jobs on your HPC
         ./rt.sh -a <account_name> -r -c -k -n "control_c48 gnu"

Miscellaneous
--------------
The rt.sh and default_vars.sh could have modifications between the version in this folder and the ufs-weather-model repo that could cause the RTs to fail.
To resolve this, users would need to use the rt.sh and default_vars.sh found in the new ufs-weather-model repo and add the singularity parts, which can be 
determined by running a diff between the file in this folder and in the new ufs-weather-model repo.
