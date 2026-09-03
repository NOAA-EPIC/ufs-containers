#!/bin/bash 
set -euo pipefail

echo "Build a full intel HPC kit as a container sandbox from Docker intel/hpckit:2024.2.1-0-devel-rockylinux9"
singularity build --sandbox --fix-perms intel-sandbox docker://intel/hpckit:2024.2.1-0-devel-rockylinux9 \
	2> >(grep -v 'ignoring (usually) harmless EPERM on setxattr ' >&2)
echo "Done building an intel-sandbox"
