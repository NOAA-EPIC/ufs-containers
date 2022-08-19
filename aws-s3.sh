#!/bin/bash

declare -a subfolders=("FV3_input_data_RRTMGP" "FV3_input_data_gsd" "FV3_input_frac" "FV3_regional_input_data" "GOCART" "MOM6_FIX" "MOM6_IC" "fv3_regional_control" )

PASSWORD=${PASSWORD:-'abc'}

cd /to/path/ 
mkdir input-data-20220414
cd input-data-20220414

for i in "${subfolders[@]}"; do
    
    mkdir ${i}
    cd ${i} 
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/${i}/ . --recursive
    cd ..

done
