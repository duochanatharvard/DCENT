# Set up download directories
source ../DCENT_config.sh
export dir_list_file="../dir_list.txt"
dir_download=$(grep "others" "$dir_list_file" | head -n 1)

export dir_local=${dir_download}"/ERSST5/"
rm ${dir_local}ERSST5_5x5_regridded.mat

export dir_local=${dir_download}"/CobeSST2/"
rm ${dir_local}COBESST_5x5_regridded.mat

export dir_local=${dir_download}"/Berkeley_Earth_Land/"
rm ${dir_local}Berkeley_5x5_regridded.mat

export dir_local=${dir_download}"/Berkeley_Earth_Global/"
rm ${dir_local}Berkeley_global_air_5x5_regridded.mat
rm ${dir_local}Berkeley_global_ocean_5x5_regridded.mat

export dir_local=${dir_download}"/GISTEMP/"
rm ${dir_local}GISTEMP_5x5_regridded.mat


# Call AOI Main ###########################################################################
export Process=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J Process_others
#SBATCH --nodes=1 
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_net_mem}
#SBATCH -o ${dir_log}/err_Process_others

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..'));  [ERSST5,lon,lat,yr] = CDC_load_ERSST5(0); [COBESST2,lon,lat,yr] = CDC_load_COBESST2(0); [Berkeley, lon, lat, yr] = CDC_load_Berkeley(0); [GISTEMP, lon, lat, yr] = CDC_load_GISTEMP(1); [GISTEMP, lon, lat, yr] = CDC_load_GISTEMP(2);  [Berkeley, lon, lat, yr] = CDC_load_Berkeley_global(1,1);  [Berkeley, lon, lat, yr] = CDC_load_Berkeley_global(0,1); quit;">>${dir_log}/log_process_others_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : AOI : ${Process} 


