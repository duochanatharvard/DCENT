export case_name=$1     # "debug"
export PHA_version=$2   # "white" / "auto" / "GAPL"

export N_rnd=$3         # How many members to run : 0 ~ N_rnd-1
export N_sub=$4         # How many subsets to run pair-wise BP detection

source ../DCENT_config.sh
export dir_list_file="../dir_list.txt"
dir_log=$(grep "log" "$dir_list_file" | head -n 1)

###########################################################################
# 1. Get network of station pairs (#JOB = # of parameter combinations)
###########################################################################
export job_net=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J get_network_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --array=1-${N_rnd}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_net_mem}
#SBATCH -o ${dir_log}/${case_name}_err_get_network_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; mem_id = \${SLURM_ARRAY_TASK_ID}-1; Run_SATH_multiple_CPUs_S1_net; quit;">>${dir_log}/${case_name}_log_get_network_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : Get Network : ${job_net}

###########################################################################
# 2. Get initial BP from the union of networks
###########################################################################
export job_IBP=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J get_IBP_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${job_net}
#SBATCH --array=1-${N_sub}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_ibp_mem}
#SBATCH -o ${dir_log}/${case_name}_err_pair_wise_BP_detection_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; N_rnd = ${N_rnd}; N_sub = ${N_sub}; sub_id = \${SLURM_ARRAY_TASK_ID}; Run_SATH_multiple_CPUs_S2_IBP; quit;">>${dir_log}/${case_name}_log_pair_wise_BP_detection_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : Get initial BPs : ${job_IBP}

###########################################################################
# 3. Calculate later steps (Attribution)
###########################################################################
export job_A=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J A_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${job_IBP}
#SBATCH --array=1-${N_rnd}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_att_mem}
#SBATCH -o ${dir_log}/${case_name}_err_A_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; N_sub = ${N_sub}; mem_id = \${SLURM_ARRAY_TASK_ID}-1; Run_SATH_multiple_CPUs_S3_A; quit;">>${dir_log}/${case_name}_log_A_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : Attribution : ${job_A}

###########################################################################
# 4. Calculate later steps (Combination)
###########################################################################
export job_C=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J C_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${job_A}
#SBATCH --array=1-${N_rnd}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_comb_mem}
#SBATCH -o ${dir_log}/${case_name}_err_C_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; N_sub = ${N_sub}; mem_id = \${SLURM_ARRAY_TASK_ID}-1; Run_SATH_multiple_CPUs_S4_C; quit;">>${dir_log}/${case_name}_log_C_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : Combination : ${job_C}

###########################################################################
# 5. Calculate later steps (Estimation)
###########################################################################
export job_Est=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J Est_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${job_C}
#SBATCH --array=1-${N_rnd}
#SBATCH -t ${cluster_time}
#SBATCH --exclusive
#SBATCH -o ${dir_log}/${case_name}_err_E_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; N_sub = ${N_sub}; mem_id = \${SLURM_ARRAY_TASK_ID}-1; Run_SATH_multiple_CPUs_S5_E; quit;">>${dir_log}/${case_name}_log_E_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : Estimation : ${job_Est}

###########################################################################
# 6. Calculate the second round of PHA for early stations -> NIBP
###########################################################################
if [ ${PHA_version} = "GAPL" ]; then
  export CPU_per_job=15
else
  export CPU_per_job=1
fi
export N_sub_jobs=$(expr ${N_rnd} \* ${CPU_per_job})
export job_R2_NIBP=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J R2_NIBP_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${job_Est}
#SBATCH --array=1-${N_sub_jobs}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_2nd_mem}
#SBATCH -o ${dir_log}/${case_name}_err_R2_NIBP_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}';  N_sub = ${CPU_per_job};  [sub_id, mem_id]= ind2sub([${CPU_per_job},${N_rnd}],\${SLURM_ARRAY_TASK_ID}); mem_id = mem_id - 1; Run_SATH_multiple_CPUs_S6_R2_NIBP; quit;">>${dir_log}/${case_name}_log_R2_NIBP_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : R2_NIBP : ${job_R2_NIBP}

###########################################################################
# 7. Calculate the second round of PHA for early stations -> ACE
###########################################################################
export job_R2_ACE=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J R2_ACE_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${job_R2_NIBP}
#SBATCH --array=1-${N_rnd}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_2nd_mem}
#SBATCH -o ${dir_log}/${case_name}_err_R2_ACE_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; mem_id = \${SLURM_ARRAY_TASK_ID}-1; Run_SATH_multiple_CPUs_S7_R2_ACE; quit;">>${dir_log}/${case_name}_log_R2_ACE_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : R2_ACE : ${job_R2_ACE}


###########################################################################
# 8. Calculate post pair-wise homogenization GAPL
###########################################################################
export job_R3=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J Post_GAPL_${case_name}_${PHA_version}
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${job_R2_ACE}
#SBATCH --array=1-${N_rnd}
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_2nd_mem}
#SBATCH -o ${dir_log}/${case_name}_err_Post_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; mem_id = \${SLURM_ARRAY_TASK_ID} - 1;  Run_SATH_multiple_CPUs_S8_P; quit;">>${dir_log}/${case_name}_log_Post_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : POST_GAPL : ${job_R3}
