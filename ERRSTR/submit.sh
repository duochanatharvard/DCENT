export reso=$1 
export ERRSTR_mem=22150
export N_job=15

source ../DCENT_config.sh
export dir_list_file="../dir_list.txt"
dir_log=$(grep "log" "$dir_list_file" | head -n 1)
echo $dir_log

# Step 01 count_numbers  ###########################################################################
export ERRSTR_S1=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J ERRSTR_S1
#SBATCH --nodes=1 
#SBATCH --array=1-${N_job}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${ERRSTR_mem}
#SBATCH -o ${dir_log}/err_ERRSTR_S1

matlab -nosplash -nodesktop -nodisplay -r "num=\${SLURM_ARRAY_TASK_ID}; addpath(genpath('..')); yr_list = (1849+num):${N_job}:2024; reso = ${reso}; ERRSTR_Step_01_count_numbers(yr_list,reso); quit;">>${dir_log}/log_ERRSTR_S1_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : ERRSTR_S1 : ${ERRSTR_S1} 

# Step 02 infer  ###########################################################################
export ERRSTR_S2=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J ERRSTR_S2
#SBATCH --nodes=1 
#SBATCH --array=1-${N_job}
#SBATCH --dependency=afterok:${ERRSTR_S1}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${ERRSTR_mem}
#SBATCH -o ${dir_log}/err_ERRSTR_S2

matlab -nosplash -nodesktop -nodisplay -r "num=\${SLURM_ARRAY_TASK_ID}; addpath(genpath('..')); yr_list = (1849+num):${N_job}:2024; reso = ${reso}; ERRSTR_Step_02_infer(yr_list,reso); quit;">>${dir_log}/log_ERRSTR_S2_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : ERRSTR_S2 : ${ERRSTR_S2} 

# Step 03 covariance matrix  ###########################################################################
export ERRSTR_S3=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J ERRSTR_S3
#SBATCH --nodes=1 
#SBATCH --array=1-${N_job}
#SBATCH --dependency=afterok:${ERRSTR_S2}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${ERRSTR_mem}
#SBATCH -o ${dir_log}/err_ERRSTR_S3

matlab -nosplash -nodesktop -nodisplay -r "num=\${SLURM_ARRAY_TASK_ID}; addpath(genpath('..')); yr_list = (1849+num):${N_job}:2024; reso = ${reso}; ERRSTR_Step_03_cov_matrix(yr_list,reso); quit;">>${dir_log}/log_ERRSTR_S3_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : ERRSTR_S3 : ${ERRSTR_S3} 

# Step 04 assemble covariance matrix  ###########################################################################
export ERRSTR_S4=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J ERRSTR_S4
#SBATCH --nodes=1 
#SBATCH --array=1-${N_job}
#SBATCH --dependency=afterok:${ERRSTR_S3}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${ERRSTR_mem}
#SBATCH -o ${dir_log}/err_ERRSTR_S4

matlab -nosplash -nodesktop -nodisplay -r "num=\${SLURM_ARRAY_TASK_ID}; addpath(genpath('..')); yr_list = (1849+num):${N_job}:2024; reso = ${reso}; ERRSTR_Step_04_assemble(yr_list,reso); quit;">>${dir_log}/log_ERRSTR_S4_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : ERRSTR_S4 : ${ERRSTR_S4} 
