# Download data ------------------------------------------
source ../DCENT_config.sh

# Set directories
export dir_list_file="../dir_list.txt"

export dir_log=$(grep "log" "$dir_list_file" | head -n 1)
export code_dir=$(pwd)

export GHCN_dir=$(grep "DCLAT" "$dir_list_file" | head -n 1)
mkdir -p ${GHCN_dir}
echo ${GHCN_dir}
cd ${GHCN_dir}

wget -O ghcnm.tavg.latest.qcu.tar.gz "https://www.ncei.noaa.gov/pub/data/ghcn/v4/ghcnm.tavg.latest.qcu.tar.gz"
wget -O ghcnm.tavg.latest.qcf.tar.gz "https://www.ncei.noaa.gov/pub/data/ghcn/v4/ghcnm.tavg.latest.qcf.tar.gz"

tar -xzvf ${GHCN_dir}/ghcnm.tavg.latest.qcu.tar.gz
tar -xzvf ${GHCN_dir}/ghcnm.tavg.latest.qcf.tar.gz

export date=$(tree ghcnm.v4.0.1.* | grep ghcnm.v4.0.1. | grep -oP "(?<=ghcnm\.v4\.0\.1\.)\d+")
mv  ghcnm.v4.0.1.${date}/*  ./
rmdir ghcnm.v4.0.1.${date}
rm ghcnm.tavg.latest.qcf.tar.gz
rm ghcnm.tavg.latest.qcu.tar.gz

mkdir GHCNmV4
mv *.dat GHCNmV4/
mv *.inv GHCNmV4/

cd ${code_dir}
sed -i "s/dir = '[0-9]\{8\}';/dir = '$date';/g" GHCN_IO.m
matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); do_QC = 0; GHCN_setup; GHCN_pre_01_ascii2mat; clear; do_QC = 1; GHCN_setup; GHCN_pre_01_ascii2mat; quit;" >> ${dir_log}/log_prepare_GHCNmV4_data

