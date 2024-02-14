#!/bin/bash
set -x

# make sure that a container image has been set
if [[ ${img} == '' ]]; then 
  echo "specify your container image by export img=path-to-image"
  exit 1
fi
# get full path to singularity executable
SINGULARITY=`/usr/bin/which singularity`
# determine if it is really singularity or actually apptainer
# copy out the modulefiles
${SINGULARITY} exec -B $PWD ${img} cp -r /opt/spack-stack/spack-stack-1.5.1/envs/ufs-wm-env/install/modulefiles container-modules

APPTAINER=`${SINGULARITY} --version | grep -c apptain`
if [[ ${APPTAINER} == 0 ]]; then
  echo "no apptainer"
  find ./container-modules/ -iname *.lua | xargs sed -i 's/_path("/_path("SINGULARITYENV_/g'
  find ./container-modules/ -iname *.lua | xargs sed -i 's/SINGULARITYENV_PATH/SINGULARITYENV_PREPEND_PATH/g'
  find ./container-modules/ -iname *.lua | xargs sed -i 's/setenv("/setenv("SINGULARITYENV_/g'
  find ./container-modules/ -iname *.lua | xargs sed -i "s|/opt/spack-stack/spack-stack-1.5.1/envs/ufs-wm-env/install/modulefiles|$PWD/container-modules|g"
  find ./container-modules/ -iname *.lua | xargs sed -i 's/SINGULARITYENV_MODULEPATH/MODULEPATH/g'
  sed -i "/MODULEPATH/a prepend_path(\"PATH\",\"$PWD\/sing-bin\")" container-modules/Core/stack-intel/*.lua 
  sed -i "/MODULEPATH/a setenv(\"img\",\"${img}\")" container-modules/Core/stack-intel/*.lua 
else
  find ./container-modules/ -iname *.lua | xargs sed -i 's/_path("/_path("APPTAINERENV_/g'
  find ./container-modules/ -iname *.lua | xargs sed -i 's/APPTAINERENV_PATH/APPTAINERENV_PREPEND_PATH/g'
  find ./container-modules/ -iname *.lua | xargs sed -i 's/setenv("/setenv("APPTAINERENV_/g'
  find ./container-modules/ -iname *.lua | xargs sed -i "s|/opt/spack-stack/spack-stack-1.5.1/envs/ufs-wm-env/install/modulefiles|$PWD/container-modules|g"
  find ./container-modules/ -iname *.lua | xargs sed -i 's/APPTAINERENV_MODULEPATH/MODULEPATH/g'
  sed -i "/MODULEPATH/a prepend_path(\"PATH\",\"$PWD\/sing-bin\")" container-modules/Core/stack-intel/*.lua 
  sed -i "/MODULEPATH/a setenv(\"img\",\"${img}\")" container-modules/Core/stack-intel/*.lua 
fi
tar xvfz sing-bin.tar.gz
sed -i "s|SINGBIN|${SINGULARITY}|g" sing-bin/*.sh
