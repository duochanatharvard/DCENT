# Set up download directories
source ../DCENT_config.sh
export dir_list_file="../dir_list.txt"
dir_download=$(grep "others" "$dir_list_file" | head -n 1)
dir_log=$(grep "log" "$dir_list_file" | head -n 1)

export dir_local=${dir_download}"/HadSST4/"
mkdir -p ${dir_local}/HadSST4_ensemble_perturbed/
rm -rf ${dir_local}/HadSST4_ensemble_perturbed/*

export dir_local=${dir_download}"/CRUTEM5/"
mkdir -p ${dir_local}/CRUTEM5_ensemble_perturbed/
rm -rf ${dir_local}/CRUTEM5_ensemble_perturbed/*
mkdir -p ${dir_local}/CRUTEM5_ensemble/
rm -rf ${dir_local}/CRUTEM5_ensemble/*

export dir_local=${dir_download}"/HadCRUT5/"
mkdir -p ${dir_local}/HadCRUT5_ensemble_perturbed/
rm -rf ${dir_local}/HadCRUT5_ensemble_perturbed/*

# Call AOI Main ###########################################################################
export Process=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J Process_HadCRUT5
#SBATCH --nodes=1 
#SBATCH --array=1-200
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_net_mem}
#SBATCH -o ${dir_log}/err_Process_HadCRUT5

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); ct=\${SLURM_ARRAY_TASK_ID}; Other_SST_setup; P.do_random = 1; rng(ct*100); [HadSST4,lon,lat,yr] = CDC_load_HadSST4(ct,P); P.do_analysis = 0; P.do_random = 1; rng(ct*100); [HadCRUT5,lon,lat,yr] = CDC_load_HadCRUT5(ct,P);  P.do_random = 0; [CRUTEM5,lon,lat,yr] = CDC_load_CRUTEM5(ct,P); P.do_random = 1; rng(ct*100); [CRUTEM5,lon,lat,yr] = CDC_load_CRUTEM5(ct,P); quit;">>${dir_log}/log_process_HadCRUT5_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : AOI : ${Process} 


