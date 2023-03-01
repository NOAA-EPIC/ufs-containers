#!/bin/bash
set -x

tag_name=$1

echo "tag is " $tag_name
docker build -f Dockerfile.ubuntu20.04-base-intel -t noaaepic/ubuntu20.04-base-intel:intel-2021.8.0-amd .
docker push noaaepic/ubuntu20.04-base-intel:intel-2021.8.0-amd 

#copy out locenvs, which will be cat'ed onto the end of the Dockerfile for the final recipe
#We need to do this extra stuff because spack installs packages in unpredictable places (they are appended with a long hash)
#and we need to get that information out of the container after spack has finished installing everything
cp Dockerfile.ubuntu20.04-intel-spack-landda Dockerfile.ubuntu20.04-intel-stage2
sed -i "s/TAGNAME/$tag_name/g" Dockerfile.ubuntu20.04-intel-stage2
docker build -f Dockerfile.ubuntu20.04-intel-stage2 -t noaaepic/ubuntu20.04-intel-spack-landda:$tag_name . 
docker push noaaepic/ubuntu20.04-intel-spack-landda:$tag_name 
#rm Dockerfile.ubuntu20.04-intel-stage2

#the last step of the build for ubuntu20.04-spack is to get the paths and LD_LIBRARY stuff written to a file
#copy out that file so that we can set those paths for anyone executing the container later
#start the container so we can copy the file
docker run -d --name landda-tmp noaaepic/ubuntu20.04-intel-spack-landda:$tag_name 

#copy out locenvs, which will be cat'ed onto the end of the Dockerfile for the final recipe
#We need to do this extra stuff because spack installs packages in unpredictable places (they are appended with a long hash)
#and we need to get that information out of the container after spack has finished installing everything
docker cp landda-tmp:/opt/spack-stack/locenvs $PWD
docker rm  -f landda-tmp
cp Dockerfile.ubuntu20.04-intel-landda Dockerfile.ubuntu20.04-intel-stage3
cat locenvs >> Dockerfile.ubuntu20.04-intel-stage3
cat locenvs
sed -i "s/TAGNAME/$tag_name/g" Dockerfile.ubuntu20.04-intel-stage3
#remove the temporary docker container so it can be re-created next time this script is run
docker rm  -f landda-tmp
#Build the final container with the WM and environment variables (path, LD_LIBRARY_PATH, etc.) set for use with singularity
echo tagname is $tag_name
wget https://epic-sandbox-srw.s3.amazonaws.com/landda-test-comps.tar.gz 
wget https://epic-sandbox-srw.s3.amazonaws.com/landda-test-inps.tar.gz 
docker build --no-cache -f Dockerfile.ubuntu20.04-intel-stage3 -t noaaepic/ubuntu20.04-intel-landda:$tag_name  .
docker push noaaepic/ubuntu20.04-intel-landda:$tag_name 
rm Dockerfile*stage*
##Convert the finished docker container into a singularity container for use on HPC systems. 
#
