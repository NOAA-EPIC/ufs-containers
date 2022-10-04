#!/bin/bash
set +x

#
branch_name=$1

#
git clone -b ${branch_name} https://github.com/clouden90/ufs-htf.git

#
cd ufs-htf
docker build -t clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test -f ./docker/recipe/Dockerfile.ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins .

#
docker run --user root --rm clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test /bin/bash -c "bash ./docker/recipe/run_toy.sh"

#remove 
docker image rm clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test
