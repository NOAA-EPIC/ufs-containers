#!/bin/bash

python3 -c 'import jinja2' >& .test
resp=`cat .test`
rm .test
if [[ $resp == "" ]]
then 
  echo "yes"
else 
  tar xvfz $PWD/ufs-srweather-app/tarballs/MarkupSafe-2.1.2.tar.gz
  cd MarkupSafe-2.1.2
  python3 ./setup.py install --user 
  cd ..
  tar xvfz $PWD/ufs-srweather-app/tarballs/Jinja2-3.1.2.tar.gz 
  cd Jinja2-3.1.2
  python3 ./setup.py install --user 
  cd ..
fi

python3 -c 'import yaml' >& .test
resp=`cat .test`
rm .test
if [[ $resp == "" ]]
then 
  echo "yes"
else 
  tar xvfz $PWD/ufs-srweather-app/tarballs/PyYAML-6.0.tar.gz
  cd PyYAML-6.0
  python3 ./setup.py install --user 
  cd ..
fi

python3 -c 'import f90nml' >& .test
resp=`cat .test`
rm .test
if [[ $resp == "" ]]
then 
  echo "yes"
else 
  tar xvfz $PWD/ufs-srweather-app/tarballs/f90nml.tar.gz
  cd f90nml
  python3 ./setup.py install --user 
  cd ..
fi
