#!/bin/bash
declare -a subfolders=("CICE_FIX/100" "CICE_IC/100" "CPL_FIX/aC96o100" "FV3_fix/fix_co2_proj" "FV3_fix_tiled/C96" "FV3_input_data/INPUT" "FV3_input_data/INPUT_L127" "FV3_input_data/INPUT_L127_mx100" "FV3_input_data/ORO_FLAKE" "FV3_input_data/RESTART" "FV3_input_data_gsd/FV3_input_data_C96_with_aerosols" "FV3_input_data_gsd/drag_suite" "FV3_input_data_INCCN_aeroclim/mg2_IN_CCN" "FV3_input_data_INCCN_aeroclim/MERRA2" "FV3_input_data_INCCN_aeroclim/aer_data" "FV3_input_data_INCCN_aeroclim/aer_data/LUTS" "FV3_input_frac/C96_L64.mx100_frac" "FV3_input_frac/C96_L127.mx100_frac" "MOM6_IC/100" "MOM6_IC/100/2011100100" "MOM6_FIX/100" "fv3_regional_control/INPUT" "fv3_regional_control/RESTART" "GOCART/p7/ExtData/dust" "GOCART/p7/ExtData/MERRA2/sfc" "GOCART/p7/ExtData/QFED/2013/04" "GOCART/p7/ExtData/QFED/2013/save03" "GOCART/p7/ExtData/CEDS/v2019/2013" "GOCART/p7/ExtData/monochromatic" "GOCART/p7/ExtData/optics" "GOCART/p7/ExtData/MEGAN_OFFLINE_BVOC/v2019-10/2013" "GOCART/p7/ExtData/PIESA/L127" "GOCART/p7/ExtData/PIESA/sfc/HTAP/v2.2" "GOCART/p7/ExtData/volcanic" "GOCART/p7/rc" "GOCART/p8/ExtData/dust" "GOCART/p8/ExtData/MERRA2/sfc" "GOCART/p8/ExtData/QFED/2021/03" "GOCART/p8/ExtData/QFED/2013/04" "GOCART/p8/ExtData/CEDS/v2019/2021" "GOCART/p8/ExtData/CEDS/v2019/2013" "GOCART/p8/ExtData/monochromatic" "GOCART/p8/ExtData/optics" "GOCART/p8/ExtData/MEGAN_OFFLINE_BVOC/v2019-10/2021" "GOCART/p8/ExtData/MEGAN_OFFLINE_BVOC/v2019-10/2013" "GOCART/p8/ExtData/PIESA/L127" "GOCART/p8/ExtData/PIESA/sfc/HTAP/v2.2" "GOCART/p8/ExtData/volcanic" "GOCART/p8/rc" "GOCART/ExtData/dust" "GOCART/ExtData/monochromatic" "GOCART/ExtData/optics" "GOCART/ExtData/PIESA/sfc/HTAP/v2.2" "GOCART/ExtData/PIESA/sfc/QFED/NRT/v2.5" "GOCART/ExtData/volcanic" "GOCART/rc")
PASSWORD=${PASSWORD:-'abc'}

#update line number 6, 13, and 15 with path where script will be running

cd /home/ubuntu/data-container
mkdir input-data-20220414
cd input-data-20220414
for i in "${subfolders[@]}"; do

    mkdir -p ${i}
    cd /home/ubuntu/data-container/input-data-20220414/${i}
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/${i}/ . --recursive
    cd /home/ubuntu/data-container/input-data-20220414/
done



## Build, Tag & Push Data Container To DockerHub 


##update line 24 with path to the directory with the directory where input-data-20220414 lies
cd /path/to/s3/test-script/
sudo git clone https://github.com/jkbk2004/fv3-input-data 
sudo cp -r input-data-20220414 fv3-input-data
sudo cd fv3-input-data
sudo docker login --username noaaepic --password=$PASSWORD
sudo docker build -t my_image .
sudo docker tag my_image noaaepic/input-data:20220414 
sudo docker push noaaepic/input-data:20220414