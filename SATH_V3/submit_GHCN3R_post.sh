export case_name=$1
export PHA_version=$2
export N_rnd=$3         # How many members to run : 0 ~ N_rnd-1

# Set directories
source ../DCENT_config.sh
export dir_list_file="../dir_list.txt"
dir_log=$(grep "log" "$dir_list_file" | head -n 1)

###########################################################################
# Part 1 :: Calculate General Statistics
###########################################################################
# # export job_P1=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
# #!/bin/sh
# #SBATCH --account=${my_lab}
# #SBATCH -p ${partition}
# #SBATCH -J P1_${case_name}_${PHA_version}
# #SBATCH --nodes=1  
# #SBATCH --array=1-${N_rnd}
# #SBATCH -t 10080
# #SBATCH --mem-per-cpu=20000
# #SBATCH -o logs/${case_name}_err_P1_${PHA_version}

# matlab -nosplash -nodesktop -nodisplay -r "case_name = '${case_name}'; PHA_version = '${PHA_version}'; mem_id = \${SLURM_ARRAY_TASK_ID}-1; SATH_GHCN3R_post_01_stats; quit;">>${dir_log}/${case_name}_log_P1_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
# EOF
# )
# echo Submitted Job ID : P1 : ${job_P1}

###########################################################################
# Part 2 :: Gridding data 
###########################################################################
export job_P2=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J P2_${case_name}_${PHA_version}
#SBATCH -n 1 
#SBATCH --array=1-${N_rnd}
#SBATCH -t ${cluster_time}
#SBATCH --mem=50000
#SBATCH -o ${dir_log}/${case_name}_err_P2_${PHA_version}

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); case_name = '${case_name}'; PHA_version = '${PHA_version}'; mem_id = \${SLURM_ARRAY_TASK_ID}-1; SATH_GHCN3R_post_02_grid; quit;">>${dir_log}/${case_name}_log_P2_${PHA_version}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : P2 : ${job_P2}

echo ${dir_log}
