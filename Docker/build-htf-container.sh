#!/bin/bash
set +x

#
branch_name=$1

#
git clone -b ${branch_name} https://github.com/clouden90/ufs-htf.git

#
cd ufs-htf
docker build --quiet -t clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test -f ./docker/recipe/Dockerfile.ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins .

#
echo "HTF hpc-stack build Start!"
docker run --user root --rm clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test /bin/bash -c "bash ./docker/recipe/run_toy.sh"
echo "HTF hpc-stack build Done!"

#remove images
docker image rmi clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test &> /dev/null
docker image rmi noaaepic/ubuntu20.04-gnu9.3-hpc-stack:v1.2b &> /dev/null
