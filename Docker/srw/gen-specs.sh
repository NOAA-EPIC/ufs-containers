#!/bin/bash
set +x

sed -i "s/v//g" ufs-srweather-app/modulefiles/srw_common
grep "load " ufs-srweather-app/modulefiles/srw_common | awk -F " " '{print $3}' | tr "/" "@" | tr "wrf_" "wrf-" | grep -v netcdf | grep -v pio | grep -v zlib | grep -v mapl > specs 
grep "load-" ufs-srweather-app/modulefiles/srw_common | awk -F " " '{print $3}' | tr "/" "@" | grep -v "pio" | grep -v "netcdf" | grep -v "^png" | grep -v esmf >> specs
grep "load-" ufs-srweather-app/modulefiles/srw_common | awk -F " " '{print $4}' | tr "/" "@" | grep -v "pio" | grep -v "netcdf" | grep -v "^png" | grep -v esmf >> specs
grep "load-any esmf"  ufs-srweather-app/modulefiles/srw_common | awk -F " " '{print $3"\n"$4}' | sort -n | tail -n 1 | tr "/" "@" >> specs
#grep "load-any mapl"  ufs-srweather-app/modulefiles/srw_common | awk -F " " '{print $3"\n"$4}' | sort -n | tail -n 1 | tr "/" "@" >> specs
grep "netcdf-c"  ufs-srweather-app/modulefiles/srw_common* | awk -F " " '{print $3"\n"$4}' | sort -d | tail -n 1 | tr "/" "@" >> specs
grep "netcdf-fortran"  ufs-srweather-app/modulefiles/srw_common* | awk -F " " '{print $3"\n"$4}' | sort -d | tail -n 1 | tr "/" "@" >> specs
grep "parallelio"  ufs-srweather-app/modulefiles/srw_common* | awk -F " " '{print $3"\n"$4}' | sort -dr | tail -n 1 | tr "/" "@" >> specs
grep "mapl" ufs-srweather-app/modulefiles/srw_common | awk -F " " '{print $3}' | tr "/" "@" | awk -F "-esmf" '{print $1}' >> specs
sed -i 's/^/  - /g' specs
sed -i 's/\[\]//g' envs/$1/spack.yaml 
cat specs >> envs/$1/spack.yaml
cat envs/$1/spack.yaml

