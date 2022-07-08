git clone --recursive -b mji_uwm-ci https://github.com/MinsukJi-NOAA/emc-containers

cd emc-containers

docker build -f app/Dockerfile.hpc.ubuntu_20.04.gnu -t my_image .

docker login --username noaaemc

docker tag my_image noaaemc/ubuntu-hpc:v###

docker push noaaemc/ubuntu-hpc:v###

docker run --rm -it noaaemc/input-data:20220414 sh

cd /tmp/input-data-20220414

git clone https://github.com/MinsukJi-NOAA/fv3-input-data 

cp -r input-data-yyyymmdd fv3-input-data

cd fv3-input-data

docker build -t my_image .

docker tag my_image noaaemc/input-data:yyyymmdd

docker login --username noaaemc

docker push noaaemc/input-data:yyyymmdd
