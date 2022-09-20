#!/bin/bash
set +x

env_name=$1

docker build -f Dockerfile.ubuntu20.04-base-intel -t noaaepic/ubuntu20.04-base-intel:$env_name .
docker build -f Dockerfile.ubuntu20.04-spack -t noaaepic/ubuntu20.04-intel-spack:$env_name --build-arg env_name=$env_name .
#the last step of the build for ubuntu20.04-spack is to get the paths and LD_LIBRARY stuff written to a file
#copy out that file so that we can set those paths for anyone executing the container later
#start the container so we can copy the file
docker run -d --name spack-stack noaaepic/ubuntu20.04-intel-spack:$env_name

#copy out locenvs, which will be cat'ed onto the end of the Dockerfile for the ufs-srweather recipe
#We need to do this extra stuff because spack installs packages in unpredictable places (they are appended with a long hash)
#and we need to get that information out of the container after spack has finished installing everything
docker cp spack-stack:/opt/spack-stack/locenvs $PWD
cp Dockerfile.ubuntu20.04-intel-srwapp Dockerfile.tmp
cat locenvs >> Dockerfile.tmp
cat locenvs
#remove the temporary docker container so it can be re-created next time this script is run
docker rm  -f spack-stack
#Build the final container with the WM and environment variables (path, LD_LIBRARY_PATH, etc.) set for use with singularity
docker build -f Dockerfile.tmp -t noaaepic/ubuntu20.04-intel-srwapp:$env_name --build-arg env_name=$env_name .
rm Dockerfile.tmp
#Convert the finished docker container into a singularity container for use on HPC systems. 

