#!/bin/bash
set +x

#
env_name=$1

#
git clone -b $1 https://github.com/clouden90/ufs-htf.git

#
cd ufs-htf
docker build -t clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test -f ./docker/recipe/Dockerfile.ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins .
