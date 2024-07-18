source ../DCENT_config.sh

# Redo the processing
export redo=0

# Set up the log file for output
dir_list_file="../dir_list.txt"
dir_log=$(grep "log" "$dir_list_file" | head -n 1)

# Submit N_yr of sub_jobs
export N_yr=$(( $(date +%Y) - 1849 ))

export JOB_process=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J ICOADS_preprocess
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH --array=1-${N_yr}
#SBATCH -t ${cluster_time}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/ICOADS_01_preprocess_err

matlab -nosplash -nodesktop -nodisplay -r "yr=\${SLURM_ARRAY_TASK_ID}+1849;  for mon = 1:12,  ICOADS_NC_Step_01_pre_QC(yr,mon,${redo}); ICOADS_NC_Step_02_WM(yr,mon,1,${redo});  ICOADS_NC_Step_02_WM(yr,mon,2,${redo});  end; quit;">>${dir_log}/ICOADS_01_preprocess_log_\$SLURM_ARRAY_TASK_ID

EOF
)

echo submitted ICOADS preprocess job :: $JOB_process
