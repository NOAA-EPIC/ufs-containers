git clone --recursive -b ufs-wm-ci https://github.com/NOAA-EPIC/ufs-containers

cd ufs-containers

docker build -f Docker/Dockerfile.ubuntu20.04-gnu9.3-hpc-stack.v1.2 -t  ubuntu20.04-gnu9.3-hpc-stack .

docker login --username noaaepic

docker tag ubuntu20.04-gnu9.3-hpc-stack noaaemc/ubuntu20.04-gnu9.3-hpc-stack:v1.2

docker push noaaepic/ubuntu20.04-gnu9.3-hpc-stack:v1.2

docker run --rm -it noaaemc/input-data:20220414 sh

cd /tmp/input-data-20220414

git clone https://github.com/MinsukJi-NOAA/fv3-input-data 

cp -r input-data-yyyymmdd fv3-input-data

cd fv3-input-data

docker build -t my_image .

docker tag my_image noaaemc/input-data:yyyymmdd

docker login --username noaaemc

docker push noaaemc/input-data:yyyymmdd
